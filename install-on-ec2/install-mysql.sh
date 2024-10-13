

# update & install
sudo apt update
sudo apt install mysql-server -y

# check if service status
sudo systemctl status mysql.service

# if you see active(running) in above command, then this cmd is not needed
sudo systemctl start mysql.service


# connect to sql shell
sudo mysql

# to exit shell - type "exit" & press enter

# check version
mysql --version