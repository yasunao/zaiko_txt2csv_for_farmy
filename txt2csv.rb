#! /usr/bin/ruby
Encoding.default_external = 'UTF-8'
require 'csv'
require 'date'
class Pharmy2Epark
  def initialize
    #pharmy_text_headerメモ
    #薬品ｺｰﾄﾞ	ﾖﾐｶﾞﾅ	種	薬品名	規格	メーカー	棚番	薬価	購入価	
    #在庫数	調整量	単位	①薬価金額	②購入金額	①－②	販売会社	厚生省ｺｰﾄﾞ	JAN
    set_exceptions #private_method
    @order_points=get_order_points_from_csv#private_method
    @orders=[]
    now=DateTime.now
    @zaiko_csv_filename="在庫一覧_#{now.year}年#{now.month}月#{now.day}日_#{now.hour}時#{now.min}分.csv"
    @order_txt_filename="発注予定.txt"
    pwd=File.expand_path( __FILE__).split("/")
    @directory=pwd.slice(0..pwd.count-2).join("/")
    @i=0
  end
  def create_order_csv
    i=0
    jans=@order_points.keys
    header=["JAN","薬品名","棚番","在庫数","発注点","不足"]
    Dir.chdir(@directory) do
      CSV.open(@order_txt_filename, 'w:CP932:UTF-8') do |csv|
        csv << header
        File.open("在庫一覧.txt", mode = "rt:sjis:utf-8") do |file|
          file.each_line do |line|
            line=line.chomp.scrub('?').split("\t")
            line.push("JAN")  if i==0 #headerに追加
            line_17_jan=line[17].nil? ? [] : line[17].split(";")
            jan=(jans & line_17_jan)[0]
            if jan!=nil then
              order_point=@order_points[jan][:order_point]
              order=[line[17],line[3],line[6],line[9],order_point,line[9].to_i-order_point]
              @orders.push(order)
              i+=1
              csv << order
              p order
            end
          end
        end
      end
    end
    return true
  end
  def create_order_txt
    i=0
    jans=@order_points.keys
    now=DateTime.now
    title="＜＜＜発注予定表＞＞＞＞　作成日時：#{now.year}年#{now.month}月#{now.day}日_#{now.hour}時#{now.min}分"+ "\n"
    header="| "+["JAN".ljust(15),"stock".ljust(5),"point".ljust(5),"husoku".ljust(6),"薬品名 場所"].join(" | ") + "\n"
    Dir.chdir(@directory) do
      File.open(@order_txt_filename, mode = "w") do |output_file|
        output_file.write(title)
        output_file.write(header)
        File.open("在庫一覧.txt", mode = "rt:sjis:utf-8") do |file|
          file.each_line do |line|
            line=line.chomp.scrub('?').split("\t")
            line_17_jan=line[17].nil? ? [] : line[17].split(";")
            jan=(jans & line_17_jan)[0]
            if jan!=nil then
              order_point=@order_points[jan][:order_point]
              #order=[line[17],line[3],line[6],line[9],order_point,line[9].to_i-order_point]
              order="| #{line[17].ljust(15)} | #{line[9].ljust(5)} | #{order_point.to_s.ljust(5)} | #{(line[9].to_i-order_point).to_s.ljust(6)} |#{line[3]}、#{line[6]}"
              @orders.push(order)
              i+=1
              output_file.write("#{order.to_s}")  # ファイルに書き込む
            end
          end
        end
      end
    end
    return true
  end
  def create_zaiko_csv
    Dir.chdir(@directory) do
      CSV.open(@zaiko_csv_filename, 'w:CP932:UTF-8') do |csv|
        File.open("在庫一覧.txt", mode = "rt:sjis:utf-8") do |file|
          file.each_line do |line|
            line=line.chomp.scrub('?').split("\t")
            line.push("JAN")  if @i==0 #headerに追加
            #csv << line if line[9]!="0"
            if @execption_codes.include?(line[0]) then
              @exceptions.push(@execptions_hash[line[0]])
            else
              csv << line
              @i+=1
              p "#{(@i)}#{line}"
            end
          end
        end
      end
    end
    return true
  end
  
  def puts_messages_on_console
    puts "以下の薬は、ファーミーの在庫を、おくすり箱へアップロードしません。"
    @exceptions.each do |exception|
      puts "・#{exception}"
    end
    puts "1剤に2種類のフレーバーを混ぜで交付した場合は、必ず、お薬箱を手動で在庫調整してください。"
    puts "-------------------------------------------"
    puts "品目数：#{@i-1}品目"
    puts "無事、ファイル変換に成功しました。何かキーを入力して下さい。ウインドウを閉じます"
    STDIN.getc
  end
  def open_order_txt
    begin
      Dir.chdir(@directory) do
        exec("発注予定.txt")
      end
    rescue
      Dir.chdir(@directory) do
        exec("open 発注予定.txt")
      end
    end
  end
  private
  def set_exceptions
    @execptions_hash = {
      "53259114S10201" => "エンシュア・Ｈ(缶250mL)",
      "53259109S10201" => "エンシュア・リキッド(缶250mL)",
      "52190016S10202" => "カリメート経口液２０％　２５ｇ(分包10包)"
    }
    @execption_codes=@execptions_hash.keys
    @exceptions=[]
  end
  def get_order_points_from_csv
    order_points={}
    pwd=File.expand_path( __FILE__).split("/")
    directory=pwd.slice(0..pwd.count-2).join("/")
    i=-1
    Dir.chdir(directory) do
      File.open("発注点設定ファイル.csv", mode = "rt:sjis:utf-8") do |file|
        file.each_line do |line|
          i+=1
          next if i==0
          name,order_point,jans=line.chomp.scrub('?').split(",")
          jan=jans.split(";")[0]
          order_point=order_point.to_i
          order_points[jan]={name: name, order_point: order_point,jan: jan}
        end
      end
    end
    return order_points
  end
  
end
class String
  def mb_ljust(width, padding='')
    #widthは全角サイズのワイド
    rails RuntimeError.new("padding_char must be 1 bytesize.") if padding.bytesize==2
    self_size = each_char.map{|c| c.bytesize == 1 ? 1 : 2}.sum
    padding_size = [0, width*2 - self_size].max
    self + padding * padding_size
  end
end

pharmy2epark=Pharmy2Epark.new()
pharmy2epark.create_order_csv
pharmy2epark.create_order_txt
pharmy2epark.create_zaiko_csv
pharmy2epark.puts_messages_on_console
pharmy2epark.open_order_txt




