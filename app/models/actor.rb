class Actor < ActiveRecord::Base
  belongs_to :user
  has_many :actor_genres
  has_many :genres, :through => :actor_genres
  has_many :actor_movies
  has_many :movies, :through => :actor_movies
  has_many :actor_shows
  has_many :shows, :through => :actor_shows
  validates :name, presence: true

  def slug
  	x = self.name
  	x = x.downcase.gsub(/[^a-z ]/,"").gsub(" ","-")
    x
  end

  def self.find_by_slug(slug)
  	x = Actor.all.find do |a|
      a.slug == slug
  	  end
    x
  end

end
