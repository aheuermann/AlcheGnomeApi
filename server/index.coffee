Alchemy = require './Alchemy'
Klout = require './Klout'
Twitter = require './Twitter'
ContextIO = require './ContextIO'
async = require 'async'
_ = require 'underscore'

express = require 'express'
app = express()


getKloutScore = (tweet, done) ->
  Klout.getKloutScore tweet.user.screen_name, (err, score) ->
    tweet.klout_score = score
    done err, tweet

getTweets: ->

doWork = (type, messages, res) ->
  if messages and messages?.length > 0
    async.parallel [
      (done) ->
        if type is 'tweet'
          async.eachLimit messages, 1, getKloutScore, (err) ->
            done err
        else done(null)
      (done) ->
        async.eachLimit messages, 500, Alchemy.getSentiment, (err) ->
          done err
    ], (err) ->
      console.log err if err
      res.send messages || []

doTwitter = (method, q, res) ->
  Twitter.getTweets method, q, (err, tweets) ->
    doWork 'tweet', tweets, res

app.get '/api/user/:user', (req, res) ->
  doTwitter 'statuses/user_timeline', {screen_name: req.params.user}, res

app.get '/api/search', (req, res) ->
  method = q = null
  if req.query.q?[0] is '@'
    doTwitter 'statuses/user_timeline', {screen_name: req.query.q}, res
  else
    doTwitter 'search/tweets', req.query, res

app.get '/api/email', (req, res) ->
  ContextIO.getMessages (err, messages) ->
    doWork 'message', messages, res

port = process?.env?.PORT || 3000
app.listen port
console.log "listening #{port}"
