require File.join(File.dirname(__FILE__), %w[spec_helper])

describe Handcar do
  class StubLogger < Array
    def debug(text)
      self << text
    end
  end

  before :each do
    @logger = StubLogger.new
    @context = stub("Context")
    @context.stub!(:with_trace_context).
      and_yield(123, 456, 789, "foo_controller", "bar_action")
    Handcar::Context.stub!(:instance).and_return(@context)
    reset_global_const(:RAILS_DEFAULT_LOGGER, @logger)
    @caller = ["yabba", "dabba", "doo"]
    Kernel.stub!(:caller).and_return(@caller)
  end

  def trace(index)
    Handcar::TraceLine.parse(@logger[index])
  end

  describe "when tracing a line" do
    before :each do
      do_trace
    end

    def do_trace
      hc_trace('foo')
    end

    it "should log trace and backtrace info" do
      trace(0).type.should == 'user'
      trace(1).type.should == 'stack'
      trace(1).text.should == "yabba"
      trace(2).type.should == 'stack'
      trace(2).text.should == "dabba"
      trace(3).type.should == 'stack'
      trace(3).text.should == "doo"
    end

    it "should log process ID" do
      trace(0).pid.should == 456
    end

    it "should log thread ID" do
      trace(0).tid.should == 789
    end

    it "should log controller" do
      trace(0).controller.should == "foo_controller"
    end
    it "should log action" do
      trace(0).action.should == "bar_action"
    end
  end

end

# EOF
