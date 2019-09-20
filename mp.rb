require_relative "lib/spiders/routes_spider"

class Mp < Thor
  desc "fetch_routes AREA_ID", "Fetches route info for a given area id"
  def fetch_routes(area_id)
    route_finder_url = "https://www.mountainproject.com/route-finder?selectedIds=#{area_id}&type=rock&diffMinrock=800&diffMinboulder=20000&diffMinaid=70000&diffMinice=30000&diffMinmixed=50000&diffMaxrock=12400&diffMaxboulder=20050&diffMaxaid=75260&diffMaxice=38500&diffMaxmixed=60000&is_trad_climb=1&is_sport_climb=1&is_top_rope=1&stars=0&pitches=0&sort1=popularity+desc&sort2=rating"

    RoutesSpider.parse!(:parse, url: route_finder_url)
  end
end
