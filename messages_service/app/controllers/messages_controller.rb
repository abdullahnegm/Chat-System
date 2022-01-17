class MessagesController < ApplicationController
    before_action :set_message, only: %i[ show ]
  
    def index
      @message = Message.where(token: params[:token], chat_number: params[:chat_number]).map {|message| {number: message.number, body: message.body, token: message.token, chat_number: message.chat_number}}
      render json: { data: @message }, status: :ok
    rescue => e
      render json: {error: e}, status: :bad_request
    end
  
    def show
      render json: { data: {number: @message.number, body: @message.body, chat_number: @message.chat_number, token: @message.token} }
    end

    def search
      results = Message.search params["body"]
      render json: { data: results.records.to_a }
    end

    private
    def set_message
      @message = Message.where(message_params).first

      render json: {data: nil} if @message.nil?
    rescue => e
        render json: {error: e}
    end

    def message_params
      params.permit(:token, :chat_number, :number, :body)
    end
  
end