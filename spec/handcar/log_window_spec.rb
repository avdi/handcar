require 'pathname'
require Pathname(__FILE__).ascend{|d| h=d+'spec_helper.rb'; break h if h.file?}

describe Handcar::LogWindow do
  before :each do
    @line1      = stub("LINE 1")
    @line2      = stub("LINE 2")
    @traceline1 = stub("TraceLine 1").as_null_object
    @traceline2 = stub("TraceLine 2").as_null_object
    Handcar::TraceLine.stub!(:parse).and_return(@traceline1, @traceline2)
    @it = Handcar::LogWindow.new
  end

  context "given two lines" do
    before :each do
      Handcar::TraceLine.stub!(:recognizable?).and_return(true, true)
      @it << @line1 << @line2
    end

    specify {  @it.should have(2).lines }

    it "should parse the lines into TraceLines" do
      @it.lines[0].should equal(@traceline1)
      @it.lines[1].should equal(@traceline2)
    end
  end

  context "with a window of three lines" do
    before :each do
      @it.window_size = 3
    end

    context "when given four lines of input" do
      before :each do
        @input = ["LINE 1", "LINE 2", "LINE 3", "LINE 4"]
        @traces = @input.map{|l| stub("TraceLine #{l}").as_null_object }
        Handcar::TraceLine.stub!(:parse).and_return(*@traces)
        Handcar::TraceLine.stub!(:recognizable?).and_return(true)
        @input.each do |line|
          @it << line
        end
      end

      it "should retain three lines" do
        @it.should have(3).lines
      end

      it "should retain the LAST three lines" do
        @it.lines.should == @traces[1..-1]
      end
    end

  end

  context "with a window of two lines" do
    before :each do
      @it.window_size = 2
    end

    context "given four lines of input" do
      before :each do
        @input = ["LINE 1", "LINE 2", "LINE 3", "LINE 4"]
        @traces = @input.map{|l| stub("TraceLine #{l}").as_null_object }
        Handcar::TraceLine.stub!(:parse).and_return(*@traces)
        Handcar::TraceLine.stub!(:recognizable?).and_return(true)
        @input.each do |line|
          @it << line
        end
      end

      it "should retain two lines" do
        @it.should have(2).lines
      end

      it "should retain the LAST two lines" do
        @it.lines.should == @traces[2..-1]
      end
    end
  end

  it "should have a default window size of 100" do
    @it.window_size.should be == 100
  end

end
