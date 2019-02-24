#!/usr/bin/env ruby

# toy to practice using Ruby to access system resources

require 'open3'

def get_cpu(holder)
  File.open("/proc/cpuinfo") do |file|
    file.readlines.each do |field|
      if field.start_with?("model name")
        holder[:cpu] = field.split(":")[1].lstrip
        break
      end
    end
  end 
end

def get_env(holder)
  env = ENV.to_h

  holder[:terminal] = env["TERM"]
  holder[:shell] = env["SHELL"]
  holder[:desktop] = env["XDG_SESSION_DESKTOP"]
end

def get_mem(holder)
  raw, status = Open3.capture2("free -h")
  holder[:mem_avail], holder[:mem_used] = raw.scan(/\d+\.?\d*[gmkbi]+/i)[0..1]
end

def get_uname(holder)
  raw, status = Open3.capture2("uname -a")
  holder[:host], holder[:kernel], holder[:distro] = raw.split(/\s+/).slice(1..3)
end

DATA = {}

get_env(DATA)
get_mem(DATA)
get_cpu(DATA)
get_uname(DATA)

DATA.each { |k, v| puts "#{k.to_s}: #{v}" }
