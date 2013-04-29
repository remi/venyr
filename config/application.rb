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
  end

  # Helpers
  helpers Sprockets::Helpers
  helpers Sinatra::ContentFor
  helpers do
    def logger
      @logger ||= Logger.new(request.env['rack.errors']).tap do |logger|
        logger.formatter = proc do |severity, datetime, progname, msg|
           "-- Venyr: #{msg}\n"
        end
      end
    end

    def socket_error(socket, message=nil)
      socket.send(MultiJson.dump(event: 'fatalError', data: { message: message }))
    end
  end

  # Sockets
  get "/broadcast/:user/live" do
    request.websocket do |socket|
      current_channel = nil

      socket.onopen do
        begin
          logger.info "Broadcast initiated for #{params[:user]}"
          # TODO Use params[:token] to make sure this is the real params[:user]
          current_channel = BroadcastChannel.new(user: params[:user], socket: socket)
          $broadcast_channels << current_channel
        rescue
        end
      end

      socket.onclose { current_channel && current_channel.close }

      socket.onmessage do |message|
        EM.next_tick do
          begin
            logger.info "Broadcast message (#{current_channel.user}) received: #{message}"
            current_channel.update_current_data(message)
            current_channel.listen_channels.each { |channel| channel.socket.send(message) }
          rescue
            socket_error(socket)
          end
        end
      end
    end
  end

  get "/listen/:user/live" do
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

  error 404 do
    haml :'404'
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
end
