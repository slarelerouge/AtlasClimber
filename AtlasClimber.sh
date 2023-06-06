## REDMINE INSTALL
# Variables
REDMINE_ADMIN_USER_NAME = "redmine"
REDMINE_ADMIN_USER_PASSWORD = "redmine"
REDMINE_INSTALLATION_ROOT = "/opt"
REDMINE_INSTALLATION_FOLDER = "redmine"
REDMINE_INSTALLATION_DIRECTORY = $REDMINE_INSTALLATION_ROOT/$REDMINE_INSTALLATION_FOLDER
APACHE_CONFIG_FOLDER = /etc/apache2

# update & upgrade 
sudo apt-get update && sudo apt-get upgrade -y

# install required packages
sudo apt install -y apache2 ruby ruby-dev build-essential libapache2-mod-passenger libmysqlclient-dev

# if you want to install mysql server locally
sudo apt install -y mysql-server

# download and extract
cd ~
wget https://redmine.org/releases/redmine-5.0.5.tar.gz
cd /opt
sudo tar -xvzf ~/redmine-5.0.5.tar.gz
cd ~

# Create a symlink folder to remove version reference
sudo ln -s $REDMINE_INSTALLATION_ROOT/redmine-5.0.5 $REDMINE_INSTALLATION_ROOT/$REDMINE_INSTALLATION_FOLDER

# Create the Mysql database for Redmine
sudo mysql -Bse "CREATE DATABASE redmine CHARACTER SET utf8mb4;CREATE USER 'redmine'@'localhost' IDENTIFIED BY 'secretPassword';GRANT ALL PRIVILEGES ON redmine.* TO 'redmine'@'localhost';FLUSH PRIVILEGES;"

# copy the example file
cp $REDMINE_INSTALLATION_DIRECTORY/config/database.yml.example $REDMINE_INSTALLATION_DIRECTORY/config/database.yml

# Set default admin acount for the database
sudo sed -i "s/username: root/username: $REDMINE_ADMIN_USER_NAME/g" $REDMINE_INSTALLATION_DIRECTORY/config/database.yml
sudo sed -i "s/password: ""/password: $REDMINE_ADMIN_USER_PASSWORD/g" $REDMINE_INSTALLATION_DIRECTORY/config/database.yml

# install bundler
sudo gem install bundler

# install redmine bundle (give sudo password when prompted)
bundle install

# generate secret token
bundle exec rake generate_secret_token

# migrate database
RAILS_ENV=production bundle exec rake db:migrate

# load default data
RAILS_ENV=production bundle exec rake redmine:load_default_data

# Set appache settings
echo "<VirtualHost *:80>
    ServerName redmine.example.com
    RailsEnv production
    DocumentRoot /opt/redmine/public

    <Directory "${REDMINE_INSTALLATION_DIRECTORY}/public">
            Allow from all
            Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/redmine_error.log
        CustomLog ${APACHE_LOG_DIR}/redmine_access.log combined
</VirtualHost>" >> $APACHE_CONFIG_FOLDER/sites-available/redmine.conf

# disable default apache sites
sudo a2dissite 000-default.conf

# enable redmine
sudo a2ensite redmine.conf

# Reload apache
sudo systemctl reload apache2

# Add template
cd ~
wget https://github.com/mrliptontea/PurpleMine2/archive/master.zip
unzip master.zip -d $REDMINE_INSTALLATION_DIRECTORY/public/themes

# Add plugin


## XWIKI INSTALL
apt-get install wget curl unzip git name gnupg2 -y

apt-get install default-jdk -y

wget https://maven.xwiki.org/xwiki-keyring.gpg -O /usr/share/keyrings/xwiki-keyring.gpg
wget https://maven.xwiki.org/xwiki-keyring.gpg -O /usr/share/keyrings/xwiki-keyring.gpg
wget "https://maven.xwiki.org/stable/xwiki-stable.list" -O /etc/apt/sources.list.d/xwiki-stable.list
wget "https://maven.xwiki.org/stable/xwiki-stable.list" -O /etc/apt/sources.list.d/xwiki-stable.list

apt update

apt install xwiki-tomcat9-mysql

