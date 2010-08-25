task :test do
  sh "ruby test/*_test.rb"
end

task :default => :test

###########################

require 'jeweler'

Jeweler::Tasks.new do |s|
  s.name = "lumberjack"
  s.summary = s.description = "Crashlog inspector which provides helpful suggestions on Heroku."
  s.author = "Nick Quaranto"
  s.homepage = "http://github.com/adamwiggins/lumberjack"
  s.executables = [ "lumberjack" ]

  s.files = FileList["[A-Z]*", "suggestions.yml", "{bin,lib}/**/*"]
end

Jeweler::GemcutterTasks.new
