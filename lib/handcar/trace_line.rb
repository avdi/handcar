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
    :text                       # Body text of trace
    ) do

    TYPE_TO_PREFIX_MAP = {
      'user'    => '**',
      'stack'   => '>>',
      'request' => '--'
    }

    PREFIX_TO_TYPE_MAP = TYPE_TO_PREFIX_MAP.invert

    TYPES = TYPE_TO_PREFIX_MAP.keys

    def self.parse(line)
      new(line)
    end

    def self.recognizable?(line)
      line.index(GLOBAL_PREFIX) == 0
    end

    GLOBAL_PREFIX = '[HANDCAR]'
    LINE_PATTERN = %r|^#{Regexp.escape(GLOBAL_PREFIX)} (..) (\d+) (\d+) (\d+) (\d+) (\w+) (\w+) (.*)$|

    def initialize(line_or_fields)
      self.version    = 0
      self.controller = 'none'
      self.action     = 'none'
      case line_or_fields
      when String then init_from_line(line_or_fields)
      when Hash   then init_from_fields(line_or_fields)
      else raise ArgumentError,
                 "line_or_fields must be String or Hash (#{line_or_fields.inspect})"
      end
      unless TYPES.include?(type)
        raise ArgumentError, "Unknown type: #{type.inspect}"
      end
    end

    def to_s
      "#{GLOBAL_PREFIX} #{type_prefix} #{version} #{number} #{pid} #{tid} #{controller} #{action} #{text}"
    end

    private

    def init_from_fields(fields)
      fields.each_pair do |key, value|
        send("#{key}=", value)
      end
    end

    def init_from_line(line)
      if(match_data = LINE_PATTERN.match(line))
        self.type       = deduce_type(match_data[1])
        self.version    = match_data[2].to_i
        self.number     = match_data[3].to_i
        self.pid        = match_data[4].to_i
        self.tid        = match_data[5].to_i
        self.controller = match_data[6]
        self.action     = match_data[7]
        self.text       = match_data[-1]
      else
        raise ArgumentError,
              "Unrecognized trace format: '#{line}'; " \
              "Expecting #{LINE_PATTERN}"
      end
    end

    def deduce_type(prefix)
      PREFIX_TO_TYPE_MAP.fetch(prefix) do
        raise ArgumentError, "Unknown prefix: #{prefix}"
      end
    end

    def type_prefix
      TYPE_TO_PREFIX_MAP.fetch(type) do
        raise ArgumentError, "Unknown type: #{type}"
      end
    end
  end
end
