Alchemy = require './Alchemy'
Klout = require './Klout'
Twitter = require './Twitter'
async = require 'async'
_ = require 'underscore'

express = require 'express'
app = express()


getKloutScore = (tweet, done) ->
  Klout.getKloutScore tweet.user.screen_name, (err, score) ->
    tweet.klout_score = score
    done err, tweet

doWork = (method, q, res) ->
  async.waterfall [
    (next) -> #get all the tweets
      Twitter.getTweets method, q, next
    (tweets, next) -> #get their sentiments
      if tweets and tweets?.length > 0
        async.parallel [
          (done) ->
            async.eachLimit tweets, 1, getKloutScore, (err) ->
              done err
          (done) ->
            async.eachLimit tweets, 500, Alchemy.getSentiment, (err) ->
              done err
        ], (err) ->
          next null, tweets
      else
        next null, []
    ], (err, results) ->
      console.log err if err
      res.send results || []

app.get '/api/user/:user', (req, res) ->
  q = 
    screen_name: req.params.user
  doWork 'statuses/user_timeline', q, res

app.get '/api/search', (req, res) ->
  if req.query.q[0] is '@'
    q = 
      screen_name: req.query.q
    doWork 'statuses/user_timeline', q, res
  else
    doWork 'search/tweets', req.query, res

port = process?.env?.PORT || 3000
app.listen port
console.log "listening #{port}"
