#!/data/data/com.termux/files/usr/bin/bash

# Function: Realistic progress bar (with animation + percentage)
progress_bar() {
    local message=$1
    local duration=$2
    local width=50
    echo -e "\n\e[36m$message\e[0m"
    for ((i=0; i<=100; i+=2)); do
        filled=$((i*width/100))
        empty=$((width-filled))
        printf "\r[%-${width}s] %3d%%" "$(printf "%0.s=" $(seq 1 $filled))" "$i"
        sleep $duration
    done
    echo -e "\n"
}

# Display ASCII art in green
echo -e "\e[32m"
echo " ________________    ___ ___ ._____________ "
echo "\__    ___/  _  \  /   |   \|   \______   \\"
echo "  |    | /  /_\  \/    ~    \   ||       _/"
echo "  |    |/    |    \    Y    /   ||    |   \\"
echo "  |____|\____|__  /\___|_  /|___||____|_  /"
echo "                \/       \/             \/ "
echo -e "\e[0m"
echo -e "\e[33mSupport Me\nIG: @f.r.e.e.c_   YT: @v5rn\e[0m"
echo -e "\n\e[31m⚠️  This entire process will take 20–30 minutes. Please be patient.\e[0m"
sleep 4
clear

# Step 1: Update Termux
progress_bar "Updating Termux packages..." 0.1
pkg update -y > /dev/null 2>&1 && pkg upgrade -y > /dev/null 2>&1

# Step 2: Setup storage
progress_bar "Setting up storage access..." 0.05
termux-setup-storage > /dev/null 2>&1

# Step 3: Install repositories
progress_bar "Installing Termux repositories..." 0.05
pkg install tur-repo -y > /dev/null 2>&1
pkg install x11-repo -y > /dev/null 2>&1

# Step 4: Install Termux-X11
progress_bar "Installing Termux-X11..." 0.05
pkg install termux-x11-nightly -y > /dev/null 2>&1

# Step 5: Install proot-distro
progress_bar "Installing proot-distro..." 0.05
pkg install proot-distro -y > /dev/null 2>&1

# Step 6: Install Ubuntu (skip if already installed)
if proot-distro list | grep -q "ubuntu"; then
    echo -e "\e[33mUbuntu is already installed. Skipping installation...\e[0m"
else
    progress_bar "Installing Ubuntu (this may take a while)..." 0.2
    proot-distro install ubuntu > /dev/null 2>&1
fi

# Step 7: Create user (input visible)
echo -e "\n\e[36mCreating Ubuntu user account...\e[0m"
while true; do
    read -p "Enter a username in lowercase letters: " username
    if [[ "$username" =~ ^[a-z]+$ ]]; then
        break
    else
        echo "❌ Username must be in lowercase letters only. Please try again."
    fi
done
read -s -p "Enter a password for the user: " password
echo

proot-distro login ubuntu --user root -- bash -c "
apt update -y && apt install -y sudo
if ! id -u $username >/dev/null 2>&1; then
    useradd -m -s /bin/bash $username
    echo \"$username:$password\" | chpasswd
    usermod -aG sudo $username
    echo '$username ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
fi
"

# Step 8: Update inside Ubuntu
progress_bar "Updating Ubuntu system..." 0.1
proot-distro login ubuntu --user $username -- bash -c "
sudo apt update -y && sudo apt upgrade -y
" > /dev/null 2>&1

# Step 9: Install GNOME Desktop
progress_bar "Installing GNOME Desktop and essential apps..." 0.15
proot-distro login ubuntu --user $username -- bash -c "
sudo apt install -y ubuntu-desktop gnome-terminal nautilus dbus-x11 fonts-dejavu xdg-utils
" > /dev/null 2>&1

# Step 10: Install Browsers
progress_bar "Installing Firefox and Chromium..." 0.1
proot-distro login ubuntu --user $username -- bash -c "
sudo apt install -y firefox chromium-browser
" > /dev/null 2>&1

# Step 11: Launch GNOME
progress_bar "Starting GNOME Desktop..." 0.05
pkill -f termux-x11 > /dev/null 2>&1
termux-x11 :0 -ac > /dev/null 2>&1 &
sleep 5
proot-distro login ubuntu --user $username -- bash -c "
export DISPLAY=:0
dbus-launch --exit-with-session gnome-session
" > /dev/null 2>&1

echo -e "\n\e[32m✅ Setup complete! GNOME desktop should now be running in Termux-X11.\e[0m"
