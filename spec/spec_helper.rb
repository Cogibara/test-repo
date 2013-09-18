DAEMON_ENV = 'test' unless defined?( DAEMON_ENV )

begin
  require 'rspec'
rescue LoadError
  require 'rubygems'
  require 'rspec'
end

require 'vcr'

require File.dirname(__FILE__) + '/../config/environment'
DaemonKit::Application.running!

RSpec.configure do |config|
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
    config.treat_symbols_as_metadata_keys_with_true_values = true
end


# require 'simplecov'

VCR.configure do |c|
  c.cassette_library_dir = "spec/vcr/cassettes"
  c.hook_into :webmock
  # c.filter_sensitive_data('APIKEY') { FFNerd.api_key }
end

def test_values(object, expected_values)
  expected_values.each do |attribute, value|
    object[attribute].should == value
  end
end


# def with_stub_feeds
#   player = test_player
#   player.projection = Hashie::Mash.new
#   player.projection.standard = 26
#   FFNerd.stub(:projections).and_return([player])

#   player = test_player
#   player.injury = Hashie::Mash.new
#   player.injury.injury_desc = "Sprained Ankle"
#   FFNerd.stub(:injuries).and_return([player])
#   yield
# end

# def test_player
#   player = Hashie::Mash.new
#   player.id = 12
#   player.position = 'RB'
#   player.team = 'SEA'
#   player
# end