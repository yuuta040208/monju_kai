require 'open-uri'
require 'nokogiri'

namespace :orepro do
  desc '俺プロのランキングページからユーザリストを取得する'
  task :get_users, ['holding_date'] => :environment do |_task, args|
    holding_date = args[:holding_date]

    html = URI.open('https://orepro.netkeiba.com/ranking/api_get_season_ranking.html?page=2&limit=100').read
    doc = Nokogiri::HTML.parse(html)
    json = JSON.parse(doc)
    user_ids = json['ranking_list'].map { |v| v["sns_user_id"] }

    user_ids.each do |user_id|
      user = User.find_or_initialize_by(id: user_id)
      user.save!
      GetPredictIdsJob.perform_later(user.id, holding_date)
    end
  end

  desc 'netkeibaのトップページからレースリストを取得する'
  task :get_races, ['holding_date'] => :environment do |_task, args|
    holding_date = args[:holding_date]

    html = URI.open("https://race.netkeiba.com/top/race_list_sub.html?kaisai_date=#{holding_date}").read
    doc = Nokogiri::HTML.parse(html)

    races = doc.css('dl.RaceList_DataList').map do |hold_element|
      race_place = hold_element.css('p.RaceList_DataTitle').text.strip.split(' ')[1]

      hold_element.css('li.RaceList_DataItem').map do |element|
        race_id = element.at_css('a').attr('href').delete('^0-9')
        race_number = element.at_css('div.Race_Num').text.strip.to_i
        race_name = element.at_css('div.RaceList_ItemTitle').text.strip

        Race.new(
          id: race_id,
          number: race_number,
          name: race_name,
          place: race_place,
          date: Date.parse(holding_date)
        )
      end
    end.flatten

    # 最大でも36レコードなのでbulk_insertは必要ないと判断
    races.each(&:save!)
  end
end
