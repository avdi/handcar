class Handcar::RequestEvent < Handcar::Event
  def initialize(request_number)
    @request_number = request_number
  end

  def record!(context)
    context.trace!(
      :type => 'request',
      :text => "BEGIN Request ##{@request_number}")
    yield
  ensure
    context.trace!(
      :type => 'request',
      :text => "END Request ##{@request_number}")
  end
end
