require "nokogiri"
require "open-uri"
require "csv"


def convert_row_to_stat(row, league_id, year)
  stat = {}
  cells = row.css("td")

  stat[:owner_id] = cells[0].css('b').css("a")[0]["class"].gsub("franchise_", "").to_i
  stat[:year] = year.to_i
  stat[:wins] = cells[1].text.split("-")[0]
  stat[:losses] = cells[1].text.split("-")[1]
  stat[:ties] = cells[1].text.split("-")[2]
  stat[:points_for] = cells[5]
  stat[:points_possible] = cells[6]

  return stat
end

##### MAIN #####

CSV.open("owner_stats.csv", "w") do |csv|csv << ["owner_id", "year", "wins", "losses", "ties", "points_for", "points_possible"]

league_id = 20896
played_years = [2017, 2018, 2019, 2020, 2021, 2022]
  played_years.each do |played_year|
    doc = Nokogiri::HTML(open("http://www67.myfantasyleague.com/#{played_year}/standings?L=#{league_id}"))
    rows = doc.css(".report")[0].css("tr")
    stats = []

    rows.each_with_index do |row, index|
    if index != 0
        stats.push(convert_row_to_stat(row, league_id, played_year))
    end
    end

    
    stats.each do |stat|
        csv << [stat[:owner_id], stat[:year], stat[:wins], stat[:losses], stat[:ties], stat[:points_for], stat[:points_possible]]
    end
  end
end
