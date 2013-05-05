class Rdio < Faraday::Connection
  def initialize
    super(url: 'https://www.rdio.com', ssl: { verify: false }) do |connection|
      connection.use ParseJson
      connection.request :url_encoded
      connection.adapter :net_http
    end
  end

  class ParseJson < Faraday::Response::Middleware
    def on_complete(env)
      env[:body] = MultiJson.load(env[:body]) rescue nil
    end
  end
end
