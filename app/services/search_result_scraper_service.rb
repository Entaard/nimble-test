class SearchResultScraperService
  def initialize(result_item, result_url)
    @result_item = result_item
    @result_url = result_url
  end

  def execute
    open_browser(@result_url)
    save_html
  ensure
    close_browser
  end

  private

  def open_browser(url)
    @chrome = Watir::Browser.start(url, :chrome, headless: true)
  end

  def save_html
    html = @chrome.html

    if @result_url.include?('webcache.googleusercontent.com')
      @result_item.cached_html = html
    else
      @result_item.live_html = html
    end
    @result_item.save
  end

  def close_browser
    @chrome && @chrome.close
  end
end
