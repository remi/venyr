class BroadcastChannel < OpenStruct
  def initialize(*args)
    super(*args)
    @listeners_count = listen_channels.count
    update_listeners
  end

  def pong!
    self.socket.send MultiJson.dump(event: 'pong', data: {})
  end

  def listen_channels
    $listen_channels.select { |c| c.user == self.user }
  end

  def self.find_by_user(user)
    $broadcast_channels.select { |c| c.user == user }.first
  end

  def close
    $broadcast_channels.delete(self)
  end

  def update_current_data(message)
    parsed_message = MultiJson.load(message, :symbolize_keys => true)

    case parsed_message[:event]
      when "playingTrackChange"
        self.current_track = parsed_message[:data][:track]
      when "playStateChange"
        self.current_state = parsed_message[:data][:state]
    end
  end

  def increase_listeners!
    @listeners_count += 1
    update_listeners
  end

  def decrease_listeners!
    @listeners_count -= 1
    update_listeners
  end

  private
  def update_listeners
    self.socket.send MultiJson.dump(event: 'listenersCountChange', data: { count: @listeners_count })
  end
end
