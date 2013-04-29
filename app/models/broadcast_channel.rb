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

  def update_current_data(message)
    parsed_message = MultiJson.load(message, :symbolize_keys => true)

    case parsed_message[:event]
      when "playingTrackChange"
        self.current_track = parsed_message[:data][:track]
      when "playStateChange"
        self.current_state = parsed_message[:data][:state]
    end
  end
end
