#!/usr/bin/env ruby

require 'zmq'
require 'redis'
require 'ohm'
require 'ohm/contrib'
require "./lib/apache.rb"

CONF = YAML.load_file( 'logzero.yml' )

z_ip = CONF['receiver']['ip']
z_port = CONF['receiver']['port']

z = ZMQ::Context.new
s = z.socket(ZMQ::PULL)
s.bind("tcp://#{z_ip}:#{z_port}")

Ohm.connect(:host => CONF['redis']['ip'], \
            :port => CONF['redis']['port'], \
            :db => CONF['redis']['db']) 

class Request < Ohm::Model
    include Ohm::Typecast

    attribute :time, Time
    attribute :host 
    attribute :port, Integer
    attribute :type
    attribute :protocol
    attribute :url
    attribute :size, Integer
    attribute :state, Integer
    attribute :referrer
    attribute :unique
    attribute :ip
    attribute :agent

    index :ip
    index :host
    index :url
    index :state
    index :referrer
    index :unique
    index :ip
    index :agent
end

while true
    log = s.recv(0)
    parser = Apache::Parser.new log

    Request.create(:time => parser.time, :host => parser.host, :port => parser.port, \
                   :type => parser.request_type, :protocol => parser.request_protocol, \
                   :url => parser.url, :size => parser.size, :state => parser.state, \
                   :referrer => parser.referrer, :unique => parser.unique, :ip => parser.ip, \
                   :agent => parser.user_agent)
end