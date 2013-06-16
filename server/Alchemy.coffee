AlchemyAPI = require 'alchemy-api'

alchemy = new AlchemyAPI('8da86f0a977a22e600739f6f693b39fddefbd503')

cache = {}

getSentiment = (tweet, done) ->
  if cache[tweet.id]
    tweet.sentiment = cache[tweet.id]
    done()
  else if tweet?.text
    alchemy.sentiment tweet.text, {}, (err, response) ->
      tweet.sentiment = response.docSentiment
      cache[tweet.id] = tweet.sentiment
      done(err)
  else 
    done()

module.exports =
  getSentiment: getSentiment