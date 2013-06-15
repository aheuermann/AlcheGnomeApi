Twit = require 'twit'
AlchemyAPI = require('alchemy-api')
async = require 'async'
_ = require 'underscore'
express = require 'express'

app = express()

T = new Twit {
  consumer_key:         'Z2lf3HcjTwaOFmynyt5cgQ'
  consumer_secret:      'FRCfnAScX3Yg6YmcQmHKeoXJTRxZV82v69scKf4jCHQ'
  access_token:         '11726242-WOb8IRAMFmrO3hU6xPrk9I0n3iwG408VDWNXshAHa'
  access_token_secret:  'GXIkzXP5GMi4XNfBlJCOq9W5e1YPyFfOkHybRFQOSY4'
}

alchemy = new AlchemyAPI('48d4b10b0009b09a9480bf64609620ff69c42dac')

getSentiment = (tweet, done) ->
  if tweet?.text
    alchemy.sentiment tweet.text, {}, (err, response) ->
      tweet.sentiment = response.docSentiment
      done()
  else 
    done()

getTweets = (q, callback) ->
  all = []
  count = 6
  q.count = 100
  async.whilst( 
    -> count > 0
    (done) ->
      console.log "Twitter loop iteration #{count}"
      T.get 'statuses/user_timeline', q, (err, tweets) ->
        if tweets and tweets.length > 0
          all = all.concat(tweets)
          q.max_id = _.last(tweets).id if tweets
          count--
        else 
          count = 0

        done(err)
    (err) ->
      console.log "Grabbed: #{all.length}"
      callback err, _.map(all, (t) -> _.pick t, ['text', 'id'])
  )

app.get '/api/:user', (req, res) ->
  q = 
    screen_name: req.params.user
  
  async.waterfall [
    (next) -> #get all the tweets
      getTweets q, next
    (tweets, next) -> #get their sentiments
      if tweets and tweets?.length > 0
        async.eachLimit tweets, 1, getSentiment, (err) ->
          next null, tweets
      else
        next null, []
    ], (err, results) ->
      if results
        res.send results
      else
        res.send "No tweets for \"#{req.params.user}\""

port = process?.env?.PORT || 3000
app.listen port
console.log "listening #{port}"
