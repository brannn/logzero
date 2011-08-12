#!/usr/bin/env ruby

require 'zmq'
require 'mongo'
require 'bson'
require "../lib/apache.rb"
 
CONF = YAML.load_file( 'logzero.yml' )
 
mdb_server = CONF['mongodb']['ip'].to_s
mdb_port = CONF['mongodb']['port'].to_i
mdb_db = CONF['mongodb']['db'].to_s
mdb_coll = CONF['mongodb']['coll'].to_s

z_ip = CONF['receiver']['ip'].to_s
z_port = CONF['receiver']['port'].to_i 

db = Mongo::Connection.new("#{mdb_server}", "#{mdb_port}").db("#{mdb_db}")
coll = db.collection("#{mdb_coll}")

z = ZMQ::Context.new
s = z.socket(ZMQ::PULL)
s.bind("tcp://#{z_ip}:#{z_port}")
 
while true
    log = s.recv(0)
    parser = Apache::Parser.new log
    doc = {
        'time' => parser.time,
        'host' => parser.host,
        'port' => parser.port,
        'request' => {
            'type' => parser.request_type,
            'protocol' => parser.request_protocol,
            'url' => parser.url,
            'size' => parser.size,
            'state' => parser.state
        },
        'referrer' => {
            'full_url' => parser.referrer 
        },
        'unique' => parser.unique,
        'ip' => parser.ip,
        'agent' => parser.user_agent
    }
    coll.insert(doc)
end
