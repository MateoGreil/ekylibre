export DISPLAY=:99.0
sh -e /etc/init.d/xvfb start
sudo apt-get install python-software-properties
echo "yes" | sudo apt-add-repository ppa:sharpie/for-science
echo "yes" | sudo apt-add-repository ppa:sharpie/postgis-stable
echo "yes" | sudo apt-add-repository ppa:ubuntugis/ubuntugis-unstable
sudo apt-get update
echo "> List postgis related packages"
sudo apt-cache search postgis
echo "> Install missing packages"
sudo apt-get install -qq libgeos-dev libgeos++-dev libproj-dev postgresql-9.1-postgis-2.1 libmagic-dev
