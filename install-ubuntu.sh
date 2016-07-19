# https://www.ap-i.net/skychart/en/documentation/installation_on_linux_ubuntu
#

# Add skychart repo
sudo apt-add-repository 'deb http://www.ap-i.net/apt stable main'

# Remove source code repo from above command
sudo apt-add-repository --remove 'deb-src http://www.ap-i.net/apt stable main'

# request public key
gpg --keyserver keyserver.ubuntu.com --recv C56CCB02D79BF92A

# Add public key
gpg --export --armor C56CCB02D79BF92A | sudo apt-key add -

# Update repo
sudo apt-get update

# Install Skychart without full dependencies
#  (does not install the packages required for the 
#   Artificial Satellites display, can be installed
#   later)
sudo apt-get install --no-install-recommends skychart

# Also install deep-sky objects (galaxies) and stars not seen with
# naked eye:
# sudo apt-get install skychart-data-stars skychart-data-dso skychart-data-pictures
