class Broadcast
  def initialize
    @thread = Thread.new do
      redis = Redis.new(timeout: 0)
      Thread.current['channels'] = []

      redis.psubscribe("broadcast.*") do |on|
        on.pmessage do |pattern, channel, message|
          user = channel.split(/^broadcast\./).last

          broadcasters = Thread.current['channels'].select { |c| c.user == user }
          broadcasters.map(&:socket).each { |socket| socket.send(message) }
        end
      end
    end
  end

  def method_missing(name, *args, &blk)
    @thread.send(name, *args, &blk)
  end

  def self.increase_listeners_count(user)
    update_listeners_count(user, 1)
  end

  def self.decrease_listeners_count(user)
    update_listeners_count(user, -1)
  end

  private
  def self.update_listeners_count(user, count)
    new_count = REDIS.hincrby "listen.#{user}", "listeners", count
    REDIS.publish "broadcast.#{user}", MultiJson.dump(event: 'listenersCountChange', data: { count: new_count })
  end
end
