require 'rubygems'
require 'rake/gempackagetask'
require 'rake/clean'
require 'rake/testtask'

spec = Gem::Specification.load('hikidoc.gemspec')

Rake::GemPackageTask.new(spec) do |pkg|
	pkg.need_zip = true
	pkg.need_tar = true
end

Rake::TestTask.new do |t|
	t.libs << 'lib'
	t.test_files = FileList['test/test*.rb']
	t.verbose = true
end
