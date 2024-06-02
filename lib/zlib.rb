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

  def adler32_combine(adler1, adler2, len2)
    # https://github.com/madler/zlib/blob/0f51fb4933fc9ce18199cb2554dacea8033e7fd3/adler32.c#L138C1-L140C29
    return 0xffffffff if len2 < 0

    a1 = adler1 & 0xFFFF
    b1 = (adler1 >> 16) & 0xFFFF
    a2 = adler2 & 0xFFFF
    b2 = (adler2 >> 16) & 0xFFFF

    a = (a1 + a2 - 1) % 65521
    b = (b1 + b2 + (a1 - 1) * len2) % 65521
    b * 65536 + a
  end

  CRC_TABLE = Array.new(256) do |i|
    8.times do
      i = i.odd? ? (0xEDB88320 ^ (i >> 1)) : (i >> 1)
    end
    i
  end

  def crc32(str = '', c = 0)
    c = ~c & 0xFFFFFFFF
    str.each_byte do |byte|
      c = CRC_TABLE[(c ^ byte) & 0xFF] ^ (c >> 8)
    end
    c ^ 0xFFFFFFFF
  end

  def crc_table
    CRC_TABLE
  end
end

require_relative 'zlib_ext'
require_relative 'zlib/deflate'
