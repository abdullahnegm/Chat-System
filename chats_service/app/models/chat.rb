class Chat < ApplicationRecord
    validates :name, presence: true, length: { in: 3..30 }

end
