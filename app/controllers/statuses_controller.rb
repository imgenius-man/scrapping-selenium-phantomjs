require 'rake'

Rake::Task.clear # necessary to avoid tasks being loaded several times in dev mode
Academia::Application.load_tasks # providing your application name is 'sample'

class StatusesController < InheritedResources::Base

  def edit
    @status = Status.find(params[:id])
  end

  # def edit
  #   flash[:warning] = "Test executed..."
  #
  #   # status = Status.find(params[:id])
  #   url = Status.find(params[:id]).site_url
  #
  #   if url.include? 'cignaforhcp'
  #     Rake::Task["cigna_test"].invoke
  #   elsif url.include? 'mhnet'
  #     Rake::Task["mhnet_test"].invoke
  #   end
  #
  #   redirect_to :back
  # end
end
