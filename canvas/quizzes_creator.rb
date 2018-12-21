require 'time'
require 'json'
require 'typhoeus'
require_relative 'quiz_question_creator'

class QuizzesCreator
 attr_accessor :access_token, :base_url, :course_ids, :number_of_quizzes, :randomize_types, :q_settings

 def initialize
  @access_token = 'Bearer '
  @base_url = ''
  @course_ids = []
  @number_of_quizzes = 1
  @randomize_types = false
  @q_settings = {}

  perform
 end

 QUIZ_TYPES = %w[assignment practice_quiz graded_survey survey].freeze

 def truthy?(value)
  %w[true Y].include? value
 end

 def input(p)
  puts p
  putc '>'
 end

 def get_info_from_user
  input 'What is the base URL for your environment? (ex: http://localhost:3000): '
  @base_url = gets.chomp

  input 'What is your API token for this instance?: '
  @access_token << gets.chomp

  input 'Input comma separated list of which Canvas course IDs you would like to create quizzes in? (ex: 1,5,7,23,100) : '
  @course_ids = gets.chomp.split(',')

  input 'How many quizzes would you like per course?: '
  @number_of_quizzes = gets.chomp.to_i

  input 'How many questions per quiz: '
  @number_of_questions = gets.chomp.to_i

  input 'Randomize quiz types? (Y/N): '

  @randomize_types = true if truthy?(gets.chomp.upcase)

  input 'Do you want to pass specific quiz settings? (Y/N): '
  quiz_settings if truthy?(gets.chomp.upcase)
 end

 def quiz_settings
  qz_options = { time_limit: nil, shuffle_answers: nil, hide_results: nil, show_correct_answers: nil, show_correct_answers_last_attempt: nil, show_correct_answers_at: nil, hide_correct_answers_at: nil, allowed_attempts: nil, scoring_policy: nil, one_question_at_a_time: nil, cant_go_back: nil, access_code: nil, ip_filter: nil, due_at: nil, lock_at: nil, unlock_at: nil, published: nil, one_time_results: nil, only_visible_to_overrides: nil }
  input "Leave blank any settings you don't wish to pass in."

  qz_options.each do |k, _v|
   puts "#{k}: "
   qz_options[k] = case k
                   when :time_limit, :allowed_attempts
                    gets.chomp.to_i
                   when :shuffle_answers, :show_correct_answers, :show_correct_answers_last_attempt, :one_question_at_a_time, :cant_go_back, :published, :one_time_results, :only_visible_to_overrides
                    truthy?(gets.chomp.downcase)
                   when :hide_results, :scoring_policy, :access_code, :ip_filter, :show_correct_answers_at, :hide_correct_answers_at, :due_at, :lock_at, :unlock_at
                    gets.chomp
   end
  end
  @q_settings = qz_options
 end

 def publish_quiz(course, quiz_id)
  quiz = Typhoeus.put(
   base_url + "/api/v1/courses/#{course}/quizzes/#{quiz_id}",
   body: {
    quiz: {
     published: true
    }
   },
   headers: { authorization: access_token, "Content-Type": 'application/x-www-form-urlencoded' }
  )
  puts quiz
 end

 def create_quiz(course, quiz_num, make_random, options)
  quiz = Typhoeus::Request.new(
   base_url + "/api/v1/courses/#{course}/quizzes",
   method: :post,
   params: {
    quiz: {
     quiz_type: type = make_random ? QUIZ_TYPES.sample : 'assignment',
     title: "Testing Republish Automated #{type} quiz #{quiz_num}",
     description: "Automated #{type} quiz generated for testing purposes",
     assignment_group_id: options[:assignment_group_id],
     time_limit: options[:time_limit],
     shuffle_answers: options[:shuffle_answers],
     hide_results: options[:hide_results],
     show_correct_answers: options[:show_correct_answers],
     show_correct_answers_last_attempt: options[:show_correct_answers_last_attempt],
     show_correct_answers_at: options[:show_correct_answers_at],
     hide_correct_answers_at: options[:hide_correct_answers_at],
     allowed_attempts: options[:allowed_attempts],
     scoring_policy: options[:scoring_policy],
     one_question_at_a_time: options[:one_question_at_a_time],
     cant_go_back: options[:cant_go_back],
     access_code: options[:access_code],
     ip_filter: options[:ip_filter],
     due_at: options[:due_at],
     lock_at: options[:lock_at],
     unlock_at: options[:unlock_at],
     published: options[:published],
     one_time_results: options[:one_time_results],
     only_visible_to_overrides: options[:only_visible_to_overrides]
    }
   },
   headers: { authorization: access_token }
  )
  quiz
 end

 def amount_of_quizzes(course, num, make_random = false, opts = {})
  hydra = Typhoeus::Hydra.new(max_concurrency: 30)
  num.times do |n|
   response = create_quiz(course, n + 1, make_random, opts)
   response.on_complete do |resp|
    q_id = JSON.parse(resp.body)['id']
    builder = QuizQuestionCreator.new(base_url, access_token, course, q_id)
    builder.questions(['multiple_choice_question'])
    res = resp.code == 200 ? "Quiz Batch successfully created rate-limit:#{resp.headers['X-Rate-Limit-Remaining']}" : "Quiz Batch failed with following #{resp.code}"
    puts res
    quiz = publish_quiz(course, q_id) if opts[:published]
   end
   hydra.queue(response)
  end
  hydra.run
 end

 def perform
  get_info_from_user
  course_ids.each do |crs|
   amount_of_quizzes(crs, number_of_quizzes, randomize_types, q_settings)
  end
 end
end
