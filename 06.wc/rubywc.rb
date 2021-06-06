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
  {
    lines: text.count("\n"),
    words: text.split(/\s+/).delete_if(&:empty?).count,
    size: text.size
  }
end

def main
  if ARGV.any?
    analyze_file(ARGV)
  elsif FileTest.pipe?($stdin)
    analyze_argv($stdin.read)
  else
    analyze_input
  end
end

main
