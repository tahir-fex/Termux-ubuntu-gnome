#!/data/data/com.termux/files/usr/bin/bash

# ===============================
# Function: RGB Glowing Progress Bar
# ===============================
progress_bar() {
    local message=$1
    shift
    local cmd="$@"

    echo -e "\n\e[36m$message\e[0m"
    (
        $cmd > /dev/null 2>&1
    ) &
    pid=$!

    local width=40
    local i=0
    local colors=(31 33 32 36 34 35)  # Red, Yellow, Green, Cyan, Blue, Magenta

    while kill -0 $pid 2>/dev/null; do
        color=${colors[$((i % ${#colors[@]}))]}
        filled=$(( (i % (width+1)) ))
        printf "\r\e[1;${color}m[%-${width}s]\e[0m" "$(printf "%0.s#" $(seq 1 $filled))"
        sleep 0.2
        ((i++))
    done

    wait $pid
    printf "\r\e[1;32m[%-${width}s]\e[0m Done!\n" "$(printf "%0.s#" $(seq 1 $width))"
}

# ===============================
# Startup Banner
# ===============================
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

# ===============================
# Step 1: Update Termux
# ===============================
progress_bar "Updating Termux packages..." pkg update -y && pkg upgrade -y

# Step 2: Setup storage
progress_bar "Setting up storage access..." termux-setup-storage

# Step 3: Install repositories
progress_bar "Installing Termux repositories..." pkg install tur-repo -y && pkg install x11-repo -y

# Step 4: Install Termux-X11
progress_bar "Installing Termux-X11..." pkg install termux-x11-nightly -y

# Step 5: Install proot-distro
progress_bar "Installing proot-distro..." pkg install proot-distro -y

# Step 6: Install Ubuntu (skip if already installed)
if proot-distro list | grep -q "ubuntu"; then
    echo -e "\e[33mUbuntu is already installed. Skipping installation...\e[0m"
else
    progress_bar "Installing Ubuntu (this may take a while)..." proot-distro install ubuntu
fi

# Step 7: Create user (manual input)
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
progress_bar "Updating Ubuntu system..." proot-distro login ubuntu --user $username -- bash -c "sudo apt update -y && sudo apt upgrade -y"

# Step 9: Install GNOME Desktop
progress_bar "Installing GNOME Desktop and essential apps..." proot-distro login ubuntu --user $username -- bash -c "sudo apt install -y ubuntu-desktop gnome-terminal nautilus dbus-x11 fonts-dejavu xdg-utils"

# Step 10: Install Browsers
progress_bar "Installing Firefox and Chromium..." proot-distro login ubuntu --user $username -- bash -c "sudo apt install -y firefox chromium-browser"

# Step 11: Launch GNOME
progress_bar "Starting GNOME Desktop..." bash -c "pkill -f termux-x11; termux-x11 :0 -ac & sleep 5; proot-distro login ubuntu --user $username -- bash -c 'export DISPLAY=:0; dbus-launch --exit-with-session gnome-session'"

echo -e "\n\e[32m✅ Setup complete! GNOME desktop should now be running in Termux-X11.\e[0m"
