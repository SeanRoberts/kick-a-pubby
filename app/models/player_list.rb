class PlayerList
  def initialize
    @players = []
    regex = /^#\s+\d+\s+\"(.+)\"\s+([_A-Za-z:0-9]+)\s/
    raw_status.split("\n")[8..-1].each do |line|
      match = line.match(regex)
      @players << Player.new(match.captures[0], match.captures[1]) if match
    end
  end
  
  
  def each(&blk)
    @players.each(&blk)
  end
  
  def size
    @players.size
  end
  
  def players
    @players
  end
  
  private
    def raw_status
      if !File.exist?(cache_path) || File.mtime(cache_path) < 5.minutes.ago
        remote_status
      else
        local_status
      end
    end
    
    def remote_status
      begin
        rcon = RconConnection.new
        f = File.new(cache_path, "w")
        status = rcon.command('status')
        f.puts status
        f.close
        status
      rescue OpenURI::HTTPError
        local_xml
      end
    end
    
    def local_status
      begin
        File.open(cache_path, "rb").read
      rescue
        raise "Could not open status"
      end
    end
  
    def cache_path
      File.join(Rails.root, 'tmp', 'status_cache.txt')
    end
end    