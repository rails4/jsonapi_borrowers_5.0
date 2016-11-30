class FriendResource < JSONAPI::Resource
  attributes :first_name, :last_name, :email, :twitter
  has_many :loans
end
