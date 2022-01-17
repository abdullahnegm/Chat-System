class ApplicationWorker
    attr_reader :data, :token
    include Sneakers::Worker
  
    from_queue "application_queue", :exchange_options => { :type => 'fanout', durable: false }, exchange: 'gateway.application', env: nil
    def work(message)
        method, data = parse_message message

        self.public_send( method, data )
        ack! 
    end

    def parse_message message
        message = JSON.parse(message)
        [message["method"], message["data"]]
    end

    def create data
        token = data['token']
        data.delete('token')

        Application.create(data)
    end

    def update data
        token = data['token']
        data.delete('token')

        Application.find( token ).update(data)
    end

    def destroy data
        token = data['token']
        
        Application.find( token ).delete()
    end
end