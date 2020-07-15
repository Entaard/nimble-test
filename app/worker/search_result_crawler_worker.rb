class SearchResultCrawlerWorker
  include Sidekiq::Worker

  def perform(result_item_id, result_url)
    result_item = result_item_by(result_item_id)
    return unless result_item.present? && result_url.present?

    break_time = rand(0.3..1.0) * 100
    expire_time = break_time * 2

    RedisMutex.with_lock(uri_host(result_url), expire: expire_time) do
      perform_service_and_sleep(result_item, result_url, break_time)
    end
  rescue RedisMutex::LockError
    SearchResultCrawlerWorker.perform_async(result_item_id, result_url)
  end

  private

  def result_item_by(result_item_id)
    ResultItem.find_by(id: result_item_id)
  end

  def uri_host(url)
    uri = URI(url)
    uri.host
  end

  def perform_service_and_sleep(result_item, result_url, initial_break_time)
    start_time = Time.now
    SearchResultScraperService.new(result_item, result_url).execute
    end_time = Time.now
    sleep(initial_break_time - (end_time - start_time) - 1)
  end
end
