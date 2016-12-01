## Fetching Data

* [JSON:API, Fetching](http://jsonapi.org/format/1.0/#fetching)

Update database with random data.
```sh
rails db:drop
rails db:seed
```

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

```sh
curl -s localhost:3000/friends?sort=last-name |  jq '.data | map(.attributes)'
```




### Filtering


### Pagination
