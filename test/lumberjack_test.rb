require 'test/unit'

require File.dirname(__FILE__) + '/../lib/lumberjack'

class LumberjackTest < Test::Unit::TestCase
  def test_segfault
    assert_match /crashed due to a segmentation fault/, Suggestion.find("Segmentation Fault")
  end

  def test_gems_install
    crashlog =<<EOCRASHLOG
Missing these required gems:
  mygem  

Run `rake gems:install` to install the missing gems.
EOCRASHLOG

    assert_match /Add those to your Gemfile/, Suggestion.find(crashlog)
  end
end
