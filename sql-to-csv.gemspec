lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sql-to-csv/version'

Gem::Specification.new do |gem|
  gem.name            = 'sql-to-csv'
  gem.version         = SqlToCsv::VERSION
  gem.summary         = "MySQL command line client that allows for results in CSV."
  gem.description     = "Small MySQL command line client. Outputs results in CSV format. Support results to file via output redirection"
  gem.authors         = ["James Baer"]
  gem.email           = 'jamesfbaer@gmil.com'
  gem.files           = Dir["lib/**/*"]
  gem.license         = 'MIT'
  gem.executables     = %w(sql-to-csv)
  gem.require_paths   = ['lib']

  gem.required_ruby_version = ">= 2.0"
  gem.add_dependency "mysql2"
end
