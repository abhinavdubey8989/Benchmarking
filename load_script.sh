# AIM : this script will load test DB for some duration to find read & write throughput
# sample usage :
#       - "./<name-of-this-file>.sh pg 100"     (test postgres db for 100 seconds)
#       - "./<name-of-this-file>.sh mysql 100"  (test mysql db for 100 seconds)

# cmd line args
DB_NAME=$1
LOAD_DURATION_IN_SECONDS=$2

# MySQL Credentials
MYSQL_USER="root"
MYSQL_PASS="password"
MYSQL_DB="test"
MYSQL_HOST="localhost"
MYSQL_CMD="mysql -u $MYSQL_USER -p $MYSQL_PASS -h $MYSQL_HOST ${MYSQL_DB}"

# number of threads or concurrent-users
THREADS=1
STATSD_PORT=8125

send_timer_metric() {
  local metric_prefix=$1
  local start_time_ms=$2
  local end_time_ms=$3

  # diff is time-elapsed
  diff_ms=$((end_time_ms - start_time_ms))

  # send metric to statsd
  final_metric="${metric_prefix}.${DB_NAME}:${diff_ms}|ms"
  echo "$final_metric" | nc -w 2 -u ec2_grafana $STATSD_PORT
}

read_query() {
  local start_time_ms=$(date +%s%3N)
  sleep 0.001 #$MYSQL_CMD -e "SELECT * FROM test_table WHERE id = FLOOR(RAND() * 1000) LIMIT 1;"
  local end_time_ms=$(date +%s%3N)

  # send metric in background
  send_timer_metric "read" $start_time_ms $end_time_ms &
}

write_query() {
  local send_metric=$1
  local start_time_ms=$(date +%s%3N)
  sleep 0.04 #$MYSQL_CMD -e "INSERT INTO test_table (name, value) VALUES ('benchmark', RAND());"
  local end_time_ms=$(date +%s%3N)

  # send metric in background
  send_timer_metric "write" $start_time_ms $end_time_ms &
}

# generate load for a specified duration
run_concurrent_load_based_on_duration() {
  local start_time_in_seconds=$(date +%s)
  local diff_in_seconds=0

  while ((diff_in_seconds < LOAD_DURATION_IN_SECONDS)); do
    if ((RANDOM % 2 == 0)); then
      read_query
    else
      write_query
    fi

    # Update the current time
    current_time_in_seconds=$(date +%s)
    diff_in_seconds=$((current_time_in_seconds - start_time_in_seconds))
    echo "diff is $diff_in_seconds"
  done
}

start_all_threads() {
  echo "Starting benchmark with $THREADS threads/users and $ITERATIONS iterations per thread..."

  for ((t = 1; t <= THREADS; t++)); do
    # Run each thread in the background
    run_concurrent_load_based_on_duration &
  done
}

# generate load for warm-up
warm_up_db() {
  local WARMUP_DURATION_IN_SECONDS=5
  local start_time_in_seconds=$(date +%s)
  local diff_in_seconds=0

  while ((diff_in_seconds < WARMUP_DURATION_IN_SECONDS)); do
    $MYSQL_CMD -e "SELECT * FROM test_table WHERE id = FLOOR(RAND() * 1000) LIMIT 1;"
    $MYSQL_CMD -e "INSERT INTO test_table (name, value) VALUES ('benchmark', RAND());"

    # Update the current time
    current_time_in_seconds=$(date +%s)
    diff_in_seconds=$((current_time_in_seconds - start_time_in_seconds))
    echo "diff is $diff_in_seconds"
  done
}

validate() {

  # DB-name must be an allowed value
  if [ "$DB_NAME" != "pg" ] && [ "$DB_NAME" != "mysql" ]; then
    echo "1st arg (DB_NAME) is not an allowed value."
    exit 0
  fi

  # LOAD_DURATION_IN_SECONDS must be a number
  if [[ ! "$LOAD_DURATION_IN_SECONDS" =~ ^[0-9]+$ ]]; then
    echo "2nd arg (LOAD_DURATION_IN_SECONDS) is not a number"
    exit 0
  fi
}

main() {
  validate
  warm_up_db
  start_all_threads
  wait # Wait for all background threads to complete
  echo "Benchmarking completed !!"
}

main