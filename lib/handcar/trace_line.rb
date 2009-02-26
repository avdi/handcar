module Handcar
  TraceLine = Struct.new(
    :version,                   # Trace format version
    :number,                    # Trace number
    :type,                      # E.g. user, stack, request, etc.
    :pid,                       # Process ID
    :tid,                       # Thread ID
    :reqnum,                    # Request Number (if in a request)
    :controller,                # Controller Name (if any)
    :action,                    # Action Name (if any)
    :tag,                       # Arbitrary tag for categorization
    :metrics,                   # Arbitrary key => value fields
    :text                       # Body text of trace
    ) do

    def self.parse(line)
      new(line)
    end

    LINE_PATTERN = %r[^_/_ (\d+) _\\_ (..) (.*)$]

    def initialize(line_or_fields)
      case line_or_fields
      when String then init_from_line(line_or_fields)
      when Hash   then init_from_fields(line_or_fields)
      else raise ArgumentError,
                 "line_or_fields must be String or Hash (#{line_or_fields.inspect})"
      end
    end

    def init_from_fields(fields)
      fields.each_pair do |key, value|
        send("#{key}=", value)
      end
    end

    def init_from_line(line)
      if(match_data = LINE_PATTERN.match(line))
        self.number = match_data[1].to_i
        self.type   = deduce_type(match_data[2])
        self.text   = match_data[3]
      else
        raise ArgumentError, "Unrecognized trace format: '#{line}'"
      end
    end

    def to_s
      "_/_ #{number} _\\_ #{type_prefix} #{text}"
    end

    private

    def deduce_type(prefix)
      case prefix
      when "**" then 'user'
      when ">>" then 'stack'
      else raise ArgumentError, "Unknown prefix: #{prefix}"
      end
    end

    def type_prefix
      case type
      when 'user'  then '**'
      when 'stack' then '>>'
      else raise ArgumentError, "Unknown type: #{type}"
      end
    end
  end
end
