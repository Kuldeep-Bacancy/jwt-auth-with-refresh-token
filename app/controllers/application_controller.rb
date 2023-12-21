class ApplicationController < ActionController::API
  include ApplicationErrors

  def index
    render_404
  end
end
