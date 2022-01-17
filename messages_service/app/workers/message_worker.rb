class MessageWorker
    attr_reader :data, :token
    include Sneakers::Worker
    
    from_queue "message_queue", :exchange_options => { :type => 'fanout', durable: false }, exchange: 'gateway.message', env: nil
    def work(message)
        method, data = parse_message message

        if data['application_token'] 
            @token = data['application_token']
            data.delete('application_token')
        end

        self.public_send( method )
        ack! 
    end

    def parse_message message
        message = JSON.parse(message)
        @method, @data = [message["method"], message["data"]]
    end

    def create
        data["token"]  = token
        
        data["number"] = messages.empty? ? 1 : messages[-1].number.to_i + 1

        sql = "UPDATE chats SET messages_count = #{messages.size} WHERE token = '#{token}' AND number = #{data['chat_number']}"
        ActiveRecord::Base.connection.execute(sql)

        Message.create( data )
    end

    def update
        # ActiveRecord doesnt allow update for a table with no primary key & doesnt support composite primary keys
        # Could use composite_primary_keys gem to solve this issue ??

        sql = "UPDATE messages SET body = '#{data['body']}' WHERE token = '#{token}' AND number = #{data['message_number']} AND chat_number = #{data['chat_number']}"
        ActiveRecord::Base.connection.execute(sql)
    end

    def destroy
        sql = "DELETE FROM messages WHERE token = '#{token}' AND number = #{data['message_number']} AND chat_number = #{data['chat_number']}"
        ActiveRecord::Base.connection.execute(sql)
    end

    def messages
        Message.where(token: token)
    end

end