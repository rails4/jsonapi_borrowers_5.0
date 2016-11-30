# class Article < ApplicationRecord
# end
class Article < ActiveRecord::Base
  validates :name, presence: true
end
