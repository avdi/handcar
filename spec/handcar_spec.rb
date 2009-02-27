require File.join(File.dirname(__FILE__), %w[spec_helper])

describe Handcar do
  it_should_behave_like 'handcar'

  before :each do
    @context = stub("Context", :trace! => nil)
    @context.stub!(:with_trace_context).and_yield(@context)
    Handcar::Context.stub!(:instance).and_return(@context)
    @caller = ["yabba", "dabba", "doo"]
    Kernel.stub!(:caller).and_return(@caller)
  end

  describe "when tracing a line" do
    after :each do
      do_trace
    end

    def do_trace
      hc_trace('foo')
    end

    it "should log trace and backtrace info" do
      @context.should_receive(:trace!).
        with(:type => 'user', :text => "foo").ordered
      @context.should_receive(:trace!).
        with(:type => 'stack', :text => "yabba").ordered
      @context.should_receive(:trace!).
        with(:type => 'stack', :text => "dabba").ordered
      @context.should_receive(:trace!).
        with(:type => 'stack', :text => "doo").ordered
    end
  end

end

# EOF
