class User < ActiveRecord::Base
  has_many :friends

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.name = auth["info"]["nickname"]
      user.community_id = auth["extra"]["raw_info"]["steamid"]
    end
  end

  def pubby?
    group = Group.new(ENV["GROUP_NAME"])
    !group.member_ids.include?(community_id)
  end

  def friend(friend_id)
    friends.find(friend_id)
  end

  def add_friend(params)
    friends.create(params)
  end
end
