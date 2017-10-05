#!/usr/bin/env ruby
require 'active_support/all'
require 'json'
require 'forgery'
require 'typhoeus'
require '../config/config'
require '../rubyize_json'

@base_url = '<base_url>'
@token = auth(1,'canvas')

def create_term(term)
end_point = "/api/v1/accounts/self/terms"
sis_id = term[:sis_term_id]
name = "Grading Period Term: #{sis_id}"
    params = {
      enrollment_term: {
        name: name,
        start_at: term[:start_date],
        end_at: term[:end_date],
        sis_term_id: sis_id
      }
    }
    puts "Creating term..."
   term_resp = rubyize_json(request(params, :POST, end_point))
   term_id = term_resp["id"]
end

def create_grading_set(term_id,periods)
  end_point = "/api/v1/accounts/self/grading_period_sets"
    params = {
      grading_period_set: {
        title: "Grading Period Test",
        weighted: false,
        display_totals_for_all_grading_periods: false
      },
      'enrollment_term_ids[]': term_id
    }
    resp = rubyize_json(request(params, :POST, end_point))
    id = resp["grading_period_set"]["id"]
    puts "Creating grading set..."
    create_grading_period(id,periods)
end

def create_grading_period(grading_set_id, grading_periods)
  grading_periods.each do |grading_period|
    end_point = "#{@base_url}/api/v1/grading_period_sets/#{grading_set_id}/grading_periods/batch_update"
      payload = { "grading_periods": [grading_period] }
      headers = { authorization: @token, 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
      options = { method: :PATCH, body: payload.to_json, headers: headers }
      resp = Typhoeus::Request.new( end_point,options )
      puts "Creating grading period..."
      rubyize_json(resp)
  end
end

# Not Currently used
# def create_course()
# end_point = "/api/v1/accounts/self/courses"
#   params = {
#       course: {
#         name: "Course #{count}",
#         course_code: "Course #{count}",
#         sis_course_id: "coursesis#{count}"
#       },
#       offer: true,
#       enroll_me: true,
#   }
#   puts "Creating course..."
#   request(params, :POST, end_point)
# end

def create_sections(course_ids, sections_count)
  section_ids = []
  sections_count.times do
    course_ids.each do |course_id|
      sis_section_id = rand(10000000)
      end_point = "/api/v1/courses/#{course_id}/sections"
        params = {
          course_section: {
            name: "GradingPeriodSection_#{course_id}_#{sis_section_id}",
            sis_section_id: sis_section_id
          }
        }
      puts "Creating section in course: #{course_id}..."
      section = rubyize_json(request(params, :POST, end_point))
      section_ids << section["id"]
    end
  end
  section_ids
end

def create_assignments(course_ids, assignment_count, grading_periods)
assignments_per = assignment_count / grading_periods.length
  assignments = []
  course_ids.each do |course_id|
    end_point = "/api/v1/courses/#{course_id}/assignments"
    grading_periods.each do |grading_period|
      gp = grading_period[:title]
      description = "Start: #{grading_period[:start_date]}-End: #{grading_period[:end_date]}"
      count = 1
      assignments_per.times do
        due_date = rand(Time.parse(grading_period[:start_date])..Time.parse(grading_period[:end_date]))
        pts = "100"
        params = {
          assignment: {
            name:"GradingPeriod(#{count}): #{gp}",
            submission_types: "online_text_entry",
            points_possible: pts,
            grading_type: "points",
            due_at: due_date.iso8601,
            description: "Auto created assignment: #{description}",
            published: true
          }
        }
        puts "Creating assignment in Course: #{course_id}..."
       assignments << rubyize_json(request(params, :POST, end_point))
       count+=1
      end
    end
  end
  assignments
end

def create_users(user_count)
  end_point = "/api/v1/accounts/self/users"
    users = []
    user_count.times do
      first_name = Forgery::Name.first_name
      last_name = Forgery::Name.last_name
      unique_id = "#{first_name.downcase}#{last_name.downcase}#{rand(10000)}bot"
      params = {
        user: {
          name: "#{first_name} #{last_name}",
          terms_of_use: true,
          skip_registration: true,
        },
        pseudonym: {
          unique_id: unique_id,
          password: unique_id,
          sis_user_id: unique_id,
        },
        communication_channel: {
          type: 'email',
          address: "#{unique_id}@example.com",
          skip_confirmation: true
        }
      }
      puts "Creating user with sis_user_id: #{unique_id} ..."
      users << rubyize_json(request(params,:POST,end_point))
    end
  users
end

def create_enrollments(user_count,section_ids)
  enrollments = []
  section_ids.each do |section|
    users = create_users(user_count)
    end_point = "/api/v1/sections/#{section}/enrollments"
    users.each do |user_id|
      params = {
        enrollment: {
          user_id: user_id['id'],
          type: "StudentEnrollment",
          enrollment_state: "active"
        }
      }
      puts "Enrolling user: #{user_id['id']} in section: #{section}..."
      enrollments << rubyize_json(request(params, :POST, end_point))
    end
  end
  enrollments
end

def grade_assignments(enrollments,assignments)
  hydra = Typhoeus::Hydra.new(max_concurrency: 20)
  enrollments.each do |enrollment|
    section_id = enrollment["course_section_id"]
    user_id = enrollment["user_id"]
    assignments.each do |assignment|
      assignment_id = assignment["id"]
      grade = rand(60..100)
      end_point = "/api/v1/sections/#{section_id}/assignments/#{assignment_id}/submissions/#{user_id}"
      params = {
        submission: {
          posted_grade: grade
        }
      }
      grade_req = request(params, :PUT, end_point)
      grade_req.on_complete do |response|
        puts "Graded Assignment: #{assignment_id} for User: #{user_id} in Course: #{enrollment["course_id"]}"
      end
      hydra.queue(grade_req)
    end
  end
  hydra.run
end

def request(params, method, end_point)
  url = "#{@base_url}#{end_point}"
  headers = { authorization: @token}
  options = { method: method, params: params, headers: headers }
  resp = Typhoeus::Request.new(url, options)
end

def run(opts={})
  term_id = create_term(opts[:term])
  create_grading_set(term_id, opts[:grading_period])
  section_ids = create_sections(opts[:existing_course_id], opts[:section_count_per_course])
  enrollments = create_enrollments(opts[:new_user_count], section_ids)
  assignments = create_assignments(opts[:existing_course_id],opts[:assignment_count],opts[:grading_period])
  grade_assignments(enrollments,assignments)
end

opts = {
  grading_period:[
    {"title":"Fall","start_date":"2017-08-01T06:00:00.000Z","end_date":"2017-10-31T05:59:59.000Z"},
    {"title":"Winter","start_date":"2017-11-01T07:00:00.000Z","end_date":"2018-02-28T05:59:59.000Z"},
    {"title":"Spring","start_date":"2018-03-01T06:00:00.000Z","end_date":"2018-05-31T05:59:59.000Z"}
  ],
  assignment_count: 12,
  new_user_count: 10,
  existing_course_id:[1],
  term:{
    start_date:"2017-08-01T06:00:00.000Z",
    end_date:"2018-05-31T06:00:00.000Z",
    sis_term_id: rand(1000000)
  }
}

run(opts)
