# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

$provision_script = <<EOF

# Fix issue with locale
sudo update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 > /dev/null

# Install dependencies
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update
sudo apt-get install --assume-yes git

# Install ruby using rbenv and rvm-download plugin
git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.profile
echo 'eval "$(rbenv init -)"' >> ~/.profile
source ~/.profile
git clone https://github.com/garnieretienne/rvm-download.git \
    ~/.rbenv/plugins/rvm-download
rbenv download 2.1.5
rbenv global 2.1.5
rbenv rehash

# Install PostgreSQL
# https://github.com/jackdb/pg-app-dev-vm/blob/master/Vagrant-setup/bootstrap.sh
POSTGRES_VERSION=9.3
sudo su --command \
    'echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > \
    /etc/apt/sources.list.d/postgresql.list'
wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | \
    sudo apt-key add -
sudo apt-get update
sudo apt-get install --assume-yes postgresql-$POSTGRES_VERSION \
    postgresql-server-dev-$POSTGRES_VERSION libpq-dev
cat << EOC | sudo --user postgres psql
-- Create the database user:
CREATE USER $USER WITH PASSWORD '$USER';
-- Create the database:
CREATE DATABASE $USER WITH OWNER $USER;
EOC
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" \
    "/etc/postgresql/$POSTGRES_VERSION/main/postgresql.conf"
echo "export DATABASE_URL=postgres://$USER:$USER@localhost:5432/$USER" > \
    ~/.bashrc

# Install SQlite
sudo apt-get install --assume-yes sqlite3 libsqlite3-dev

# Configure staticdctl to authenticate on localhost using development
# credentials
cat <<EOC > ~/.staticdctl.yml
---
http://localhost:8080/api:
  access_id: '1000'
  secret_key: XAQCxLanQwGNTS99+EAkBRDf/it4nZVa2Ct5zugRn/QorNdN+hxBrjvPLExhuFpwnQLpGIF641eddgknEbbAiw==
EOC
echo "export STATICDCTL_ENDPOINT=http://localhost:8080/api" >> ~/.bashrc

# Install gem dependencies using bundler
sudo apt-get install --assume-yes build-essential libssl-dev
gem install bundler
rbenv rehash
cd /vagrant
bundle install --path vendor/bundle

EOF

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.network "forwarded_port", guest: 8080, host: 8080
  config.vm.network "private_network", type: "dhcp"
  config.vm.synced_folder ".", "/vagrant", type: "nfs"
  config.vm.provision "shell", inline: $provision_script, privileged: false
end
