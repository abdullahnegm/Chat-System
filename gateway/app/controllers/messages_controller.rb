class MessagesController < ApplicationController
    SERVICE = "message"
    URL     = "http://messages_service:3002"
    
    before_action :call_message, only: %i[index show search]
    before_action :valid?, only: %i[create update]

    def index
      render json: { data: @message }, status: :ok
    end
  
    def show
        return render json: {error: "Message Doesn't Exist"} if @message.nil?
        render json: { data: @message }
    end

    def search
      render json: { data: @message }, status: :ok
    end
  
    def create
      message = {method: "create", data: get_payload} 
      Publisher.publish(SERVICE, message)
      render json: { message: "Message Created" }, status: :ok
    end
  
    def update
      message = {method: "update", data: get_payload}
      Publisher.publish(SERVICE, message)
      render json: { message: "Message Updated" }, status: :ok
    end
  
    def destroy
      message = {method: "destroy", data: get_payload}
      Publisher.publish(SERVICE, message)
      render json: { message: "Message Deleted" }, status: :ok
    end
  
    private
    def call_message
      @message = HttpAdapter.new(SERVICE, URL, request.method, request.fullpath).call
    rescue => e
      render json: { error: e.message }
    end

    def get_payload
      # params.permit(:body, :application_token, :chat_number, :message_number)
      {body: params[:body], application_token: params[:application_token], chat_number: params[:chat_number], message_number: params[:message_number]}.select {|k, v| v != nil}
    end

    def valid?
      body_length = params[:body].size
      error = []
      error.push("Body must be between 3 and 30 characters") if body_length < 3 || body_length > 100
      render json: { error: error } if !error.empty?
    rescue
      render json: {error: "Enter valid params"}
    end

end