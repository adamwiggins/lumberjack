require 'yaml'

module Lumberjack
  class RailsGems
    def run(contents)
      if gems = parse_gems(contents)
        gems = gems.split("\n").map { |gem| gem.strip }
        return <<EOF
-----> Your application is missing the following gems:

#{gems.map { |g| "       * #{g}" }.join("\n")}

       Add those to your Gemfile or .gems manifest and push again.

       See the docs on managing gems for more information:
       http://docs.heroku.com/gems
EOF
      else
        return <<EOF
-----> Your application is missing gems required to start up.

       See the docs on managing gems for more information:
       http://docs.heroku.com/gems
EOF
      end
    end

    def parse_gems(contents)
      if gems = /Missing .* gems:\n([\w\s\-\_]+)\n\n/.match(contents)
        gems[1]
      end
    end
  end

  module Suggestion
    extend self

    def all
      [
        {
          'lookup' => 'rake gems:install',
          'handler' => 'RailsGems',
        },
        {
          'lookup' => [ 'LoadError', 'MissingSourceFile', 'was not found' ],
          'message' => <<EOMSG
-----> Your application is requiring a file that it can't find.

       Most often this is due to missing gems, or it could be that you failed
       to commit the file to your repo.  See http://docs.heroku.com/gems for
       more information on managing gems.

       Examine the backtrace above this message to debug.
EOMSG
        },
        {
          'lookup' => [ 'NameError', 'SyntaxError', 'NoMethodError', 'ArgumentError', 'RuntimeError' ],
          'message' => <<EOMSG
-----> An error happened during the initialization of your app.

       This may be due to a typo, wrong number of arguments, or calling a
       function that doesn't exist.

       Make sure the app is working locally in production mode, by running it
       with RAILS_ENV (for Rails apps) or RACK_ENV (for Sinatra or other rack
       apps) set to production. e.g. RAILS_ENV=production script/server.

       Examine the backtrace above this message to debug.
EOMSG
        },
        {
          'lookup' => [ 'PGError', 'PostgresError' ], 'message' => <<EOMSG
-----> Your application had a fatal error when talking to Postgres.

       See http://docs.heroku.com/database for troubleshooting information.

       Make sure you've migrated your database if there are fresh migrations
       that you just pushed.

       Examine the backtrace above this message to debug.
EOMSG
        },
        {
          'lookup' => 'RAILS_GEM_VERSION', 'message' => <<EOMSG
-----> Rails can't find the expected version.

       Check to ensure you have specified the correct version of Rails in your
       Gemfile or .gems.  See http://docs.heroku.com/gems for details.

       For Rails 2.3.5 or older, you may be affected by a Rails dependency
       issue.  See http://docs.heroku.com/rails236 for details.

       Examine the backtrace above this message to debug.
EOMSG
        },
        {
          'lookup' => 'Errno::ENOENT', 'message' => <<EOMSG
-----> Your application could not find files necessary to start up.

       Make sure all your files are commited to your git repo, are not listed
       in your .gitignore, and that you have no Git submodules.

       Examine the backtrace above this message to debug.
EOMSG
        },
        {
          'lookup' => 'Segmentation', 'message' => <<EOMSG
-----> Your application crashed due to a segmentation fault.

       Check for updated versions of the libraries found in the stack trace
       that may have fixed this issue.

       Examine the backtrace above this message to debug.
EOMSG
        }
      ]
    end

    def find(crashlog)
      suggestion = all.find do |hash|
       if hash["lookup"].is_a? Array
        hash["lookup"].any? do |lookup|
          crashlog.include? lookup
        end
       else
        crashlog.include? hash["lookup"]
       end
      end

      if !suggestion
        return <<EOMSG
-----> Your application crashed.

       Examine the backtrace above this message to debug.
EOMSG
      elsif suggestion['handler']
       handler = Lumberjack.const_get(suggestion['handler'])
       handler.new.run(crashlog)
      else
       suggestion['message']
      end
    end
  end
end
