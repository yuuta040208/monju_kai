# frozen_string_literal: true

class Orepro::Command
  def self.visit_race_page(session, race_id)
    url = "https://orepro.netkeiba.com/bet/shutuba.html?mode=init&race_id=#{race_id}"
    session.visit(url)
  end

  def self.select_kantan_mode(session)
    session.find(:xpath, '/html/body/div[1]/div[3]/div/div[8]/div/ul/li[2]').click
  end

  def self.select_kaime_mode(session)
    session.find(:xpath, '/html/body/div[1]/div[3]/div/div[8]/div/ul/li[4]').click
  end

  def self.enable_twice_mode(session)
    session.find(:xpath, '/html/body/div[1]/div[3]/div/div[6]/div/div[1]/label').click
  end

  def self.select_honmei(session, number)
    session.find(:xpath, "/html/body/div[1]/div[3]/div/div[5]/div[1]/table/tbody/tr[#{number + 1}]/td[2]/ul/li[1]").click
  end

  def self.select_taikou(session, number)
    session.find(:xpath, "/html/body/div[1]/div[3]/div/div[5]/div[1]/table/tbody/tr[#{number + 1}]/td[2]/ul/li[2]").click
  end

  def self.select_tanana(session, number)
    session.find(:xpath, "/html/body/div[1]/div[3]/div/div[5]/div[1]/table/tbody/tr[#{number + 1}]/td[2]/ul/li[3]").click
  end

  def self.select_renkas(session, numbers = [])
    numbers.each do |number|
      session.find(:xpath, "/html/body/div[1]/div[3]/div/div[5]/div[1]/table/tbody/tr[#{number + 1}]/td[2]/ul/li[4]").click
    end
  end

  def self.submit(session, race_id)
    session.find(:xpath, "//*[@id=\"act-bet_#{race_id}\"]").click
  end

  def take_full_page_screenshot(session, race_id)
    width = session.page.execute_script("return Math.max(document.body.scrollWidth, document.body.offsetWidth, document.documentElement.clientWidth, document.documentElement.scrollWidth, document.documentElement.offsetWidth);")
    height = session.page.execute_script("return Math.max(document.body.scrollHeight, document.body.offsetHeight, document.documentElement.clientHeight, document.documentElement.scrollHeight, document.documentElement.offsetHeight);")

    window = session.page.driver.browser.manage.window
    window.resize_to(width + 100, height + 100)

    path = File.join(today, "#{race_id.to_s}.png")
    Dir.mkdir(today) unless Dir.exist?(today)

    session.save_screenshot(path)
  end

  private

  def today
    (Time.current + 9.hours).strftime('%Y%m%d')
  end
end