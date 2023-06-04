# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

```
select
    concat(substring(horse, '\d+'), '.', substring(horse, '\D+')),
    case mark
        when 'honmeis' then '◎'
        when 'taikous' then '○'
        when 'tananas' then '▲'
        else '△' end as 印,
    count(id)
from
    predicts
where
    race_id = '202305021211'
group by
    race_id,
    mark,
    horse
order by
    cast(substring(horse, '\d+') as int),
    case mark
        when 'honmeis' then 0
        when 'taikous' then 1
        when 'tananas' then 2
        else 3 end
```

```
with tmp1 as (
    select
        max(orepro_predict_id) as predict_id,
        max(horse) as horse,
        mark,
        count(mark) as mark_count
    from
        predicts
    where
        race_id = '202308011212'
    group by
        user_id,
        race_id,
        mark
), tmp2 as (
    select
        predict_id,
        horse,
    case mark
        when 'honmeis' then 40
        when 'taikous' then 30
        when 'tananas' then 20
        else 10 / mark_count end as point
    from
        tmp1
)
select
    concat(substring(horse, '\d+'), '.', substring(horse, '\D+')),
    sum(point)
from
     tmp2
group by
    horse
order by
    cast(substring(horse, '\d+') as int)
```