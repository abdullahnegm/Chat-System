class Message < ApplicationRecord
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    validates :body, presence: true, length: { in: 3..100 }

    settings do
        mappings dynamic: false do
          indexes :body, type: :text
        end
    end
end
