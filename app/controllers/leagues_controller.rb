class LeaguesController < ApplicationController
  load_and_authorize_resource
  before_action :set_league, only: [:show, :edit, :update, :destroy]

  def index
    @leagues = League.all
  end

  def show
    @teams = @league.teams.sort {|a,b| b.score<=>a.score}
  end

  def new
    @league = League.new
  end

  def create
    @league = League.create(league_params)
    @league.user = current_user
    if @league.save
      redirect_to @league
    else
      flash.now[:alert] = @league.errors.full_messages.first
      render :new
    end
  end

  def edit

  end

  def update
    @league.update(league_params)
    redirect_to @league
  end

  def destroy
    @league.destroy
    redirect_to leagues_path
  end

  private

  def league_params
    params.require(:league).permit(:name, :user_id)
  end

  def set_league
    @league = League.find(params[:id])
  end
end
