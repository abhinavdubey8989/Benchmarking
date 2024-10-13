#!/bin/bash

# MySQL Credentials
MYSQL_USER="root"
MYSQL_PASS="password"
MYSQL_DB="test"
MYSQL_HOST="localhost"
MYSQL_CMD="mysql -u $MYSQL_USER -p $MYSQL_PASS -h $MYSQL_HOST ${MYSQL_DB}"

# Configuration: Number of threads and iterations
THREADS=8       # or number of concurrent users
ITERATIONS=1000 # operations done by each user or thread

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
  local start_time=$(date +%s%3N)
  $MYSQL_CMD -e "SELECT * FROM test_table WHERE id = FLOOR(RAND() * 1000) LIMIT 1;"
  local end_time_ms=$(date +%s%3N)
  send_timer_metric "read" $start_time_ms $end_time_ms
}

write_query() {
  local start_time=$(date +%s%3N)
  $MYSQL_CMD -e "INSERT INTO test_table (name, value) VALUES ('benchmark', RAND());"
  local end_time_ms=$(date +%s%3N)
  send_timer_metric "write" $start_time_ms $end_time_ms
}

# generate load for specified number of iterations
run_concurrent_load_based_on_iteration() {
  for ((i = 1; i <= ITERATIONS; i++)); do
    if ((i % 2 == 0)); then
      read_query
    else
      write_query
    fi
  done
}

# generate load for a specified duration
run_concurrent_load_based_on_duration() {
  local start_time=$(date +%s) # Capture the current time in seconds
  local current_time=$start_time

  while ((current_time - start_time < DURATION)); do
    if ((RANDOM % 2 == 0)); then
      read_query
    else
      write_query
    fi

    # Update the current time
    current_time=$(date +%s)
  done
}

start_all_threads() {
  echo "Starting benchmark with $THREADS threads/users and $ITERATIONS iterations per thread..."

  for ((t = 1; t <= THREADS; t++)); do
    # Run each thread in the background
    run_concurrent_load_based_on_iteration &
    # run_concurrent_load_based_on_duration &
  done
}

start_all_threads
wait # Wait for all background threads to complete
echo "Benchmarking completed !!"