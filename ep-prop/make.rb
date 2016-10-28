#!/usr/bin/env ruby
# vim:ts=4:sw=4:et:smartindent:nowrap
require 'fileutils'
require 'kamelopard'
require 'logger'
require 'pry'

include Kamelopard

$log = Logger.new('auto-kml-gen.log')
$log.level = Logger::WARN

# Default AbstractView Setting
$abstractView = {  :heading => 45,
                   :range => 222, 
                   :tilt => 53, 
                   :altitude => 0, 
                   :altitudeMode => 'relativeToGround',
                   :delta => 360,
                   :duration => 125,
                   :step => 5
}

# Define Images for Overlay Creation
images = ['images/']
tours = 'tours/'

# Set Project Defaults
Properties = [
    {
        :type => 'Office', 
        :name => '750 Third',
        :address => '750 Third Ave',
        :city => 'New York',
        :state => 'NY',
        :heading => 165,
        #:range => 207,
        #:tilt => 37,
        :range => 407,
        :tilt => 37,
        :style => ['images/pins/750_third.png',110],
        :data => [] 
    },
    {
        :type => 'Office', 
        :name => '299 Park',
        :address => '299 Park Ave',
        :city => 'New York',
        :state => 'NY',
        :heading => 105,
        #:range => 207,
        #:tilt => 37,
        :range => 407,
        :tilt => 37,
        :style => ['images/pins/299_park.png',187],
        :data => [] 
    },
    {
        :type => 'Office', 
        :name => '40 Fulton',
        :address => '40 Fulton St',
        :city => 'New York',
        :state => 'NY',
        :heading => 195,
        #:range => 207,
        #:tilt => 37,
        :range => 407,
        :tilt => 37,
        :style => ['images/pins/40_fulton.png',110],
        :data => [] 
    },
    {
        :type => 'Office', 
        :name => '481 Washington Street',
        :address => '481 Washington St',
        :city => 'New York',
        :state => 'NY',
        :heading => 63,
        #:range => 207,
        #:tilt => 37,
        :range => 207,
        :tilt => 37,
        :style => ['images/pins/481_washington.png',33],
        :data => [] 
    },
    {
        :type => 'Residential', 
        :name => '2 Eastview',
        :address => '2 Eastview Lane',
        :city => 'New York',
        :state => 'NY',
        :heading => 297,
        :style => ['images/pins/2_eastview.png',11],
        :range => 97,
        :tilt => 53,
        :data => [] 
    },
    {
        :type => 'Residential', 
        :name => '1725 York',
        :address => '1725 York Ave',
        :city => 'New York',
        :state => 'NY',
        :heading => 247,
        :range => 419,
        :tilt => 69,
        :style => ['images/pins/1725_york.png',110],
        :data => [] 
    },
    {
        :type => 'Residential', 
        :name => '4001_lochwood',
        :address => '149-41 Powell Cove Blvd',
        :city => 'Whitestone',
        :state => 'NY',
        :heading => 157,
        :range => 97,
        :tilt => 69,
        :style => ['images/pins/4001_lochwood.png',11],
        :data => [] 
    },
    {
        :type => 'Residential', 
        :name => '15 Nicholas',
        :address => '15 Nicholas Ct',
        :city => 'Bethpage',
        :state => 'NY',
        :heading => 295,
        :range => 97,
        :tilt => 69,
        :style => ['images/pins/15_nicholas.png',11],
        :data => [] 
    },
    {
        :type => 'Residential', 
        :name => '19 Canal',
        :address => '19 Canal Way',
        :city => 'Hampton Bays',
        :state => 'NY',
        :heading => 327,
        :range => 97,
        :tilt => 53,
        :style => ['images/pins/19_canal.png',11],
        :data => [] 
    },
    {
        :type => 'Residential', 
        :name => '4 Leeton',
        :address => '4 Leeton Dr',
        :city => 'Southhold',
        :state => 'NY',
        :heading => 67,
        :range => 97,
        :tilt => 69,
        :style => ['images/pins/4_leeton.png',11],
        :data => [] 
    }
]

TemplateOverlayKML = %(<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
  <Document>
    <ScreenOverlay id="<%= name %>-id">
        <name><%= name %></name>
        <Icon><href><%= name %>.png</href></Icon>
        <overlayXY x="0" y="1" xunits="fraction" yunits="fraction"/>
        <screenXY x="0" y="1" xunits="fraction" yunits="fraction"/>
        <rotationXY x="0" y="0" xunits="fraction" yunits="fraction"/>
        <size x="-1" y="-1" xunits="fraction" yunits="fraction"/>
    </ScreenOverlay>
  </Document>
</kml>
)


def geoCode

    puts "Running geocode operations:"

    # Set Geocode API Key
    #g = GoogleGeocoder.new('AIzaSyCPAb3mLNO4PgzulbuTZaZs5YtgZsI1Hyk')
    g = GoogleGeocoder.new('AIzaSyA3OnGpvefhlhYUSSvP7PAni2F-qE-vC8A')

    success = []
    failures = []
    # Send query for each Line in client CSV datasheets
    Properties.each do |prop|

        query = [ prop[:address], prop[:city], prop[:state]].join(', ') 
        prop[:data] << g.lookup(query)
        # Report findings
        status = prop[:data].last.fetch("status")
        STDERR.puts "#{query}: #{status}"

        # Organize Results
        if status == "OK"
            success << prop[:data].last
        else
            $log.warn("Geocode Error: #{query}")
            failures << prop[:data].last
        end

        sleep_dur = ".15".to_f 
        sleep(sleep_dur)        

    end

    STDERR.puts
    STDERR.puts "Geocode Metrics:"
    STDERR.puts "Successes: #{success.length}"
    STDERR.puts "Failures: #{failures.length}"
    STDERR.puts
    sleep(1)

end

def makeKMZ(prop,lat,lng)

    # Set current attributes
    image = prop[:style][0]
    name_document = "#{prop[:name]} Pin" 
    outfile = "tours/#{name_document.gsub(' ','-').downcase}.kml"

    STDERR.puts "Generating Placemark KMZ: #{name_document}"

    # Initiate KML Document
    Document.new name_document 

    # Make Placemark Style
    pl_style = style(:icon => iconstyle(prop[:style][0], :scale => 3.5, :hotspot => xy(0.5,0)), :label => labelstyle(0, :color => 'ff5e9cbc'))

    style = pl_style
    
    # Store loc info 
    get_folder << placemark(name_document, :geometry => point(lng,lat,prop[:style][1],:relativeToGround), :styleUrl => style)

    writeKML(outfile)

    zoutfile = outfile.gsub('kml','kmz')
    STDERR.puts "Zipping KMZ Document: #{zoutfile}"
    `zip #{zoutfile} -r #{outfile} #{prop[:style][0]}`


end


def writeKML(outfile)

    STDERR.puts "Writing KML Document: #{outfile}"
    write_kml_to outfile

end


def makeKML(prop)

    # Isolate Geometry
    geo = prop[:data][0]['results'][0].select {|v| v == 'geometry'}
    lat = geo['geometry']['location']['lat']
    lng = geo['geometry']['location']['lng']

    # Orbit - Modified per client
    delta = $abstractView[:delta].to_f 
    duration = $abstractView[:duration].to_f 
    step = $abstractView[:step].to_f 

    # Set current attributes
    name_document = "#{prop[:name]} Tour" 
    tourname = name_document.gsub(' ','-').downcase 

    STDERR.puts "Generating gx:Tour KML: #{name_document}" 
    STDERR.puts "   Calculated lat: #{lat}"
    STDERR.puts "   Calculated lng: #{lng}"

    Document.new "#{name_document}"

    # Create an AutoPlay folder with the Autoplay networklink
    name_folder 'AutoPlay'

    # ROSCOE Autoplay
    get_folder << Kamelopard::NetworkLink.new( URI::encode("http://localhost:8765/query.html?query=playtour=#{tourname}"), {:name => "Autoplay", :flyToView => 0, :refreshVisibility => 0} )

    # Name the Tour element using the data filename
    name_tour    tourname 

    # Initiate gx:Tour Dynamics
    p = { :latitude => lat,
          :longitude => lng,
          :range => prop[:range], 
          :heading => prop[:heading],
          :tilt => prop[:tilt],
          :altitude => $abstractView[:altitude],
          :altitudeMode => $abstractView[:altitudeMode]
        }

    f = make_view_from(p)

    # fly to each point
    fly_to f, :duration => 3

    # orbit around "p", which is a kamelopard point() using values from the first placemark in the data file
    orbit( f, p[:range], p[:tilt], p[:heading].to_f, p[:heading].to_f + delta, {:durationation => duration, :step => step, :already_there => true} )

    # pause
    pause 1 

    # output to the same name as the data file, except with .kml extension
    FileUtils.mkdir_p 'tours'
    outfile = "tours/#{tourname}.kml"
    STDERR.puts "Writing gx:Tour: #{outfile}"
    write_kml_to outfile

    sleep(1)

    # Make Placemark for tour point
    makeKMZ(prop,lat,lng)

end


## Run Time
geoCode

# Make Tours
STDERR.puts "Building gx:Tours:"
sleep(1)

Properties.each do |prop|

    # Reject Failures
    next unless prop[:data][0]["status"] == "OK"

    makeKML(prop)
    STDERR.puts 
end

# Make general KMZ Placemarks
styles = ['Office', 'Residential']
styles.each do |s|

    # Filter by type
    images = []
    properties = Properties.select { |p| p[:type] == s }
    name_document = "#{s} Placemarks"
    outfile = "#{name_document.gsub(' ','-').downcase}.kml"

    STDERR.puts "Generating Placemarks KMZ: #{name_document}"

    # Initiate KML Document
    Document.new name_document 

    properties.each do |poi|

        # Isolate Geometry
        geo = poi[:data][0]['results'][0].select {|v| v == 'geometry'}
        lat = geo['geometry']['location']['lat']
        lng = geo['geometry']['location']['lng']
    
        # Make Placemark Style
        pl_style = style(:icon => iconstyle(poi[:style][0], :scale => 3.5, :hotspot => xy(0.5,0)), :label => labelstyle(0, :color => 'ff5e9cbc'))

        style = pl_style
        
        # Store loc info 
        get_folder << placemark(name_document, :geometry => point(lng,lat,poi[:style][1],:relativeToGround), :styleUrl => style)

        images << poi[:style][0]

    end

    writeKML(outfile)

    zoutfile = outfile.gsub('kml','kmz')
    STDERR.puts "Zipping KMZ Document: #{zoutfile}"
    `zip #{zoutfile} -r #{outfile} #{images.join}`
    STDERR.puts 
    
end
