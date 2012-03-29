class PlayersController < ApplicationController
  before_filter :not_a_pubby_required, :only => [:kick]

  def index
    respond_to do |format|
      format.html {}
      format.js {
        @players = PlayerList.new
        render partial: "list", layout: false
      }
    end
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