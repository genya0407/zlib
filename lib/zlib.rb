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

  def zlib_version
    '1.2.12'
  end

  # https://ja.wikipedia.org/wiki/Adler-32
  def adler32(str = nil, adler = 1)
    return 1 unless str

    a = adler & 0xFFFF
    b = (adler >> 16) & 0xFFFF
    str.each_byte do |byte|
      a = (a + byte) % 65521
      b = (b + a) % 65521
    end
    b * 65536 + a
  end
end

require_relative 'zlib_ext'
require_relative 'zlib/deflate'
