require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'spec'
require 'spec/rake/spectask'

desc "Run all application specs with RCov"
  Spec::Rake::SpecTask.new(:spec) do |t|
    t.spec_files = FileList['spec/**/*_spec.rb']
#    t.rcov = true
#    t.rcov_opts = ['--exclude', '_spec,spec_helper,metaid,boot.rb']
  end

desc 'Run all tests of acts_as_somebody_elses_data plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Run all tests and specs of acts_as_somebody_elses_data  plugin'
task :default => [:spec, :test]

desc 'Generate documentation for the acts_as_somebody_elses_data  plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title    = 'MckinseySecurity'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.add ['README', 'CHANGELOG', 'lib/**/*.rb']
  rdoc.main = 'README'  
  rdoc.template = '/usr/local/lib/ruby/gems/1.8/gems/allison-2.0.3/lib/allison'
end

