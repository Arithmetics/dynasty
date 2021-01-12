require "nokogiri"
require "open-uri"
require "csv"

# takws a row of mfl draft and converts it to a map/object of a 'draft pick'
def convert_row_to_draft_pick(row, league_id, year)
  draft_pick = {}
  cells = row.css("td")
  draft_pick[:pick_number] = cells[1].text
  draft_pick[:owner_id] = cells[2].css("a")[0]["class"].gsub("franchise_", "").to_i
  draft_pick[:mfl_player_id] = cells[3].css("a")[0]["href"].gsub("javascript:launch_player_modal('#{league_id}','", "").gsub("');", "").to_i

  player_info = cells[3].css("a").text

  draft_pick[:player_last_name] = player_info.split(",")[0]
  draft_pick[:player_first_name] = player_info.split(",")[1].split(" ")[0]
  draft_pick[:nfl_team] = player_info.split(",")[1].split(" ")[1]
  draft_pick[:position] = player_info.split(",")[1].split(" ")[2]
  draft_pick[:year] = year.to_i

  return draft_pick
end

##### MAIN #####

league_id = 20896
draft_year = 2020
doc = Nokogiri::HTML(open("http://www67.myfantasyleague.com/#{draft_year}/options?L=#{league_id}&O=17"))
rows = doc.css(".report")[0].css("tr")
draft_picks = []

rows.each_with_index do |row, index|
  if index != 0
    draft_picks.push(convert_row_to_draft_pick(row, league_id, draft_year))
  end
end

CSV.open("player_crosswalk_#{draft_year}.csv", "w") do |csv|
  csv << ["player_name", "mfl_player_id", "fft_player_id"]
  draft_picks.each do |pick|
    csv << ["#{pick[:player_first_name]} #{pick[:player_last_name]}", pick[:mfl_player_id]]
  end
end
