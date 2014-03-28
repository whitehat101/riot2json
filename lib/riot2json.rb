require "rubygems"
require "net/http"
require "json"
require "eventmachine"
require "rocketamf"
require_relative "riot2json/rocketamf_serializer_patch"
require "em-rtmp"
require "sinatra"
require "sinatra/async"
require "redis"
require "thin"
require "base64"

#Gem sources.
require_relative "riot2json/auth"
require_relative "riot2json/client"
require_relative "riot2json/config"
require_relative "riot2json/connectionrequest"
require_relative "riot2json/http"


module Riot2JSON
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
  user, pass, region, port, version, isDaemon = ARGV
  LolClient.new.start user, pass, region, port, version, isDaemon
end
