class RconConnection
  def initialize
    port = ENV["RCON_PORT"] ? ENV["RCON_PORT"].to_i : 27015
    @server = SourceServer.new(ENV["RCON_ADDRESS"], port)
    @server.init
    @server.rcon_auth(ENV["RCON_PASSWORD"])
  end

  def command(arg)
    @server.rcon_exec(arg)
  end
end