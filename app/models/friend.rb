class Friend < ActiveRecord::Base
  has_many :loans

  validates :first_name, presence: true
  validates :email, presence: true
  validates :last_name, presence: true
end
