# frozen_string_literal: true

require 'capybara'
require 'capybara/dsl'
require 'selenium-webdriver'

class Orepro::Session
  include Capybara::DSL

  Capybara.configure do |config|
    config.default_driver = :chrome
    config.javascript_driver = :chrome
    config.save_path = 'public'
  end

  class AuthenticationError < StandardError; end

  def self.login(email:, password:)
    top_page_url = 'https://www.netkeiba.com/'
    session = Orepro::Session.new

    session.visit(top_page_url)
    session.visit('https://regist.netkeiba.com/account/?pid=login')
    session.find(:xpath, '//*[@id="contents"]/div/form/div/ul/li[1]/input').set(email)
    session.find(:xpath, '//*[@id="contents"]/div/form/div/ul/li[2]/input').set(password)
    session.find(:xpath, '//*[@id="contents"]/div/form/div/div[1]/input').click

    raise AuthenticationError.new('ログインに失敗しました') if session.current_url != top_page_url

    session
  end

  def initialize
    Capybara.register_driver :chrome do |app|
      url = ENV.fetch('SELENIUM_DRIVER_URL')

      options = ::Selenium::WebDriver::Chrome::Options.new
      options.add_argument('--headless')
      options.add_argument('--no-sandbox')
      options.add_argument('--disable-gpu')
      options.add_argument('--disable-dev-shm-usage')
      options.add_argument('--window-size=1280,960')

      Capybara::Selenium::Driver.new(app, url: url, browser: :remote, options: options)
    end

    Capybara::Session.new(:chrome)
  end
end