require "csv"

def csv_headers
  ["player_name", "mfl_player_id", "year", "position", "positional_rank"]
end

files = Dir["2018_draft/*.csv"]
file_contents = files.map { |f| CSV.read(f) }

csv_string2018 = CSV.generate do |csv|
  csv << csv_headers
  file_contents.each do |file|
    file.shift                  # remove the headers of each file
    file.each do |row|
      csv << row
    end
  end
end

files = Dir["2019_draft/*.csv"]
file_contents = files.map { |f| CSV.read(f) }

csv_string2019 = CSV.generate do |csv|
  csv << csv_headers
  file_contents.each do |file|
    file.shift                  # remove the headers of each file
    file.each do |row|
      csv << row
    end
  end
end

File.open("all_rankings.csv", "w") do |f|
  f << csv_string2018
  f << csv_string2019
end