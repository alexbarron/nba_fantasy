class Ability
  include CanCan::Ability

  def initialize(user)

    if user.nil?
      can :read, :all
    elsif user.admin?
      can :manage, :all
    else
      can :read, :all
      can :manage, Team, user_id: user.id
      can :manage, RosterSpot, team_id: user.team.id unless user.team.nil?
      can :create, League
      can :update, League, user_id: user.id
    end
  end
end