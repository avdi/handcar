class Handcar::StackTraceEvent < Handcar::Event
  def initialize(stacktrace)
    @stacktrace = stacktrace
  end

  def record!(context)
    @stacktrace.each do |frame|
      context.trace!(:type => 'stack', :text => frame)
    end
  end
end
