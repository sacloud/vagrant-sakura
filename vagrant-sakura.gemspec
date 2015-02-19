# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant-sakura/version'

Gem::Specification.new do |spec|
  spec.name          = "vagrant-sakura"
  spec.version       = VagrantPlugins::Sakura::VERSION
  spec.authors       = ["Tomoyuki Sahara"]
  spec.email         = ["sahara@caddr.net"]
  spec.description   = %q{Enables Vagrant to manage machines in Sakura Cloud.}
  spec.summary       = %q{Enables Vagrant to manage machines in Sakura Cloud.}
  spec.homepage      = "https://github.com/tsahara/vagrant-sakura"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
end
