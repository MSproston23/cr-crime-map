class LogEntry < ActiveRecord::Base
  default_scope order('date DESC')
  acts_as_gmappable :process_geocoding => true, :lat => 'lat', :lng => 'lng'

  attr_accessible :addr, :address, :call, :city, :date, :gmaps, :lat, :lng, :log_id, :state, :zip_code, :case, :code


    def gmaps4rails_address
    #describe how to retrieve the address from your model, if you use directly a db column, you can dry your code, see wiki
    "#{self.address}, #{self.city}, #{self.state}, #{self.zip_code}" 
    end

    def gmaps4rails_infowindow
      "<h2>#{self.date}</h2>" +
      "<h3>#{self.addr}</h3>" +
      "<p><label>ID: </label>#{self.log_id}</p>" +
      "<p><label>Call Type: </label>#{self.call}</p>" +
      "<p><label>Disposition: </label>#{self.code}</p>" +
      "<p><label>Case Number: </label>#{self.case}</p>"
    end

def gmaps4rails_sidebar
      "<h1>#{self.date}</h1>" +
      "<h2>#{self.addr}</h2>" +
      "<p><label>Call Type: </label>#{self.call}</p>" 
end

  def self.update_log

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
    "medford ln",
    "Cat ct",
    "Inwood ln",
    "Kelburn Ln",
    "Kingswood Ln",
    "Minden Ln",
    "Northbrook Dr",
    "Danbern Ln"
    ]
#    name_terms = [
#    "E Ave NW",
#    "F Ave NW",
#    "G Ave NW",
#    "H Ave NW",
#    "A Ave NW",
#    "10th Street NW",
#    "13th Street NW",
#    "9th Street NW",
#    "8th Street NW"
#    ]

    puts "Searching for:" + name_terms.to_s
    LogEntry.delete_all
first_result = true
request_url = "http://apps.cedar-rapids.org/policelogs/calls_list.asp"

name_terms.each do |name_term|
  if page = RestClient.post(request_url, {
    'orderby'=>'CALLDATE, TIME_REC',
    'clearsession'=>'yes',
    'street_no'=>'',
    'street'=>name_term,
    'calltype'=>'',
    'minmonth'=>'4',
    'minday'=>'22',
    'minyear'=>'2013',
    'maxmonth'=>'5',
    'maxday'=>'9',
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
        LogEntry.create(
          :log_id => row.css('td')[0].text.strip.squeeze(" "),
          :date => row.css('td')[1].text.strip.squeeze(" "),
          :call => row.css('td')[2].text.strip.squeeze(" "),
          :addr => row.css('td')[3].text.strip.squeeze(" ").split("Apt.")[0],
          :address => row.css('td')[3].text.strip.squeeze(" ").split("/")[0].split("Apt.")[0] + ", Cedar Rapids, IA, 52402",
          :code => row.css('td')[4].text.strip.squeeze(" "),
          :case => row.css('td')[5].text.strip.squeeze(" "),

          :city => "Cedar Rapids",
          :state => "IA",
          :zip_code => "52402"
        )
#      sleep 15 # wait 15 second delay for geocoder service
#      puts "Record #{log_entries.length} added"
      end
      end
    end
  end

  end
end
