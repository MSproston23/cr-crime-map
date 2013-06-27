require 'rubygems'
require 'time'
require 'restclient'
require 'nokogiri'
require 'american_date'
require 'geokit'
#require 'kml'

REQUEST_URL = "http://apps.cedar-rapids.org/policelogs/calls_list.asp"

name_terms = [
    "stonybrook",
    "idlebrook",
    "waterbrook",
    "driftwood",
    "boxwood",
    "mosswood",
    "laurel",
    "brookview",
    "asbury",
    "arbor ln",
    "medford ln"
    ]


puts "Searching for:" + name_terms.to_s

first_result = true
log_entries = []
class LogEntry
    def initialize(id,date,call,addr,link,disp,caseno)
     @id = id,
     @date = date,
     @ruby_date = Time.parse(date)
     @call = call,
     @addr = addr,
     @search_addr = addr + ",Cedar Rapids, IA 52402"
     @lat = ""
     @lng = ""
     @link = link,
     @disp = disp,
     @caseno = caseno

     address = Geokit::Geocoders::UsGeocoder.geocode @search_addr
     @lat = address.lat
     @lng = address.lng
    end
end

name_terms.each do |name_term|
  if page = RestClient.post(REQUEST_URL, {
    'orderby'=>'CALLDATE, TIME_REC',
    'clearsession'=>'yes',
    'street_no'=>'',
    'street'=>name_term,
    'calltype'=>'',
    'minmonth'=>'1',
    'minday'=>'1',
    'minyear'=>'2013',
    'maxmonth'=>'6',
    'maxday'=>'26',
    'maxyear'=>'2013'
    })
#    puts "Success finding search term: #{name_term}"
    #File.open("data-hold/fecimg-#{name_term}.html", 'w'){|f| f.write page.body}
  
    npage = Nokogiri::HTML(page)
    rows = npage.css('table tr')
#    puts "#{rows.length} rows"

    #header
    if first_result && rows[1]
#      puts rows[1].css('td').map{|td| td.text}.join(', ')
      first_result = false
    end
   
    #data
    rows.each do |row|
      data = row.css('td').map{|td| td.text}.join(', ')
      if data[0..1] == "P1"
#        puts data
        log_entries << LogEntry.new(
          row.css('td')[0].text.strip.squeeze(" "),
          row.css('td')[1].text.strip.squeeze(" "),
          row.css('td')[2].text.strip.squeeze(" "),
          row.css('td')[3].text.strip.squeeze(" "),
          row.css('td')[4].text.strip.squeeze(" "),
          row.css('td')[5].text.strip.squeeze(" "),
          row.css('td')[5].text.strip.squeeze(" ")
        )
      sleep 15 # wait 15 second delay for geocoder service
      puts "Record #{log_entries.length} added"
      end
    end
  
  end
end

puts log_entries.to_s
