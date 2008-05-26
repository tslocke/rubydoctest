Gem::Specification.new do |s|
  s.name = %q{rubydoctest}
  s.version = "0.2.1"

  s.specification_version = 2 if s.respond_to? :specification_version=

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tom Locke", "Dr Nic Williams"]
  s.date = %q{2008-05-25}
  s.default_executable = %q{rubydoctest}
  s.description = %q{Ruby version of Python's doctest tool, but a bit different.}
  s.email = ["drnicwilliams@gmail.com"]
  s.executables = ["rubydoctest"]
  s.extra_rdoc_files = ["History.txt", "License.txt", "Manifest.txt", "PostInstall.txt", "README.txt", "website/index.txt"]
  s.files = ["History.txt", "License.txt", "Manifest.txt", "PostInstall.txt", "README.txt", "Rakefile", "bin/rubydoctest", "config/hoe.rb", "config/requirements.rb", "lib/rubydoctest.rb", "lib/rubydoctest/version.rb", "script/console", "script/destroy", "script/generate", "script/txt2html", "setup.rb", "tasks/deployment.rake", "tasks/environment.rake", "tasks/website.rake", "test/test_helper.rb", "test/test_rubydoctest.rb", "website/index.html", "website/index.txt", "website/javascripts/rounded_corners_lite.inc.js", "website/stylesheets/screen.css", "website/template.html.erb"]
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
  s.test_files = ["test/test_helper.rb", "test/test_rubydoctest.rb"]
end
