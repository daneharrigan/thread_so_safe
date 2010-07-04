require 'rubygems'
require 'rake'
require 'spec/rake/spectask'
require 'sdoc'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "thread_so_safe"
    gem.version = "0.2"
    gem.summary = %Q{thread_so_safe is a very simple gem to help keep multi-threaded environments synced.}
    gem.description = gem.summary
    gem.email = "dane.harrigan@gmail.com"
    gem.homepage = "http://github.com/daneharrigan/thread_so_safe"
    gem.authors = ["Dane Harrigan"]
    gem.add_development_dependency "rspec", ">= 1.3.0"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/*_spec.rb'
  spec.rcov = true
  spec.rcov_opts = ['--exclude', 'gem,spec']
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "thread_so_safe #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
