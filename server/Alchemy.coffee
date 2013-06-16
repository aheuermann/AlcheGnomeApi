AlchemyAPI = require 'alchemy-api'

alchemy = new AlchemyAPI('8da86f0a977a22e600739f6f693b39fddefbd503')

cache = {}

getSentiment = (message, done) ->
  if cache[message.id]
    message.sentiment = cache[message.id]
    done()
  else if message?.text
    alchemy.sentiment message.text, {}, (err, response) ->
      message.sentiment = response?.docSentiment
      cache[message.id] = message.sentiment if message.sentiment
      done(err)
  else 
    done()

module.exports =
  getSentiment: getSentiment