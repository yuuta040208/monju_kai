require 'open-uri'
require 'nokogiri'
require 'net/http'

class GetPredictDetailJob < ApplicationJob
  queue_as :default

  def perform(*args)
    predict_id, user_id = args

    p "https://orepro.netkeiba.com/mydata/yoso_detail.html?id=#{predict_id}"

    uri = URI.parse('https://orepro.netkeiba.com/mydata/yoso_detail.html')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme === "https"
    
    params = {
      'id' => predict_id
    }
    
    req = Net::HTTP::Post.new(uri.path)
    req.set_form_data(params)
    
    response = http.request(req)

    doc = Nokogiri::HTML.parse(response.body)

    is_private = !doc.at_css('p.YosoTxt01').present?
    if is_private
      p '非公開の予想です'
      return
    end

    race_date = Date.strptime(doc.at_css('p.YosoTxt01').text.split('(')[0], '%Y年%m月%d日')
    race_place, race_number, race_name = doc.at_css('p.YosoTxt02').text.scan(/(\D+)(\d{1,2}R)(.+)/)[0].map(&:strip)

    mark_dict = {
      Icon_Honmei: 'honmeis',
      Icon_Taikou: 'taikous',
      Icon_Kurosan: 'tananas',
      Icon_Osae: 'renkas',
    }

    predict_dict = {}
    doc.css('table.YosoShirushiTable01 tr').each do |element|
      mark_text = element.at_css('th > span').attr('class')
      horse_text = element.at_css('td').text.scan(/\d{1,2}[ァ-ヴー]+/)[0]

      mark_name = mark_text.split(' ')[1].to_sym
      exists = mark_dict.keys.include?(mark_name) ? predict_dict[mark_dict[mark_name]] : []
      predict_dict[mark_dict[mark_name]] = [*exists, horse_text]
    end

    race = Race.find_by(number: race_number.to_i, place: race_place, date: race_date)
    return unless race.present?

    p predict_dict

    predict_dict.each do |key, values|
      values.each do |value|
        predict = Predict.find_or_initialize_by(orepro_predict_id: predict_id, user_id: user_id, race_id: race.id, horse: value)
        predict.mark = key
        predict.save!
      end
    end
  end
end
