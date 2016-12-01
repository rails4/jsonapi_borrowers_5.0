# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Faker::Config.locale = :pl

def to_latin(s)
  s.gsub(
      /[ĄĆĘŁŃÓŚŹŻ]/,
      'Ą' => 'ą',
      'Ć' => 'ć',
      'Ę' => 'ę',
      'Ł' => 'ł',
      'Ń' => 'ń',
      'Ó' => 'ó',
      'Ś' => 'ś',
      'Ź' => 'ź',
      'Ż' => 'ż',
    ).gsub(
      /[ąćęłńóśźż]/,
      'ą' => 'a',
      'ć' => 'c',
      'ę' => 'e',
      'ł' => 'l',
      'ń' => 'n',
      'ó' => 'o',
      'ś' => 's',
      'ź' => 'z',
      'ż' => 'z')
end

def username(first, last)
  "#{first} #{last}"
end

def twittername(first)
  "@#{to_latin(first)}#{('0'..'9').to_a.shuffle[0..3].join}"
end

64.times do
  first_name = Faker::Name.first_name
  last_name = Faker::Name.last_name
  user = username(first_name, last_name)
  email = Faker::Internet.email(to_latin(user))
  twitter = twittername(first_name.downcase)

  Friend.find_or_create_by(first_name: first_name, last_name: last_name) do |f|
    f.email = email
    f.twitter = twitter
  end
end

256.times do
  name = Faker::Commerce.product_name
  Article.find_or_create_by(name: name) do |a|
    a.available = true
  end
end

friends_total = Friend.count
articles_total = Article.count
prng = Random.new

# create random loans
256.times do
  promo = Faker::Commerce.promotion_code
  Loan.find_or_create_by(notes: promo) do |loan|
    loan.returned = false
    loan.friend_id = prng.rand(friends_total) + 1
    loan.article_id = prng.rand(articles_total) + 1
  end
end
