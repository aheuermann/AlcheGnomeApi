restify = require "restify"
getTweets = require("index").getTweets
getCityLocation = require 'TomTomInterface'

defaultRadius = '1mi'

class AlcheGnome
  constructor: (options) ->
    server = restify.createServer
    server.use restify.queryParser()
    server.get '/api/search', @search

  search: (req, res, next) ->
    query = req.query.query
    location = req.query.location 
    today = req.query.today

    queryObj = 
      q: query

    if location?
      locVals = JSON.parse location.split(',')
      if typeof locVals[0] is 'number'
        queryObj.q += " geocode:#{locVals[0]},#{locVals[1]},#{defaultRadius}"
      else if typeof locVals[0] is 'string'
        getCityLocation {city: locVals[0], state: locVals[1]}, (err, loc) =>
          queryObj.q += " geocode:#{loc.lat},#{loc.lon},#{defaultRadius}"
    if today?
      yesterday = new Date().toDateString()
      #format 'yesterday' to be yyyy-MM-dd
      queryString += " since:#{yesterday}" if today

    getTweets queryString, (err, tweets) =>
      unless err
        if tweets.length > 0
          #handle response tweets
          res.send 200, tweets
          return next()

module.exports = AlcheGnome

