#!/usr/bin/env ruby

require 'webrick'

root = File.expand_path File.dirname(__FILE__) + '/../public_html'
server = WEBrick::HTTPServer.new :Port => 7777, :DocumentRoot => root

trap 'INT' do
    server.shutdown
end
server.start
