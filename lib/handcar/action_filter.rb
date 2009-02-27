class Handcar::ActionFilter
  def initialize(context)
    @context = context
  end

  def filter(controller)
    @context.controller = controller.controller_name
    @context.action     = controller.action_name
    @context.with_request_context do |request_number|
      begin
        @context.trace!(
          :type => 'request',
          :text => "BEGIN Request ##{request_number}")
        yield
      ensure
        @context.trace!(
          :type => 'request',
          :text => "END Request ##{request_number}")
      end
    end
  ensure
    @context.action     = nil
    @context.controller = nil
  end
end
