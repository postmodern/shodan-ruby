require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:development, :doc)
rescue Bundler::BundlerError => e
  STDERR.puts e.message
  STDERR.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rake'
require 'jeweler'
require './lib/shodan/version.rb'

Jeweler::Tasks.new do |gem|
  gem.name = 'shodan'
  gem.version = Shodan::VERSION
  gem.license = 'MIT'
  gem.summary = %Q{A Ruby interface to SHODAN, a computer search engine.}
  gem.description = %Q{A Ruby interface to SHODAN, a computer search engine.}
  gem.email = 'postmodern.mod3@gmail.com'
  gem.homepage = 'http://github.com/postmodern/shodan-ruby'
  gem.authors = ['Postmodern']
  gem.add_dependency 'mechanize', '>= 1.0.0'
  gem.add_development_dependency 'rspec', '>= 1.3.0'
  gem.add_development_dependency 'yard', '>= 0.5.3'
  gem.has_rdoc = 'yard'
end
Jeweler::GemcutterTasks.new

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new
task :default => :spec

require 'yard'
YARD::Rake::YardocTask.new
