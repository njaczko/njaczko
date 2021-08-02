#! /usr/bin/env ruby
# frozen_string_literal: true

class ErrInvalidLogFile < StandardError
end

class ErrNotTimeLogLine < StandardError
end

def main
  path_to_log_file = ENV['VIM_STARTUP_LOG_FILE']
  unless path_to_log_file
    puts 'VIM_STARTUP_LOG_FILE env var is required. This script should be called by the time-vim-startup wrapper script?'
    return
  end
  parsed_log = StartupLog.new(path_to_log_file)

  if ARGV.include? '--time-only'
    puts "#{parsed_log.total_startup_time}ms"
    return
  end

  puts "Total Startup Time (ms): #{parsed_log.total_startup_time}"
  puts 'Most expensive:'
  parsed_log.most_expensive.each do |l|
    puts "(#{l.elapsed}ms) #{l.description}"
  end

rescue ErrInvalidLogFile => e
  puts e.message
end

# StartupLog represents a parsed nvim --startuptime log file. non-time lines
# are ignored
class StartupLog
  attr_accessor :total_startup_time, :most_expensive

  def initialize(path_to_startup_log_file, num_most_expensive: 15)
    raw_log_lines = File.read(path_to_startup_log_file).split("\n")
    all_log_lines = raw_log_lines.map do |raw_log_line|
      begin
        StartupLogLine.new(raw_log_line)
      rescue ErrNotTimeLogLine
      end
    end
    @log_lines = all_log_lines.filter { |l| !l.nil? }
    @total_startup_time = @log_lines[-1].clock
    @most_expensive = @log_lines.sort_by(&:elapsed).reverse[0..num_most_expensive - 1]
  rescue Errno::ENOENT
    raise ErrInvalidLogFile, "Log file does not exist: #{path_to_startup_log_file}"
  end
end

# StartupLogLine represents one parsed time-related line from a nvim
# --startuptime log file.
class StartupLogLine
  attr_accessor :clock, :elapsed, :description

  def initialize(log_line_string)
    components = log_line_string.split(' ')
    raise ErrNotTimeLogLine if components[0].to_f == 0.0

    @clock = components[0].to_f
    @elapsed = components[1].to_f
    @description = components[2..-1].join(' ')
  end
end

main
