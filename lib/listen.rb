class Listen
  def initialize
    @thread = Thread.new do
      redis = Redis.new(timeout: 0)
      Thread.current['channels'] = []

      redis.psubscribe("user.*") do |on|
        on.pmessage do |pattern, channel, message|
          user = channel.split(/^user\./).last

          listeners = Thread.current['channels'].select { |c| c.user == user }
          listeners.map(&:socket).each { |socket| socket.send(message) }
        end
      end
    end
  end

  def method_missing(name, *args, &blk)
    @thread.send(name, *args, &blk)
  end
end
