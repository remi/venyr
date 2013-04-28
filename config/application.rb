class BroadcastChannel < OpenStruct
  def listen_channels
    $listen_channels.select { |c| c.user == self.user }
  end

  def self.find_by_user(user)
    $broadcast_channels.select { |c| c.user == user }.first
  end

  def self.find_by_ws(ws)
    $broadcast_channels.select { |c| c.ws == ws }.first
  end

  def close
    $broadcast_channels.delete(self)
  end
end

class ListenChannel < OpenStruct
  def self.find_by_ws(ws)
    $listen_channels.select { |c| c.ws == ws }.first
  end

  def close
    $listen_channels.delete(self)
  end
end

# TODO SQLite memory or something?
$broadcast_channels = []
$listen_channels = []

class App < Sinatra::Base
  # Middleware
  use Rack::CanonicalHost, ENV['CANONICAL_HOST']
  use Rack::Logger

  # Plugins
  register Sinatra::Partial

  # Configuration
  configure do
    set :haml, :format => :html5, :attr_wrapper => '"', :ugly => false
    set :root, proc { File.expand_path('./') }
    set :views, proc { File.join(root, 'app/views') }
    set :public_folder, proc { File.join(root, 'public') }

    enable :static
    enable :partial_underscores
  end

  # Helpers
  helpers Sprockets::Helpers
  helpers Sinatra::ContentFor
  helpers do
    def logger
      request.logger
    end
  end

  # Sockets
  get "/broadcast/:user/live" do
    request.websocket do |ws|
      current_channel = nil

      ws.onopen do
        # TODO Use params[:token] to make sure this is the real params[:user]
        current_channel = BroadcastChannel.new(user: params[:user], ws: ws)
        $broadcast_channels << current_channel
      end

      ws.onclose { current_channel.close }

      ws.onmessage do |message|
        # Forward the message to the listeners
        EM.next_tick { current_channel.listen_channels.each { |channel| channel.ws.send(message) } }
      end
    end
  end

  get "/listen/:user/live" do
    request.websocket do |ws|
      current_channel = nil

      ws.onopen do
        current_channel = ListenChannel.new(user: params[:user], ws: ws)
        $listen_channels << current_channel
      end

      ws.onclose { current_channel.close }
    end
  end

  # Routes
  get "/" do
    haml :index
  end

  get "/listen/:user" do
    halt 404 unless BroadcastChannel.find_by_user(params[:user])
    haml :listen
  end

  get "/broadcast" do
    haml :broadcast
  end
end
