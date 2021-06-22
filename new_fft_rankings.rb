require "nokogiri"
require "open-uri"
require "csv"
require 'json'

def load_crosswalk
  mfl_to_fft = {}
  table = CSV.parse(File.read("player_crosswalk.csv"), headers: true)
  table.each do |row|
    mfl_to_fft[row["mfl_player_id"]] = row["fft_player_id"]
  end
  return mfl_to_fft
end

def load_draft_picks
  players = []
  table = CSV.parse(File.read("all_draft_picks.csv"), headers: true)
  table.each do |row|
    players.push(row)
  end
  return players
end

# def scrape_rankings(link)
#   ranks = {}
#   doc = Nokogiri::HTML(open(link))
#   # data_rows = doc.css("#rank-data").css("tbody").css("tr").css("player-row")
#   data_rows = doc.css("#rank-data").css("tbody").css("tr")

#   data_rows.each do |row|
#     mfl_player_id = row["data-id"]
#     if mfl_player_id != nil
#       ranks[mfl_player_id] = row.css(".sticky-cell-one").text()
#     end
#   end

#   return ranks
# end

def get_rankings_from_json(filename)
  ranks = {}
  file = File.read(filename)
  data_hash = JSON.parse(file)
  data_hash["players"].each do |player|
    mfl_player_id = row["player_id"]
    ranks[mfl_player_id] = row["rank_ecr"]
  end
end

def get_new_rankings
  # qb_link = "https://www.fantasypros.com/nfl/rankings/qb-cheatsheets.php"
  # rb_link = "https://www.fantasypros.com/nfl/rankings/half-point-ppr-rb-cheatsheets.php"
  # wr_link = "https://www.fantasypros.com/nfl/rankings/half-point-ppr-wr-cheatsheets.php"
  # te_link = "https://www.fantasypros.com/nfl/rankings/half-point-ppr-te-cheatsheets.php"
  qb_rankings = get_rankings_from_json("./qb.json")
  # qb_rankings = scrape_rankings(qb_link)
  rb_rankings = get_rankings_from_json("./rb.json")
  # rb_rankings = scrape_rankings(rb_link)
  wr_rankings = get_rankings_from_json("./wr.json")
  # wr_rankings = scrape_rankings(wr_link)
  te_rankings = get_rankings_from_json("./te.json")
  # te_rankings = scrape_rankings(te_link)
  return qb_rankings.merge(rb_rankings).merge(wr_rankings).merge(te_rankings)
end

def write_new_csv(drafted_players, old_year, current_year)
  CSV.open("#{old_year}_draft/player_ranks_#{current_year}.csv", "wb") do |csv|
    csv << ["player_name", "mfl_player_id", "year", "position", "positional_rank"]

    drafted_players.each do |player|
      if player["year_drafted"].to_i == old_year
        csv << [player["player_name"], player["mfl_player_id"], current_year, player["position"], player["positional_rank"]]
      end
    end
  end
end

#  MAIN #
current_year = 2020

mfl_to_fft = load_crosswalk()
drafted_players = load_draft_picks()
all_new_rankings = get_new_rankings()

drafted_players.each do |player|
  fft_id = mfl_to_fft[player["mfl_player_id"]]
  player["positional_rank"] = all_new_rankings[fft_id].to_i
end

drafted_players.each { |player| puts "#{player["player_name"]} - #{player["positional_rank"]}" }

write_new_csv(drafted_players, 2018, 2020)
write_new_csv(drafted_players, 2019, 2020)
