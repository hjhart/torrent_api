# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{tpb}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["James Hart"]
  s.date = %q{2011-05-29}
  s.description = %q{A API to query TPB}
  s.email = %q{hjhart@gmail.com}
  s.extra_rdoc_files = ["CHANGELOG", "lib/pirate_bay.rb", "lib/pirate_bay/base.rb", "lib/pirate_bay/categories.rb", "lib/pirate_bay/result.rb", "lib/pirate_bay/result_set.rb"]
  s.files = ["CHANGELOG", "Manifest", "Rakefile", "junk.html", "lib/pirate_bay.rb", "lib/pirate_bay/base.rb", "lib/pirate_bay/categories.rb", "lib/pirate_bay/result.rb", "lib/pirate_bay/result_set.rb", "tpb.gemspec"]
  s.homepage = %q{http://www.github.com/hjhart/tpb}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Tpb"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{tpb}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{A API to query TPB}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
