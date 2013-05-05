module VenyrHelper
  def logger
    @logger ||= Logger.new(request.env['rack.errors']).tap do |logger|
      logger.formatter = proc do |severity, datetime, progname, msg|
         "-- #{datetime} Venyr: #{msg}\n"
      end
    end
  end

  def current_user
    @_current_user ||= begin
      logger.info 'Fetching Rdio user'
      response = settings.rdio.post('/api/1') do |req|
        req.body = { method: 'currentUser', extras: 'username' }
        req.headers['Authorization'] = "Bearer #{params[:token]}"
      end

      OpenStruct.new(response.body["result"])
    rescue
      nil
    end
  end

  def pong!(socket)
    socket.send MultiJson.dump(event: 'pong', data: {})
  end

  def error!(socket, message=nil)
    socket.send(MultiJson.dump(event: 'fatalError', data: { message: message }))
  end
end
