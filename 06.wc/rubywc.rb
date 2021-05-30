# frozen_string_literal: true

def analyze_input
  text = readlines
  elements = count_element(text.join)
  puts "#{elements[:lines].to_s.rjust(8)}#{elements[:words].to_s.rjust(8)}#{elements[:size].to_s.rjust(8)}"
end

def analyze_file(files)
  total_line = 0
  total_words = 0
  total_size = 0
  files.each do |filename|
    file = File.open(filename)
    text = file.read
    elements = count_element(text)
    puts "#{elements[:lines].to_s.rjust(8)}#{elements[:words].to_s.rjust(8)}#{elements[:size].to_s.rjust(8)} #{filename}"
    next if files.length == 1

    total_line += elements[:lines]
    total_words += elements[:words]
    total_size += elements[:size]
  end
  puts "#{total_line.to_s.rjust(8)}#{total_words.to_s.rjust(8)}#{total_size.to_s.rjust(8)} total" if files.length >= 2
end

def analyze_argv(text)
  num = count_element(text)
  puts "#{num[:lines].to_s.rjust(8)}#{num[:words].to_s.rjust(8)}#{num[:size].to_s.rjust(8)}"
end

def count_element(text)
  elements = {}
  elements[:lines] = text.count("\n")
  elements[:words] = text.split(/\s+/).delete_if(&:empty?).count
  elements[:size] = text.size
  elements
end

def main
  analyze_input if ARGV.empty? && !FileTest.pipe?($stdin)
  analyze_file(ARGV) unless ARGV.empty?
  analyze_argv($stdin.read) if FileTest.pipe?($stdin)
end

main
