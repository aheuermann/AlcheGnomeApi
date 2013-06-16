ContextIO = require 'contextio'

ctxioClient = new ContextIO.Client({
  key: "hh0jn0bl" #fake email account
  secret: "Q7aUikjvJMd8bJEY"
})

cache = {}

getMessages = (done) ->
  console.log 
  ctxioClient.accounts('51bd21a98c157f583f2183d6').messages().get (err, resp) ->
    done err, resp

module.exports =
  getMessages: getMessages