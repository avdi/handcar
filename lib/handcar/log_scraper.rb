require 'ick'
require 'forwardable'

class Handcar::LogScraper
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

  attr_reader   :lines
  attr_accessor :included_types
  attr_accessor :selected_numbers
  attr_accessor :selected_pids
  def_delegator :@lines, :max_size=, :window_size=
  def_delegator :@lines, :max_size,  :window_size

  def initialize
    @lines            = BoundedQueue.new(100)
    @included_types   = ['user']
    @selected_numbers = :all
    @selected_pids    = :last
    @last_pid         = nil
  end

  def <<(log_line)
    returning self do
      if TraceLine.recognizable?(log_line)
        @lines << returning(TraceLine.parse(log_line)) do |traceline|
          @last_pid = traceline.pid if traceline.pid
        end
      end
    end
  end

  def filtered_lines
    @lines.select(&method(:filter_by_type)).
      select(&method(:filter_by_number)).
      select(&method(:filter_by_pid))
  end

  private

  def filter_by_type(line)
    case included_types
    when :all then true
    when Array then
      included_types.include?(line.type)
    else
      raise "Invalid value for included_types: #{included_types.inspect}"
    end
  end

  def filter_by_number(line)
    case selected_numbers
    when :all then true
    when Range then
      selected_numbers.include?(line.number)
    when Integer then
      selected_numbers == line.number
    else
      raise "Invalid value for selected_numbers: #{selected_numbers.inspect}"
    end
  end

  def filter_by_pid(line)
    case line.pid
    when Integer
      case selected_pids
      when :all then true
      when :last then
        line.pid == @last_pid
      else
        Array(selected_pids).include?(line.pid)
      end
    else
      true
    end
  end
end
