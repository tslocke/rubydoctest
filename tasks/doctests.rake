namespace :test do
  namespace :doctest do
    desc "Run rstakeout on test/doctest files"
    task :auto do
      sh "rstakeout 'ruby #{File.dirname(__FILE__)}/../bin/rubydoctest' #{File.dirname(__FILE__)}/../test/doctest/* --pass-as-arg"
    end
  end
end