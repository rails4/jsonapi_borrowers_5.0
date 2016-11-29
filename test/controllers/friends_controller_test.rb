require 'test_helper'

class FriendTest < ActiveSupport::TestCase
  test 'requires first_name' do
    friend = Friend.new(last_name: 'A', email: 'a@example.com')
    assert_not friend.save, 'Saved friend without first_name'
    assert_not_empty friend.errors[:first_name]
  end

  test 'requires last_name' do
    friend = Friend.new(first_name: 'B', email: 'b@example.com')
    assert_not friend.save, 'Saved friend without last_name'
    assert_not_empty friend.errors[:last_name]
  end

  test 'requires email' do
    friend = Friend.new(first_name: 'C', last_name: 'D')
    assert_not friend.save, 'Saved friend without email'
    assert_not_empty friend.errors[:email]
  end
end

# class FriendsControllerTest < ActionDispatch::IntegrationTest
#   # test "the truth" do
#   #   assert true
#   # end
# end
