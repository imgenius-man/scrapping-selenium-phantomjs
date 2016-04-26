module StatusesHelper
  def status_of_site(status_id)
    status = Status.find(status_id)
    status.status && status.login_status  && status.patient_search_status && status.site_status
  end
end
