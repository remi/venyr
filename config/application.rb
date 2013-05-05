class App < Sinatra::Base
  # Middleware
  use Rack::CanonicalHost, ENV['CANONICAL_HOST']

  # Plugins
  register Sinatra::Partial

  # Configuration
  configure do
    set :haml, format: :html5, attr_wrapper: '"', ugly: false
    set :root, proc { File.expand_path('./') }
    set :views, proc { File.join(root, 'app/views') }
    set :public_folder, proc { File.join(root, 'public') }
    set :rdio, Rdio.new
    set :listen, Listen.new
    set :broadcast, Broadcast.new

    enable :static
    enable :partial_underscores
  end

  # Helpers
  helpers Sprockets::Helpers
  helpers Sinatra::ContentFor
  helpers VenyrHelper

  # Sockets
  get "/live/broadcast/:user" do
    request.websocket do |socket|
      user = params[:user]
      channel = OpenStruct.new(socket: socket, user: user)

      socket.onopen do
        begin
          if current_user && current_user.username == user
            logger.info "Broadcast started for #{user}"
            REDIS.hset "listen.#{user}", "listeners", 0
            settings.broadcast['channels'] << channel
          else
            logger.info "Broadcast rejected for #{user}"
            halt 401
          end
        rescue
          error!(socket)
        end
      end

      socket.onmessage do |message|
        parsed_message = MultiJson.load(message, symbolize_keys: true) rescue(error! socket)

        EM.next_tick do
          begin
            case parsed_message[:event]
              when 'ping'
                pong!(socket)
              when 'playingTrackChange'
                REDIS.hset "listen.#{user}", "track", MultiJson.dump(parsed_message[:data][:track])
                REDIS.publish "listen.#{user}", message
              when 'playStateChange'
                REDIS.hset "listen.#{user}", "state", parsed_message[:data][:state]
                REDIS.publish "listen.#{user}", message
            end
          rescue
            error!(socket)
          end
        end
      end

      socket.onclose do |socket|
        settings.broadcast['channels'].delete(channel)
        REDIS.del "listen.#{user}"
      end
    end
  end

  get "/live/listen/:user" do
    request.websocket do |socket|
      user = params[:user]
      channel = OpenStruct.new(socket: socket, user: user)

      socket.onopen do
        begin
          settings.listen['channels'] << channel
          Broadcast.increase_listeners_count(user)

          if track = REDIS.hget("listen.#{user}", "track")
            socket.send MultiJson.dump(event: 'playingTrackChange', data: { track: MultiJson.load(track) })
          end

          if state = REDIS.hget("listen.#{user}", "state")
            socket.send MultiJson.dump(event: 'playStateChange', data: { state: state })
          end
        rescue
          error!(socket)
        end
      end

      socket.onmessage do |message|
        begin
          parsed_message = MultiJson.load(message, symbolize_keys: true)
          EM.next_tick { pong!(socket) if parsed_message[:event] == 'ping' }
        rescue
          error!(socket)
        end
      end

      socket.onclose do
        settings.listen['channels'].delete(channel)
        Broadcast.decrease_listeners_count(user)
      end
    end
  end

  # Routes
  get("/") { haml :index }
  get("/broadcast") { haml :broadcast }
  get("/listen/:user") do
    @user = params[:user]
    if REDIS.hget("listen.#{@user}", 'track')
      haml :listen
    else
      @message = :no_broadcasting
      halt 404
    end
  end


  # Errors
  not_found { haml :'404' }
end
