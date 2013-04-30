class ListenChannel < OpenStruct
  def self.find_by_ws(ws)
    $listen_channels.select { |c| c.ws == ws }.first
  end

  def pong!
    self.socket.send MultiJson.dump(event: 'pong', data: {})
  end

  def close
    $listen_channels.delete(self)
  end
end
