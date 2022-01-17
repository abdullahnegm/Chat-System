class ChatWorker
    attr_reader :data, :token
    include Sneakers::Worker
    
    from_queue "chat_queue", :exchange_options => { :type => 'fanout', durable: false }, exchange: 'gateway.chat', env: nil
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
        data["number"] = chats.empty? ? 1 : chats[-1].number.to_i + 1
        data["token"]  = token

        app = Application.find(token)
        app.update(chats_count: chats.size)
        Chat.create( data )
    end

    def update
        # ActiveRecord doesnt allow update for a table with no primary key & doesnt support composite primary keys
        # Could use composite_primary_keys gem to solve this issue ??

        sql = "UPDATE chats SET name = '#{data["name"]}' WHERE token = '#{token}' AND number = #{data["number"]}"
        ActiveRecord::Base.connection.execute(sql)
    end

    def destroy
        sql = "DELETE FROM chats WHERE token = '#{token}' AND number = #{data['number']}"
        ActiveRecord::Base.connection.execute(sql)
    end

    def chats
        Chat.where(token: token)
    end

end