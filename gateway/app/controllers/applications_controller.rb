class ApplicationsController < ApplicationController
    SERVICE = "application"
    URL     = "http://applications_service:3000"
    
    before_action :call_application, only: %i[index show]
    before_action :valid?, only: %i[create update]

    def index
      render json: { data: @applications }, status: :ok
    end
  
    def show
      render json: { data: @applications }
    end
  
    def create
      message = {method: "create", data: get_payload}
      Publisher.publish(SERVICE, message)
      render json: { message: "Application Created" }, status: :ok
    end
  
    def update
      message = {method: "update", data: get_payload}
      Publisher.publish(SERVICE, message)
      render json: { message: "Application Updated" }, status: :ok
    end
  
    def destroy
      message = {method: "destroy", data: get_payload}
      Publisher.publish(SERVICE, message)
      render json: { message: "Application Deleted" }, status: :ok
    end
  
    private
    def call_application
      @applications = HttpAdapter.new(SERVICE, URL, request.method, request.fullpath).call
    rescue => e
      return render json: { error: e.message }
    end

    def get_payload
      params.permit(:name, :token)
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
  