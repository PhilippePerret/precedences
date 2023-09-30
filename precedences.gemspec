require_relative 'lib/precedences/version'

Gem::Specification.new do |s|
  s.name          = "precedences"
  s.version       = Precedences::VERSION
  s.authors       = ["PhilippePerret"]
  s.email         = ["philippe.perret@yahoo.fr"]

  s.summary       = %q{Sort list with "the last is the first" principle}
  s.description   = %q{Tty-prompt extension to sort a list of choices along the "last is firts" principle.}
  s.homepage      = "https://rubygems.org/gems/precedences"
  s.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  s.add_dependency 'clir', '>= 0.16'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'minitest-color'

  s.metadata["allowed_push_host"] = "https://rubygems.org"

  s.metadata["homepage_uri"] = s.homepage
  s.metadata["source_code_uri"] = "https://github.com/PhilippePerret/precedences"
  s.metadata["changelog_uri"] = "https://github.com/PhilippePerret/precedences/CHANGELOG"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  s.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|features)/}) }
  end
  s.bindir        = "exe"
  s.executables   = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]
end
