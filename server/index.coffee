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

alchemy = new AlchemyAPI('8da86f0a977a22e600739f6f693b39fddefbd503')

MAX_TWEETS = 320


getSentiment = (tweet, done) ->
  if tweet?.text
    alchemy.sentiment tweet.text, {}, (err, response) ->
      tweet.sentiment = response.docSentiment
      done(err)
  else 
    done()

getTweets = (method, q, callback) ->
  all = []
  count = 4
  q.count = 100
  async.whilst( 
    -> count > 0
    (done) ->
      console.log "Twitter loop iteration #{count}"
      T.get method, q, (err, tweets) ->
        tweets = tweets.statuses if tweets.statuses
        if tweets and tweets.length > 0
          all = all.concat(tweets)
          q.max_id = _.last(tweets).id if tweets
          count--
        else 
          count = 0

        done(err)
    (err) ->
      #i = 0;
      if all.length > MAX_TWEETS
        all = all.splice 0, MAX_TWEETS

      console.log "Grabbed: #{all.length}"
      callback err, _.map(all, (t) -> 
        user = t.user
        t = _.pick t, ['text', 'id', 'created_at', 'retweet_count', 'favorite_count']
        t.user = {}
        t.user = _.extend t.user, _.pick(user, ['profile_image_url', 'screen_name', 'name', 'location'])
        t
      ) 
  )

doWork = (method, q, res) ->
  async.waterfall [
    (next) -> #get all the tweets
      getTweets method, q, next
    (tweets, next) -> #get their sentiments
      if tweets and tweets?.length > 0
        async.eachLimit tweets, 500, getSentiment, (err) ->
          next null, tweets
      else
        next null, []
    ], (err, results) ->
      if results
        res.send results
      else
        res.send "No tweets for \"#{req.params.user}\""

app.get '/api/user/:user', (req, res) ->
  q = 
    screen_name: req.params.user
  doWork 'statuses/user_timeline', q, res

app.get '/api/search', (req, res) ->
  doWork 'search/tweets', req.query, res

port = process?.env?.PORT || 3000
app.listen port
console.log "listening #{port}"

#module.exports =
#  getTweets: getTweets
#  getSentiment: getSentiment
