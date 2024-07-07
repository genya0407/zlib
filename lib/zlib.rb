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

  def crc32(str = '', c = 0)
    c = ~c & 0xFFFFFFFF
    n = str.size
    i = 0
    while i < n
      c = CRC_TABLE[(c ^ str.getbyte(i)) & 0xFF] ^ (c >> 8)
      i += 1
    end
    c ^ 0xFFFFFFFF
  end

  def crc32_combine(crc1, crc2, len2)
    multmodp(x2nmodp(len2, 3), crc1) ^ (crc2 & 0xffffffff)
  end

  def multmodp(a, b)
    m = 1 << 31
    p = 0

    while true do
      if a & m != 0
        p ^= b
        break if a & (m - 1) == 0
      end
      m >>= 1
      b = if b & 1 != 0
            (b >> 1) ^ POLY
          else
            b >> 1
          end
    end

    p
  end

  def x2nmodp(n, k)
    p = 1 << 31

    while n != 0 do
      p = multmodp(X2N_TABLE[k & 31], p) if n & 1 != 0

      n >>= 1
      k += 1
    end

    p
  end

  def crc_table
    CRC_TABLE
  end

  POLY = 0xedb88320
  CRC_TABLE = Array.new(256) do |i|
    8.times do
      i = i.odd? ? (0xEDB88320 ^ (i >> 1)) : (i >> 1)
    end
    i
  end
  X2N_TABLE = Array.new(32).tap do |x2n_table|
    p = 1 << 30 # x^1
    x2n_table[0] = p
    (1..31).each do |i|
      x2n_table[i] = p = multmodp(p, p);
    end
  end
end

require_relative 'zlib_ext'
require_relative 'zlib/deflate'
