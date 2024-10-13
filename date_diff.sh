
DB="pg"

send_timer_metric() {
  local metric_prefix=$1
  local start_time_ms=$2
  local end_time_ms=$3

  # diff is time-elapsed
  diff_ms=$((end_time_ms - start_time_ms))

  # send metric to statsd
  final_metric="${metric_prefix}.${DB}:${diff_ms}|ms"
  echo -n "$final_metric"
}

read_query() {
  local start_time_ms=$(date +%s%3N)
  sleep 0.001
  local end_time_ms=$(date +%s%3N)
  send_timer_metric "read" $start_time_ms $end_time_ms
}

write_query() {
  local start_time_ms=$(date +%s%3N)
  sleep 0.02
  local end_time_ms=$(date +%s%3N)
  send_timer_metric "write" $start_time_ms $end_time_ms
}



read_query
echo
write_query
echo