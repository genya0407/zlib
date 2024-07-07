require_relative './lib/zlib'
require 'securerandom'
require 'benchmark/ips'

def do_benchmark(target_method: nil)
  methods = [
    { method: :adler32, args: [SecureRandom.bytes(4096)] },
    { method: :adler32_combine, args: [Zlib.adler32(SecureRandom.bytes(4096)), Zlib.adler32(SecureRandom.bytes(4096)), 4092 * 2] },
    { method: :crc32, args: [SecureRandom.bytes(4096)] },
    { method: :crc32_combine, args: [Zlib.adler32(SecureRandom.bytes(4096)), Zlib.adler32(SecureRandom.bytes(4096)), 4092 * 2] },
  ]
  if target_method
    methods = methods.select { |method| method[:method] == target_method }
  end
  methods.each do |matrix|
    pure_method = matrix[:method]
    ext_method = "#{matrix[:method]}_ext".to_sym

    puts "===== starts #{matrix[:method]} ====="
    Benchmark.ips do |x|
      x.time = 5
      x.warmup = 2

      [pure_method, ext_method].each do |method|
        x.report(method) do |times|
          while times > 0
            Zlib.public_send(method, *matrix[:args])
            times -= 1
          end
        end
      end
      x.compare!
    end
    puts "===== finishes #{matrix[:method]} ====="
  end
end
