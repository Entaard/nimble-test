class HardWorker
  include Sidekiq::Worker

  def perform
    p 'Hello sidekiq!!!'

    Selenium::WebDriver::Remote::Capabilities.chrome
    Selenium::WebDriver
    chrome = Watir::Browser.start('https://www.google.com/search?q=buy+helmet', :chrome, headless: true)
    str = chrome.div(id: 'result-stats').text
    p str

    p 'Bye sidekiq!!!'
  end
end
