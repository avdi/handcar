require File.join(File.dirname(__FILE__), %w[.. spec_helper])

describe Handcar::Context do
  before :each do
    # Sneak around the singleton-ness
    @it = Handcar::Context.instance_eval do new end
  end

  it "should keep track of current controller" do
    @it.controller = "foo_controller"
    @it.with_trace_context do |number, pid, tid, controller, action|
      controller.should be == "foo_controller"
    end
  end

  it "should keep track of current action" do
    @it.action = "foo_action"
    @it.with_trace_context do |number, pid, tid, controller, action|
      action.should be == "foo_action"
    end
  end

  it "should increment the trace number" do
    @it.with_trace_context do |number, pid, tid, controller, action|
      number.should be == 1
    end
    @it.with_trace_context do |number, pid, tid, controller, action|
      number.should be == 2
    end
  end

  it "should provide the current Process ID" do
    @it.with_trace_context do |number, pid, tid, controller, action|
      pid.should be == Process.pid
    end
  end

  it "should provide the current Thread ID" do
    @it.with_trace_context do |number, pid, tid, controller, action|
      tid.should be == Thread.list.index(Thread.current)
    end
  end
end
