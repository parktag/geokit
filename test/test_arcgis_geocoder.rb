# -*- coding: utf-8 -*-
require File.join(File.dirname(__FILE__), 'helper')

class ArcGisGeocoderTest < BaseGeocoderTest #:nodoc: all
  def setup
    super

    @query_longitude = 13.401262
    @query_latitude  = 52.529758
    @full_address = "Torstraße 122, 10119 Berlin"

    @lng = 13.401081416443811
    @lat = 52.529562495307715

  end

  def assert_url(expected_url)
    assert_equal expected_url, TestHelper.
      get_last_url.gsub(/&oauth_[a-z_]+=[a-zA-Z0-9\-. %]+/, '').gsub('%20', '+')
  end

  def test_arcgis_geocode
    VCR.use_cassette('arcgis_geocode') do

      loc = Geokit::Geocoders::ArcGisGeocoder.geocode(@full_address)
      url = "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/find?f=pjson&text=#{Geokit::Inflector.url_escape(@full_address)}"

      assert_url url
      assert_equal 52.529562495000505, loc.lat
      assert_equal 13.401081416000466, loc.lng
    end
  end

  def test_arcgis_reverse_geocode
    VCR.use_cassette('arcgis_reverse_geocode') do

      loc = Geokit::Geocoders::ArcGisGeocoder.reverse_geocode(Geokit::LatLng.new(@query_latitude, @query_longitude))
      url = "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/reverseGeocode?f=pjson&location=#{@query_longitude}%2C#{@query_latitude}"

      assert_url url
      verify(loc)
    end
  end


  def verify(location)
    assert_equal 'Berlin', location.city
    assert_equal location.zip, '10119'
    assert_equal location.street_address, 'Torstraße 122'
    assert_equal location.lat, @lat
    assert_equal location.lng, @lng
  end
end
