class ReportController < ApplicationController
  def index
    @search_metadata = current_user.search_metadata.order(created_at: :desc)
  end
end
