require 'ick'
require 'forwardable'
require 'fattr'

class Handcar::LogWindow
  include Handcar::Necessities
  include Handcar
  extend Forwardable

  class BoundedQueue < Array
    attr_accessor :max_size

    def initialize(size)
      @max_size = size
    end

    def <<(object)
      self.shift until size < max_size
      super(object)
    end

    alias push <<
  end

  attr_reader :lines

  def_delegator :@lines, :max_size=, :window_size=
  def_delegator :@lines, :max_size,  :window_size

  def initialize
    @lines            = BoundedQueue.new(100)
  end

  def interpret(log_line)
    returning self do
      if TraceLine.recognizable?(log_line)
        @lines << TraceLine.parse(log_line)
      end
    end
  end

  alias << interpret

end
