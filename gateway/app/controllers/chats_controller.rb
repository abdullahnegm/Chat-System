class ChatsController < ApplicationController
    SERVICE = "chat"
    URL     = "http://chats_service:3001"
    APP_URL = "http://applications_service:3000"
    
    before_action :call_chat, only: %i[index show]
    before_action :valid?, only: %i[create update]

    def index
      render json: { data: @chat }, status: :ok
    end
  
    def show
        return render json: {error: "Chat Doesn't Exist"} if @chat.nil?
        render json: { data: @chat }
    end
  
    def create
      message = {method: "create", data: get_payload} # , next_number: (chat_size.to_i + 1)
      Publisher.publish(SERVICE, message)
      render json: { message: "Chat Created" }, status: :ok
    end
  
    def update
      message = {method: "update", data: get_payload}
      Publisher.publish(SERVICE, message)
      render json: { message: "Chat Updated" }, status: :ok
    end
  
    def destroy
      message = {method: "destroy", data: get_payload}
      Publisher.publish(SERVICE, message)
      render json: { message: "Chat Deleted" }, status: :ok
    end
  
    private
    def call_chat
      @chat = HttpAdapter.new(SERVICE, URL, request.method, request.fullpath).call
    rescue => e
      render json: { error: e.message }
    end

    def next_number
      @size = (HttpAdapter.new("application", APP_URL, "GET", "/applications/#{params[:token]}?force=true").call)['chat_size']
    rescue => e
      return render json: { error: e.message }
    end

    def get_payload
      params.permit(:name, :application_token, :number)
    end

    def valid?
      name_length = params[:name].size
      error = []
      error.push("Name must be between 3 and 30 characters") if name_length < 3 || name_length > 30
      render json: { error: error } if !error.empty?
    rescue
      render json: {error: "Enter valid params"}
    end

end
  