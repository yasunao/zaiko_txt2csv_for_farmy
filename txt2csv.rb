#! /usr/bin/ruby
Encoding.default_external = 'UTF-8'
require 'csv'
require 'date'
#headerメモ
#薬品ｺｰﾄﾞ	ﾖﾐｶﾞﾅ	種	薬品名	規格	メーカー	棚番	薬価	購入価	在庫数	調整量	単位	①薬価金額	②購入金額	①－②	販売会社	厚生省ｺｰﾄﾞ	JAN
execptions_hash = {
  "53259114S10201" => "エンシュア・Ｈ(缶250mL)",
  "53259109S10201" => "エンシュア・リキッド(缶250mL)",
  "52190016S10202" => "カリメート経口液２０％　２５ｇ(分包10包)"
}
execption_codes=execptions_hash.keys
exceptions=[]
now=DateTime.now
filename="在庫一覧_#{now.year}年#{now.month}月#{now.day}日_#{now.hour}時#{now.min}分.csv"
pwd=File.expand_path( __FILE__).split("/")
directory=pwd.slice(0..pwd.count-2).join("/")
Dir.chdir(directory) do
  CSV.open(filename, 'w:CP932:UTF-8') do |csv|
      File.open("在庫一覧.txt", mode = "rt:sjis:utf-8") do |file|
      i=0
      file.each_line do |line|
        line=line.chomp.scrub('?').split("\t")
        line.push("JAN")  if i==0
        i=i+1
        #csv << line if line[9]!="0"
        if execption_codes.include?(line[0]) then
          exceptions.push(execptions_hash[line[0]])
        else
          csv << line
          p line
        end
      end
    end
  end
end
puts "以下の薬は、ファーミーの在庫を、おくすり箱へアップロードしません。"
exceptions.each do |exception|
  puts "・#{exception}"
end
puts "1剤に2種類のフレーバーを混ぜで交付した場合は、必ず、お薬箱を手動で在庫調整してください。"
puts "-------------------------------------------"
puts "無事、ファイル変換に成功しました。何かキーを入力して下さい。ウインドウを閉じます"
STDIN.getc



