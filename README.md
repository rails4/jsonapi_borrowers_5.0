# Borrowers JSON API

Przykład z książki – Adolfo Builes, _JSON API by Exmple_.
Purpose: Want to learn about JSON API.

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


## Getting started

Generate a new Rails application preconfigure for API only apps:
```sh
rails new jsonapi_borrowers_5.0 --api
```


## Up and running

Show HTTP status codes:
```sh
cheat http
```

```sh
rails new borrowers-api --api
rails g model friend first_name:string last_name:string email:string twitter:string
    invoke  active_record
    create    db/migrate/20160513110627_create_friends.rb
    create    app/models/friend.rb
    invoke    test_unit
    create      test/models/friend_test.rb
    create      test/fixtures/friends.yml
rails db:migrate
rails serve
```

Resource model:

```json
{
  "type": "friends",
  "id": "1",
  "attributes": {
    "first_name": "Włodek",
    "last_name": "Bzyl",
     "email": "wb@rails.pl"
  }
}
```
```sh
rails g jsonapi:resource friend
    create  app/resources/friend_resource.rb
```
```ruby
class FriendResource < JSONAPI::Resource
end
```
```sh
curl localhost:3000/friends # {"status":404,"error":"Not Found","exception …
rails g controller friends
    create  app/controllers/friends_controller.rb
    invoke  test_unit
    create    test/controllers/friends_controller_test.rb
```      
```ruby
# app/controllers/friends_controller.rb
# class FriendsController < ApplicationController
#   JSONAPI::ResourceController
# end
class FriendsController < JSONAPI::ResourceController
end
# config/routes.rb
Rails.application.routes.draw do
  jsonapi_resources :friends
end
```
```sh
curl localhost:3000/friends | jq
{
  "data": []
}
```


## TODO

Bash:

```bash
rails g model User name:string
rails g model Post user:references title:string body:text
rails g model Comment post:references user:references body:text
rails db:migrate
```

Ruby:

```ruby
gem 'faker'
gem 'active_model_serializers', github: 'rails-api/active_model_serializers'
gem 'jsonapi-resources', github: 'cerebris/jsonapi-resources', branch: 'rails5'
```

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
