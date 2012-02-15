class DashboardController < ApplicationController
  
  
  skip_authorization_check

  def index
    @num_males = Record.where(:gender => 'M').to_a.length
    @num_females = Record.where(:gender => 'F').to_a.length
    @ages, @age_groups,@age_males, @age_females = Record.get_ages
    @race_counts = Record.get_races

    @groups = Record.get_race_groups


  end
  
end
