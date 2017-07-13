require 'typhoeus'
require 'json'
require 'forgery'
require '../config/config'
require '../rubyize_json'

@base_url = '<canvas_subdomain>'
@token = auth(1,'canvas')

puts 'How many users would you like to create?'

@students_count = gets.chomp.to_i

puts 'What course would you like to enroll users in?'

@course_id = gets.chomp

enrollment =  Typhoeus::Request.new(
    @base_url + "/api/v1/courses/#{@course_id}/sections",
    method: :post,
    params: {
      course_section: {
        name: "Course #{@course_id}-auto-gen",
        sis_section_id:"#{@course_id}-auto-gen"
      }
    },
    headers: { :authorization => @token }
)
  data = rubyize_json(enrollment)
  section_id = data['id']

@students_count.times do
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
  user_id = response['id']

  enrollment =  Typhoeus::Request.new(
      @base_url + "/api/v1/courses/#{@course_id}/enrollments",
      method: :post,
      params: {
        enrollment: {
          user_id: user_id,
          type: 'StudentEnrollment',
          enrollment_state: 'active',
          course_section_id: section_id
        }
      },
      headers: { :authorization => @token }
  )
  puts rubyize_json(enrollment)
end
