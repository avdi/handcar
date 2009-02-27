require 'singleton'
class Handcar::Context
  include Singleton

  attr_accessor :controller
  attr_accessor :action
  attr_reader   :number
  attr_reader   :request_number

  def initialize
    @number         = 1
    @request_number = 1
    @controller     = 'unset'
    @action         = 'unset'
  end

  def pid
    Process.pid
  end

  def tid
    Thread.list.index(Thread.current)
  end

  def trace!(text_or_attributes)
    attributes = case text_or_attributes
                 when String then {:text => text_or_attributes}
                 else text_or_attributes
                 end
    full_attributes = {
      :number     => number,
      :reqnum     => request_number,
      :type       => 'user',
      :pid        => pid,
      :tid        => tid,
      :controller => controller,
      :action     => action,
    }.merge(attributes)
    RAILS_DEFAULT_LOGGER.debug(
      Handcar::TraceLine.new(full_attributes).to_s)
  end

  def with_request_context
    yield request_number
    @request_number += 1
  end

  def with_trace_context
    yield self
    @number += 1
  end
end
