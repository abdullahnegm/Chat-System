class ChatsController < ApplicationController
    before_action :set_chat, only: %i[ show edit update destroy ]
  
    def index
      @chat = Chat.where(token: params[:token]).map {|chat| {name: chat.name, token: chat.token, number: chat.number}}
      render json: { data: @chat }, status: :ok
    rescue => e
      render json: {error: e}, status: :bad_request
    end
  
    def show
      render json: { data: {number: @chat.number, name: @chat.name, token: @chat.token} }
    end



    private
    def set_chat
      @chat = Chat.where(chat_params).first

      render json: {data: nil} if @chat.nil?
    rescue => e
        render json: {error: e}
    end

    def chat_params
      params.permit(:token, :number)
    end
  
  end
  