class RoutesSpider < Kimurai::Base
  @name = "routes_spider"
  @engine = :mechanize
  @start_urls = [] # not used, we pass url directly to parse method

  def parse(response, url:, data: {})
    new_routes = response.xpath("//tr[@class='route-row']/td/a").map { |a| { link: a[:href] } }
    new_routes += data if data.present?
    raise "No Routes Found" unless new_routes

    next_button = response.at_xpath("//div[@class='pagination']/a[not(@class='no-click')][img[@alt='Next' and not(@class ='rotate-180 skinny')]]")
    request_to(:parse, url: next_button[:href], data: new_routes) if next_button

    new_routes.each do |route|
      request_to(:parse_route_page, url: route[:link], data: route)
    end

    save_to "results.json", { routes: new_routes }, format: :pretty_json
  end

  def parse_route_page(response, url:, data: {})
    data[:name] = response.at_xpath("//div[@id='route-page']//h1").text.strip
    data[:stars] = response.at_xpath("//span[contains(@id, 'starsWithAvgText')]").text.strip[/\d/]
    data[:type] = response.at_xpath("//table[@class='description-details']//tr[td[contains(text(), 'Type:')]]/td[2]").text.strip
    data[:grade] = response.at_xpath("//span[@class='rateYDS']").text.strip
    data[:location] = response.at_xpath("//*[@id='route-page']/div/div[1]/div[2]").text.gsub(/\s+/, " ")

    opinions_link = response.at_xpath("//div[@id='you-and-route']/*/a[contains(text(), 'Opinions')]")
    request_to :parse_opinions_page, url: opinions_link[:href], data: data
  end

  def parse_opinions_page(response, url:, data: {})
    ticks_column = response.at_xpath("//div[@id='route-stats']//div[h3[contains(text(), 'Ticks')]]")
    return unless ticks_column

    data[:ticks_count] = ticks_column.at_xpath("h3/span").text.strip
    data[:ticks] = ticks_column.xpath("*/*/tr/td[@class='small']").map { |tick| date_from_string(tick.text.strip) }
  end

  private

  def date_from_string(txt)
    txt[/\w{3} \d*, \d{4}/]
  end
end