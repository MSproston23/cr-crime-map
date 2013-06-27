class LogEntriesController < ApplicationController

  def show
    @json = LogEntry.all.to_gmaps4rails
  end
end
