class Player
  attr_accessor :steam_id, :name

  # Pass a line from an rcon status call
  def initialize(name, steam_id)
    self.name, self.steam_id = name, steam_id
  end

  def community_id
    arr = steam_id.split(':')
    @community_id ||= '7656' + (arr[1].to_i + arr[2].to_i * 2 + 1197960265728).to_s
  end

  def pubby?
    group = Group.new(ENV["GROUP_NAME"])
    bot? || !group.member_ids.include?(community_id)
  end

  def bot?
    steam_id == "BOT"
  end

  def kick
    file = File.join(Rails.root, 'tmp', 'status_cache.txt')
    File.unlink(file) if File.exist?(file)
    @rcon = RconConnection.new
    @rcon.command("kick \"#{name}\"")
    @rcon.command("say \"#{name} was kicked by kick-a-pubby.\"")
    self
  end
end