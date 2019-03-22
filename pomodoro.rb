#! /usr/bin/env ruby

# TODO:
#   *** fix tag list acquisition
#   add error handling to `run_timer`
#   refactor `validate`: extract STDERR messages to hsh
#   add help option
#   implement option to watch `timew` (approximates a running timer)
#     - would this require forking?
#     - maybe spawn process, keep its pid and kill at end?

require 'open3'

class Pomodoro
  attr_reader :options, :valid_tags
  SECONDS_PER_POMODORO = 25 * 60
  DEFAULTS = { duration: 1, stop_timer: false }.freeze

  def initialize(opts)
    @valid_tags = extract_tags
    @options = extract_options(opts)
  end

  def run_timer
    system("timew start #{options[:task]} > /dev/null")
    system("notify-send 'Timer initiated for #{options[:task]}'")

    sleep(options[:duration] * SECONDS_PER_POMODORO)

    if options[:stop_timer]
      system("timew stop > /dev/null")
      system("notify-send -u critical -t 5000 'Timer stopped'")
    else
      system("notify-send -u critical -t 60000 'Pomodoros completed; Timer still running!'")
    end

    exit(0)
  end

  private
  def extract_tags
    Open3.capture2("timew tags")[0]
      .sub(/\n.+\n.+\n/, "") # remove header line
      .split(/\n+/)
      .map { |full_tag| full_tag.split[0] }
  end

  def extract_options(opts)
    options = DEFAULTS.dup

    opts.each_with_index do |opt, idx|
      if opt.eql?('-t')
        options[:task] = opts[idx + 1]
      elsif opt.eql?('-p')
        options[:duration] = opts[idx + 1].to_i
      elsif opt.eql?('-s')
        options[:stop_timer] = true
      end
    end

    validate(options)
  end

  def validate(opts)
    if !opts[:task]
      STDERR.puts("ERROR: value -t (task) must be present")
      exit(1)
    elsif !valid_tags.include?(opts[:task])
      STDERR.puts("ERROR: value of -t (task) must be existing tag")
      exit(1)
    elsif opts[:duration].to_s.match?(/[^123]/)
      STDERR.puts("ERROR: value of -p (pomodoros) must be 1, 2 or 3")
      exit(1)
    end

    opts
  end
end

Pomodoro.new(ARGV).run_timer
