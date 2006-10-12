require 'date'

Gem::Specification.new do |s|
  s.name = %q{hikidoc}
  s.date = Date.today
  s.version = "0." + s.date.strftime('%Y%m%d')
  s.summary = %q{A text-to-HTML conversion tool for web writers.}
  s.email = %q{kazuhiko@fdiary.net}
  s.homepage = %q{http://projects.netlab.jp/hikidoc/}
  s.description = %q{'HikiDoc' is a text-to-HTML conversion tool for web writers. HikiDoc allows you to write using an easy-to-read, easy-to-write plain text format, then convert it to structurally valid HTML (or XHTML).}
  s.default_executable = %q{hikidoc}
  s.authors = ["Kazuhiko"]
  s.files = ["bin/hikidoc", "COPYING", "README", "README.ja", "Rakefile", "TextFormattingRules", "TextFormattingRules.ja", "setup.rb", "lib/hikidoc.rb", "test/test_hikidoc.rb"]
  s.test_files = ["test/test_hikidoc.rb"]
  s.executables = ["hikidoc"]
end
