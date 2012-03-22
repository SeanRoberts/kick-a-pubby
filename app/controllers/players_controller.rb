class PlayersController < ApplicationController
  before_filter :not_a_pubby_required, :only => [:kick]

  def index
    @players = PlayerList.new
  end

  def kick
    @players = PlayerList.new
    resp = @players.kick_pubby
    if resp
      flash[:notice] = "#{resp.name} kicked."
    else
      flash[:notice] = "No pubbies to kick."
    end
    redirect_to players_path
  end
end