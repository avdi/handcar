
module Handcar

  # :stopdoc:
  VERSION = '0.0.1'
  LIBPATH = ::File.expand_path(::File.dirname(__FILE__)) + ::File::SEPARATOR
  PATH = ::File.dirname(LIBPATH) + ::File::SEPARATOR

  # Returns the version string for the library.
  #
  def self.version
    VERSION
  end

  # Returns the library path for the module. If any arguments are given,
  # they will be joined to the end of the libray path using
  # <tt>File.join</tt>.
  #
  def self.libpath( *args )
    args.empty? ? LIBPATH : ::File.join(LIBPATH, args.flatten)
  end

  # Returns the lpath for the module. If any arguments are given,
  # they will be joined to the end of the path using
  # <tt>File.join</tt>.
  #
  def self.path( *args )
    args.empty? ? PATH : ::File.join(PATH, args.flatten)
  end

  # Utility method used to rquire all files ending in .rb that lie in the
  # directory below this file that has the same name as the filename passed
  # in. Optionally, a specific _directory_ name can be passed in such that
  # the _filename_ does not have to be equivalent to the directory.
  #
  def self.require_all_libs_relative_to( fname, dir = nil )
    dir ||= ::File.basename(fname, '.*')
    search_me = ::File.expand_path(
        ::File.join(::File.dirname(fname), dir, '*.rb'))

    Dir.glob(search_me).sort.each {|rb| require rb}
  end
  # :startdoc:

  def self.with_trace_number
    Thread.exclusive do
      @@trace_number ||= 1
      yield(@@trace_number)
      @@trace_number += 1
    end
  end

  def self.reset!
    Thread.exclusive do
      @@trace_number = 1
    end
  end

end  # module Handcar

Handcar.require_all_libs_relative_to(__FILE__)

module ::Kernel
  def hc_trace(text)
    Handcar::Context.instance.with_trace_context do |context|
      context.trace!(text)
      Kernel.caller.each do |frame|
        context.trace!(:type => 'stack', :text => frame).to_s
      end
    end
  end
end

# EOF
