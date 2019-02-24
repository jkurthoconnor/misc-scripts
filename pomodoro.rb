#! /usr/bin/env ruby

# TODO:
#   add error handling to `run_timer`
#   refactor `validate`: extract STDERR messages to hsh
#   add help option
#   implement option to watch `timew` (approximates a running timer)
#     - would this require forking?
#     - maybe spawn process, keep its pid and kill at end?

require 'open3'

class Pomodoro
  attr_reader :options, :valid_tags
  SECONDS_PER_POMODORO = 1 * 60

  def initialize(opts)
    @valid_tags = extract_tags
    @options = extract_options(opts)
  end

  def run_timer
    system("timew start #{options[:task]} > /dev/null")
    system("notify-send 'Timer initiated for #{options[:task]}'")

    # pid = Process.spawn('watch timew')
    # Process.detach(pid)
    
    sleep(options[:duration] * SECONDS_PER_POMODORO)

    if options[:stop_timer]
      system("timew stop > /dev/null")
      system("notify-send -u critical -t 5000 'Timer stopped'")
    else
      system("notify-send -u critical -t 60000 'Pomodoros completed'")
    end

    # Process.kill("EXIT", pid)

    exit(0)
  end

  private
  def extract_tags
    Open3.capture2("timew tags")[0]
      .gsub(/\n.+\n.+\n/, "")
      .split(/\s+-\n+/)
  end

  def extract_options(opts)
    options = {}
    idx = 0

    while idx < opts.length
      opt = opts[idx]

      if opt.eql?('-t')
        options[:task] = opts[idx + 1]
        idx += 1
      elsif opt.eql?('-p')
        options[:duration] = opts[idx + 1].to_i
        idx += 1
      elsif opt.eql?('-s')
        options[:stop_timer] = true
      end

      idx += 1
    end

    validate(options)
  end

  def validate(opts)
    if !opts[:task]
      STDERR.puts("ERROR: value -t (task) must be present")
      exit(127)
    elsif !valid_tags.include?(opts[:task])
      STDERR.puts("ERROR: value of -t (task) must be existing tag")
      exit(127)
    elsif opts[:duration].to_s.match?(/[^123]/)
      STDERR.puts("ERROR: value of -p (pomodoros) must be 1, 2 or 3")
      exit(127)
    end

    opts
  end
end

Pomodoro.new(ARGF.argv).run_timer