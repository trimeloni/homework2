class Movie < ActiveRecord::Base
  def self.Ratings
    return ['G','PG','PG-13','R']
  end 
end
