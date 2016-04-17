class RosterSpotsController < ApplicationController
  load_and_authorize_resource

  def create
    if !!current_user.team
      response = current_user.team.add_player(params[:player_id])
      redirect_to current_user.team, notice: response
    else
      redirect_to new_team_path, alert: "Please create a team first."
    end
  end

  def destroy
    @spot = RosterSpot.find(params[:id])
    team = @spot.team
    team.drop_player(@spot.player_id)
    redirect_to team, notice: "Player successfully dropped."
  end

  def update
    @spot = RosterSpot.find(params[:id])
    response = @spot.toggle
    redirect_to @spot.team, notice: response
  end

end
