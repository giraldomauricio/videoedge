$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'videoedge'
require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)
