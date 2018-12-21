require 'typhoeus'
require 'json'
require '../rubyize_json'

class QuizQuestionCreator
 attr_reader :base_url, :token, :course_id, :quiz_id

 QUESTION_TYPES = %w[
  calculated_question
  essay_question
  file_upload_question
  fill_in_multiple_blanks_question
  matching_question
  multiple_answers_question
  multiple_choice_question
  multiple_dropdoans_question
  numerical_question
  short_answer_question
  text_only_question
  true_false_question
 ].freeze

 def initialize(base_url, token, course_id, quiz_id)
  @base_url = base_url
  @token = token
  @course_id = course_id
  @quiz_id = quiz_id
  end

 def questions(question_type = [])
  q_name = 'name'
  q_text = 'testing'
  points = rand(1..20)
  question_type.each do |q_type|
   question = Typhoeus::Request.new(
    base_url + "/api/v1/courses/#{course_id}/quizzes/#{quiz_id}/questions",
    method: :post,
    params: {
     question: {
      question_name: q_name,
      question_text: q_text,
      question_type: q_type,
      points_possible: points,
      answers: question_type_answer(q_type)
     }
    },
    headers: { authorization: token }
   )
   rubyize_json(question)
  end
   end

 def question_type_answer(_question_type)
  [
   { text: 'A', weight: 0 },
   { text: 'B', weight: 0 },
   { text: 'C', weight: 100 },
   { text: 'D', weight: 0 }
  ]
 end
end
