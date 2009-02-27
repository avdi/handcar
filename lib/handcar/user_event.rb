class Handcar::UserEvent < Handcar::Event
  def initialize(text)
    @text = text
  end

  def record!(context)
    context.trace!(:type => 'user', :text => @text)
  end
end
