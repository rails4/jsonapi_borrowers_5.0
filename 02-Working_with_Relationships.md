## Working with Relationships

* [Guide](http://jsonapi-resources.com/v0.8/guide/)

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
```sh
rails routes
#   Prefix Verb   URI Pattern             Controller#Action
#  friends ...
# articles ...
#    loans GET    /loans(.:format)        loans#index
#         POST    /loans(.:format)        loans#create
#     loan GET    /loans/:id(.:format)    loans#show
#        PATCH    /loans/:id(.:format)    loans#update
#          PUT    /loans/:id(.:format)    loans#update
#       DELETE    /loans/:id(.:format)    loans#destroy
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

TODO: add saved requests

```sh
http localhost:3000/loans
```
```json
{
    "data": [
        {
            "attributes": {
                "notes": "necessarily wash",
                "returned": false
            },
            "id": "1",
            "links": {
                "self": "http://localhost:3000/loans/1"
            },
            "relationships": {
                "article": {
                    "links": {
                        "related": "http://localhost:3000/loans/1/article",
                        "self": "http://localhost:3000/loans/1/relationships/article"
                    }
                },
                "friend": {
                    "links": {
                        "related": "http://localhost:3000/loans/1/friend",
                        "self": "http://localhost:3000/loans/1/relationships/friend"
                    }
                }
            },
            "type": "loans"
        }
    ]
}
```
```sh
http localhost:3000/loans | jq '.data[0].relationships.friend.links.self'
```

Get friend via relationships.
```sh
curl -s localhost:3000/loans/1/relationships/friend | jq
```
```json
{
  "links": {
    "self": "http://localhost:3000/loans/1/relationships/friend",
    "related": "http://localhost:3000/loans/1/friend"
  },
  "data": {
    "type": "friends",
    "id": "1"
  }
}
```

Get friend directly.
```sh
curl -s localhost:3000/loans/1/friend | jq
```
```json
{
  "data": {
    "id": "1",
    "type": "friends",
    "links": {
      "self": "http://localhost:3000/friends/1"
    },
    "attributes": {
      "first-name": "Cyryl",
      "last-name": "Metody",
      "email": "cm@example.com",
      "twitter": null
    }
  }
}
```

















## ?
