# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{handcar}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Avdi Grimm"]
  s.date = %q{2009-02-25}
  s.default_executable = %q{handcar}
  s.description = %q{A step up from debugging your Rails apps with with 'puts' and 'raise'.  Handcar emits specially formatted trace lines into your Rails log files, along with backtrace information.  The 'handcar' executable scrapes your log files for these trace lines, so you can see whether, and when, they are being hit.  It can do this in real-time, a la "tail -f".}
  s.email = %q{avdi@avdi.org}
  s.executables = ["handcar"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.rdoc", "bin/handcar"]
  s.files = [".gitignore", "History.txt", "Manifest.txt", "README.rdoc", "Rakefile", "bin/handcar", "example/log/development.log", "lib/handcar.rb", "spec/handcar_spec.rb", "spec/spec_helper.rb", "tasks.archive/ann.rake", "tasks.archive/bones.rake", "tasks.archive/cucumber.rake", "tasks.archive/gem.rake", "tasks.archive/git.rake", "tasks.archive/manifest.rake", "tasks.archive/notes.rake", "tasks.archive/post_load.rake", "tasks.archive/rdoc.rake", "tasks.archive/rubyforge.rake", "tasks.archive/setup.rb", "tasks.archive/spec.rake", "tasks.archive/svn.rake", "tasks.archive/test.rake", "tasks/ann.rake", "tasks/bones.rake", "tasks/gem.rake", "tasks/git.rake", "tasks/notes.rake", "tasks/post_load.rake", "tasks/rdoc.rake", "tasks/rubyforge.rake", "tasks/setup.rb", "tasks/spec.rake", "tasks/svn.rake", "tasks/test.rake", "test/test_handcar.rb"]
  s.has_rdoc = true
  s.homepage = %q{FIXME (project homepage)}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{handcar}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{A step up from debugging your Rails apps with with 'puts' and 'raise'}
  s.test_files = ["test/test_handcar.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bones>, [">= 2.4.0"])
    else
      s.add_dependency(%q<bones>, [">= 2.4.0"])
    end
  else
    s.add_dependency(%q<bones>, [">= 2.4.0"])
  end
end
