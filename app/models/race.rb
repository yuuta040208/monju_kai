class Race < ApplicationRecord
  has_many :predicts, dependent: :destroy
  has_many :odds, dependent: :destroy

  def prediction_ratio
    query = <<~"SQL"
      with tmp1 as (
        select
            max(orepro_predict_id) as predict_id,
            max(horse) as horse,
            mark,
            count(mark) as mark_count
        from predicts
        where race_id = '#{id}'
        group by user_id, race_id, mark
      ), tmp2 as (
        select
            predict_id,
            horse,
            case mark
              when 'honmeis' then 40
              when 'taikous' then 30
              when 'tananas' then 20
              else 10 / mark_count end as point
        from tmp1
      )
      select horse, sum(point) as point
      from tmp2
      group by horse
    SQL

    points = ActiveRecord::Base.connection.select_all(query).rows
    sum = points.map { |_, point| point }.sum
    points.map { |horse, point| [horse, (point / sum)] }
  end

  def odds_ratio
    odds.pluck(:horse, :value).map { |(horse, value)| [horse, 1 / value] }
  end

  def my_predicts
    prediction_ratios = prediction_ratio
    odds_ratio.map do |o_horse, o_ratio|
      _, target_ratio = prediction_ratios.detect { |horse, _| horse == o_horse }
      value = if target_ratio.present? && odds_ratio.present?
                Math.log(o_ratio) / Math.log(target_ratio)
              else
                0
              end
      [o_horse, value]
    end.sort_by { |_, ratio| ratio }.reverse
  end
end
