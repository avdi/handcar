class Handcar::ActionFilter
  def initialize(context)
    @context = context
  end

  def filter(controller)
    @context.controller = controller.controller_name
    @context.action     = controller.action_name
    yield
  ensure
    @context.action     = nil
    @context.controller = nil
  end
end
