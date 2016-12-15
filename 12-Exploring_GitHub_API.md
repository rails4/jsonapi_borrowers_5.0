## Exploring GitHub API

1. [Getting Started](https://developer.github.com/guides/getting-started/)
1. [Authentication](https://developer.github.com/v3/#authentication) –
  increase hourly rate limits from 60 to 5000:
  - [Creating an access token for command-line use](https://help.github.com/articles/creating-an-access-token-for-command-line-use/) –
  Personal Access Token
1. [Gitignore Templates API](https://developer.github.com/changes/2012-11-29-gitignore-templates/):
  - `curl https://api.github.com/gitignore/templates`
1. [API v3](https://developer.github.com/v3/)
1. [Basics of Authentication](https://developer.github.com/guides/basics-of-authentication/)
  - [rest-client](https://github.com/rest-client/rest-client)
  - use _RestClient.{get,post}_ in the two examples below


### Exploring API in Ruby

Check rate limits.

```ruby
require 'net/http'
require 'net/https'

# increase rate limits with OAuth2 token (GET)
def send_get_request
  uri = URI('https://api.github.com/rate_limit')

  # Create client
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_PEER

  # Create GET Request
  req =  Net::HTTP::Get.new(uri)
  # Add headers
  req.add_field "Authorization", "token [PERSONAL ACCESS TOKEN]"

  # Fetch Request
  res = http.request(req)
  puts "Response HTTP Status Code: #{res.code}"
  puts "Response HTTP Response Body: #{res.body}"
rescue StandardError => e
  puts "HTTP Request failed (#{e.message})"
end

send_get_request
```

Almost any meaningful use of the GitHub API will involve some level of
repository information.

Create a repository.

```ruby
require 'net/http'
require 'net/https'
require 'json'

# create public repository (POST )
def send_post_request(repo_name, gitignore_template)
  uri = URI('https://api.github.com/user/repos')

  # Create client
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_PEER
  dict = {
            "private" => false,
            "name" => repo_name,
            "auto_init" => true,
            "gitignore_template" => gitignore_template
        }
  body = JSON.dump(dict)

  # Create Request
  req =  Net::HTTP::Post.new(uri)
  # Add headers
  req.add_field "Authorization", "token [PERSONAL ACCESS TOKEN]"
  # Add headers
  req.add_field "Content-Type", "application/json; charset=utf-8"
  # Set body
  req.body = body

  # Fetch Request
  res = http.request(req)
  puts "Response HTTP Status Code: #{res.code}"
  puts "Response HTTP Response Body: #{res.body}"
rescue StandardError => e
  puts "HTTP Request failed (#{e.message})"
end

# list all gitignore templates:
#   curl https://api.github.com/gitignore/templates
send_post_request("raz_dwa_trzy", 'Ruby')
```

Pagination.

``````sh
curl https://api.github.com/repos/rails/rails/pulls
# show headers only
curl -I https://api.github.com/repos/rails/rails/pulls
# Link: <https://api.github.com/repositories/8514/pulls?page=2>; \
#   rel="next", \
#   <https://api.github.com/repositories/8514/pulls?page=23>; \
#   rel="last"

http https://api.github.com/repos/rails/rails/pulls
```
