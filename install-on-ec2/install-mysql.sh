# update & install
sudo apt update
sudo apt install -y mysql-server

# check if service status
sudo systemctl status mysql.service

# if you see active(running) in above command, then this cmd is not needed
sudo systemctl start mysql.service

# check version
mysql --version

# ================
# MYSQL commands
# ================

# 0. connect to sql : sudo mysql -u <user-name> -p (then enter password)
# 1. show dbs : SHOW DATABASES;
# 2. create db : CREATE DATABASE <db-name>;                [eg: CREATE DATABASE ad_sql_db;]
# 3. select db to perform table level ops : USE <db-name>; [eg: USE ad_sql_db;]
# 4. create table commands
# CREATE TABLE students (
#   id INT AUTO_INCREMENT PRIMARY KEY,
#   name VARCHAR(255),
#   marks DOUBLE
# );
# 5. insert into table : INSERT INTO students (name, marks) VALUES (SUBSTRING(MD5(RAND()), 1, 10), RAND());
# 6. show tables in current SQL db : SHOW TABLES;
# 7. describe a table : DESC <table-name>;
# 8. drop/delete table : DROP TABLE <table-name>;

# =======
# 9. current user : SELECT user();
# 10. change password for username "root" : ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'new_password';
