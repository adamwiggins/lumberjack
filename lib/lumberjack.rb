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
      @suggestions ||= YAML.load_stream(File.open(File.dirname(__FILE__) + "/../suggestions.yml")).documents
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
