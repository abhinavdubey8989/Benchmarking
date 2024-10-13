# cmd line args
TARGET_HOSTNAME=$1

# pints to /etc/hosts on EC2 machines & this file on local
HOSTS_FILE=~/Documents/ad/DB-benchmarking/etc_hosts.txt
PEM_FILE=~/Documents/ad/aws-and-docker/0_secrets/aws_ad89.pem

get_ip_for_ec2_hostname() {
    local target_ec2_hostname=$1
    grep "$target_ec2_hostname" "$HOSTS_FILE" | awk '{print $1}'
}

main() {
    IP_ADDRESS=$(get_ip_for_ec2_hostname "$TARGET_HOSTNAME")

    # if no IP found, exit without doing SSH
    if [ -z "$IP_ADDRESS" ]; then
        echo "Cannot find IP_ADDRESS corresponsing to 1st arg (TARGET_HOSTNAME)"
        exit 0
    fi

    # for valid IP, do SSH
    echo ssh -i $PEM_FILE ubuntu@$IP_ADDRESS
    ssh -i $PEM_FILE ubuntu@$IP_ADDRESS
}

main