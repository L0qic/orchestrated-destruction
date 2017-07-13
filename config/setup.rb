#!/usr/bin/env ruby
require 'yaml'
require 'yaml/store'
require 'colorize'
require 'byebug'

def input(p)
  puts p
  putc '>'
end

def handle_file(name)
  raise 'A block must be given' unless block_given?
  config_file = YAML.load_file name
  raise 'Missing file %s' % name unless config_file
  yield config_file
end

def is_not_empty(user_input)
  return true unless user_input.empty?
  puts 'No token entered'.red
  puts 'Run setup again to enter token'.yellow
  return false
end

def set_token(tok='token', accounts)
  accounts.each do |a|
    @config['Credentials'][a][tok] ||= {}
    input "Enter your #{a.capitalize} token"
    user_input= gets.chomp
    if is_not_empty(user_input)
      @config['Credentials'][a][tok]['1'] = user_input
      puts "#{a.capitalize} token was successfully added".green
    end
  end
end

def store_data
  ##https://ruby-doc.org/stdlib-2.4.0/libdoc/yaml/rdoc/YAML/Store.html
  save = YAML::Store.new 'config.yml'
  save.transaction do
    @config.each do |k, v|
      save[k] = v
    end
  end
end

handle_file('config.yml') do |config_file|
  @config = config_file
  accounts =["canvas","bridge"]
  input "Choose an option to update token(s)\n1. Canvas\n2. Bridge\n3. Both"
  user_input= gets.chomp
 case user_input.to_i
   when 1
     set_token(accounts.values_at(0))
   when 2
     set_token(accounts.values_at(1))
   when 3
     set_token(accounts)
   else
     puts "\"#{user_input}\" is not a valid option, please run setup again.".yellow
   end
   store_data
end
