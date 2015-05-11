require 'pixiv'
require 'mechanize'
require 'webmock/rspec'
require 'rspec/its'

# Disable "should" syntax.
RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def fixture_path
  File.expand_path('../fixtures', __FILE__)
end

def fixture(filename)
  open(File.join(fixture_path, filename))
end

def fixture_as_doc(filename)
  Nokogiri::HTML::Document.parse(fixture(filename))
end
