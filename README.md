# Borrowers JSON API

Przykład z książki – Adolfo Builes, _JSON API by Example_ –

* The application will allow us to keep track of items we lend to our friends.

The main resources will be **friends**, **articles** and **loans** (pol.
_wypożyczki_). We can create as many friends and articles as we want. Each
friend will be able to borrow any number of articles as long as they are
available.

We’ll need to keep track of the status of every article (e.g. _borrowed_ or
_returned_) and we’ll need the option of adding notes to it.

The basic idea behind **serverless computing** is to make the unit of
computation a function.

1. [ServerLess Framework](https://serverless.com) – build auto-scaling, pay-per-execution,
  event-driven apps on AWS Lambda
1. [Fission](http://fission.io) – serverless functions for Kubernetes.
  - [repo](https://github.com/platform9/fission)

----

**Purpose:** Want to learn about JSON API by error messages driven development,
[EMD2](http://www.progressrail.com) in short.

* Ruby version: 2.4.0
* Gem dependencies:
  - [jsonapi-resources](https://github.com/cerebris/jsonapi-resources), 0.8.1
  - consider use of
    the [jsonapi-utils](https://github.com/tiagopog/jsonapi-utils) gem
  - [cheat](http://cheat.errtheblog.com) – puts Ruby-centric cheat sheets
    right into your terminal ,
    [faker](https://github.com/stympy/faker) – a library for generating
    fake data such as names, addresses, and phone numbers
* API dependencies:
  [JSON:API](http://jsonapi.org/) – a specification for building APIs in JSON)
* System dependencies:
  - [jq](https://github.com/stedolan/jq) –
    [playground](https://jqplay.org), [docs](https://stedolan.github.io/jq/)
  - [HTTPie](https://httpie.org) – a command line HTTP client with
    an intuitive UI, JSON support, syntax highlighting,
    wget-like downloads, extensions, [docs](https://httpie.org/docs)
* Database creation: TODO – use MongoDB with Mongoid
* Database initialization: TODO
* How to run the test suite: TODO
* Services (job queues, cache servers, search engines, etc.)
* Deployment instructions: TODO


## Up and running

Generate a new Rails application preconfigure for API only apps:
```sh
rails new borrowers_5.0.1 --api # use Rails 5.0.1
cd borrowers_5.0.1
```

Uncomment _rack-cors_ gem and add gem _jsonapi-resources_ (v0.8.1) to _Gemfile_.

```sh
bundle install
```

Begin with generating a model and accompanying resource:
```sh
rails g model friend first_name:string last_name:string email:string twitter:string
rails db:migrate
```

Generate _FriendResource_ and _FriendsController_.
```sh
rails g jsonapi:resource   friend
rails g jsonapi:controller friends
```

Now, remove (unused) _application_controller.rb_.

Resource:
```json
{
  "type": "friends",
  "id": "1",
  "attributes": {
    "first-name": "Adolfo",
    "last-name": "Builes",
    "email": "ab@example.com",
    "twitter": null
  }
}
```

Run Rails server
```sh
rails server
```

# Do some checks

Curl or HTTPie?
```sh
curl http://localhost:3000/friends | jq
http localhost:3000/friends
```

Show HTTP status codes:
```sh
cheat http
```

This errror message (on terminal running rails server)
```
Started GET "/friends" for ::1 at 2016-11-28 09:28:36 +0100
  ActiveRecord::SchemaMigration Load (0.4ms)  SELECT "schema_migrations".* FROM "schema_migrations"

ActionController::RoutingError (No route matches [GET] "/friends"):
```
says that we have not defined a route for a friend resource.
```ruby
# config/routes.rb
Rails.application.routes.draw do
  jsonapi_resources :friends
end
```

Now, try hit/get _friends_ endpoint/resource once more.
```sh
http localhost:3000/friends
{
  "data": []
}
```
This yields expected result, since we don’t yet have any friends.


## TODO: Trying to get friends

**jsonapi_resources** offers two ways to help bring together our controllers and
resources: we inherit from _JSONAPI::ResourceController_.
```ruby
class FriendsController < JSONAPI::ResourceController
end
```


## Trying to create a friend

```sh
curl -s -i localhost:3000/friends -X POST --data-binary ''
curl -s    localhost:3000/friends -X POST --data-binary '' | jq

curl -s localhost:3000/friends -X POST -H 'Content-Type: application/vnd.api+json' \
| jq
curl -s localhost:3000/friends -X POST -H 'Content-Type: application/vnd.api+json' \
  -d '' \
| jq
curl -s localhost:3000/friends -X POST -H 'Content-Type: application/vnd.api+json' \
  -d '{"data": {"type":"friends", "attributes":{}}}' \
| jq
```

HTTPie needs an appropriate Accept header.
```sh
http POST 'http://localhost:3000/friends' \
 'Accept':'application/vnd.api+json' \
 'Content-Type':'application/vnd.api+json' \
  data:='{
    "type": "friends",
    "attributes": {
    }
  }'
```

Create an alias for curl/POST:
```sh
alias cpf="curl -s localhost:3000/friends -X POST -H 'Content-Type: application/vnd.api+json'"
```

```sh
cpf -d '{"data":{"type":"friends", "attributes":{"first-name":"Ryszard", "last-name":"K"}}}' \
| jq
```
```json
{
  "errors": [
    {
      "title": "Param not allowed",
      "detail": "first-name is not allowed.",
      "code": "105",
      "status": "400"
    },
    {
      "title": "Param not allowed",
      "detail": "last-name is not allowed.",
      "code": "105",
      "status": "400"
    }
  ]
}
```
```ruby
# resources/friend_resource.rb
class FriendResource < JSONAPI::Resource
  attributes :first_name, :last_name, :email
  attribute :twitter
end
```
```sh
cpf -d '{
  "data": {
    "type": "friends",
    "attributes": {
      "first-name": "Ryszard",
      "last-name": "K"
    }
  }
}' \
| jq
```
or use HTTPie
```sh
http POST 'http://localhost:3000/friends' \
 'Accept':'application/vnd.api+json' \
 'Content-Type':'application/vnd.api+json' \
  data:='{
    "type": "friends",
    "attributes": {
      "first-name": "Ryszard",
      "last-name": "K",
      "email": "rk@example.com"
    }
  }'
```

Define `hpf` alias:
```sh
alias hpf="http POST 'http://localhost:3000/friends' \
  'Accept':'application/vnd.api+json' \
  'Content-Type':'application/vnd.api+json'"
```


### Model validation

```ruby
# test/models/friend_test.rb
require 'test_helper'

class FriendTest < ActiveSupport::TestCase
  test 'requires first_name' do
    friend = Friend.new(last_name: 'A', email: 'a@example.com')
    assert_not friend.save, 'Saved friend without first_name'
    assert_not_empty friend.errors[:first_name]
  end

  test 'requires last_name' do
    friend = Friend.new(first_name: 'B', email: 'b@example.com')
    assert_not friend.save, 'Saved friend without last_name'
    assert_not_empty friend.errors[:last_name]
  end

  test 'requires email' do
    friend = Friend.new(first_name: 'C', last_name: 'D')
    assert_not friend.save, 'Saved friend without email'
    assert_not_empty friend.errors[:email]
  end
end
```
Tests should fail.
```sh
rails test test/models/friend_test.rb
```
```ruby
# models/friend.rb
class Friend < ActiveRecord::Base
  validates :first_name, presence: true
  validates :email, presence: true
  validates :last_name, presence: true
end
```
Tests should pass.
```sh
rake test test/models/friend_test.rb # use rake -- not rails
```
```sh
cpf -d'{"data":{"type":"friends", "attributes":{}}}' \
| jq
```
```json
{
  "errors": [
    {
      "title": "can't be blank",
      "detail": "first-name - can't be blank",
      "code": "100",
      "source": {
        "pointer": "/data/attributes/first-name"
      },
      "status": "422"
    },
    {
      "title": "can't be blank",
      "detail": "email - can't be blank",
      "code": "100",
      "source": {
        "pointer": "/data/attributes/email"
      },
      "status": "422"
    },
    {
      "title": "can't be blank",
      "detail": "last-name - can't be blank",
      "code": "100",
      "source": {
        "pointer": "/data/attributes/last-name"
      },
      "status": "422"
    }
  ]
}
```
```sh
cheat http # check for status 422
```
```sh
cpf -d '{
  "data": {
    "type": "friends",
    "attributes": {
      "first-name": "Cyryl",
      "last-name": "Metody",
      "email": "cm@example.com"
    }
  }
}' | jq
```
```json
{
  "data": {
    "id": "13",
    "type": "friends",
    "links": {
      "self": "http://localhost:3000/friends/13"
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

### Deleting _friends_

Add more friends:
```sh
hpf data:='{
  "type": "friends",
  "attributes": {
    "first-name": "X",
    "last-name": "Y",
    "email": "xy@example.com"
  }
}'
```
and immediately delete them (update friends id’s from the output above):
```sh
curl -X DELETE localhost:3000/friends/2 -i
curl -X DELETE localhost:3000/friends/2 -i
```
