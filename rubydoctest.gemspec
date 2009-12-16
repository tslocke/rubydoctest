Gem::Specification.new do |s|
  s.name = "rubydoctest"
  s.version = "1.1.2"

  s.specification_version = 2 if s.respond_to? :specification_version=

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Duane Johnson", "Tom Locke", "Dr Nic Williams"]
  s.date = "2008-12-06"
  s.default_executable = "rubydoctest"
  s.description = "Ruby version of Python's doctest tool, but a bit different."
  s.email = ["duane.johnson@gmail.com"]
  s.executables = ["rubydoctest"]
  s.extra_rdoc_files = ["History.txt", "License.txt", "Manifest.txt", "PostInstall.txt", "README.txt", "website/index.txt"]
  manifest = <<-MANIFEST
    History.txt
    License.txt
    Manifest.txt
    PostInstall.txt
    README.txt
    Rakefile
    bin/rubydoctest
    config/hoe.rb
    config/requirements.rb
    lib/code_block.rb
    lib/doctest_require.rb
    lib/lines.rb
    lib/result.rb
    lib/rubydoctest.rb
    lib/rubydoctest/version.rb
    lib/runner.rb
    lib/special_directive.rb
    lib/statement.rb
    lib/test.rb
    rubydoctest.gemspec
    script/console
    script/destroy
    script/generate
    script/rstakeout
    script/txt2html
    setup.rb
    tasks/deployment.rake
    tasks/doctests.rake
    tasks/environment.rake
    tasks/website.rake
    textmate/DocTest (Markdown).textmate
    textmate/DocTest (Ruby).textmate
    textmate/DocTest (Text).textmate
    website/index.html
    website/index.txt
    website/javascripts/rounded_corners_lite.inc.js
    website/stylesheets/screen.css
    website/template.html.erb
  MANIFEST
  s.files = manifest.strip.split("\n").map{|m| m.strip}
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
