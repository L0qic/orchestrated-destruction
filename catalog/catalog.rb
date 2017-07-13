require 'rest-client'
require 'pry'
require 'json'
require 'byebug'

class CatalogTester
  def initialize(params = {})
    session_key = '<key>'
    csrf = '<csrf_token>'
    @params = params
    sub_domain = "<canvas_subdomain>"
    @base_url = "https://#{sub_domain}.catalog.instructure.com"
    @headers = {
      "Host" => "#{sub_domain}.catalog.instructure.com",
      "Referer" => "#{sub_domain}.catalog.instructure.com/admin",
      'Content-Type' => 'application/json; charset=utf-8',
      "X-CSRF-Token" => csrf,
      cookies: {'_gallery_session' => session_key}
    }
  end

  def index()
    response = RestClient.get "#{@base_url}/#{@params[:url]}/", @headers
    print_response(response)
    response
  end

  def show(id)
    response = RestClient.get "#{@base_url}/#{@params[:url]}/#{id}", @headers
    print_response(response)
    response
  end

  def create(params)
    response = RestClient.post "#{@base_url}/#{@params[:url]}/", params, @headers
    print_response(response)
    response
  end

  def update(id, params)
    response = RestClient.put "#{@base_url}/#{@params[:url]}/#{id}", params, @headers
    print_response(response)
    response
  end

  def destroy(id)
    response = RestClient.delete "#{@base_url}/#{@params[:url]}/#{id}", @headers
  end

  def print_response(response)
    puts response.body
    sleep 1
  end

end

################################### Account ###################################
if ARGV.include?('--account')
    tester = CatalogTester.new({url: 'admin/accounts'})
    puts 'ACCOUNT'
    puts '------------'
    puts 'INDEX'
    begin
      tester.index
    rescue => e
    puts e
    end
    begin
      byebug
      puts 'SHOW VALID'
      tester.show(55) # valid catalog id
    rescue => e
      puts e
    end

      puts 'SHOW INVALID'
    begin
      tester.show(56) # invalid catalog id
    rescue => e
      puts e
    end

    params = {"account"=>
      {"name"=>"Subcatalog #{SecureRandom.hex}",
       "about"=>"updated",
       "type"=>"DomainAccount",
       "portal_path"=>"#{SecureRandom.hex}.com",
       "css_content"=>nil,
       "js_content"=>nil,
       "locale"=>"en",
       "currency"=>"USD",
       "logo"=>"",
       "uploaded_logo"=>nil,
       "header_image"=>"",
       "uploaded_header_image"=>nil,
       "favicon"=>"",
       "uploaded_favicon"=>nil,
       "country"=>"US",
       "header"=>nil,
       "footer"=>nil,
       "full_url"=>"#pseng.instructure.com",
       "level"=>1,
       "show_listings_in_parent"=>true,
       "inherit_user_defined_fields"=>true,
       "product_count"=>2,
       "inherit_categories"=>true,
       "parent_id"=>10,
       "categories_attributes"=>[]}}

    puts 'CREATE VALID'
    begin
      response = tester.create(params)
      account_id = JSON.parse(response)['account']['id']
    rescue  => e
      puts e
    end

    puts 'CREATE INVALID'
    begin
      params['account']['parent_id'] = 10 # create invalid catalog with id
      tester.create(params)
    rescue => e
      puts e
    end

    puts 'UPDATE VALID'
    begin
      params['account']['parent_id'] = 10 # update valid catalog with id
      respup = tester.update(account_id, params)
    if respup.code == 204
      puts "Catalog #{account_id} was updated successfully"
    end
    rescue => e
      puts e
    end

    puts 'UPDATE INVALID'
    begin
      tester.update(5, params) # update invalid catalog
      puts response.code
    rescue => e
      puts e
    end

    puts 'DELETE VALID'
    begin
      respdel = tester.destroy(account_id) # delete valid catalog
      if respdel.code == 204
        puts "Catalog #{account_id} was deleted successfully"
      end
    rescue => e
      puts e
    end

    puts 'DELETE INVALID'
    begin
      tester.destroy(72) # delete invalid catalog
    rescue => e
      puts e
    end
end

################################### Category ###################################
if ARGV.include?('--category')
  tester = CatalogTester.new({url: 'admin/categories'})
  puts 'CATEGORY'
  puts '------------'
  puts 'INDEX'
  begin
  tester.index
  rescue => e
  puts e
  end

  puts 'SHOW VALID'
  begin
  tester.show(10) # display category
  rescue => e
    puts e
  end

  puts 'SHOW INVALID'
  begin
    tester.show(56) # display invalid category
  rescue => e
    puts e
  end

  params = {'category' => {"account_id" => "10", "name" => "test", "group_id" => 56,"group_type" => "Account"}} #
  puts 'CREATE VALID'
  begin
    response = tester.create(params)
    category_id = JSON.parse(response)['category']['id']
  rescue => e
    puts e
  end
  puts 'CREATE INVALID'
  begin
    params['category']['account_id'] = 10 # invalid catalog id
    tester.create(params)
  rescue => e
    puts e
  end

  puts 'DELETE VALID'
  begin
    tester.destroy(category_id)
  rescue => e
    puts e
  end

  puts 'DELETE INVALID'
  begin
    tester.destroy(10) # delete invalid category
  rescue => e
    puts e
  end
end

################################### Product(program) ###################################
if ARGV.include?('--product')
  tester = CatalogTester.new({url: 'admin/products'})
  puts 'PRODUCT'
  puts '------------'
  puts 'INDEX'
  begin
  tester.index
  rescue => e
  puts e

  end

  puts 'SHOW VALID'
  begin
    tester.show(39408)
  rescue => e
    puts e
  end

  puts 'SHOW INVALID'
  begin
    tester.show(34989)
  rescue => e
    puts e
  end

  params = {
    "product"=>{
      "title"=>"#{SecureRandom.hex} Product",
      "visibility"=>"listed",
      "type"=>"Program",
      "localized_type"=>"Program",
      "description"=>"#{SecureRandom.hex}",
      "teaser"=>"#{SecureRandom.hex}",
      "path"=>"#{SecureRandom.hex}",
      "enrollment_open"=>true,
      "enrollment_fee"=>"10.0",
      "enrollment_count"=>9,
      "account_id"=>10,
      "certificate_id"=>26
    }
 }

  puts 'CREATE VALID'
  begin
  response = tester.create(params)
  product_id = JSON.parse(response)['product']['id']
  rescue => e
    puts e

  end

  puts 'CREATE INVALID'
  begin
    params['product']['account_id'] = 10 # catalog_id for root catalog
    tester.create(params)
  rescue => e
    puts e
  end

  begin
  puts 'UPDATE VALID'
  params['product']['account_id'] = 56
  params['product']['teaser'] = "updated #{product_id} test1"
  respprod = tester.update(product_id, params)
    if respprod.code == 204
      puts "Program #{product_id} was updated successfully"
    end
  rescue => e
    puts e
  end
  puts 'UPDATE INVALID'
  begin
    a_id = params['product']['account_id'] = 10
    respprod = tester.update(product_id, params)
    if respprod.code == 204
      puts "Program #{product_id} was updated with account_id #{a_id}"
    end
  rescue => e
    puts e
  end

  puts 'DELETE VALID'
  begin
    delresp = tester.destroy(product_id)
    if delresp.code == 204
      puts "Program #{product_id} was successfully deleted"
    end
  rescue => e
    puts e
  end

  puts 'DELETE INVALID'
  begin
    tester.destroy(38161)
  rescue => e
    puts e
  end
end

################################### Promotion ###################################
if ARGV.include?('--promotion')
  tester = CatalogTester.new({url: 'admin/promotions'})
  puts 'PROMOTION'
  puts '------------'
  puts 'INDEX'
  begin
  tester.index
  rescue => e
  puts e
  end

  puts 'SHOW VALID'
  begin
  tester.show(17)
  rescue => e
  puts e
  end

  puts 'SHOW INVALID'
  begin
    tester.show(9)
  rescue => e
    puts e
  end

  params = {"promotion"=>{"account_id"=>10, "amount"=>"10.0", "discount_type"=>"percent", "code"=>"#{SecureRandom.hex}", "name"=>"#{SecureRandom.hex}", "active"=>true, "usage_type"=>"unlimited"}}
  puts 'CREATE VALID'
  begin
  response = tester.create(params)
  promotion_id = JSON.parse(response)['promotion']['id']
  rescue => e
    puts e
  end

  puts 'CREATE INVALID'
  begin
    params['promotion']['account_id'] = 10
    tester.create(params)
  rescue => e
    puts e
  end

  puts 'UPDATE VALID'
  params['promotion']['account_id'] = 10
  begin
  promoresp = tester.update(promotion_id, params)
    if promoresp.code == 204
      puts "promo #{promotion_id} successfully updated"
    end
  rescue => e
    puts e
  end
  puts 'UPDATE INVALID'
  params['promotion']['account_id'] = 10
  begin
    tester.update(3, params)
  rescue => e
    puts e
  end

  puts 'DELETE VALID'
  begin
  promodel = tester.destroy(promotion_id)
  if promodel.code == 204
    puts "promo #{promotion_id} successfully deleted"
  end
  rescue => e
    puts e
  end

  puts 'DELETE INVALID'
    begin
    tester.destroy(10)
  rescue => e
    puts e
  end
end

################################### ProgramRequirement ###################################
if ARGV.include?('--program-requirement')
  tester = CatalogTester.new({url: 'admin/program_requirements'})
  puts 'PROGRAM REQUIREMENT'
  puts '------------'
  puts 'INDEX'
  begin
  tester.index
  rescue => e
  puts e
  end

  puts 'SHOW VALID'
  begin
  tester.show(4716)
rescue => e

puts e
end
  puts 'SHOW INVALID'
  begin
    tester.show(4720)
  rescue => e
    puts e
  end

  params = {"program_requirement"=>{"program_id"=>42922, "product_id"=>79}}
  puts 'CREATE VALID'
  begin
  response = tester.create(params)
  program_requirement_id = JSON.parse(response)['program_requirement']['id']
  rescue => e
    puts e
  end
  puts 'CREATE INVALID'
  begin
    params['program_requirement']['product_id'] = 76
    tester.create(params)
  rescue => e
    puts e
  end

  puts 'UPDATE VALID'
  params['program_requirement']['product_id'] = 52
  begin
  respreq = tester.update(program_requirement_id, params)
  if respreq.code == 204
    puts "Program Requirement #{program_requirement_id} was updated successfully"
  end
rescue => e
puts e

end
  puts 'UPDATE INVALID'
  begin
    tester.update(4720, params)
    puts response.code
  rescue => e
    puts e
  end

  puts 'DELETE VALID'
  begin
  respval = tester.destroy(program_requirement_id)
  if respval.code == 204
    puts "Program Requirement #{program_requirement_id} was deleted successfully"
  end
rescue => e

puts e
end
  puts 'DELETE INVALID'
  begin
    tester.destroy(4720)
  rescue => e
    puts e
  end
end

################################### UserDefinedField ###################################
if ARGV.include?('--user-defined-field')
  tester = CatalogTester.new({url: 'admin/user_defined_fields'})
  puts 'USER DEFINED FIELD'
  puts '------------'
  puts 'INDEX'
  begin
  tester.index
rescue => e
puts e
end
  puts 'SHOW VALID'
  begin
  tester.show(63)
rescue => e
puts e
end
  puts 'SHOW INVALID'
  begin
    tester.show(40)
  rescue => e
    puts e
  end

  params = {"user_defined_field"=>{"name"=>"#{SecureRandom.hex}", "label"=>"#{SecureRandom.hex}", "field_type"=>"text", "required"=>false, "required_message"=>"#{SecureRandom.hex}", "account_id"=>74}}
  puts 'CREATE VALID'
  begin
  response = tester.create(params)
  user_defined_field_id = JSON.parse(response)['user_defined_field']['id']
rescue => e
puts e
end
  puts 'CREATE INVALID'
  begin
    params['user_defined_field']['account_id'] = 4
    tester.create(params)
  rescue => e
    puts e
  end

  puts 'UPDATE VALID'
  params['user_defined_field']['account_id'] = 74
  begin
  respudf = tester.update(user_defined_field_id, params)
  if respudf.code == 204
    puts "User Defined Field #{user_defined_field_id} was updated successfully"
  end
rescue => e
puts e
end
  puts 'UPDATE INVALID'
  begin
    params["user_defined_field"]["name"] = "update name"
    tester.update(4, params)
  rescue => e
    puts e
  end

  puts 'DELETE VALID'
  begin
  tester.destroy(user_defined_field_id)
rescue => e
puts e
end
  puts 'DELETE INVALID'
  begin
    tester.destroy(4)
  rescue => e
    puts e
  end
end

################################### revenu ###################################
  if ARGV.include?('--revenue')
    tester = CatalogTester.new({url: 'admin/order_items/revenue_synopses'})
    puts 'USER DEFINED FIELD'
    puts '------------'
    puts 'INDEX'
    byebug
    tester.index

    puts 'SHOW VALID'
    tester.show(63)

    puts 'SHOW INVALID'
    begin
      tester.show(40)
    rescue => e
      puts e
    end

    params = {"user_defined_field"=>{"name"=>"#{SecureRandom.hex}", "label"=>"#{SecureRandom.hex}", "field_type"=>"text", "required"=>false, "required_message"=>"#{SecureRandom.hex}", "account_id"=>74}}
    puts 'CREATE VALID'
    response = tester.create(params)
    user_defined_field_id = JSON.parse(response)['user_defined_field']['id']

    puts 'CREATE INVALID'
    begin
      params['user_defined_field']['account_id'] = 4
      tester.create(params)
    rescue => e
      puts e
    end

    puts 'UPDATE VALID'
    params['user_defined_field']['account_id'] = 74
    respudf = tester.update(user_defined_field_id, params)
    if respudf.code == 204
      puts "User Defined Field #{user_defined_field_id} was updated successfully"
    end

    puts 'UPDATE INVALID'
    begin
      params["user_defined_field"]["name"] = "update name"
      tester.update(4, params)
    rescue => e
      puts e
    end

    puts 'DELETE VALID'
    tester.destroy(user_defined_field_id)

    puts 'DELETE INVALID'
    begin
      tester.destroy(4)
    rescue => e
      puts e
    end
end
############analytics###############
if ARGV.include?('--analytics')
  tester = CatalogTester.new({url: 'analytics/accounts'})
  puts 'USER DEFINED FIELD'
  puts '------------'
  puts 'INDEX'
  byebug
  tester.index

  puts 'SHOW VALID'
  tester.show(63)

  puts 'SHOW INVALID'
  begin
    tester.show(40)
  rescue => e
    puts e
  end

  params = {"user_defined_field"=>{"name"=>"#{SecureRandom.hex}", "label"=>"#{SecureRandom.hex}", "field_type"=>"text", "required"=>false, "required_message"=>"#{SecureRandom.hex}", "account_id"=>74}}
  puts 'CREATE VALID'
  response = tester.create(params)
  user_defined_field_id = JSON.parse(response)['user_defined_field']['id']

  puts 'CREATE INVALID'
  begin
    params['user_defined_field']['account_id'] = 4
    tester.create(params)
  rescue => e
    puts e
  end

  puts 'UPDATE VALID'
  params['user_defined_field']['account_id'] = 74
  respudf = tester.update(user_defined_field_id, params)
  if respudf.code == 204
    puts "User Defined Field #{user_defined_field_id} was updated successfully"
  end

  puts 'UPDATE INVALID'
  begin
    params["user_defined_field"]["name"] = "update name"
    tester.update(4, params)
  rescue => e
    puts e
  end

  puts 'DELETE VALID'
  tester.destroy(user_defined_field_id)

  puts 'DELETE INVALID'
  begin
    tester.destroy(4)
  rescue => e
    puts e
  end
end
