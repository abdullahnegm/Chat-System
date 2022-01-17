class HttpAdapter
    attr_reader :service, :method, :path, :url

    def initialize service, url, method, path
        @service = service
        @url     = url
        @method  = method
        @path    = path
    end
    
    def call
        response = self.public_send(method)
        response_body = JSON.parse( response.body )
        raise response_body["error"] if response_body["error"]
        
        response_body["data"]
    rescue => e
        raise "Something went wrong with #{service}, at #{path}"
    end

    def uri
        @uri ||= URI( url + path )
    end

    def http
        @http ||= Net::HTTP.new( uri.host, uri.port )
    end

    def GET
        request = Net::HTTP::Get.new uri
        http.request request
    end

end