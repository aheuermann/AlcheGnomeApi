ContextIO = require 'contextio'
_ = require 'underscore'

ctxioClient = new ContextIO.Client({
  key: "hh0jn0bl" #fake email account
  secret: "Q7aUikjvJMd8bJEY"
})

cache = {}

getMessages = (done) ->
  console.log 
  ctxioClient.accounts('51bd21a98c157f583f2183d6').messages().get (err, resp) ->
    done err, _.map(resp.body, (m) ->
      rval =
        id: "m:#{m.message_id}"
        text: m.subject
        created_at: new Date(m.date)
        user:
          screen_name: m.addresses.from.email
          name: m.addresses.from.name
          sent_count: Math.random()*10
          received_count:  Math.random()*5

      rval.user.profile_image_url = m.person_info[m.addresses.from.email].thumbnail if m.person_info[m.addresses.from.email]?.thumbnail
      rval
    )
module.exports =
  getMessages: getMessages