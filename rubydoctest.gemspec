Gem::Specification.new do |s|
  s.name = %q{rubydoctest}
  s.version = "1.0.0"

  s.specification_version = 2 if s.respond_to? :specification_version=

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Duane Johnson", "Tom Locke", "Dr Nic Williams"]
  s.date = %q{2008-06-21}
  s.default_executable = %q{rubydoctest}
  s.description = %q{Ruby version of Python's doctest tool, but a bit different.}
  s.email = ["duane.johnson@gmail.com"]
  s.executables = ["rubydoctest"]
  s.extra_rdoc_files = ["History.txt", "License.txt", "Manifest.txt", "PostInstall.txt", "README.txt", "website/index.txt"]
  s.files = IO.read("Manifest.txt").split("\n")
  s.has_rdoc = true
  s.homepage = %q{http://rubydoctest.rubyforge.org}
  s.post_install_message = %q{
rubydoctest comes as an executable that takes a file or directory:
	
  rubydoctest .
	rubydoctest simple.doctest


}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{rubydoctest}
  s.rubygems_version = %q{1.1.1}
  s.summary = %q{Ruby version of Python's doctest tool, but a bit different.}
  s.test_files = []
end
