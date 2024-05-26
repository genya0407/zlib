require "bundler/gem_tasks"
require "rake/testtask"

desc "Run tests"
task :test do
  # Avoid possible test failures with the zlib applying the following patch on
  # s390x CPU architecture.
  # https://github.com/madler/zlib/pull/410
  ENV["DFLTCC"] = "0" if RUBY_PLATFORM =~ /s390x/
  Rake::Task["test_internal"].invoke
end

desc "benchmark"
task :benchmark do
  require 'benchmark'
  require 'securerandom'
  require_relative 'lib/zlib'

  RubyVM::YJIT.enable

  long_string = SecureRandom.bytes(10_000)
  Benchmark.bmbm do |x|
    x.report('C-ext') do
      i = 0
      while i < 1000
        Zlib.adler32(long_string)
        i += 1
      end
    end

    x.report('pure Ruby') do
      i = 0
      while i < 1000
        Zlib.adler32_pure(long_string)
        i += 1
      end
    end
  end
end

Rake::TestTask.new(:test_internal) do |t|
  t.libs << "test/lib"
  t.ruby_opts << "-rhelper"
  t.test_files = FileList["test/**/test_*.rb"]
end

require 'rake/extensiontask'
Rake::ExtensionTask.new("zlib_ext")

task :default => [:compile, :test]
