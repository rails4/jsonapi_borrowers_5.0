## Exploring GitHub API

1. [Getting Started](https://developer.github.com/guides/getting-started/)
1. [Authentication](https://developer.github.com/v3/#authentication) –
  increase hourly rate limits from 60 to 5000:
  - [Creating an access token for command-line use](https://help.github.com/articles/creating-an-access-token-for-command-line-use/) –
  Personal Access Token
1. [API v3](https://developer.github.com/v3/)

### Exploring API in Ruby

```ruby
require 'net/http'
require 'net/https'

# increase rate limits with OAuth2 token (GET)
def send_request
  uri = URI('https://api.github.com/rate_limit')

  # Create client
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_PEER

  # Create Request
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
```
