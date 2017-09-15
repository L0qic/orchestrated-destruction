
require 'json'
require 'forgery'
require 'typhoeus'
require '../rubyize_json'
require '../config/config'

@base_url = ''
@token = auth(1,'bridge')

def create_users(user_count)
  if user_count >= 1
    users = []
    user_count.times do
      first_name = Forgery::Name.first_name
      last_name = Forgery::Name.last_name
      unique_id = "#{first_name.downcase}#{last_name.downcase}#{rand(10000)}bot"
      email = "#{unique_id}@example.com"
      users << {
          "uid" => unique_id, # unique id
          "first_name" => "#{first_name}",
          "last_name" => "#{last_name}",
          "email" => email
      }
    end
    users.uniq { |user| user["uid"] }
    add_users(users)
  end
end

def add_users(users)
  url = "#{@base_url}/api/admin/users"
  ucount = 1
  hydra = Typhoeus::Hydra.new(max_concurrency: 5) # may need to change concurrency if rate limit is exceeded
  users.each do |user|
      payload = { 'users' => [user] }
      headers = { authorization: @token, 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
      options = { method: :POST, body: payload.to_json, headers: headers }
      user_resp = Typhoeus::Request.new(url,options )
      user_resp.on_complete do |response|
        json_response = JSON.parse(response.body)
        json_response["users"].each do |user|
          puts "  #{ucount} created: #{user['name']} with id #{user['id']}"
          ucount +=1
        end
      end
      hydra.queue(user_resp)
  end
   hydra.run
end

puts "How many students would you like to enroll into Bridge?"

students = gets.chomp

create_users(students.to_i)
