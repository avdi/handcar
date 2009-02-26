require File.join(File.dirname(__FILE__), %w[spec_helper])

describe Handcar do
  class StubLogger < Array
    def debug(text)
      self << text
    end
  end

  before :each do
    Handcar.reset!
    @logger = StubLogger.new
    reset_global_const(:RAILS_DEFAULT_LOGGER, @logger)
    @caller = ["yabba", "dabba", "doo"]
    Kernel.stub!(:caller).and_return(@caller)
  end

  def trace(index)
    Handcar::TraceLine.parse(@logger[index])
  end

  describe "when tracing a line" do
    def do_trace
      hc_trace('foo')
    end

    it "should log trace and backtrace info" do
      do_trace
      trace(0).type.should == 'user'
      trace(1).type.should == 'stack'
      trace(1).text.should == "yabba"
      trace(2).type.should == 'stack'
      trace(2).text.should == "dabba"
      trace(3).type.should == 'stack'
      trace(3).text.should == "doo"
    end
  end

  describe "when tracing a few lines" do
    def do_trace
      hc_trace('foo')
      hc_trace('bar')
    end

    it "should number the traces" do
      do_trace
      trace(0).number.should == 1
      trace(1).number.should == 1
      trace(2).number.should == 1
      trace(3).number.should == 1
      trace(4).number.should == 2
      trace(5).number.should == 2
      trace(6).number.should == 2
      trace(7).number.should == 2
    end
  end
end

# EOF
