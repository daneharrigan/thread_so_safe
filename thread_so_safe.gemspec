# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{thread_so_safe}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Dane Harrigan"]
  s.date = %q{2010-06-27}
  s.description = %q{thread_so_safe is a very simple gem to help keep multi-threaded environments synced.}
  s.email = %q{dane.harrigan@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "lib/thread_so_safe.rb",
     "spec/spec_helper.rb",
     "spec/thread_so_safe_spec.rb",
     "thread_so_safe.gemspec"
  ]
  s.homepage = %q{http://github.com/daneharrigan/thread_so_safe}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{thread_so_safe is a very simple gem to help keep multi-threaded environments synced.}
  s.test_files = [
    "spec/spec_helper.rb",
     "spec/thread_so_safe_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 1.2.9"])
    else
      s.add_dependency(%q<rspec>, [">= 1.2.9"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 1.2.9"])
  end
end

