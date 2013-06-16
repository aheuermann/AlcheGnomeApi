AlchemyAPI = require 'alchemy-api'
alchemy = new AlchemyAPI('8da86f0a977a22e600739f6f693b39fddefbd503')

cache = require './RedisVanguard'

#redis = require 'redis'
#cache = redis.createClient() 

getSentiment = (message, done) ->
  key = "alchemy:#{message.id}"
  cache.get key, (err, result) ->
    if result
      console.log "cached"
      message.sentiment = result
      done()
    else if message?.text
      alchemy.sentiment message.text, {}, (err, response) ->
        message.sentiment = response?.docSentiment
        cache.set(key, message.sentiment) if message.sentiment
        done(err)
    else 
      done()

module.exports =
  getSentiment: getSentiment