require 'rcon'

class RconConnection
  def initialize
    @rcon = RCon::Query::Source.new(ENV["RCON_ADDRESS"], ENV["RCON_PORT"] || 27015)
    @rcon.auth(ENV["RCON_PASSWORD"])
  end
  
  def command(arg)
    @rcon.command(arg)
  end
end