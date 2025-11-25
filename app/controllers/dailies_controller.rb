class DailiesController < ApplicationController
  def index
    # Show all summaries collected so far
    @dailies = Daily.order(created_at: :desc)
  end

  def show
    # Show only the last/most recent daily summary
    @daily = Daily.order(created_at: :desc).first
  end
end
