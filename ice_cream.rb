require 'rest-client'
require 'json'
require 'addressable/uri'
require 'nokogiri'
require_relative 'secrets.rb'

#http://maps.googleapis.com/maps/api/geocode/output?parameters

puts 'Type in your current location: '
start_loc = gets.chomp

start_address = Addressable::URI.new(
   :scheme => "https",
   :host => "maps.googleapis.com",
   :path => "maps/api/geocode/json",
   :query_values => {
     :address => start_loc,
     :sensor => "false",
   }
 ).to_s


loc_response = RestClient.get(start_address)
start_coords = JSON.parse(loc_response)
start_coords = start_coords["results"][0]["geometry"]["location"]
start_lat = start_coords["lat"]
start_lng = start_coords["lng"]


test_address = Addressable::URI.new(
   :scheme => "https",
   :host => "maps.googleapis.com",
   :path => "maps/api/place/nearbysearch/json",
   :query_values => {
     :key => API_KEY,
     :location => "#{start_lat},#{start_lng}",
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
     :origin => "#{start_lat},#{start_lng}",
     :destination => "#{choice_lat},#{choice_lng}",
     :sensor => "false",
     :mode => "walking"
   }
 ).to_s

 # 6) Recieve/parse directions data

direction_response = RestClient.get(direction_request)
directions = JSON.parse(direction_response)


html_steps = []

directions["routes"][0]["legs"][0]["steps"].each do |step|
  html_steps << step["html_instructions"]
end

html_steps.map! { |step| Nokogiri::HTML(step) }

html_steps.each_with_index do |step, i|

  puts "#{i + 1}: #{step.text}"
end
