curl --verbose -X POST -u sms:DZn7pzdC \
  -H "Content-Type: application/json" \
  -d '{ "message": "Hello, eureka!", "phoneNumbers": ["+4917681764859"] }' \
  http://192.168.178.45:8080/message


  curl -X POST -u sms:DZn7pzdC \
  -H "Content-Type: application/json" \
  -d '{ "id": "101", "url": "https://e515-2003-fb-ef01-2500-8c61-7745-b8e2-f58b.ngrok-free.app/webhooks/sms", "event": "sms:received" }' \
  http://192.168.178.45:8080/webhooks


curl -X POST -u sms:DZn7pzdC \
  -H "Content-Type: application/json" \
  -d '{ "id": "102", "url": "https://e515-2003-fb-ef01-2500-8c61-7745-b8e2-f58b.ngrok-free.app/webhooks/sms", "event": "sms:sent" }' \
  http://192.168.178.45:8080/webhooks


curl -X POST -u sms:DZn7pzdC \
  -H "Content-Type: application/json" \
  -d '{ "id": "103", "url": "https://e515-2003-fb-ef01-2500-8c61-7745-b8e2-f58b.ngrok-free.app/webhooks/sms", "event": "sms:failed" }' \
  http://192.168.178.45:8080/webhooks

  curl -X POST -u sms:DZn7pzdC \
  -H "Content-Type: application/json" \
  -d '{ "id": "104", "url": "https://e515-2003-fb-ef01-2500-8c61-7745-b8e2-f58b.ngrok-free.app/webhooks/sms", "event": "sms:delivered" }' \
  http://192.168.178.45:8080/webhooks



  curl -X GET -u sms:DZn7pzdC http://192.168.178.45:8080/webhooks




### clean run
rake db:drop db:create  db:migrate:with_data
bundle exec rake  "init_admin_roles:seed[recloud]"
bundle exec rake  "init_admin_roles:seed[hush]"
rake "templates:update"
rake "utils:correct_issue_uuids[2]"






migrations

./scripts/snapshot_prodb.sh

kubectl run my-temp-mysql-client --image=mysql:5.7 --restart=Never --rm -it /bin/bash
./scripts/snapshot_prodb.sh
# gzip the file
kubectl cp /tmp/latest_backup.gz default/my-temp-mysql-client:/tmp

10.255.0.2
on mysql client
mysql -h 10.xxxxx -u recloud -p -e "DROP DATABASE hush_production; CREATE DATABASE hush_production"
mysql -h 10.xxxxx -u recloud -p hush_production < /tmp/latest_backup

MyRecl0ud2025


# Hush run instruction
create a public user and get api-key
create busniss hours



# ufw rules


ufw allow from 172.18.0.0/16 to any port 3306 proto tcp





sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl status docker

sudo apt-get install docker-compose-plugin
docker compose version
apt install -y git curl jq
git clone https://github.com/postalserver/install /opt/postal/install
sudo ln -s /opt/postal/install/bin/postal /usr/bin/postal
apt install ufw
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow http
ufw allow https
ufw enable
ufw status
sudo ufw allow 25/tcp
sudo ufw allow 587/tcp
sudo ufw allow 465/tcp
docker run -d --name postal-mariadb -p 127.0.0.1:3306:3306 --restart always -e MARIADB_DATABASE=postal -e MARIADB_ROOT_PASSWORD=HushMe1971 mariadb
mysql
sudo apt install default-mysql-client -y
htop
mysql -uroot -p
/root/.bash_history
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl status docker
docker run hello-world
docker ps
 sudo apt-get install docker-compose-plugin
docker compose version
[200~apt install git curl jq
apt install git curl jq
apt install -y git curl jq
git clone https://github.com/postalserver/install /opt/postal/install
sudo ln -s /opt/postal/install/bin/postal /usr/bin/postal
ufw
apt install ufw
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow http
ufw allow https
ufw enable
ufw status
sudo ufw allow 25/tcp
sudo ufw allow 587/tcp
sudo ufw allow 465/tcp
[200~docker run -d    --name postal-mariadb    -p 127.0.0.1:3306:3306    --restart always    -e MARIADB_DATABASE=postal    -e MARIADB_ROOT_PASSWORD=HushMe1971    mariadb
docker run -d --name postal-mariadb -p 127.0.0.1:3306:3306 --restart always -e MARIADB_DATABASE=postal -e MARIADB_ROOT_PASSWORD=HushMe1971 mariadb
mysql
sudo apt install default-mysql-client -y
htop
mysql -uroot -p
mysql -uroot -p -h 127.0.0.1
sudo systemctl status mysql
sudo systemctl status mariadb
docker ps
postal bootstrap postal.hush-haarentfernung.de
vi /opt/postal/config/postal.yml
docker ps
docker stop mariadb
docker stop portal-mariadb
docker ls
docker ps
docker stop a3de53028508
--------


ufw allow from 172.18.0.0/16 to any port 3306 proto tcp
ufw allow from 172.18.0.0/16 to any port 6379 proto tcp
ufw allow from 172.18.0.0/16 to any port 5000 proto tcp
sudo ufw status verbose