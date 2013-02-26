# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hikidoc'

Gem::Specification.new do |spec|
  spec.name          = "hikidoc"
  spec.version       = HikiDoc::VERSION
  spec.authors       = ['Kazuhiko', "SHIBATA Hiroshi"]
  spec.email         = ['kazuhiko@fdiary.net', "shibata.hiroshi@gmail.com"]
  spec.description   = %q{'HikiDoc' is a text-to-HTML conversion tool for web writers.}
  spec.summary       = %q{'HikiDoc' is a text-to-HTML conversion tool for web writers. HikiDoc allows you to write using an easy-to-read, easy-to-write plain text format, then convert it to structurally valid HTML (or XHTML).}
  spec.homepage      = "https://github.com/hiki/hikidoc"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
end
