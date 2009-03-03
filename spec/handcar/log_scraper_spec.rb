require 'pathname'
require Pathname(__FILE__).ascend{|d| h=d+'spec_helper.rb'; break h if h.file?}

describe Handcar::LogScraper do
  before :each do
    @line1      = stub("LINE 1")
    @line2      = stub("LINE 2")
    @traceline1 = stub("TraceLine 1").as_null_object
    @traceline2 = stub("TraceLine 2").as_null_object
    Handcar::TraceLine.stub!(:parse).and_return(@traceline1, @traceline2)
    @it = Handcar::LogScraper.new
  end

  context "given a a recognizable log line" do
    before :each do
      Handcar::TraceLine.stub!(:recognizable?).and_return(true)
      @it << @line1
    end

    specify { @it.should have(1).lines }

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

  context "given a recognizable line and an unrecognizable line" do
    before :each do
      Handcar::TraceLine.stub!(:recognizable?).and_return(false, true)
      @it << @line1 << @line2
    end

    specify { @it.should have(1).lines }

    it "it should have a trace line for the recognizable line" do
      @it.lines[0].should equal(@traceline1)
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

  context "given a variety of valid trace lines" do
    before :each do
      @traces = [
        @user_trace = stub("UserTrace",
          :type => 'user').as_null_object,
        @stack_trace = stub("StackTrace",
          :type => 'stack').as_null_object,
        @request_trace = stub("RequestTrace",
          :type => 'request').as_null_object,
        @data_trace = stub("DataTrace",
          :type => 'data').as_null_object,
      ]
      @inputs = ["LINE1", "LINE2", "LINE3", "LINE4"]
      Handcar::TraceLine.stub!(:recognizable?).and_return(true)
      Handcar::TraceLine.stub!(:parse).and_return(*@traces)
      @inputs.each do |line| @it << line end
    end

    context "by default" do
      it "should include only 'user' traces in the filtered view" do
        @it.filtered_lines.should == [@user_trace]
      end
    end

    context "when user and stack types are selected" do
      before :each do
        @it.included_types = ['user', 'stack']
      end

      it "should include user and stack traces in filtered view" do
        @it.filtered_lines.should == [@user_trace, @stack_trace]
      end
    end

    context "when :all trace types are selected" do
      before :each do
        @it.included_types = :all
      end

      it "should include all trace types in filtered view" do
        @it.filtered_lines.should == @traces
      end
    end
  end


  it "should have a default window size of 100" do
    @it.window_size.should be == 100
  end

  context "given three numbered traces" do
    before :each do
      @traces = [
        @trace122 = stub("UserTrace122",
          :type => 'user', :number => 122).as_null_object,
        @trace123 = stub("UserTrace123",
          :type => 'user', :number => 123).as_null_object,
        @trace124 = stub("UserTrace124",
          :type => 'user', :number => 124).as_null_object,
      ]
      @inputs = ["LINE1", "LINE2", "LINE3"]
      Handcar::TraceLine.stub!(:recognizable?).and_return(true)
      Handcar::TraceLine.stub!(:parse).and_return(*@traces)
      @inputs.each do |line| @it << line end
    end

    it "should include all in the filtered output by default" do
      @it.filtered_lines.should == @traces
    end

    context "with trace numbers 0-123 selected" do
      before :each do
        @it.selected_numbers = (0..123)
      end

      it "should include traces 122..123 in the filtered view" do
        @it.filtered_lines.should == [@trace122, @trace123]
      end
    end

    context "with trace numbers 124..200 selected" do
      before :each do
        @it.selected_numbers = (124..200)
      end

      it "should include trace 124 in the filtered view" do
        @it.filtered_lines.should == [@trace124]
      end
    end

    context "with just trace number 123 selected" do
      before :each do
        @it.selected_numbers = 123
      end

      it "should include just trace 123 in the filtered view" do
        @it.filtered_lines.should == [@trace123]
      end
    end
  end

  context "given traces from two different PIDs" do
    before :each do
      @traces = [
        @trace2 = stub("UserTrace2", :type => 'user', :pid => 333),
        @trace3 = stub("UserTrace3", :type => 'user', :pid => 333),
        @trace4 = stub("UserTrace4", :type => 'user', :pid => 444),
        @trace5 = stub("UserTrace5", :type => 'user', :pid => 444),
      ]
      @inputs = ["LINE1", "LINE2", "LINE3", "LINE5"]
      Handcar::TraceLine.stub!(:recognizable?).and_return(true)
      Handcar::TraceLine.stub!(:parse).and_return(*@traces)
      @inputs.each do |line| @it << line end
    end

    context "by default" do
      it "should include only the later PIDs traces in filtered view" do
        @it.filtered_lines.should == [@trace4, @trace5]
      end
    end

    context "when all PIDs are selected" do
      before :each do
        @it.selected_pids = :all
      end

      it "should include all traces in the filtered view" do
        @it.filtered_lines.should be == @traces
      end
    end

    context "when a single PID is slected" do
      before :each do
        @it.selected_pids = 333
      end

      it "should include only the selected PID in the filtered view" do
        @it.filtered_lines.should be == [@trace2, @trace3]
      end
    end
  end
  context "given traces from multiple requests" do
    before :each do
      @traces = [
        @trace2 = stub("UserTrace2",
          :type => 'user', :reqnum => 111).as_null_object,
        @trace3 = stub("UserTrace3",
          :type => 'user', :reqnum => 222).as_null_object,
        @trace4 = stub("UserTrace4",
          :type => 'user', :reqnum => 222).as_null_object,
        @trace5 = stub("UserTrace5",
          :type => 'user', :reqnum => 333).as_null_object,
      ]
      @inputs = ["LINE1", "LINE2", "LINE3", "LINE4"]
      Handcar::TraceLine.stub!(:recognizable?).and_return(true)
      Handcar::TraceLine.stub!(:parse).and_return(*@traces)
      @inputs.each do |line| @it << line end
    end

    it "should have all requests selected by default" do
      @it.selected_request.should be == :all
    end

    context "by default" do
      it "should select all traces in the filtered view" do
        @it.filtered_lines.should be == [@trace2, @trace3, @trace4, @trace5]
      end
    end

    context "with a single request selected" do
      before :each do
        @it.selected_request = 222
      end

      it "should include only the selected request in the filtered view" do
        @it.filtered_lines.should == [@trace3, @trace4]
      end
    end

  end
end
