require File.join(File.dirname(__FILE__), %w[.. spec_helper])

describe Handcar::TraceLine do
  it "should be able to identify if a line is a Handcar trace" do
    # Note that for this test we only expect a rough (but FAST) heuristic
    Handcar::TraceLine.parseable?("[HANDCAR] yadda yadda").should be_true
    Handcar::TraceLine.parseable?("[CARHAND] blah blah").should_not be_true
  end
end
