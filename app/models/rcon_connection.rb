class RconConnection
  class AuthError < Exception; end;
  def initialize
    port = ENV["RCON_PORT"] ? ENV["RCON_PORT"].to_i : 27015
    @server = SourceServer.new(ENV["RCON_ADDRESS"], port)
  end

  def command(arg)
    if @server.rcon_authenticated? || @server.rcon_auth(ENV["RCON_PASSWORD"])
      @server.rcon_exec(arg)
    else
      raise AuthError, "Failed RCON Authentication"
    end
  end
end