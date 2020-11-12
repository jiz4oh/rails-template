class HomeController < ApplicationController
  def index
  end

  def error_404
    raise PageNotFound
  end

  def status
    render plain: "OK #{Time.now.iso8601}"
  end
end
