class CrawlerWorker
  include Sidekiq::Worker

  def perform(keyword)
    GoogleScraperService.new(keyword).execute
  end
end
