class App < Sinatra::Base
  # Middleware
  use Rack::CanonicalHost, ENV['CANONICAL_HOST']

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

    # Use globals, because why not?
    $broadcast_channels = []
    $listen_channels = []

    # Rdio API
    class ParseJson < Faraday::Response::Middleware
      def on_complete(env)
        env[:body] = MultiJson.load(env[:body]) rescue nil
      end
    end

    $api = Faraday.new(url: 'https://www.rdio.com', ssl: { verify: false }) do |connection|
      connection.use ParseJson
      connection.request :url_encoded
      connection.adapter :net_http
    end
  end

  # Helpers
  helpers Sprockets::Helpers
  helpers Sinatra::ContentFor
  helpers do
    def logger
      @logger ||= Logger.new(request.env['rack.errors']).tap do |logger|
        logger.formatter = proc do |severity, datetime, progname, msg|
           "-- #{datetime} Venyr: #{msg}\n"
        end
      end
    end

    def socket_error(socket, message=nil)
      socket.send(MultiJson.dump(event: 'fatalError', data: { message: message }))
    end

    def current_user
      @_current_user ||= begin
        logger.info '!!!!!!!!!!! Fetching Rdio user'
        response = $api.post('/api/1') do |req|
          req.body = { method: 'currentUser', extras: 'username' }
          req.headers['Authorization'] = "Bearer #{params[:token]}"
        end

        OpenStruct.new(response.body["result"])
      rescue
        nil
      end
    end
  end

  # Sockets
  get "/live/broadcast/:user" do
    request.websocket do |socket|
      current_channel = nil

      socket.onopen do
        begin
          logger.info "Broadcast initiated for #{params[:user]}"

          if current_user && current_user.username == params[:user]
            current_channel = BroadcastChannel.new(user: params[:user], socket: socket)
            $broadcast_channels << current_channel
          else
            logger.info "Broadcast rejected for #{params[:user]}"
          end
        rescue
        end
      end

      socket.onclose { current_channel && current_channel.close }

      socket.onmessage do |message|
        EM.next_tick do
          begin
            logger.info "Broadcast message (#{current_channel.user}) received: #{message}"
            parsed_message = MultiJson.load(message, :symbolize_keys => true)
            current_channel.update_current_data(parsed_message)

            if parsed_message[:event] != "ping"
              current_channel.listen_channels.each { |channel| channel.socket.send(message) }
            else
              current_channel.pong!
            end
          rescue
            socket_error(socket)
          end
        end
      end
    end
  end

  get "/live/listen/:user" do
    request.websocket do |socket|
      current_channel = nil

      socket.onopen do
        begin
          logger.info "New listener for #{params[:user]}"
          current_channel = ListenChannel.new(user: params[:user], socket: socket)
          $listen_channels << current_channel

          if broadcast_channel = BroadcastChannel.find_by_user(params[:user])
            broadcast_channel.increase_listeners!
            socket.send MultiJson.dump(event: 'playingTrackChange', data: { track: broadcast_channel.current_track })
            socket.send MultiJson.dump(event: 'playStateChange', data: { state: broadcast_channel.current_state })
          end
        rescue
          socket_error(socket)
        end
      end

      socket.onmessage do |message|
        EM.next_tick do
          begin
            logger.info "Listener message (broadcaster: #{current_channel.user}) received: #{message}"
            current_channel.pong!
          rescue
            socket_error(socket)
          end
        end
      end

      socket.onclose do
        if broadcast_channel = BroadcastChannel.find_by_user(current_channel.user)
          broadcast_channel.decrease_listeners!
        end

        current_channel && current_channel.close
      end
    end
  end

  # Routes
  get "/" do
    haml :index
  end

  get "/listen/:user" do
    if BroadcastChannel.find_by_user(@user = params[:user])
      haml :listen
    else
      @message = :no_broadcasting
      halt 404
    end
  end

  get "/broadcast" do
    haml :broadcast
  end

  # Errors
  not_found do
    haml :'404'
  end
end
