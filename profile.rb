require_relative './lib/zlib'
require 'securerandom'
require 'ruby-prof'

str = SecureRandom.bytes(4096)
n = 10000
while n > 0
  Zlib.crc32(str)
  n -= 1
end

result = RubyProf::Profile.profile do
  n = 1000
  while n > 0
    Zlib.crc32(str)
    n -= 1
  end
end
printer = RubyProf::GraphHtmlPrinter.new(result)
File.open('tmp/profile.html', 'w') do |f|
  printer.print(f, min_percent: 0)
end
