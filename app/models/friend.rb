class Friend < ActiveRecord::Base
  MAX_FRIENDS_PER_USER = 4

  belongs_to :user
  validates_presence_of :user
  validates_presence_of :steam_id
  validates_uniqueness_of :steam_id, :on => :create, :message => "is already someone's friend."
  validate :is_not_over_limit

  attr_accessible :steam_id, :name

  def name
    super || "[unknown]"
  end

  def self.max_friends_per_user
    MAX_FRIENDS_PER_USER
  end

  private
    def is_not_over_limit
      errors.add(:base, "You already have #{MAX_FRIENDS_PER_USER} friends, don't you think that's enough?") if user.friends.size > MAX_FRIENDS_PER_USER
    end
end
