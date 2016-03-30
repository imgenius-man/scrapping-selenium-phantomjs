class ServiceTypesController < ApplicationController
  def index
    respond_to do |format|
      format.html
      format.csv { send_data ServiceType.to_csv(params[:id]) }
    end
  end
end
