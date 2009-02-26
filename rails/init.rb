ActionController::Base.around_filter(Handcar::ActionFilter.new(Handcar::Context.instance))
