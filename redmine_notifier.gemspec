# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'redmine_notifier/version'

Gem::Specification.new do |spec|
  spec.name          = "redmine_notifier"
  spec.version       = RedmineNotifier::VERSION
  spec.authors       = ["Peer Allan"]
  spec.email         = ["peer.allan@canadadrugs.com"]
  spec.summary       = %q{Command line tool to show Redmine updates in OS X notification center}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'feedzirra'
  spec.add_dependency 'terminal-notifier'

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
