## Working with Relationships

* [JSONAPI::Resources Guide](http://jsonapi-resources.com/v0.8/guide/)

Create _Article_ model.
```sh
rails g model article name:string available:boolean
rails db:migrate
```

Create _Article_ resource and _ArticleController_.
```sh
rails g jsonapi:resource article
rails g controller articles
```

Add validations to _Article_ model and attributes to _ArticleResource_.
```ruby
# app/models/friend.rb
class Article < ActiveRecord::Base
  validates :name, presence: true
end
# app/resources/article_resource.rb
class ArticleResource < JSONAPI::Resource
  attributes :name, :available
end
```
Finally add `jsonapi_resources :articles` to routes
```ruby
# config/routes.rb.
Rails.application.routes.draw do
  jsonapi_resources :friends
  jsonapi_resources :articles
end
```
and update _ArticlesController_.
```ruby
# app/controllers/articles_controller.rb
class ArticlesController < JSONAPI::ResourceController
end
```

### Check if everything works as expected

- [ ] export requests


## Keeping track of loans

```sh
rails g model loan \
  notes:text \
  returned:boolean \
  friend:references \
  article:references
rails db:migrate
```
```sh
rails g jsonapi:resource loan
rails g controller loans
```
```ruby
# config/routes.rb.
Rails.application.routes.draw do
  jsonapi_resources :friends
  jsonapi_resources :articles
  jsonapi_resources :loans
end
```
and update _LoansController_.
```ruby
# app/controllers/loans_controller.rb
class LoansController < JSONAPI::ResourceController
end
```

TODO: check GET /loans endpoint


## Exposing the relationships in JSON API

First, update all models.
```ruby
# app/models/loan.rb
class Loan < ActiveRecord::Base
  belongs_to :friend
  belongs_to :article

  validates :friend, presence: true
  validates :article, presence: true
end

# app/models/article.rb
class Article < ActiveRecord::Base
  has_many :loans

  validates :name, presence: true
end

# app/models/friend.rb
class Friend < ActiveRecord::Base
  has_many :loans

  validates :first_name, presence: true
  validates :email, presence: true
  validates :last_name, presence: true
end
```
And and all resources.
```ruby
# app/resources/loan_resource.rb
class LoanResource < JSONAPI::Resource
  has_one :article # resources use has_one instead of belongs_to
  has_one :friend

  attributes :notes, :returned
end

# app/resources/article_resource.rb
class ArticleResource < JSONAPI::Resource
  has_many :loans

  attributes :name, :available
end

# app/resources/friend_resource.rb
class FriendResource < JSONAPI::Resource
  has_many :loans

  attributes :first_name, :last_name, :email, :twitter
end
```

Once our models are wired up, we want to expose the relationships in JSON
API. To do so, we use a syntax similar to the one we just used, but this time
we’ll write the relationships in the resource classes.

* see [JSONAPI::Resources Guide](http://jsonapi-resources.com/v0.10/guide/resources.html#Relationships)


### Creating _loans_

```sh
rails routes
#                      Prefix Verb      URI Pattern
#  friend_relationships_loans GET       /friends/:friend_id/relationships/loans
#                             POST      /friends/:friend_id/relationships/loans
#                             PUT|PATCH /friends/:friend_id/relationships/loans
#                             DELETE    /friends/:friend_id/relationships/loans
#                friend_loans GET       /friends/:friend_id/loans
#                     friends GET       /friends
#                             POST      /friends
#                      friend GET       /friends/:id
#                             PATCH     /friends/:id
#                             PUT       /friends/:id
#                             DELETE    /friends/:id
# article_relationships_loans GET       /articles/:article_id/relationships/loans
#                             POST      /articles/:article_id/relationships/loans
#                             PUT|PATCH /articles/:article_id/relationships/loans
#                             DELETE    /articles/:article_id/relationships/loans
#               article_loans GET       /articles/:article_id/loans
#                    articles GET       /articles
#                             POST      /articles
#                     article GET       /articles/:id
#                             PATCH     /articles/:id
#                             PUT       /articles/:id
#                             DELETE    /articles/:id
#  loan_relationships_article GET       /loans/:loan_id/relationships/article
#                             PUT|PATCH /loans/:loan_id/relationships/article
#                             DELETE    /loans/:loan_id/relationships/article
#                loan_article GET       /loans/:loan_id/article
#   loan_relationships_friend GET       /loans/:loan_id/relationships/friend
#                             PUT|PATCH /loans/:loan_id/relationships/friend
#                             DELETE    /loans/:loan_id/relationships/friend
#                 loan_friend GET       /loans/:loan_id/friend
#                       loans GET       /loans
#                             POST      /loans
#                        loan GET       /loans/:id
#                             PATCH     /loans/:id
#                             PUT       /loans/:id
#                             DELETE    /loans/:id
```

**Execute saved request.**

Using _jq_ to filter data from the response.
```sh
http localhost:3000/articles
http localhost:3000/articles | jq '.data[0]'
http localhost:3000/articles | jq '.data[0].links.self'
http localhost:3000/articles | jq '.data[0].relationships.loans.links'
```

Create an article.

Bash.
```sh
curl -X "POST" "http://localhost:3000/articles" \
     -H "Accept: application/vnd.api+json" \
     -H "Content-Type: application/vnd.api+json" \
     -d '{
           "data": {
             "type": "articles",
             "attributes": {
               "name": "Make Your Own Neural Network",
               "available": "true"
             }
           }
         }'
```

Ruby.
```ruby
def send_request
  uri = URI('http://localhost:3000/articles')

  # Create client
  http = Net::HTTP.new(uri.host, uri.port)
  dict = {
            "data" => {
                "type" => "articles",
                "attributes" => {
                    "name" => "Make Your Own Neural Network",
                    "available" => "true"
                }
            }
        }
  body = JSON.dump(dict)

  # Create Request
  req =  Net::HTTP::Post.new(uri)
  # Add headers
  req.add_field "Accept", "application/vnd.api+json"
  # Add headers
  req.add_field "Content-Type", "application/vnd.api+json"
  # Set body
  req.body = body

  # Fetch Request
  res = http.request(req)
  puts "Response HTTP Status Code: #{res.code}"
  puts "Response HTTP Response Body: #{res.body}"
rescue StandardError => e
  puts "HTTP Request failed (#{e.message})"
end
```


### Updating articles and loans

Get article 1
```sh
curl -s localhost:3000/article/1 | jq
# {
#   "data": {
#     "id": "1",
#     "type": "articles",
#     "links": {
#       "self": "http://localhost:3000/articles/1"
#     },
#     "attributes": {
#       "name": "Salomon Exo Motion Long",
#       "available": true
#     },
#   ...
```

Update article 1.
```sh
curl -X "PATCH" "http://localhost:3000/articles/1" \
     -H "Accept: application/vnd.api+json" \
     -H "Content-Type: application/vnd.api+json" \
     -d '
{
  "data": {
    "id": "1",
    "type": "articles",
    "attributes": {
      "name": "Salomon Exo Motion XXL"
    }
  }
}'
```

Get loan 1.
```sh
curl -s localhost:3000/loans/1 | jq
# {
#   "data": {
#     "id": "1",
#     "type": "loans",
#     "links": {
#       "self": "http://localhost:3000/loans/1"
#     },
#     "attributes": {
#       "notes": "necessarily wash",
#       "returned": false
#     },
#     ...
```


Update loan 1.
```sh
curl -X "PATCH" "http://localhost:3000/loans/1" \
     -H "Accept: application/vnd.api+json" \
     -H "Content-Type: application/vnd.api+json" \
     -d '
{
  "data": {
    "id": "1",
    "type": "loans",
    "attributes": {
      "notes": "size XXL (black)"
    }
  }
}'
```

### Updating relationships

Through `self` URL.
```sh
curl -s http://localhost:3000/loans/1/relationships/friend \
  -X PATCH \
  -H "Accept: application/vnd.api+json" \
  -H "Content-Type: application/vnd.api+json" \
  -d '
{
  "data": {
    "id": "4",
    "type": "friends"
  }
}'
```
