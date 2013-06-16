ContextIO = require 'contextio'
_ = require 'underscore'
async = require 'async'

ctxioClient = new ContextIO.Client({
  key: "hh0jn0bl" #fake email account
  secret: "Q7aUikjvJMd8bJEY"
})

cache =
  messages: {}

getMessage = (message, done) ->
  if cache[message.id]
    done() 
  else
    ctxioClient.accounts('51bd21a98c157f583f2183d6').messages(message.id).body().get (err, resp) ->
      if err
        done err
      else
        m = _.find resp.body, (m) -> m.type is 'text/plain'
        message.text = m?.content
        message.alchemyText += " " + message.text
        done err

getMessages = (done) ->
  ctxioClient.accounts('51bd21a98c157f583f2183d6').messages().get {limit:320}, (err, resp) ->
    messages = _.map(resp.body, (m) ->
      rval =
        id: m.message_id
        subject: m.subject
        alchemyText:m.subject
        created_at: new Date(m.date)
        user:
          screen_name: m.addresses.from.email
          name: m.addresses.from.name
          sent_count: Math.floor(Math.random()*10)
          received_count:  Math.floor(Math.random()*5)

      rval.user.profile_image_url = m.person_info[m.addresses.from.email].thumbnail if m.person_info[m.addresses.from.email]?.thumbnail
      rval
    )
    if messages and messages.length > 0
      while messages.length < 320
        messages.push _.clone(messages[Math.floor(Math.random()*messages.length)])

    async.eachLimit messages, 500, getMessage, (err) ->
      done err, messages

module.exports =
  getMessages: getMessages