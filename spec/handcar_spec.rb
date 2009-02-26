require File.join(File.dirname(__FILE__), %w[spec_helper])

describe Handcar do
  def reset_global_const(name, value)
    if Object.const_defined?(name)
      Object.instance_eval do remove_const name end
    end
    Object.const_set(name, value)
  end

  before :each do
    Handcar.reset!
    @logger = stub("Logger")
    reset_global_const(:RAILS_DEFAULT_LOGGER, @logger)
    @caller = ["yabba", "dabba", "doo"]
    Kernel.stub!(:caller).and_return(@caller)
  end

  describe "when tracing a line" do
    def do_trace
      hc_trace('foo')
    end

    it "should log trace and backtrace info" do
      @logger.should_receive(:debug).with("_/_ 1 _\\_ ** foo").ordered
      @logger.should_receive(:debug).with("_/_ 1 _\\_ >> yabba").ordered
      @logger.should_receive(:debug).with("_/_ 1 _\\_ >> dabba").ordered
      @logger.should_receive(:debug).with("_/_ 1 _\\_ >> doo").ordered
      do_trace
    end
  end

  describe "when tracing a few lines" do
    def do_trace
      hc_trace('foo')
      hc_trace('bar')
    end

    it "should number the traces" do
      @logger.should_receive(:debug).with("_/_ 1 _\\_ ** foo").ordered
      @logger.should_receive(:debug).with("_/_ 1 _\\_ >> yabba").ordered
      @logger.should_receive(:debug).with("_/_ 1 _\\_ >> dabba").ordered
      @logger.should_receive(:debug).with("_/_ 1 _\\_ >> doo").ordered
      @logger.should_receive(:debug).with("_/_ 2 _\\_ ** bar").ordered
      @logger.should_receive(:debug).with("_/_ 2 _\\_ >> yabba").ordered
      @logger.should_receive(:debug).with("_/_ 2 _\\_ >> dabba").ordered
      @logger.should_receive(:debug).with("_/_ 2 _\\_ >> doo").ordered
      do_trace
    end
  end
end

# EOF
