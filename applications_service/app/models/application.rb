class Application < ApplicationRecord
    self.primary_key = "token"

    before_create { |application| application.token = generate_token } 

    validates :name, presence: true, length: { in: 3..30 }

    def to_param
        token
    end

    def generate_token
        SecureRandom.hex(10)
    end
end
