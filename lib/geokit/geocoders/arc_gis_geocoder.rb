# -*- coding: utf-8 -*-
module Geokit
  module Geocoders
    # ArcGIS Geocoder Service
    class ArcGisGeocoder < Geocoder
      self.secure = true

      private

      # Template method which does the reverse-geocode lookup.
      def self.do_reverse_geocode(latlng)
        latlng = LatLng.normalize(latlng)
        url =  "#{protocol}://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/reverseGeocode?f=pjson"
        url += "&location=#{Geokit::Inflector.url_escape(latlng.lng.to_s + ',' + latlng.lat.to_s)}"
        process :json, url
      end

      # Template method which does the geocode lookup.
      def self.do_geocode(address)
        address_str = address.is_a?(GeoLoc) ? address.to_geocodeable_s : address
        url =  "#{protocol}://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/find?f=pjson"
        url += "&text=#{Geokit::Inflector.url_escape(address_str)}"
        process :json, url
      end

      def self.parse_json(results)
        #return GeoLoc.new
        extract_geoloc(results)
      end

      def self.extract_geoloc(result_json)
        loc = new_loc
        extract_geo_data result_json, loc

        if address_json = result_json['address']
          loc.street_address = address_json['Address']
          loc.neighborhood   = address_json['Neighborhood']
          loc.city           = address_json['City']
          loc.state_name     = address_json['Region']
          loc.zip            = address_json['Postal']
          loc.country_code   = address_json['CountryCode']
          loc.success = true
        elsif result_json['locations']
          address_json = result_json['locations'][0]
          loc.street_address = address_json['name']
        end
        loc
      end

      def self.extract_geo_data(result_json, loc)
        if result_json['locations']
          loc.lng = result_json['locations'][0]['feature']['geometry']['x']
          loc.lat = result_json['locations'][0]['feature']['geometry']['y']
        elsif result_json['location']
          loc.lng = result_json['location']['x']
          loc.lat = result_json['location']['y']
        end
      end
    end
  end
end
