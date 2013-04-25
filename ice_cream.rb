require 'rest-client'
require 'json'
require 'addressable/uri'
require_relative 'secrets.rb'


### DO NOT COMMIT API KEY TO GIT!!!!!!!!
# 1) Get request from API
# - give ice cream shops based on location


test_address = Addressable::URI.new(
   :scheme => "https",
   :host => "maps.googleapis.com",
   :path => "maps/api/place/nearbysearch/json",
   :query_values => {
     :key => API_KEY,
     :location => "40.7309,-73.991305",
     :sensor => "false",
     :keyword => "ice cream",
     :rankby => "distance"
   }
 ).to_s


# 2) Recieve data from google
response = RestClient.get(test_address)


# 3) Parse data w/ JSON
ice_cream_shops = JSON.parse(response)

#3.1 pull out relevant data
# name = ice_cream_shops["results"][0]["name"]
# name2 = ice_cream_shops["results"][1]["name"]
#
# puts name
#
# puts name2
shops = []
ice_cream_shops["results"].each do |result|
  shops << {
    :name => result["name"],
    :location => result["geometry"]["location"],
    :rating => result["rating"],
    :open_now => result["opening_hours"]
  }

end



# 4) Display output to user
shops.each_with_index do |shop, i|
  puts "Shop #{i + 1}: #{shop[:name]}"
  puts "Rating: #{shop[:rating]}"
  puts
end

#4.1 Get user choice
puts "Enter shop number for directions (E.g. '15')"
choice_index = gets.chomp.to_i - 1

choice_loc = shops[choice_index][:location]
choice_lat = choice_loc["lat"]
choice_lng = choice_loc["lng"]


# 5) Get request from Directions API

direction_request = Addressable::URI.new(
   :scheme => "https",
   :host => "maps.googleapis.com",
   :path => "maps/api/directions/json",
   :query_values => {
     :origin => "40.7309,-73.991305",
     :destination => "#{choice_lat},#{choice_lng}",
     :sensor => "false"
   }
 ).to_s

 # 6) Recieve/parse directions data

direction_response = RestClient.get(direction_request)
directions = JSON.parse(direction_response)


# 7) Display directions to user