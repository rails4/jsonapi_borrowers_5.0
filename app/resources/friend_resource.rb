class FriendResource < JSONAPI::Resource
  attributes :first_name, :last_name, :email
  attribute :twitter
end
