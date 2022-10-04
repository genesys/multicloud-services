### Check that iwdem pod is running

( ! wait_running_status "servicename=iwdem" 180 ) && exit 1

return 0