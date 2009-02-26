require 'singleton'
class Handcar::Context
  include Singleton

  attr_accessor :controller
  attr_accessor :action
  attr_reader   :number

  def initialize
    @number     = 1
    @controller = 'unset'
    @action     = 'unset'
  end

  def pid
    Process.pid
  end

  def tid
    Thread.list.index(Thread.current)
  end

  def with_trace_context
    yield number, pid, tid, controller, action
    @number += 1
  end
end
