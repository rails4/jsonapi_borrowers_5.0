# Borrowers JSON API

Przykład z książki – Adolfo Builes, _JSON API by Example_ –

* The application will allow us to keep track of items we lend to our friends.

The main resources will be **friends**, **articles** and **loans** (pol.
_wypożyczki_). We can create as many friends and articles as we want. Each
friend will be able to borrow any number of articles as long as they are
available.

We’ll need to keep track of the status of every article (e.g. _borrowed_ or
_returned_) and we’ll need the option of adding notes to it.

----

**Purpose:** Want to learn about JSON API by error messages driven development,
[EMD2](http://www.progressrail.com) in short.

* Ruby version: 2.3.3
* Gem dependencies:
  * [jsonapi-resources](https://github.com/cerebris/jsonapi-resources), 0.8.1
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
* Database creation: TODO
* Database initialization: TODO
* How to run the test suite: TODO
* Services (job queues, cache servers, search engines, etc.)
* Deployment instructions: TODO


## Up and running

Generate a new Rails application preconfigure for API only apps:
```sh
rails new jsonapi_borrowers_5.0 --api
cd jsonapi_borrowers_5.0
bundle install
```

Begin with generating a model and accompanying resource:
```sh
rails g model friend first_name:string last_name:string email:string twitter:string
rails db: migrate
rails generate jsonapi:resource friend
```

_app/resources/friend_resource.rb_
```ruby
class FriendResource < JSONAPI::Resource
end
```

Resource:
```json
{
  "type": "friends",
  "id": "1",
  "attributes": {
    "first-name": "Adolfo",
    "last-name": "Builes",
    "email": "ab@example.com"
  }
}
```

Run Rails server
```sh
rails server
```

Curl or HTTPie?
```sh
curl http://localhost:3000/friends | jq
http localhost:3000/friends
```

Show HTTP status codes:
```sh
cheat http
```

## Trying to get friends

```sh
http localhost:3000/friends
```
displays this error message (on terminal running rails server)
```
Started GET "/friends" for ::1 at 2016-11-28 09:28:36 +0100
  ActiveRecord::SchemaMigration Load (0.4ms)  SELECT "schema_migrations".* FROM "schema_migrations"

ActionController::RoutingError (No route matches [GET] "/friends"):
```

We have not defined a route for a friend.
```sh
rails g controller friends
  create  app/controllers/friends_controller.rb
  invoke  test_unit
  create  test/controllers/friends_controller_test.rb
```
and define in _routes.rb_ routes to friends resource
```ruby
# config/routes.rb
Rails.application.routes.draw do
  jsonapi_resources :friends
end
```

**jsonapi_resources** offers two ways to help bring together our controllers and
resources: we can either inherit from _JSONAPI::ResourceController_, or use the
_ActsAsResourceController_ module.

Let change the controller to use _JSONAPI::ResourceController_:
```ruby
# class ApplicationController < ActionController::API
# end
# class FriendsController < ApplicationController
# end
class FriendsController < JSONAPI::ResourceController
end
```

Now, try
```sh
http localhost:3000/friends
{
  "data": []
}
```
This yields expected result, since we don’t yet have any friends.


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

HTTPie doesn’t work:
```sh
http --json POST 'http://localhost:3000/friends' 'Content-Type':'application/vnd.api+json' \
    data:='{"type": "friends", "attributes": {}}'
```

Try to delete some friends:
```sh
curl -i -X DELETE localhost:3000/friends/2
curl -i -X DELETE localhost:3000/friends/8
```

Create an alias for curl/POST:
```sh
alias cpf="curl -s localhost:3000/friends -X POST -H 'Content-Type: application/vnd.api+json'"
```

```sh
cpf -d '{"data":{"type":"friends", "attributes":{"first-name":"Cyril", "last-name":"Neveu"}}}' \
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
cpf -d '{"data":{"type":"friends", "attributes":{"first-name":"Cyril", "last-name":"Neveu"}}}' \
| jq
```






## Fake stuff

Seed database:

```ruby
george = User.where(name: Faker::Name.name).create
bob = User.where(name: Faker::Name.name).create

2.times do
  post = george.posts.create(
    title: [Faker::Hacker.adjective, Faker::Hacker.noun].join(' ').titleize,
    body: Faker::Hacker.say_something_smart
  )
  post.comments.create(body: Faker::Hipster.sentence, user: bob)
end
```

Ruby:

```ruby
# gem 'active_model_serializers', github: 'rails-api/active_model_serializers'
class PostsController < JSONAPI:ResourceController
end
```

Seed DB:

```ruby
george = User.where(name: Faker::Name.name).create
bob = User.where(name: Faker::Name.name).create

2.times do
  post = george.posts.create(
    title: [Faker::Hacker.adjective, Faker::Hacker.noun].join(' ').titleize,
    body: Faker::Hacker.say_something_smart
  )
  post.comments.create(body: Faker::Hipster.sentence, user: bob)
end
```

```bash
rails g model User name:string
rails g model Post user:references title:string body:text
rails g model Comment post:references user:references body:text
rails db:migrate

rails g serializer post
```

```ruby
gem 'faker'

gem 'active_model_serializers', github: 'rails-api/active_model_serializers'
gem 'jsonapi-resources'

ActiveModelSerializers.config.adapter = :json_api # serializers folder
```
