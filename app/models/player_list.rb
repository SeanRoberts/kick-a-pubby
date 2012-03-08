class PlayerList
  def initialize
    @players = []
    @remote_attempts = 0
    regex = /^#\s+\d+\s+\"(.+)\"\s+([_A-Za-z:0-9]+)\s/
    raw_status.split("\n")[8..-1].each do |line|
      match = line.match(regex)
      @players << Player.new(match.captures[0], match.captures[1]) if match && match.captures[0] != "replay"
    end
  end


  def each(&blk)
    @players.each(&blk)
  end

  def select(&blk)
    @players.select(&blk)
  end

  def size
    @players.size
  end

  def players
    @players
  end

  private
    def raw_status
      if !File.exist?(cache_path) || File.mtime(cache_path) < lambda { 5.minutes.ago }.call
        remote_status
      else
        local_status
      end
    end

    def remote_status
      begin
        @remote_attempts += 1
        rcon = RconConnection.new
        f = File.new(cache_path, "wb")
        status = rcon.command('status')
        f.puts status
        f.close
        status
      rescue RCon::NetworkException => e
        puts "[Rcon Error] " + e
        if @remote_attempts < 3
          local_status
        else
          raise "Unable to retrieve remote status and local status cache empty."
        end
      end
    end

    def local_status
      status = File.open(cache_path, "rb").read
      status.blank? ? remote_status : status
    end

    def cache_path
      File.join(Rails.root, 'tmp', 'status_cache.txt')
    end
end