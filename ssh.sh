



# cmd line args
TARGET_MACHINE=$1
EC2_IP=0.0.0.0


# IP of instances
EC2_PG=65.2.30.76
EC2_MYSQL=65.2.30.70

# store content of above file (which is an IP) to this variable 
PEM_FILE=~/Documents/ad/aws-and-docker/0_secrets/aws_ad89.pem


# get final IPv4
if [ "$TARGET_MACHINE" = "pg" ] ; then
    EC2_IP=$EC2_PG
elif [ "$TARGET_MACHINE" = "mysql" ]; then
   EC2_IP=$EC2_MYSQL
else
    echo "Invalid 1st arg"
    exit 0
fi

# now ssh 
echo ssh -i $PEM_FILE ubuntu@$EC2_IP