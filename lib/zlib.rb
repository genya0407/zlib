module Zlib
  class Error < StandardError; end
  class StreamEnd < Error; end
  class NeedDict < Error; end
  class DataError < Error; end
  class StreamError < Error; end
  class MemError < Error; end
  class BufError < Error; end
  class VersionError < Error; end
  class InProgressError < Error; end

  module_function

  def adler32(str = '', adler = 1)
    str = str.respond_to?(:read) ? str.read : str

    a = adler & 0xFFFF
    b = (adler >> 16) & 0xFFFF
    bytesize = str.bytesize
    i = 0
    while i < bytesize
      b += (a += str.getbyte(i))
      i += 1
    end
    a %= 65521
    b %= 65521
    b * 65536 + a
  end
end

require_relative 'zlib_ext'
require_relative 'zlib/deflate'
