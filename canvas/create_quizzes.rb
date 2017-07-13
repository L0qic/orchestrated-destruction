require 'typhoeus'
require 'json'
require 'Forgery'
require '../config/config.rb'
require '../rubyize_json'

@base_url = '<canvas_subdomain>'
@token = auth(1,'canvas')

def question(quiz_id)
  question = Typhoeus::Request.new(
      @base_url + "/api/v1/courses/#{@course_id}/quizzes/#{quiz_id}/questions",
      method: :post,
      params: {
        :question=>{
          :question_name => 'Question 1',
          :question_text => 'automated essay question',
          :question_type => 'essay_question',
          :points_possible => 2
        }
      },
      headers: { :authorization => @token }
  )
  puts rubyize_json(question)
end

puts 'How many quizzes of different types would you like to create?'

quizzes = gets.chomp.to_i

puts 'What course would you like to create quizzes for?'

@course_id = gets.chomp

quizzes.times do
   create_quiz = Typhoeus::Request.new(
      @base_url + "/api/v1/courses/#{@course_id}/quizzes",
      method: :post,
      params: {
        quiz: {
          title: "Quiz Assignment #{Forgery::Basic.text}",
          description: 'This is an automated quiz',
          quiz_type: 'assignment',
          published: 'true'
        }
     },
      headers: { :authorization => @token }
  )
  graded_response = rubyize_json(create_quiz)
  quiz_id = graded_response['id']

  question(quiz_id)

  create_quiz = Typhoeus::Request.new(
      @base_url + "/api/v1/courses/#{@course_id}/quizzes",
      method: :post,
      params: {
        quiz: {
          title: "Quiz Practice #{Forgery::Basic.text}",
          description: 'This is an automated quiz',
          quiz_type: 'practice_quiz',
          published: 'true'
        }
     },
      headers: { :authorization => @token }
  )
  practice_response = rubyize_json(create_quiz)
  quiz_id = practice_response['id']

  question(quiz_id)

  create_quiz = Typhoeus::Request.new(
      @base_url + "/api/v1/courses/#{@course_id}/quizzes",
      method: :post,
      params: {
        quiz: {
          title: "Quiz Graded Survey #{Forgery::Basic.text}",
          description: 'This is an automated quiz',
          quiz_type: 'graded_survey',
          published: 'true'
        }
     },
      headers: { :authorization => @token }
  )
  graded_survey_response = rubyize_json(create_quiz)
  quiz_id = graded_survey_response['id']

  question(quiz_id)

  create_quiz = Typhoeus::Request.new(
      @base_url + "/api/v1/courses/#{@course_id}/quizzes",
      method: :post,
      params: {
        quiz: {
          title: "Quiz Survey #{Forgery::Basic.text}",
          description: 'This is an automated quiz',
          quiz_type: 'survey',
          published: 'true'
        }
      },
      headers: { :authorization => @token }
  )
  survey_response = rubyize_json(create_quiz)
  quiz_id = survey_response['id']

  question(quiz_id)
end
