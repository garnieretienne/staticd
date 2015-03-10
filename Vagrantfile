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

# Install SQlite
sudo apt-get install --assume-yes sqlite3 libsqlite3-dev

# Configure staticdctl to authenticate on localhost using development
# credentials.
cat <<EOC > ~/.staticdctl.yml
---
http://localhost:8080/api/v1:
  access_id: '1000'
  secret_key: not_secure
EOC
echo "export STATICDCTL_ENDPOINT=http://localhost:8080/api/v1" >> ~/.bashrc

# Install bundler.
sudo apt-get install --assume-yes build-essential libssl-dev
gem install bundler
rbenv rehash
cd /vagrant

# Use system libraries on Ubuntu 14.04 to build nokogiri and save time.
# See: https://github.com/sparklemotion/nokogiri/issues/1099
sudo apt-get install --assume-yes libxslt-dev libxml2-dev
bundle config build.nokogiri "--use-system-libraries=true --with-xml2-include=/usr/include/libxml2"

# Install system dependencies and gems using bundler.
sudo apt-get install --assume-yes postgresql-server-dev-9.3 libpq-dev
bundle install --path vendor/bundle

EOF

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--memory", "1024"]
    v.customize ["modifyvm", :id, "--cpus", "2"]
  end

  config.vm.box = "ubuntu/trusty64"
  config.vm.network "forwarded_port", guest: 8080, host: 8080
  config.vm.network "private_network", ip: "192.168.50.10"
  config.vm.synced_folder ".", "/vagrant", type: "nfs"
  config.vm.provision "shell", inline: $provision_script, privileged: false
end
