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
    @orders={}
    now=DateTime.now
    @zaiko_csv_filename="在庫一覧_#{now.year}年#{now.month}月#{now.day}日_#{now.hour}時#{now.min}分.csv"
    @order_txt_filename="発注予定.txt"
    pwd=File.expand_path( __FILE__).split("/")
    @directory=pwd.slice(0..pwd.count-2).join("/")
    @i=0
  end
  def create_order_txt
    i=0
    jans=@order_points.keys
    Dir.chdir(@directory) do
      File.open(@order_txt_filename, mode = "w") do |output_file|
        File.open("在庫一覧.txt", mode = "rt:sjis:utf-8") do |file|
          file.each_line do |line|
            line=line.chomp.scrub('?').split("\t")
            line_17_jan=line[17].nil? ? [] : line[17].split(";")
            jan=(jans & line_17_jan)[0]
            if jan!=nil then
              order_point=@order_points[jan][:order_point]
              to_be=((order_point.to_f-line[9].to_f)/@order_points[jan][:package].to_f).ceil.to_i
              next if (to_be)<=0
              order_package=@order_points[jan][:package].to_s+@order_points[jan][:unit].to_s+"*"+to_be.to_s
              order="| #{line[17].ljust(15)} | #{line[9].ljust(5)} | #{order_point.to_s.ljust(5)} | #{(order_package).to_s.ljust(6)} |#{line[3]}、#{line[6]}"+ "\n"
              @orders[@order_points[jan][:tonya]]=[] if @orders[@order_points[jan][:tonya]].nil?
              @orders[@order_points[jan][:tonya]].push(order)
              i+=1
            end
          end
          # ファイルに書き込む
          now=DateTime.now
          title="＜＜＜発注予定表＞＞＞＞　作成日時：#{now.year}年#{now.month}月#{now.day}日_#{now.hour}時#{now.min}分"+ "\n"
          header="| "+["JAN".ljust(15),"stock".ljust(5),"point".ljust(5),"発注".ljust(6),"薬品名 場所"].join(" | ") + "\n"
          output_file.write("発注予定品目はありません") if i==0
          @orders.each do |tonya,orders|
            output_file.write(title)
            output_file.write(tonya+ "御中\n")
            output_file.write(header)
            orders.each do |order|
              output_file.write("#{order.to_s}")
            end
            output_file.write("---------------------------------------------------------------------------"+"\n")
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
          header=[]
          file.each_line do |line|
            line=line.chomp.scrub('?').split("\t")
            if @i==0 then
              line.push("JAN")    #headerに追加
              header=line
            end
            if @execption_codes.include?(line[0]) then
              @exceptions.push(@execptions_hash[line[0]])
            else
              if @i!=0 then#複数のJANを一つに絞る
                next if line.count==0
                line.push("") if line.count==17
                jans=line.pop.split(";").select{|jan|!jan.empty?}
                jan=jans.first
                jan="" if jans==""
                line.push(jan)
              end
              next if line.count==1
              hash = Hash[*[header,line].transpose.flatten]
              @exceptions.push(hash["薬品名"]) if hash["JAN"]==""
              csv << ["JAN","在庫数","薬品名","棚番"].map{|key|hash[key]} if hash["JAN"]!=""
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
        exec("notepad 発注予定.txt")
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
      "61259700Q10201" => "エクロックゲル5％(本20g)"
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
      #薬品名,問屋,発注点,発注包装,JAN;）
      File.open("発注点設定ファイル.csv", mode = "rt:sjis:utf-8") do |file|
        file.each_line do |line|
          i+=1
          next if i==0
          name,tonya,order_point,unit,package,jans=line.chomp.scrub('?').split(",")
          jan=jans.split(";")[0]
          order_point=order_point.to_i
          order_points[jan]={name: name,tonya: tonya, order_point: order_point,unit: unit,package: package,jan: jan}
        end
      end
    end
    return order_points
  end
  
end

pharmy2epark=Pharmy2Epark.new()
pharmy2epark.create_order_txt
pharmy2epark.create_zaiko_csv
pharmy2epark.puts_messages_on_console
pharmy2epark.open_order_txt




