require File.join(File.dirname(__FILE__), %w[.. spec_helper])

describe Handcar::TraceLine do
  it "should be able to identify if a line is a Handcar trace" do
    # Note that for this test we only expect a rough (but FAST) heuristic
    Handcar::TraceLine.recognizable?("[HANDCAR] yadda yadda").should be_true
    Handcar::TraceLine.recognizable?("[CARHAND] blah blah").should_not be_true
  end

  describe "given options for a request trace" do
    before :each do
      @it = Handcar::TraceLine.new(:type => "request")
    end

    it "should format the trace with a prefix of --" do
      @it.to_s.split[1].should == "--"
    end
  end

  describe "given a request trace to parse" do
    before :each do
      @it = Handcar::TraceLine.parse("[HANDCAR] -- 0 1 1 1 1 foo bar hello")
    end

    it "should interpret it as a request trace" do
      @it.type.should be == 'request'
    end
  end
end
