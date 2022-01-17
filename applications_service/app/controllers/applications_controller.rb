class ApplicationsController < ApplicationController
  SERVICE  = 'application'
  Chat_URL = "http://chats_service:3001"

  before_action :set_application, only: %i[ show  ]
  before_action :authenticate, only: %i[ show ]

  def index
    @applications = Application.select(:name, :token).map {|app| {name: app.name, token: app.token}}
    render json: { data: @applications }, status: :ok
  rescue => e
    render json: {error: e}, status: :bad_request
  end

  def show
    render json: { data: {name: @application.name, token: @application.token, chat_size: chat_size} }
  rescue => e
    render json: {error: e}
  end


  private

  def chat_size

    size = REDIS.get(@application.token)
    if size.nil?
      # size = (HttpAdapter.new(SERVICE, Chat_URL, "GET", "/applications/#{@application.token}/chats").call).size
      size = @application.chats_count
      REDIS.set(@application.token, size, ex: 60 * 60) 
    end

    size
  rescue => e
    raise e
  end

end
