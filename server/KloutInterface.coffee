express = require "express"
Klout = require "node_klout"

getKloutScore: (twitterHandle, callback) ->
  klout = new Klout().setKey('5u7zsbnt6mbme9zn395nygem')

  klout.getKloutIdentity twitterHandle, (err, kloutUser) ->
    klout.getUserScore kloutUser.id, (err, res) ->
      callback err, res.score if callback

module.exports:
  getKloutScore: getKloutScore