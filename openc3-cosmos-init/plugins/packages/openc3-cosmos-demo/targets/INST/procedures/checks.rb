# Display the environment variables
puts ENV.inspect
# Print the TYPE env var which is set in the INST COMMANDING screen
puts "ENV['TYPE']:#{ENV['TYPE']}"

# Test some of the various keyword arguments
cmd("<%= target_name %> ABORT", timeout: 30)
cmd("<%= target_name %> ABORT", log_message: false)
cmd("<%= target_name %> ABORT", validate: false)
collect_cnt = tlm("<%= target_name %> HEALTH_STATUS COLLECTS")
cmd("<%= target_name %> COLLECT with DURATION 11, TYPE NORMAL")
cmd_no_range_check("<%= target_name %> COLLECT with DURATION 11, TYPE NORMAL")
cmd_no_hazardous_check("<%= target_name %> COLLECT with DURATION 11, TYPE NORMAL")
cmd_no_checks("<%= target_name %> COLLECT with DURATION 11, TYPE NORMAL")
wait_check("<%= target_name %> HEALTH_STATUS COLLECTS == #{collect_cnt + 2}", 10)
cmd("<%= target_name %> CLEAR")
cmd_no_range_check("<%= target_name %> CLEAR")
cmd_no_hazardous_check("<%= target_name %> CLEAR")
cmd_no_checks("<%= target_name %> CLEAR")
puts tlm("<%= target_name %> HEALTH_STATUS COLLECTS")
