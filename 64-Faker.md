## Faker stuff

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
