require File.join(File.dirname(__FILE__), %w[.. spec_helper])

describe Handcar::Context do
  it_should_behave_like 'handcar'

  before :each do
    # Sneak around the singleton-ness
    @it = Handcar::Context.instance_eval do new end
  end

  it "should keep track of current controller" do
    @it.controller = "foo_controller"
    @it.with_trace_context do |context|
      context.controller.should be == "foo_controller"
    end
  end

  it "should keep track of current action" do
    @it.action = "foo_action"
    @it.with_trace_context do |context|
      context.action.should be == "foo_action"
    end
  end

  it "should increment the trace number" do
    @it.with_trace_context do |context|
      context.number.should be == 1
    end
    @it.with_trace_context do |context|
      context.number.should be == 2
    end
  end

  it "should provide the current Process ID" do
    @it.with_trace_context do |context|
      context.pid.should be == Process.pid
    end
  end

  it "should provide the current Thread ID" do
    @it.with_trace_context do |context|
      context.tid.should be == Thread.list.index(Thread.current)
    end
  end

  it "should provide incremented request numbers on demand" do
    @it.with_request_context do |request_number|
      request_number.should be == 1
    end
    @it.with_request_context do |request_number|
      request_number.should be == 2
    end
  end

  it "should execute the context of request contexts" do
    sensor = stub("Sensor")
    sensor.should_receive(:ping!)
    @it.with_request_context do |request_number|
      sensor.ping!
    end
  end

  it "should be able to record a basic trace" do
    @it.trace!("Test")
    trace(0).text.should be == "Test"
    trace(0).version.should be == 0
    trace(0).number.should be == 1
    trace(0).reqnum.should be == nil
    trace(0).pid.should be == Process.pid
    trace(0).tid.should be == Thread.list.index(Thread.current)
    trace(0).controller.should be == 'unset'
    trace(0).action.should be == 'unset'
  end

  describe 'when logging a trace' do
    before :each do
      @it.trace!(
        :pid        => 456,
        :tid        => 789,
        :controller => "foo_controller",
        :action     => "bar_action")
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
