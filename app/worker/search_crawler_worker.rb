class SearchCrawlerWorker
  include Sidekiq::Worker

  def perform(user_id, keyword)
    user = user_by(user_id)
    return unless user.present? && keyword.present?

    break_time = rand(0.3..1.0) * 100
    expire_time = break_time * 2

    RedisMutex.with_lock(:google_search, expire: expire_time) do
      perform_service_and_sleep(user, keyword, break_time)
    end
  rescue RedisMutex::LockError
    SearchCrawlerWorker.perform_async(user_id, keyword)
  end

  private

  def user_by(user_id)
    User.find_by(id: user_id)
  end

  def perform_service_and_sleep(user, keyword, initial_break_time)
    start_time = Time.now
    GoogleScraperService.new(user, keyword).execute
    end_time = Time.now
    sleep(initial_break_time - (end_time - start_time) - 1)
  end
end
