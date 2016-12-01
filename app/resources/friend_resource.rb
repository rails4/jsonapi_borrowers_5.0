# class FriendResource < JSONAPI::Resource
#   attributes :first_name, :last_name, :email, :twitter
#   has_many :loans
# end

class FriendResource < JSONAPI::Resource
  attributes :first_name, :last_name, :email, :twitter

  has_many :loans, acts_as_set: true

  filters :last_name, :email

  # If we want to extend the filter to be more flexible, we can do so by passing
  # a callback in the apply option. The following modifies the first name filter
  # to return all records that match a certain pattern.

  filter :first_name
  # filter :first_name, apply: ->(records, value, _options) {
  #   records.where('friends.first_name LIKE ?', "%#{value.first}%")
  # }
  # filter[first_name]=to
end
