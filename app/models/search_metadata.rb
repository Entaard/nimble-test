class SearchMetadata < ApplicationRecord
  self.table_name = 'search_metadata'

  belongs_to :user
end
