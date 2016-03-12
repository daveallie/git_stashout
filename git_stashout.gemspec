# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$:.unshift lib unless $:.include?(lib)
require 'git_stashout/version'

Gem::Specification.new do |spec|
  spec.name          = "git_stashout"
  spec.version       = GitStashout::VERSION
  spec.authors       = ["Dave Allie"]
  spec.email         = ["dave@daveallie.com"]

  spec.summary       = %q{Git tool that stashes, checks-out, then unstashes.}
  spec.description   = %q{Git tool that stashes, checks-out, then unstashes.}
  spec.homepage      = "https://github.com/daveallie/git_stashout"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "grit"
  spec.add_dependency "colored", ">= 1.2"
end
