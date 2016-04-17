module TeamsHelper
  def teams_index_header(league)
    if league.nil?
      content_tag :h1, "All Team Rankings"
    else
      content_tag :h1, "#{league.name} Rankings"
    end
  end

  def create_team_link
    if current_user && !has_team_check?
      link_to "Create Your Team", new_team_path, class: "btn btn-success btn-sm"
    end
  end
end
