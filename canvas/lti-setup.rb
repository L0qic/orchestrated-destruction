require 'typhoeus'
require 'json'
require 'csv'
require '../config/config'
require '../rubyize_json'

@external_tool_end_point = '/api/v1/accounts/self/external_tools/'
@token = auth(1,"canvas")

def input(p)
  puts p
  putc '>'
end

def lti_creation(name,base_url,consumer_key,shared_secret,config_url)
  lti_response = Typhoeus::Request.new(
    base_url + @external_tool_end_point,
    method: :post,
    params: {
        name: name,
        privacy_level: "public",
        consumer_key: consumer_key,
        shared_secret: shared_secret,
        config_type: "by_url",
        config_url: config_url,
      },
    headers: {authorization: @token}
  )
  begin
    puts rubyize_json lti_response
  rescue => error
    puts error
  end
end

def lti_csv_config
    input "Enter LTI name"
    name = gets.chomp
    input "Enter Canvas url e.g https://canvas.instructure.com"
    base_url = gets.chomp
    input "Enter LTI key. If no key is needed just enter 'key'"
    key = gets.chomp
    input "Enter Secret"
    secret = gets.chomp
    input "Enter Config URL"
    config_url = gets.chomp

    lti_creation(name,base_url,key,secret,config_url) if lti_exists?(base_url,name)
end

def lti_exists?(base_url,name)
  lti_response = Typhoeus::Request.new(
    base_url + @external_tool_end_point,
    params:{per_page: 100},
    headers: {authorization: @token}
  )
  resp = rubyize_json(lti_response)

  if resp.kind_of? Array
    result = resp.index{ |x|  x["url"].include? name if x["url"] != nil}
    result.nil?
  else
     puts "No results found make sure #{base_url} is a valid url"
  end
end

lti_csv_config
