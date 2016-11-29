require 'net/http'
require 'json'

# Request (POST )
def send_request
  uri = URI('http://localhost:3000/friends')

  # Create client
  http = Net::HTTP.new(uri.host, uri.port)
  dict = {
    'data' => {
      'type' => 'friends',
      'attributes' => {

      }
    }
  }
  body = JSON.dump(dict)

  # Create Request
  req =  Net::HTTP::Post.new(uri)
  # Add headers
  req.add_field 'Content-Type', 'application/vnd.api+json'
  # Set body
  req.body = body

  # Fetch Request
  res = http.request(req)
  puts "Response HTTP Status Code: #{res.code}"
  puts "Response HTTP Response Body: #{res.body}"
rescue StandardError => e
  puts "HTTP Request failed (#{e.message})"
end
