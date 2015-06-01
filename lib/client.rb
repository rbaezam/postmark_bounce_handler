require 'json'
require 'postmark'

RESULT_OK = 1
RESULT_ERROR = 0

class PostmarkBounceHandler

  @client = nil

  # Initialize the Postmark Bounce Handler
  # @param api_token a string containing the token to use for connecting to Postmark
  def initialize(api_token)
    @client = Postmark::ApiClient.new(api_token)
  end

  # Method that would be called by the bounce webhook
  # @param json_string [string] in json format with the bounce information
  # @return [boolean] true if the process was executed correctly, false if not
  def process_bounce_notification(json_string)

    result = true

    begin
      my_hash = parse_json(json_string)
    rescue JSON::JSONError
      puts 'Error parsing the JSON string'
      result = false
    end

    if my_hash['status'] == RESULT_OK
      res = my_hash['json']
      if res['can_activate'] == true
        res = try_reactivate_email res
        if res['status'] == RESULT_ERROR
          result = false
        end
      end
    end

  end

  # Parse json string and converts it to hash
  # @param json_string [string] containing the values in json format
  # @return [hash] containing all the values in the json passed as parameter
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

  # Try to reactivate the bounce using the ID contained in the hash parameter
  # @param [hash] containing the bounce values, including the ID needed to activate the email
  # @return [hash] with the result of the operation. 'status' contains the outcome of the process.
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
