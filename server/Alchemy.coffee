AlchemyAPI = require 'alchemy-api'
alchemy = new AlchemyAPI('8da86f0a977a22e600739f6f693b39fddefbd503')

cache = require './RedisVanguard'

getSentiment = (message, done) ->
  #console.log "calling"
  key = "alchemy:#{message.id}"
  cache.get key, (err, result) ->
    #console.log "done: #{result}"
    if result
      #console.log "Cached: #{JSON.stringify(result)}"
      message.sentiment = result
      done()
    else if message?.alchemyText
      #console.log "calling with #{message.alchemyText}"
      alchemy.sentiment message.alchemyText, {}, (err, response) ->
        console.log "AlchemyError: #{JSON.stringify(err)}" if err
        message.sentiment = response?.docSentiment
        cache.set(key, message.sentiment) if message.sentiment
        done(err)
    else 
      done()

module.exports =
  getSentiment: getSentiment