class Team < ActiveRecord::Base
  validates_presence_of :name, :user_id
  belongs_to :user
  belongs_to :league
  has_many :roster_spots, dependent: :destroy
  has_many :players, through: :roster_spots

  def players_attributes=(players_attributes)
    players_attributes.values.each do |player_attribute|
      if player_attribute[:player_url].include?("http://www.basketball-reference.com/players")
        player = Player.find_or_create_by(player_url: player_attribute[:player_url])
        player.update_info
        unless self.players.include?(player)
          self.players << player
        end
      end  
    end   
  end 

  def join_league(league_id)
    self.update(league_id: league_id)
  end
  
  def owner_name
    self.user.name
  end

  def full_starters?
    self.starters.count >= 5
  end

  def salary
    self.players.inject(0){|sum, player| sum += player.salary}
  end

  def self.most_efficient_teams
    Team.all.max_by(10) do |team|
      team.efficiency
    end
  end

  def efficiency
    if self.salary == 0 || self.salary.nil?
      return 0
    else
      return (self.score / (self.salary.to_f / 1000000)).round(2)
    end
  end

  def starters
    self.players.select do |player|
      player if player.status(self) == "Starter"
    end
  end

  def benchwarmers
    self.players.select do |player|
      player if player.status(self) == "Benched"
    end
  end

  def status_sorted_roster
    self.starters + self.benchwarmers
  end

  def update_salaries
    self.update(salary_remaining: 70000000 - salary)
  end

  def team_setup
    update_salaries
    response = enforce_salary_cap
    set_lineup
    response == 0 ? "Successfully created team" : "Created team but you couldn't afford all those players. #{response} players were auto-dropped."
  end

  def enforce_salary_cap
    dropped = 0
    while self.salary > 70000000
      least_valuable = self.players.least_valuable
      self.drop_player(least_valuable.id)
      self.reload.update_salaries
      dropped += 1
    end
    return dropped
  end

  def bench_all
    self.players.each {|player| player.set_status(self, false)}
  end

  def set_lineup
    self.bench_all
    starting_lineup = self.players.max_by(5) do |player|
      player.score
    end
    starting_lineup.each do |player|
      player.set_status(self, true)
    end
  end

  def add_player(player_id)
    player = Player.find(player_id)
    if player.salary < self.salary_remaining
      self.roster_spots.build(player_id: player_id, starter: !self.full_starters?).save
      self.reload.update_salaries
      return "#{player.name} added to #{self.name}"
    else
      return "Sorry, you can't afford that player. Try dropping players to free up salary."
    end
  end

  def drop_player(player_id)
    spot = RosterSpot.find_by(player_id: player_id, team_id: self.id)
    spot.destroy
    self.update_salaries
  end

end
