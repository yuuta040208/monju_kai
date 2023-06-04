require 'open-uri'
require 'nokogiri'
require 'net/http'

class GetPredictIdsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    user_id, holding_date = args
    
    html = URI.open("https://race.netkeiba.com/top/race_list_sub.html?kaisai_date=#{holding_date}").read
    doc = Nokogiri::HTML.parse(html)
    
    holding_ids = doc.css('a.LinkHaraimodoshiichiran').map do |element|
      URI.decode_www_form(element.attr('href'))[0][1]
    end

    uri = URI.parse('https://orepro.netkeiba.com/api/api_get_goods_list.html')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme === "https"
    
    params = {
      'yosoka_id' => user_id,
      'search_date_tab' => holding_date,
      'kaisai_id[]' => holding_ids,
      'cond_type' => 'y'
    }
    
    req = Net::HTTP::Post.new(uri.path)
    req.set_form_data(params)
    
    response = http.request(req)

    # NokogiriがHTMLをうまくパースしてくれないので正規表現で抽出する
    strs = response.body.scan(/oreshow_\d+-\d+/)

    predict_ids = strs.map { |str| str.split('_')[1] }

    predict_ids.each do |predict_id|
      GetPredictDetailJob.perform_later(predict_id, user_id)
    end
  end
end
