# frozen_string_literal: true

require 'optparse'
require 'etc'

def main
  file_data = make_list(optparse)
  puts file_data
end

def optparse
  opt = OptionParser.new
  param = {
    all_file: false,
    reverse: false,
    long_info: false
  }
  opt.on('-a') { param[:all_file] = true }
  opt.on('-r') { param[:reverse] = true }
  opt.on('-l') { param[:long_info] = true }
  opt.parse!(ARGV)
  param
end

def make_list(param)
  param[:long_info] ? make_long_info(read_files(param)) : generate_table(read_files(param))
end

def read_files(param)
  list = (param[:all_file] ? Dir.glob('*', File::FNM_DOTMATCH) : Dir.glob('*'))
  param[:reverse] ? list.sort.reverse : list.sort
end

def generate_table(list)
  max_column = 3 # 最大列数を指定
  low_num = (list.length - 1) / max_column + 1 # リストの数に合わせてちょうど良い行数を計算。
  column_num = (list.length + low_num - 1) / low_num # 行数から最大値を超えない範囲で列数を計算。
  low_unit = []
  sorted_list = []
  column_unit = list.each_slice(low_num).to_a # 列ごとに配列を分ける
  low_num.times do |l|
    unit = []
    column_num.times { |c| unit << column_unit[c][l] } # 列を順に取り出して行の塊にする
    low_unit << unit
  end
  low_unit.map do |unit|
    unit.delete(nil) # 配列の中あるnilを消す
    sorted_list << unit.map { |file| file.ljust(20) } # 適当な間隔をとる
  end
  sorted_list.map { |low| low << "\n" }.join # 改行を追加する
end

# -lオプションの表を生成する
def make_long_info(files)
  long_info_list = []
  files.map do |file|
    stat = File.stat(file)
    long_info_list = [
      filetype(stat),
      "#{permission(stat)} ",
      "#{stat.nlink.to_s.rjust(2)} ", # rjustの幅はざっくりです
      "#{user(stat).rjust(6)} ",   # ファイルによってはレイアウトが崩れるかもしれません
      "#{group(stat).rjust(5)} ",
      "#{stat.size.to_s.rjust(7)} ",
      "#{time(stat)} ",
      file
    ].join
  end
end

def filetype(stat)
  if stat.ftype == 'file'
    '-'
  else
    stat.ftype[0]
  end
end

def permission(stat)
  filemode = format('0%o', stat.mode)
  result = [
    trance_rwx(filemode.to_s[-3]),
    trance_rwx(filemode.to_s[-2]),
    trance_rwx(filemode.to_s[-1])
  ]
  result.join
end

def user(stat)
  p Etc.getpwuid(stat.uid)
  Etc.getpwuid(stat.uid).to_s.scan(/Passwd name="(.+)", passwd/).join
end

def group(stat)
  Etc.getgrgid(stat.gid).to_s.scan(/Group name="(.+)", passwd/).join
end

def time(stat)
  stat.mtime.strftime('%m %d %Y')
end

def trance_rwx(num)
  case num.to_i
  when 0 then '---'
  when 1 then '--x'
  when 2 then '-w-'
  when 3 then '-wx'
  when 4 then 'r--'
  when 5 then 'r-x'
  when 6 then 'rw-'
  when 7 then 'rwx'
  end
end

main
