# Borrowers API

This README would normally document whatever steps are necessary to get the
application up and running.

* Ruby version: 2.3.1

* System dependencies

* Configuration:
  - https://github.com/cerebris/jsonapi-resources

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

## Up and running

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
