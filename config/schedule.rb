every 1.day, :at => '1:30 am' do
  rake "web_html_test"
end

every 17.minutes do
  rake "web_html_test"
end
