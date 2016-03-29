class ServiceTypesController < ApplicationController
  def index
    @service_types = ServiceType.all
    respond_to do |format|
      format.html
      format.csv { send_data ServiceType.to_csv }
    end
  end
end
