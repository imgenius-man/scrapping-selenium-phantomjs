every :friday, :at => "03:27pm" do
  rake "mhnet_test"
end

every 5.minutes do
  rake "mhnet_test"
end
