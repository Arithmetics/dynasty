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


def get_rankings_from_json(filename)
  ranks = {}
  file = File.read(filename)
  data_hash = JSON.parse(file)
  data_hash["players"].each do |player|
    mfl_player_id = player["player_id"].to_s
    ranks[mfl_player_id] = player["rank_ecr"]
  end
  return ranks
end

def get_new_rankings
  qb_rankings = get_rankings_from_json("./qb.json")
  rb_rankings = get_rankings_from_json("./rb.json")
  wr_rankings = get_rankings_from_json("./wr.json")
  te_rankings = get_rankings_from_json("./te.json")
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
current_year = 2022

mfl_to_fft = load_crosswalk()
drafted_players = load_draft_picks()
all_new_rankings = get_new_rankings()

drafted_players.each do |player|
  fft_id = mfl_to_fft[player["mfl_player_id"]]
  player["positional_rank"] = all_new_rankings[fft_id].to_i
end

drafted_players.each { |player| puts "#{player["player_name"]} - #{player["positional_rank"]}" }

write_new_csv(drafted_players, 2018, current_year)
write_new_csv(drafted_players, 2019, current_year)
write_new_csv(drafted_players, 2020, current_year)
write_new_csv(drafted_players, 2021, current_year)
