# class ArticleResource < JSONAPI::Resource
# end
class ArticleResource < JSONAPI::Resource
  attributes :name, :available
  has_many :loans
end
