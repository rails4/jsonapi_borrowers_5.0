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
