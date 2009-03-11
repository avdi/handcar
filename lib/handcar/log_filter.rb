require 'ick'
require 'forwardable'
require 'fattr'

class Handcar::LogFilter
  include Handcar::Necessities
  include Handcar

  fattr :included_types   => ['user']
  fattr :selected_numbers => :all
  fattr :selected_pids    => :all
  fattr :selected_request => :all

  def filter(trace_line)
    yield self, trace_line if block_given? && filters.match?(trace_line)
  end

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
