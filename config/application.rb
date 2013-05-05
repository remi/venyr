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
    set :redis, Redis.new
    set :listen, Listen.new

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

      socket.onopen do
        begin
          if current_user && current_user.username == user
            logger.info "Broadcast started for #{user}"
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
                settings.redis.hset "user.#{user}", "track", MultiJson.dump(parsed_message[:data][:track])
                settings.redis.publish "user.#{user}", message
              when 'playStateChange'
                settings.redis.hset "user.#{user}", "state", parsed_message[:data][:state]
                settings.redis.publish "user.#{user}", message
            end
          rescue
            error!(socket)
          end
        end
      end

      socket.onclose do |socket|
        settings.redis.del "user.#{user}"
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

          if track = settings.redis.hget("user.#{user}", "track")
            socket.send MultiJson.dump(event: 'playingTrackChange', data: { track: MultiJson.load(track) })
          end

          if state = settings.redis.hget("user.#{user}", "state")
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
      end
    end
  end

  # Routes
  get("/") { haml :index }
  get("/broadcast") { haml :broadcast }
  get("/listen/:user") do
    @user = params[:user]
    if settings.redis.hget("user.#{@user}", 'track')
      haml :listen
    else
      @message = :no_broadcasting
      halt 404
    end
  end


  # Errors
  not_found { haml :'404' }
end
