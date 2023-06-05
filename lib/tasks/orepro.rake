require 'open-uri'
require 'nokogiri'

namespace :orepro do
  desc 'netkeibaのトップページからレースリストを取得する'
  task :get_races, ['holding_date'] => :environment do |_task, args|
    # レース情報一覧を取得
    races = Orepro::Runner.get_races(args[:holding_date])

    # 最大でも36レコードなのでbulk_insertは必要ないと判断
    races.each(&:save!)
  end

  desc 'netkeibaのレースページから単勝オッズを取得する'
  task :get_win_odds, ['race_id'] => :environment do |_task, args|
    # レース情報が存在しない場合はエラー
    race = Race.find_by(id: args[:race_id])
    raise StandardError('指定された開催日のレース情報が存在しません') if race.blank?

    # オッズ情報を取得
    odds = Orepro::Runner.get_odds(race.id)

    # 多くても18件なのでbulk_insertは必要ないと判断
    odds.each(&:save!)
  end

  desc '俺プロのランキングページから予想リストを取得する'
  task :get_predicts, ['holding_date'] => :environment do |_task, args|
    # レース情報が存在しない場合はエラー
    race = Race.find_by(date: Date.parse(args[:holding_date]))
    raise StandardError('指定された開催日のレース情報が存在しません') if race.blank?

    # ユーザ情報一覧を取得
    users = Orepro::Runner.get_users(100)

    # 多くても100件程度なのでbulk_insertは必要ないと判断
    users.each(&:save!)

    # ユーザごとの予想を取得するジョブを実行
    users.each do |user|
      GetPredictIdsJob.perform_later(user.id, args[:holding_date])
    end
  end
end
