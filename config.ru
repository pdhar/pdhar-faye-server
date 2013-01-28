require 'rubygems'
require 'bundler'
Bundler.require
require 'faye'
require 'json'

require File.expand_path('../config/initializers/faye_token.rb', __FILE__)

class ServerAuth
  def incoming(message, callback)
    parsed_message = JSON.parse(message)
    if parsed_message['channel'] !~ %r{^/meta/}
      if parsed_message['ext']['auth_token'] != FAYE_TOKEN
        parsed_message['error'] = 'Invalid authentication token'
      end
    end
    #Rails.logger.debug(" message['channel'] #{message['channel']} message['ext']['auth_token'] #{message['ext']['auth_token']}")
    callback.call(message)
  end
end

faye_server = Faye::RackAdapter.new(:mount => '/faye', :timeout => 45)
faye_server.add_extension(ServerAuth.new)
run faye_server
