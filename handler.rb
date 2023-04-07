require 'json'
require './src/chat_request'
require "net/http"

def conversation(event:, context:)
  params = event['queryStringParameters']

  {
    'statusCode': 200,
    'body': {
      response: ChatRequest.new.send(params['speech'])
    }.to_json
  }
end

def conversation_from_slack(event:, context:)
  p event.inspect
  return { 'statusCode': 200 } unless event['headers']['x-slack-retry-num'].nil?

  request_body = event['body']

  timestamp = event['headers']['x-slack-request-timestamp']
  signature = event['headers']['x-slack-signature']

  sig_basestring = "v0:#{timestamp}:#{request_body}"
  slack_signing_secret = ENV['SLACK_SIGNING_SECRET']
  signing_secret = OpenSSL::Digest::SHA256.new(slack_signing_secret)
  signature_hash = OpenSSL::HMAC.hexdigest(signing_secret, slack_signing_secret, sig_basestring)
  my_signature = "v0=#{signature_hash}"

  if my_signature == signature
    request = JSON.parse(request_body)
    if request['type'] == 'url_verification'
      return {
        'statusCode': 200,
        'body': { challenge: request['challenge'] }.to_json,
        'headers': {
          'Content-type': 'application/json'
        }
      }
    else
      message = request['event']['text'].gsub(/<@[A-Z0-9]+>/, '')
      channel = request['event']['channel']
      session_id = request['event']['user']
      reply = ChatRequest.new.send(message, session_id)
      post_to_slack(channel, reply)
      return { 'statusCode': 200 }
    end
  else
    return { 'statusCode': 403 }
  end
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
