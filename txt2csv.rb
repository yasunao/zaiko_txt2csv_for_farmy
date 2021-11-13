#! /usr/bin/ruby
require 'csv'
require 'date'

now=DateTime.now
filename="在庫一覧_#{now.year}#{now.month}#{now.day}_#{now.hour}_#{now.min}.csv"
pwd=File.expand_path( __FILE__).split("/")
directory=pwd.slice(0..pwd.count-2).join("/")
Dir.chdir(directory) do
  CSV.open(filename, 'w:CP932:UTF-8') do |csv|
    open("在庫一覧.txt", "r:CP932:UTF-8") { |io|
      i=0
      io.read.split("\n").each do |line|
        line=line.chomp.split("\t")
        line.push("JAN")  if i==0
        i=i+1
        csv << line
      end
    }
  end
end 



