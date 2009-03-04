require 'ick'
require 'forwardable'
require 'fattr'

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

  attr_reader :lines

  fattr :included_types   => ['user']
  fattr :selected_numbers => :all
  fattr :selected_pids    => :last
  fattr :selected_request => :all

  def_delegator :@lines, :max_size=, :window_size=
  def_delegator :@lines, :max_size,  :window_size

  def initialize
    @lines            = BoundedQueue.new(100)
    @included_types   = ['user']
    @selected_numbers = :all
    @selected_pids    = :last
    @selected_request = :all
    @last_pid         = nil
  end

  def interpret(log_line)
    returning self do
      if TraceLine.recognizable?(log_line)
        @lines << returning(TraceLine.parse(log_line)) do |traceline|
          yield self, traceline if block_given? && filters.match?(traceline)
          @last_pid = traceline.pid if traceline.pid
        end
      end
    end
  end

  alias << interpret

  def filtered_lines
    filters.inject(@lines) do |lines, filter|
      lines.select(&filter)
    end
  end

  private

  module FilterChain
    def match?(trace_line)
      all?{|f| f.call(trace_line)}
    end
  end

  def filters
    [
      method(:filter_by_type),
      method(:filter_by_number),
      method(:filter_by_pid),
      method(:filter_by_request)
    ].extend FilterChain
  end

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

  def filter_by_request(line)
    case selected_request
    when :all then true
    when Integer then line.reqnum == selected_request
    else
      raise "Invalid selected request: #{selected_request.inspect}"
    end
  end
end
