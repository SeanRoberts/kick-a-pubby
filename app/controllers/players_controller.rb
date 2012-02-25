class PlayersController < ApplicationController
  before_filter :not_a_pubby_required, :only => [:kick]
  
  def index
    @players = PlayerList.new
  end
  
  def kick
    flash[:notice] = Player.kick_pubby
    redirect_to players_path
  end
end