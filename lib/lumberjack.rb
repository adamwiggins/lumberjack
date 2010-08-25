require 'yaml'

class RailsGems
  def run(contents)
    if gems = parse_gems(contents)
      gems = gems.split("\n").map { |gem| gem.strip }
      <<EOF
Your application is missing the following gems:

#{gems.map { |g| "* #{g}" }.join("\n")}

Add those to your Gemfile or .gems manifest and push again.

[Read the docs on managing gems](http://docs.heroku.com/gems) for more information.
EOF
    else
      <<EOF
Your application is missing gems required to start up.

[Read the docs on managing gems](http://docs.heroku.com/gems) for more information.
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
     "[Check out the troubleshooting section on our Documentation site.](http://docs.heroku.com)"
    elsif suggestion['handler']
     handler = Kernel.const_get(suggestion['handler'])
     handler.new.run(crashlog)
    else
     suggestion['message']
    end
  end
end
