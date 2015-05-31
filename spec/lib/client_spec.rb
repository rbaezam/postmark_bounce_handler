require "spec_helper"
require "client"

JSON_TEST = '{
"ID": 42,
"Type": "HardBounce",
"TypeCode": 1,
"Name": "Hard bounce",
"Tag": "Test",
"MessageID": "883953f4-6105-42a2-a16a-77a8eac79483",
"Description": "The server was unable to deliver your message (ex: unknown user, mailbox not found).",
"Details": "Test bounce details",
"Email": "john@example.com",
"BouncedAt": "2014-08-01T13:28:10.2735393-04:00",
"DumpAvailable": true,
"Inactive": true,
"CanActivate": true,
"Subject": "Test subject"
}'

JSON_TEST_WRONG = '{
"wrong json string"
}'

RSpec.describe PostmarkBounceHandler do
  before(:each) do
    @pbh = PostmarkBounceHandler.new('test_api_token')
  end

  context '#parse_json' do

    context 'with valid json' do
      it 'should return a valid hash' do
        hash = @pbh.parse_json(JSON_TEST)
        expect(hash).to_not be_nil
        expect(hash['json']['ID']).to be(42)
      end
    end

    context 'with invalid json' do
      it 'should return a hash with status equal to 0' do
        hash = @pbh.parse_json(JSON_TEST_WRONG)
        expect(hash).to_not be_nil
        expect(hash['status']).to eq(0)
        expect(hash['message']).to_not be_nil
      end
    end
  end

  context '#try_reactivate_email' do

    context 'with valid bounce ID in the hash' do
      before(:each) do
        @hash = { 'ID': 0 } # a valid ID should be set here
      end

      it 'should call the activate bound API method' do

        res = @pbh.try_reactivate_email(@hash)
        expect(res['status']).to eq(1)

      end

    end

    context 'with invalid bounce ID in the hash' do
      before(:each) do
        @hash = { 'ID': 10001 }
      end

      it 'should return status = 0' do

        res = @pbh.try_reactivate_email(@hash)
        expect(res['status']).to eq(0)
        expect(res['message']).to_not be_nil

      end
    end

  end
end