# Update this Gemfile with any additional dependencies and run
# 'bundle install' to get them all installed. Daemon-kit's capistrano
# deployment will ensure that the bundle required by your daemon is properly
# installed.
#
# For more information on bundler, please visit http://gembundler.com

source 'https://rubygems.org'

# Live on the edge instead: gem 'daemon-kit', :github => 'kennethkalmer/daemon-kit'
gem 'daemon-kit'

#
# safely (http://github.com/kennethkalmer/safely)
#

gem 'safely' # Optional, but recommended.

# gem 'toadhopper' # For reporting exceptions to hoptoad
# gem 'mail' # For reporting exceptions via mail

gem 'blather', '~> 0.8.7'
group :development, :test do
  gem 'rake'
  gem 'rspec'
end

group :test do
  gem 'vcr'
  gem 'webmock', '~> 1.11.0'
end
# gem 'vines', git: 'https://github.com/negativecode/vines.git'
# gem 'cogibara', git: 'https://github.com/wstrinz/cogibara.git'

gem 'rdf'
gem 'rdf-turtle'
gem 'spira'

## COGIBARA GEMS
gem 'cleverbot'