# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "mass_migrator/version"

Gem::Specification.new do |s|
  s.name        = "mass_migrator"
  s.version     = MassMigrator::VERSION
  s.authors     = ["Mark Abramov"]
  s.email       = ["markizko@gmail.com"]
  s.homepage    = "http://github.com/markiz/mass_migrator"
  s.summary     = %q{Tool for mass migrations on sharded tables.}
  s.description = %q{Tool for mass migrations on sharded tables.}

  s.rubyforge_project = "mass_migrator"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  s.add_development_dependency "mysql2"
  s.add_development_dependency "pry"
  s.add_runtime_dependency "sequel"
end
