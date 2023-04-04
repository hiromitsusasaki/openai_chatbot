require 'json'
require './src/chat_request'
require "net/http"

def conversation(event:, context:)
  params = event['queryStringParameters']

  {
    statusCode: 200,
    body: {
      response: ChatRequest.new.send(params['speech'])
    }.to_json
  }
end

def conversation_from_slack(event:, context:)
  return { statusCode: 200 } unless event['headers']['x-slack-retry-num'].nil?

  request_body = JSON.parse(event['body'])
  message = request_body['event']['text'].delete_prefix('<@U04GLEKAATU> ')
  channel = request_body['event']['channel']
  reply = ChatRequest.new.send(message)
  post_to_slack(channel, reply)

  { statusCode: 200 }
end

def post_to_slack(channel, response)
  uri = URI.parse("https://slack.com/api/chat.postMessage")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  params = {
    text: response,
    channel: channel
  }

  req = Net::HTTP::Post.new(uri.path)
  req["Authorization"] = "Bearer #{ENV['BOT_USER_OAUTH_TOKEN']}"
  req["Content-Type"] = "application/json; charset=UTF-8"
  req.body = params.to_json
  http.request(req)
end

