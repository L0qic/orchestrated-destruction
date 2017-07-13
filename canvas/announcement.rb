require 'typhoeus'
require 'json'
require 'time'
require '../config/config'
require '../rubyize_json'

@base_url = '<canvas_subdomain>'
@token = auth(1,'canvas')

puts 'Enter Course ID'

course_id = gets.chomp

@course_id = course_id

puts 'How many announcements would you like to create'

announce = gets.chomp.to_i

### Annoucements
count = 1
announce.times do
  announcement = Typhoeus::Request.new(
      @base_url + "/api/v1/courses/#{@course_id}/discussion_topics",
      method: :post,
      params: {
        title: "Announcement #{count}",
        message: "This is announcement #{count}",
        published: true,
        is_announcement: true
      },
      headers: {:authorization => @token}
  )
  response = rubyize_json(announcement)
  puts response
  count += 1
end
