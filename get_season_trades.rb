require "nokogiri"
require "open-uri"
require "csv"
require 'time'


def convert_row_to_stat(row, league_id, year)
  stat = {}
  cells = row.css("td")

  stat[:owner_id_1] = cells[1].css('a')[0]["class"].gsub("franchise_", "").to_i
  stat[:owner_id_2] = cells[1].css('a')[1]["class"].gsub("franchise_", "").to_i
  stat[:owner_1_receives] = cells[3].css('li')[1].text.split("gave up ")[1]
  stat[:owner_2_receives] = cells[3].css('li')[0].text.split("gave up ")[1]
  stat[:timestamp] = Time.parse(cells[4].text).iso8601
  stat[:year] = year.to_i

  return stat
end

##### MAIN #####

CSV.open("season_trades.csv", "w") do |csv|csv << ["owner_id_1", "owner_id_2", "owner_1_receives", "owner_2_receives", "year", "timestamp"]

  league_id = 20896
  played_years = [2017, 2018, 2019, 2020, 2021, 2022]
  played_years.each do |played_year|
    doc = Nokogiri::HTML(open("http://www47.myfantasyleague.com/#{played_year}/options?L=#{league_id}&O=03&TYPE=TRADE&FRANCHISE=0000&DAYS=30000"))
    rows = doc.css(".report")[0].css("tr")
    stats = []

    rows.each_with_index do |row, index|
    if index != 0 && index != rows.length - 1
        stats.push(convert_row_to_stat(row, league_id, played_year))
    end
    end

    
    stats.each do |stat|
        csv << [stat[:owner_id_1], stat[:owner_id_2], stat[:owner_1_receives], stat[:owner_2_receives], stat[:year], stat[:timestamp]]
    end
  end
end
