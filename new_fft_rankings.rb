require "nokogiri"
require "open-uri"
require "csv"

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

def scrape_rankings(link)
  ranks = {}
  doc = Nokogiri::HTML(open(link))
  # data_rows = doc.css("#rank-data").css("tbody").css("tr").css("player-row")
  data_rows = doc.css("#rank-data").css("tbody").css("tr")

  data_rows.each do |row|
    mfl_player_id = row["data-id"]
    if mfl_player_id != nil
      ranks[mfl_player_id] = row.css(".sticky-cell-one").text()
    end
  end

  return ranks
end

#  MAIN #
current_year = 2020
qb_link = "https://www.fantasypros.com/nfl/rankings/qb-cheatsheets.php"
rb_link = "https://www.fantasypros.com/nfl/rankings/half-point-ppr-rb-cheatsheets.php"
wr_link = "https://www.fantasypros.com/nfl/rankings/half-point-ppr-wr-cheatsheets.php"
te_link = "https://www.fantasypros.com/nfl/rankings/half-point-ppr-te-cheatsheets.php"

mfl_to_fft = load_crosswalk()
drafted_players = load_draft_picks()

qb_rankings = scrape_rankings(qb_link)
rb_rankings = scrape_rankings(rb_link)
wr_rankings = scrape_rankings(wr_link)
te_rankings = scrape_rankings(te_link)

all_rankings = qb_rankings.merge(rb_rankings).merge(wr_rankings).merge(te_rankings)

drafted_players.each do |player|
  fft_id = mfl_to_fft[player["mfl_player_id"]]
  player["positional_rank"] = all_rankings[fft_id].to_i
end

drafted_players.each { |player| puts "#{player["player_name"]} - #{player["positional_rank"]}" }

puts drafted_players.length
