#!/data/data/com.termux/files/usr/bin/bash

# Display ASCII art in green
echo -e "\e[32m"  # Set green color
echo " ________________    ___ ___ ._____________ "
echo "\__    ___/  _  \  /   |   \|   \______   \\"
echo "  |    | /  /_\  \/    ~    \   ||       _/"
echo "  |    |/    |    \    Y    /   ||    |   \\"
echo "  |____|\____|__  /\___|_  /|___||____|_  /"
echo "                \/       \/             \/ "
echo -e "\e[0m"  # Reset color
echo -e "\e[33mSupport Me\nIG: @f.r.e.e.c_ YT: @v5rn\e[0m"  # Smaller yellow text for support
sleep 2  # Pause to show the text
clear

# Update Termux packages
pkg update -y && pkg upgrade -y

# Setup storage
termux-setup-storage

# Install necessary repositories if not already enabled
pkg install tur-repo -y
pkg install x11-repo -y

# Install Termux-X11 nightly and related packages
pkg install termux-x11-nightly x11-repo -y

# Install proot-distro
pkg install proot-distro -y

# Clear the screen
clear

# Install Ubuntu distro
proot-distro install ubuntu

# Prompt for username (lowercase letters only)
while true; do
    read -p "Enter a username in lowercase letters: " username
    if [[ "$username" =~ ^[a-z]+$ ]]; then
        break
    else
        echo "Username must be in lowercase letters only. Please try again."
    fi
done

# Prompt for password securely
read -s -p "Enter a password for the user: " password
echo

# Set up user inside Ubuntu chroot with sudo privileges (no password required for sudo)
proot-distro login ubuntu --user root -- bash -c "
useradd -m -s /bin/bash $username
echo \"$username:$password\" | chpasswd
usermod -aG sudo $username
echo '$username ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
"

# Update and upgrade packages inside Ubuntu
proot-distro login ubuntu --user $username -- bash -c "
sudo apt update -y && sudo apt upgrade -y
"

# Install GNOME desktop, necessary apps, fonts, and required packages
proot-distro login ubuntu --user $username -- bash -c "
sudo apt install -y ubuntu-desktop gnome-terminal nautilus dbus-x11 fonts-dejavu xdg-utils
"

# Install Firefox and Chromium
proot-distro login ubuntu --user $username -- bash -c "
sudo apt install -y firefox chromium-browser
"

# Launch Termux-X11 and start GNOME session
termux-x11 :0 -ac &
sleep 5  # Wait for X server to start
proot-distro login ubuntu --user $username -- bash -c "
export DISPLAY=:0
dbus-launch --exit-with-session gnome-session
"

echo "Setup complete! GNOME desktop should be running in Termux-X11."
