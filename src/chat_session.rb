require 'aws-sdk-dynamodb'
require 'securerandom'

class ChatSession
  def initialize
    if ENV['DYNAMO_DB_ENDPOINT_URL'].nil?
      credentials = Aws::Credentials.new(ENV['IAM_USER_AWS_ACCESS_KEY_ID'], ENV['IAM_USER_AWS_SECRET_ACCESS_KEY'])
      @dynamodb_client = Aws::DynamoDB::Client.new(region: ENV['AWS_REGION'], credentials: credentials)
    else
      @dynamodb_client = Aws::DynamoDB::Client.new(endpoint: ENV['DYNAMO_DB_ENDPOINT_URL'])
    end
    @table_name = 'ChatSessions'
    initialize_table unless table_exist?
  end

  def add_message(role, message, session_id='1')
    item = {
      'MessageId': SecureRandom.uuid,
      'SessionId': session_id,
      'Role': role,
      'Message': message,
      'CreatedAt': Time.now.to_i
    }
    condition_expression = 'attribute_not_exists(MessageId)'
    @dynamodb_client.put_item(table_name: @table_name, item: item, condition_expression: condition_expression)
  end

  def get_last_messages(limit, session_id="1")
    @dynamodb_client.query({
      table_name: @table_name,
      index_name: 'SessionIdIndex',
      key_condition_expression: 'SessionId = :session_id',
      expression_attribute_values: {
        ':session_id': session_id
      },
      scan_index_forward: false,
      limit: limit
    }).items
  end

  private

  def table_exist?
    @dynamodb_client.list_tables.table_names.include?(@table_name)
  end

  def initialize_table
    @dynamodb_client.create_table(
      table_name: @table_name,
      attribute_definitions: [
        { attribute_name: 'MessageId', attribute_type: 'S' },
        { attribute_name: 'SessionId', attribute_type: 'S' },
        { attribute_name: 'CreatedAt', attribute_type: 'N' }
      ],
      key_schema: [
        { attribute_name: 'MessageId', key_type: 'HASH' }
      ],
      billing_mode: 'PAY_PER_REQUEST',
      global_secondary_indexes: [
        {
          index_name: 'SessionIdIndex',
          key_schema: [
            { attribute_name: 'SessionId', key_type: 'HASH' },
            { attribute_name: 'CreatedAt', key_type: 'RANGE' }
          ],
          projection: {
            projection_type: 'ALL'
          }
        }
      ],
      provisioned_throughput: {
        read_capacity_units: 1,
        write_capacity_units: 1
      }
    )
  end
end
