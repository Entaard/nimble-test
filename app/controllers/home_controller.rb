class HomeController < ApplicationController
  def index
  end

  def upload
    keywords_params.each do |keyword|
      SearchCrawlerWorker.perform_async(current_user.id, keyword)
    end
  end

  private

  def keywords_params
    keywords_params = params.require(:keywords)
    keywords_params.compact.map! { |keyword| CGI.escape(keyword.strip) }
  end
end
