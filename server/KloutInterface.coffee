express = require "express"
Klout = require "node_klout"

klout = new Klout("5u7zsbnt6mbme9zn395nygem", "json", "v2")

cache = {}

getKloutScore= (username, callback) ->
  if not username
    callback null, null
  else if cache[username]
    #console.log "CACHE: #{username} -> #{cache[username]}"
    callback null, cache[username]
  else
    #console.log "u:#{username}"
    klout.getKloutIdentity username, (err, kloutUser) ->
      klout.getUserScore kloutUser.id, (err, res) ->
        #console.log "#{username} -> #{JSON.stringify(res.score)}"
        cache[username] = res.score
        callback(err, res.score) if callback

module.exports =
  getKloutScore: getKloutScore