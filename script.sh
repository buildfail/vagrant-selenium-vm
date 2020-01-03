#! /bin/bash

set -e

if [ -e /.installed ]; then
  echo 'Already installed.'

else
  echo ''
  echo 'Installing basic packages'
  echo '----------'

  # Add Google public key to apt
  wget -q -O - "https://dl-ssl.google.com/linux/linux_signing_key.pub" | sudo apt-key add -

  # Add Google to the apt-get source list
  echo 'deb http://dl.google.com/linux/chrome/deb/ stable main' >> /etc/apt/sources.list

  # Update app-get
  apt-get update

  # Install Java, Chrome, Xvfb, and unzip
  apt-get -y install openjdk-7-jre google-chrome-stable xvfb unzip firefox

  # Download and copy the ChromeDriver to /usr/local/bin
  cd /tmp

  echo "Download latest selenium server..."
  SELENIUM_VERSION="2.53.0"
  wget -O selenium-server-standalone.jar "https://selenium-release.storage.googleapis.com/2.53/selenium-server-standalone-2.53.0.jar"

  chown vagrant:vagrant selenium-server-standalone.jar
  mv selenium-server-standalone.jar /usr/local/bin

  echo "Download latest chrome driver..."
  CHROMEDRIVER_VERSION=$(curl "http://chromedriver.storage.googleapis.com/LATEST_RELEASE")
  wget "http://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip"

  unzip chromedriver_linux64.zip
  sudo rm chromedriver_linux64.zip
  chown vagrant:vagrant chromedriver
  mv chromedriver /usr/local/bin

  echo "Done downloading and installing basic packages"

  echo "Writing entries into the host file"
  for var in "$@"
  do
      echo "192.168.33.1  $var" >> /etc/hosts
  done

  # So that running `vagrant provision` doesn't redownload everything
  touch /.installed
fi

# build fail
echo -n 'CiAgICBfX19fX18gICAgIF9fX18KICAgLyAgICAgICBcICB8ICBvIHwgCiAgfCAgICAgICAgIHwvIF9fX1x8IAogIHxfX19fX19fX18vICAgICAKICB8X3xffCB8X3xffAoKICA6YnVpbGQgZmFpbDoKCgAA'|base64 --decode >> /etc/update-motd.d/00-header


# Start Xvfb, Chrome, and Selenium in the background
export DISPLAY=:10
cd /vagrant

echo "Starting Xvfb ..."
Xvfb :10 -screen 0 1366x768x24 -ac &

echo "Starting Google Chrome ..."
su - vagrant -c 'google-chrome --headless --disable-gpu --remote-debugging-port=9222 http://localhost'

echo "Starting Selenium ..."
cd /usr/local/bin
nohup java -jar ./selenium-server-standalone.jar &

