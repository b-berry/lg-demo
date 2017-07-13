#!/usr/bin/env ruby
# vim:ts=4:sw=4:et:smartindent:nowrap
require 'fileutils'
require 'kamelopard'
require 'json'
require 'logger'
require 'pry'

include Kamelopard


$log = Logger.new('.make-tours.log')
$log.level = Logger::WARN

Sleep = 0.15
Outfile = 'poi.json' 

Locations = [
                {   :address => 'Statue of Liberty, New York, NY',
                    :id => 'landmark',
                    :icon => 'https://cdn4.iconfinder.com/data/icons/flat-icon-set/128/location-icon.png',
                    :geo => [] },
                {   :address => 'Empire State Building, New York, NY',
                    :id => 'architecture',
                    :icon => 'https://cdn4.iconfinder.com/data/icons/flat-icon-set/128/location-icon.png',
                    :geo => [] },
                {   :address => 'Central Park, New York, NY',
                    :id => 'park' ,
                    :icon => 'https://cdn4.iconfinder.com/data/icons/flat-icon-set/128/location-icon.png',
                    :geo => [] },
                {   :address => 'Metropolitan Museum of Art, New York, NY',
                    :id => 'museum',
                    :icon => 'https://cdn4.iconfinder.com/data/icons/flat-icon-set/128/location-icon.png',
                    :geo => [] },
                {   :address => 'Rockefeller Center, New York, NY',
                    :id => 'architecture',
                    :icon => 'https://cdn4.iconfinder.com/data/icons/flat-icon-set/128/location-icon.png',
                    :geo => [] },
                {   :address => 'New York Public Library, New York, NY',
                    :id => 'museum',
                    :icon => 'https://cdn4.iconfinder.com/data/icons/flat-icon-set/128/location-icon.png',
                    :geo => [] },
                {   :address => 'Guggenheim Museum, New York, NY',
                    :id => 'museum',
                    :icon => 'https://cdn4.iconfinder.com/data/icons/flat-icon-set/128/location-icon.png',
                    :geo => [] },
                {   :address => 'St Patricks Cathedral, New York, NY',
                    :id => 'architecture',
                    :icon => 'https://cdn4.iconfinder.com/data/icons/flat-icon-set/128/location-icon.png',
                    :geo => [] },
                {   :address => 'One World Observatory, New York, NY',
                    :id => 'architecture',
                    :icon => 'https://cdn4.iconfinder.com/data/icons/flat-icon-set/128/location-icon.png',
                    :geo => [] },
                {   :address => 'The High Line, New York, NY',
                    :id => 'park',
                    :icon => 'https://cdn4.iconfinder.com/data/icons/flat-icon-set/128/location-icon.png',
                    :geo => [] },
                {   :address => 'Grand Central Terminal, New York, NY',
                    :id => 'landmark',
                    :icon => 'https://cdn4.iconfinder.com/data/icons/flat-icon-set/128/location-icon.png',
                    :geo => [] },
            ]


def geoCode()

    puts "Running geocode operations:"
    sleep(1)

    # Set Geocode API Key
    g = GoogleGeocoder.new('AIzaSyA3OnGpvefhlhYUSSvP7PAni2F-qE-vC8A')

    locations = []
    success = 0 
    failures = 0
    # Send lookup query
    Locations.each do |poi|

        query = poi[:address] 
        results =  g.lookup(query)
        # Report findings
        status = results.fetch("status")
        STDOUT.puts "#{query}: #{status}"

        # Organize Results
        if status == "OK"

            success += 1 

            # Isolate geo
            geo = results.fetch('results')[0].select {|v| v == 'geometry'}
            lat = geo['geometry']['location']['lat']
            lng = geo['geometry']['location']['lng']

            # Store in points 
            poi[:geo] << { :lat => lat, :lng => lng }

        else
            $log.warn("Geocode Error: #{query}")
            failures += 1
        end

        # Rest for API limit
        sleep(Sleep)        

    end

    STDOUT.puts
    STDOUT.puts "Geocode Metrics:"
    STDOUT.puts "Successes: #{success}"
    STDOUT.puts "Failures: #{failures}"
    STDOUT.puts
    sleep(1)

end


def makeAutoplay(poi)

    # Set current attributes
    name_document = poi[:nameDocument]
    tourname = poi[:tourName]

    # Create an AutoPlay folder with the Autoplay networklink
    name_folder 'AutoPlay'
    
    # ROSCOE Autoplay
    get_folder << Kamelopard::NetworkLink.new( URI::encode("http://localhost:8765/query.html?query=playtour=#{tourname}"), {:name => "Autoplay", :flyToView => 0, :refreshVisibility => 0} )

end


def makeFlyto

    # fly to each point
    $points.each do |p|

        # Create new Doc if user specified --each-write
        unless $options[:inline]

            # Get |p| attributes 
            modAttr(p)
            
            nameDoc
 
            makeAutoplay

            # Name the Tour element using the data filename
            name_tour     "#{$data_attr[:tourName]}"

        end

        # fly to each point
        fly_to make_view_from(p), :duration => 6

        # pause
        pause 4

            
        # Write KML if user specified --each-write
        unless $options[:inline]

            tourname = $data_attr[:tourName]
            writeTour 

        end
    end

end


def makePlacemarks

    binding.pry

    # Create KML Document
    nameDoc

    name_folder = "#{$data_attr[:tourname]}"

    # Make Placemark Style
    pl_style = style(:icon => iconstyle("#{$options[:iconStyle]}", :scale => 3.5, :hotspot => xy(0.5,0)), :label => labelstyle(0, :color => 'ff5e9cbc'))

    $points.each do |pmark|

        name = pmark[:name].to_s
        lat  = pmark[:latitude].to_f
        lng  = pmark[:longitude].to_f

        # Store loc info 
        get_folder << placemark(name, :geometry => point(lng,lat,75,:relativeToGround), :styleUrl => pl_style)

    end
end


def makeTour    

    # Make autoplay link
    makeAutoplay

    # Name the Tour element using the data filename
    name_tour     "#{$data_attr[:tourName]}"

    makeFlyto

    
end


def nameDoc(name)

    #Document.new "#{name_document}"
    Document.new name 

end


def writeTour

    STDOUT.puts "Writing gx:Tour to file..."

    # Set current attributes
    tourname = $data_attr[:tourName]

    # output to the same name as the data file, except with .kml extension
    outfile = "#{$options[:assetdir]}/#{tourname}.kml"
    write_kml_to outfile

    STDOUT.puts "...Done."

end


## Run Time Operations ##

# Call g.Geocoder
geoCode

# Make Placemarks
#makePlacemarks(locations)

# Print results to Outfile
json = JSON.pretty_generate(Locations)
f = File.new(Outfile,"w")
f.write(json)
f.close
