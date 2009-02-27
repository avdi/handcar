class Handcar::ActionFilter
  def initialize(context)
    @context = context
  end

  def filter(controller)
    @context.controller = controller.controller_name
    @context.action     = controller.action_name
    @context.with_request_context do |request_number|
      begin
        Handcar::RequestEvent.new(request_number).record!(@context) do
          yield
        end
      end
    end
  ensure
    @context.action     = nil
    @context.controller = nil
  end
end
