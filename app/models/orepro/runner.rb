# frozen_string_literal: true

require 'open-uri'
require 'nokogiri'

class Orepro::Runner
  def self.get_races(holding_date)
    html = URI.open("https://race.netkeiba.com/top/race_list_sub.html?kaisai_date=#{holding_date}").read
    doc = Nokogiri::HTML.parse(html)

    races = doc.css('dl.RaceList_DataList').map do |hold_element|
      race_place = hold_element.css('p.RaceList_DataTitle').text.strip.split(' ')[1]

      hold_element.css('li.RaceList_DataItem').map do |element|
        race_id = element.at_css('a').attr('href').delete('^0-9')
        race_number = element.at_css('div.Race_Num').text.strip.to_i
        race_name = element.at_css('div.RaceList_ItemTitle').text.strip

        Race.find_or_initialize_by(
          id: race_id,
          number: race_number,
          name: race_name,
          place: race_place,
          date: Date.parse(holding_date)
        )
      end
    end.flatten

    races
  end

  def self.get_users(limit)
    html = URI.open("https://orepro.netkeiba.com/ranking/api_get_season_ranking.html?page=1&limit=#{limit}").read
    doc = Nokogiri::HTML.parse(html)
    json = JSON.parse(doc)
    user_ids = json['ranking_list'].map { |v| v["sns_user_id"] }

    users = user_ids.map do |user_id|
      User.find_or_initialize_by(id: user_id)
    end

    users
  end

  def self.get_odds(race_id)
    session = Orepro::Session.new

    session.visit("https://race.netkeiba.com/odds/index.html?race_id=#{race_id}&rf=race_submenu")
    doc = Nokogiri::HTML.parse(session.html)
    odds = doc.css('table#Ninki tr[id^="ninki-data"]').map do |element|
      td_elements = element.css('td')
      horse_number = td_elements[2].text
      horse_name = td_elements[4].text
      win_value = td_elements[5].text.to_f

      odd = Odd.find_or_initialize_by(
        race_id: race_id,
        horse: "#{horse_number}#{horse_name}",
      )
      odd.value = win_value

      odd
    end

    odds
  end

  def self.post_prediction(email:, password:, race_id:, honmei:, taikou:, tanana:, renkas:, double: false)
    session = Orepro::Session.login(email: email, password: password)

    Orepro::Command.visit_race_page(session, race_id)
    Orepro::Command.select_kaime_mode(session)
    Orepro::Command.select_renkas(session, renkas) if renkas.present?
    Orepro::Command.select_tanana(session, tanana) if tanana.present?
    Orepro::Command.select_taikou(session, taikou) if taikou.present?
    Orepro::Command.select_honmei(session, honmei)
    Orepro::Command.enable_twice_mode(session) if double

    Orepro::Command.submit(session, race_id)

    sleep(5)

    Orepro::Command..take_full_page_screenshot(session, race_id)
  end
end
