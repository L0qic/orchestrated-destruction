require 'typhoeus'
require 'json'
require '../rubyize_json'

class QuizQuestionCreator
 attr_reader :base_url, :token, :course_id, :quiz_id

 QUESTION_TYPES = %w(
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
).freeze

 def initialize(base_url, token, course_id, quiz_id)
  @base_url = base_url
  @token = token
  @course_id = course_id
  @quiz_id = quiz_id
 end

 def questions(question_type = [])
  q_name = 'name'
  q_text = 'Automated question'
  points = rand(1..20)
   question = Typhoeus::Request.new(
    base_url + "/api/v1/courses/#{course_id}/quizzes/#{quiz_id}/questions",
    method: :post,
    params: {
     question: {
      question_name: q_name,
      question_text: q_text,
      question_type: question_type,
      points_possible: points,
      answers: question_type_answer(question_type)
     }
    },
    headers: { authorization: token }
   )
   question
 end

 def question_type_answer(question_type)
   essay = [{text: 'This is an essay question', weight: 100 }]
   if QUESTION_TYPES.include? question_type
     case question_type
     when QUESTION_TYPES[1]
       essay
     when QUESTION_TYPES[6]
        [
          { text: 'A', weight: 0 },
          { text: 'B', weight: 0 },
          { text: 'C', weight: 100 },
          { text: 'D', weight: 0 }
        ]
     end
   else
     essay
  end
 end
end
