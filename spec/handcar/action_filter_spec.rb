require File.join(File.dirname(__FILE__), %w[.. spec_helper])

describe Handcar::ActionFilter do
  it_should_behave_like 'handcar'

  before :each do
    @req_num    = 42
    @context    = stub("context").as_null_object
    @context.stub!(:with_request_context).and_yield(@req_num)
    @controller = stub("Controller",
      :controller_name => "my_controller",
      :action_name     => "my_action")
    @sensor     = stub("sensor").as_null_object
    @it         = Handcar::ActionFilter.new(@context)
  end

  def do_filter
    @it.filter(@controller) do
      @sensor.ping!
    end
  end

  it "should record the action name" do
    @context.should_receive(:action=).with("my_action").ordered
    @sensor.should_receive(:ping!).ordered
    @context.should_receive(:action=).with(nil).ordered
    do_filter
  end

  it "should record the controller name" do
    @context.should_receive(:controller=).with("my_controller").ordered
    @sensor.should_receive(:ping!).ordered
    @context.should_receive(:controller=).with(nil).ordered
    do_filter
  end

  it "should be exception-safe" do
    @context.should_receive(:action=).with("my_action").ordered
    @sensor.stub!(:ping!).and_raise("Error!")
    @context.should_receive(:action=).with(nil).ordered
    do_filter rescue nil
  end

  it "should log the start and end of the request" do
    @context.should_receive(:trace!).
      with( :type => 'request',
            :text => "BEGIN Request ##{@req_num}").ordered
    @sensor.should_receive(:ping!).ordered
    @context.should_receive(:trace!).
      with( :type => 'request',
            :text => "END Request ##{@req_num}").ordered
    do_filter
  end
end
