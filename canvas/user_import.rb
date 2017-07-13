require 'json'
require 'typhoeus'
require '../config/config.rb'
require '../rubyize_json'


@token = auth(1,"canvas")

puts "Enter institution's subdomain"

subdomain = gets.chomp

@base_url = "https://#{subdomain}.instructure.com"

puts "How many students would you like to enroll?"

students = gets.chomp

students_count = students.to_i

puts "What course would you like to enroll users in?"

course_id = gets.chomp

counter = 1
students_count.times {
  first_name = Forgery::Name.first_name
  last_name = Forgery::Name.last_name
  unique_id = "#{first_name}#{last_name}#{rand(1000)}bot"

  create_user = Typhoeus::Request.new(
      @base_url + '/api/v1/accounts/self/users',
      method: :post,
      params: {
        user: {
          name: "#{first_name} #{last_name}",
          skip_registration: 'true',
          :local => 'en',
          :time_zone => 'America/Denver'
        },
        pseudonym: {
          unique_id: unique_id,
          sis_user_id: unique_id,
          send_confirmation: 'false'
        },
       communication_channel: {
         type: 'email',
         address: "#{unique_id}@example.com",
         skip_confirmation: 'true'
       },
       force_validation: 'true'
     },
      headers: { :authorization => @token }
  )

  response = rubyize_json(create_user)
  puts response
  counter += 1
}

puts "#{counter} users enrolled!"
