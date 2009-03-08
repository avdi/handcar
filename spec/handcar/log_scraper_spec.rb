require 'pathname'
require Pathname(__FILE__).ascend{|d| h=d+'spec_helper.rb'; break h if h.file?}

describe Handcar::LogScraper do
  before :each do
    @traceline = stub("TraceLine").as_null_object
    Handcar::TraceLine.stub!(:parse).and_return(@traceline)
    @inputs      = [stub("Raw Log Line")]
    @outputs     = []
    @it = Handcar::LogScraper.new
  end

  def do_scrape
    @inputs.each do |input|
      @it.interpret(input) do |scraper, traceline|
        @outputs << traceline
      end
    end
  end

  context "given a recognizable but non-matching log line" do
    before :each do
      Handcar::TraceLine.stub!(:recognizable?).and_return(true)
      do_scrape
    end

    it "should not generate a trace line object" do
      @outputs.should be_empty
    end
  end


  context "given an unrecognizable line" do
    before :each do
      Handcar::TraceLine.stub!(:recognizable?).and_return(false)
      do_scrape
    end

    it "should not generate a traceline object" do
      @outputs.should be_empty
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
    end

    context "by default" do
      it "should include only 'user' traces in the filtered view" do
        do_scrape
        @outputs.should == [@user_trace]
      end
    end

    context "when user and stack types are selected" do
      before :each do
        @it.included_types = ['user', 'stack']
      end

      it "should include user and stack traces in filtered view" do
        do_scrape
        @outputs.should == [@user_trace, @stack_trace]
      end
    end

    context "when :all trace types are selected" do
      before :each do
        @it.included_types = :all
      end

      it "should include all trace types in filtered view" do
        do_scrape
        @outputs.should == @traces
      end
    end
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
    end

    it "should include all in the filtered output by default" do
      do_scrape
      @outputs.should == @traces
    end

    context "with trace numbers 0-123 selected" do
      before :each do
        @it.selected_numbers = (0..123)
      end

      it "should include traces 122..123 in the filtered view" do
        do_scrape
        @outputs.should == [@trace122, @trace123]
      end
    end

    context "with trace numbers 124..200 selected" do
      before :each do
        @it.selected_numbers = (124..200)
      end

      it "should include trace 124 in the filtered view" do
        do_scrape
        @outputs.should == [@trace124]
      end
    end

    context "with just trace number 123 selected" do
      before :each do
        @it.selected_numbers = 123
      end

      it "should include just trace 123 in the filtered view" do
        do_scrape
        @outputs.should == [@trace123]
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
    end

    context "by default" do
      it "should include only all PID's traces in filtered view" do
        do_scrape
        @outputs.should == @traces
      end
    end

    context "when a single PID is slected" do
      before :each do
        @it.selected_pids = 333
      end

      it "should include only the selected PID in the filtered view" do
        do_scrape
        @outputs.should be == [@trace2, @trace3]
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
      @inputs  = ["LINE1", "LINE2", "LINE3", "LINE4"]
      @outputs = []
      Handcar::TraceLine.stub!(:recognizable?).and_return(true)
      Handcar::TraceLine.stub!(:parse).and_return(*@traces)
    end

    it "should have all requests selected by default" do
      do_scrape
      @it.selected_request.should == :all
    end

    context "by default" do
      it "should select all traces in the filtered view" do
        do_scrape
        @outputs.should be == [@trace2, @trace3, @trace4, @trace5]
      end
    end

    context "with a single request selected" do
      before :each do
        @it.selected_request = 222
      end

      it "should include only the selected request in the filtered view" do
        do_scrape
        @outputs.should == [@trace3, @trace4]
      end

      it "should output only the selected request" do
        do_scrape
        @outputs.should == [@trace3, @trace4]
      end

    end
  end
end
