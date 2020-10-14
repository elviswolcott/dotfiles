# clone the repo and run the install script
echo "cloning dotfiles repository..."
git clone https://github.com/elviswolcott/dotfiles.git
cd dotfiles
chmod ./linux-setup.sh +x
echo "entering setup script..."
./linux-setup.sh