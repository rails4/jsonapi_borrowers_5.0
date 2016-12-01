## Fetching Data

* [JSON:API. Fetching Data](http://jsonapi.org/format/1.0/#fetching)

Update database with random data.
```sh
rails db:drop
rails db:seed
```

* Check code in [db/seeds.rb](db/seeds.rb).

Check seeded data on `rails console`.
```ruby
Friend.count
Article.count
Loan.count

ap Friend.first.loans
ap Friend.first
ap Article.first.loans
Article.first.loans.length
```


### Side-loading related resources

Pobierz wypożyczkę 1.
```sh
http GET 'http://localhost:3000/loans/1?include=friend,article' \
  | jq
http GET 'http://localhost:3000/loans/1?include=friend,article' \
  | jq '.included[0].attributes'
http GET 'http://localhost:3000/loans/1?include=friend,article' \
  | jq '.included[1].attributes'
```


### Sparse Fieldsets

Let’s explore how can we ask the API to only include a specific subset of fields
for a resource.

```sh
# does not work – should be percent-encoded (following rfc3986)
curl -s localhost:3000/friends/2?fields[friends]=first-name,last-name | jq
# does work
curl -s localhost:3000/friends/2?fields%5Bfriends%5D=first-name,last-name | jq
curl -X GET http://localhost:3000/friends/2 \
  --data-urlencode 'fields[friends]=first-name,last-name' | jq
# this also works with curl
curl -X GET http://localhost:3000/friends/2 \
  -d 'fields[friends]=first-name,last-name' | jq
```

We also side-load all the loans limiting the fields to notes for the loans.
```sh
curl -s -X GET localhost:3000/friends/1 \
  -d 'include=loans' \
  -d 'fields[loans]=notes' \
  | jq '.included'
```


### Sorting

Ascending.
```sh
curl -s localhost:3000/friends?sort=last-name |  jq '.data | map(.attributes)'
```
Descending.
```sh
curl -s localhost:3000/friends?sort=-last-name \
  |  jq '.data | map(.attributes)'
curl -s localhost:3000/friends?sort=-first-name,last-name \
  |  jq '.data | map(.attributes)'
```


### Filtering

Unlike sorting and sparse fields, JSON API doesn’t have a strict specification
on how filtering35 should work. The keyword filter is reserved for this kind of
operation and the server API designer can implement any strategy, based on their
own needs.

Update _FriendResource_.
```ruby
# app/resources/friend_resource.rb
class FriendResource < JSONAPI::Resource
  attributes :first_name, :last_name, :email, :twitter

  has_many :loans, acts_as_set: true

  filter :id
  filters :last_name, :first_name, :email
end
```

Examples of filtering.
```sh
curl -s -X GET http://localhost:3000/friends -d 'filter[id]=2,3' \
  | jq '.data | map(.id)'
curl -s -X GET http://localhost:3000/friends -d 'filter[id]=2,3' \
  | jq '.data | map(.attributes)'
curl -s -X GET http://localhost:3000/friends -d 'filter[first-name]=Tomasz' \
  | jq '.data | map (.attributes)'
# | jq '.data | map (.attributes."first-name")'
```

* zob. też [JSONAPI::Resources. Filters](http://jsonapi-resources.com/v0.8/guide/resources.html#Filters)

Uncomment `filter :first_name` in _friend_resource.rb_,
restart Rails server and run this command:
```sh
curl -s -X GET http://localhost:3000/friends -d 'filter[first-name]=to' \
  | jq '.data | map(.attributes)'
```


### Pagination

* [JSONAPI::Resources. Pagination](http://jsonapi-resources.com/v0.8/guide/resources.html#Pagination)
