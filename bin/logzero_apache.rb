#!/usr/bin/env ruby

require 'zmq'

CONF = YAML.load_file( 'logzero.yml' )

z_ip = CONF['receiver']['ip'].to_s
z_port = CONF['receiver']['port'].to_i
z_hwm = CONF['receiver']['hwm'].to_i

z = ZMQ::Context.new
s = z.socket(ZMQ::PUSH)
s.setsockopt(ZMQ::HWM, "#{z_hwm}")

s.connect("tcp://#{z_ip}:#{z_port}")

while(log = STDIN.gets)
    s.send(log)
end
