# frozen_string_literal: true

require 'optparse'

def main
  param = {
    all_file: false,
    reverse: false,
    long_info: false
  }
  file_data = make_list(optparse(param))
  puts file_data
end

def optparse(param)
  opt = OptionParser.new
  opt.on('-a') { param[:all_file] = true }
  opt.on('-r') { param[:reverse] = true }
  opt.on('-l') { param[:long_info] = true }
  opt.parse!(ARGV)
  param
end

def make_list(param)
  result = generate_table(read_files(param)) if param[:long_info] == false
  result = make_long_info(read_files(param)) if param[:long_info] == true
  result
end

def read_files(param)
  list = []
  Dir.foreach('.') { |item| list << item }
  list.delete_if { |file| file[0] == '.' } if param[:all_file] == false # ファイル名の先頭が.ならリストから削除
  case param[:reverse]
  when true then list.sort.reverse
  when false then list.sort
  end
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
      "#{stat.uid.to_s.rjust(5)} ",   # ファイルによってはレイアウトが崩れるかもしれません
      "#{stat.gid.to_s.rjust(5)} ",
      "#{stat.size.to_s.rjust(9)} ",
      "#{stat.mtime} ",
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
