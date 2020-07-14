class GoogleScraperService
  GOOGLE_SEARCH_URL = 'https://www.google.com/search?hl=en&q='.freeze

  def initialize(keyword)
    @keyword = keyword
  end

  def execute
    open_browser

    extract_num_of_ads
    extract_num_of_links
    extract_total_search_results
    extract_search_results
  ensure
    close_browser
  end

  private

  def open_browser
    keyword_google_search = "#{GOOGLE_SEARCH_URL}#{@keyword}"
    @chrome = Watir::Browser.start(keyword_google_search, :chrome, headless: true)
  end

  def extract_num_of_ads
    num_of_ads = 0
    num_of_ads += @chrome.
      div(class: /commercial-unit-desktop/).
      divs(class: 'pla-unit').
      size
    num_of_ads += @chrome.
      div(id: 'taw').
      div(id: 'tads').
      lis(class: /ads/).
      size
  end

  def extract_num_of_links
    @chrome.links.size
  end

  def extract_total_search_results
    total_search_results_text = @chrome.div(id: 'result-stats').text
    regex = /([\d,?]+).+([\d]+\.[\d]+)/
    matches = total_search_results_text.match(regex)
    num_of_results = matches[1]
    search_time = matches[2]

    [num_of_results, search_time]
  end

  def extract_search_results
    search_result_urls = []

    search_results = @chrome.div(id: 'search').divs(class: 'g')
    search_results.each do |result|
      next if result.class_name != 'g' || result.links.size < 3

      anchors = result.links
      live_url = anchors.first.href
      cached_anchor = anchors.detect do |anchor|
        anchor.href.include?('webcache.googleusercontent.com')
      end
      cached_url = cached_anchor ? cached_anchor.href : ''

      search_result_urls << [live_url, cached_url]
    end

    search_result_urls
  end

  def close_browser
    @chrome || @chrome.close
  end
end
