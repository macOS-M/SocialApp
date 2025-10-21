class SearchController < ApplicationController
  before_action :authenticate_user!

  def index
    @q = params[:q].to_s
    @type = params[:type].presence || "users"

    @results = {}

    if @type == "users"
      scope = User.search(@q)
      scope = scope.where.not(id: current_user.id) if current_user.present?
      @results[:users] = scope.order(username: :asc).limit(50)
    else
      scope = User.search(@q)
      scope = scope.where.not(id: current_user.id) if current_user.present?
      @results[:users] = scope.order(username: :asc).limit(50)
    end
  end
end
