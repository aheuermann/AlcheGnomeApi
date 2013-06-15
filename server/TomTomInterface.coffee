restify = require "restify"

url = "https://api.tomtom.com/"
apiKey = "cq8vw3fjhax8rvzyu5nte5y9"
uri = "lbs/services/geocode/4/geocode"

getCityLocation: (place, callback) ->
  if typeof query is "object"
    
  else if typeof query is "string"
    city = place.city.replace(' ', '%20')
    state = place.state.replace(' ', '%20')

    queryString = "?language=en&L=#{city}&AA=#{state}$key=#{apiKey}"
    client = restify.createClient
      url: url
      headers:
        'Content-Type' : 'application/json'      

    client.get uri + queryString, (err, req, res, obj) ->
      req.on "response", (err, res) ->
        if res.statusCode is 200
          resObj =
            lat: response.geoResponse.geoResult.latitude
            lon: response.geoResponse.geoResult.longitude

          callback undefined, resObj if callback #assuming 'obj' is {lat: , lon}
        else 
          callback "Error: TomTom error #{res.statusCode}", undefined if callback
          
module.exports =
  getCityLocation: getCityLocation