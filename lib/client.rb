require 'json'
require 'postmark'

RESULT_OK = 1
RESULT_ERROR = 0

class PostmarkBounceHandler

  @client = nil

  def initialize(api_token)
    @client = Postmark::ApiClient.new(api_token)
  end

  def receive_bounce_notification(json_string)

    begin
      my_hash = parse_json(json_string)
    rescue JSON::JSONError
      puts 'Error parsing the JSON string'
    end

    if my_hash['status'] == RESULT_OK
      res = my_hash['json']
      if res['can_activate'] == true
        try_reactivate_email res
      end
    end

  end

  def parse_json(json_string)

    hash = {}
    begin
      res = JSON.parse(json_string)
      hash['status'] = RESULT_OK
      hash['json'] = res
    rescue JSON::JSONError => e
      hash['status'] = RESULT_ERROR
      hash['message'] = e.message
      hash['json'] = nil
    end

    return hash
  end

  def try_reactivate_email(hash)

    hash = {}
    begin
      res = @client.activate_bounce(hash['ID'])
      hash['status'] = RESULT_OK
      hash['json'] = res
    rescue Postmark::UnknownError => e
      hash['status'] = RESULT_ERROR
      hash['message'] = e.message
    end

    return hash

  end

end
