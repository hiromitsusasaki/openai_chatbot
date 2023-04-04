require 'openai'
require './src/chat_session'

class ChatRequest
  def initialize
    @client = OpenAI::Client.new(
      access_token: ENV['OPENAI_AUTH_KEY'],
      uri_base: "https://oai.hconeai.com/",
      request_timeout: 240
    )
    @chat_session = ChatSession.new
  end

  def send(message, session_id="1")
    recent_messages = [{ role: "system", content: "あなたはとても優秀なAIアシスタントです" }]
    recent_messages.concat(
      @chat_session.get_last_messages(4, session_id).map do |item|
        {
          role: item["Role"],
          content: item["Message"],
        }
      end
    )
    recent_messages.append({ role: "user", content: message })
    response = @client.chat(
      parameters: {
          model: "gpt-3.5-turbo",
          messages: recent_messages,
          temperature: 0.7,
      })

    if response["choices"].empty?
      raise StandardError, "Response was empty."
    end

    reply_message = response.dig("choices", 0, "message", "content")
    @chat_session.add_message('user', message, session_id)
    @chat_session.add_message('assistant', reply_message, session_id)

    reply_message
  rescue StandardError => e
    puts "An error occurred while making the request: #{e}"
    nil
  end
end
