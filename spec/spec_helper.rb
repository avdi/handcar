require 'rubygems'
require 'spec'

require File.expand_path(
    File.join(File.dirname(__FILE__), %w[.. lib handcar]))

Spec::Runner.configure do |config|
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
end

def reset_global_const(name, value)
  if Object.const_defined?(name)
    Object.instance_eval do remove_const name end
  end
  Object.const_set(name, value)
end

def traceline(text)
  %r(_/_ \d+ _\\_ #{text})
end

# EOF
