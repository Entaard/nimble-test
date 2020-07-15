class HomeController < ApplicationController
  def index

  end

  def upload
    p keywords_params
  end

  private

  def keywords_params
    params.require(:keywords)
  end
end
