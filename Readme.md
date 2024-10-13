




========
# AWS
========

added the below to SSH into EC2 :

- Changed subnet setting -> enable assign IPv4
- NACL in-bound rule -> allow all
- NACL out-bound rule -> allow all
- Security group in-bound rule -> allow traffic from all IP & to all ports on EC2 
    - a stricter rule could be to allow SSH traffic only from current machine IP address
- Security group out-bound rule -> allow traffic from all IP & to all ports on EC2
