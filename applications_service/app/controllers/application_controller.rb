class ApplicationController < ActionController::API

    def authenticate
        render json: {error: "Application Doesn't Exist"} if @application.token != params[:token]
    end

    def set_application
        @application = Application.find(params[:token])
    rescue 
        render json: {error: "Application Doesn't Exist"}
    end
  
    def application_params
        params.permit(:name)
    end
end
