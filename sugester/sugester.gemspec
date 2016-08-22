# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sugester'

Gem::Specification.new do |spec|
  spec.name          = "sugester"
  spec.version       = Sugester::VERSION
  spec.authors       = ["marcin", "mateuszkitlas"]
  spec.email         = ["dev@sugester.com"]

  spec.summary       = %q{Sugester API}
  spec.description   = %q{Sugester API}
  spec.homepage      = 'http://rubygems.org/gems/sugester'
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = %w{
    Gemfile
    Gemfile.lock
    LICENSE.txt
    Rakefile
    bin/console
    bin/setup
    lib/sugester.rb
  }
  spec.bindir        = "exe"
  spec.executables   = []
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "minitest", "~> 5.1"
  spec.add_dependency "aws-sdk", '~> 2'
  spec.add_dependency 'activesupport'
end
