#!/data/data/com.termux/files/usr/bin/bash

# ===============================
# RGB Progress Bar
# ===============================
progress_bar() {
    local message=$1
    shift
    local cmd="$@"

    echo -e "\n\e[36m$message\e[0m"
    (
        $cmd > install.log 2>&1
    ) &
    pid=$!

    local width=40
    local i=0
    local colors=(31 33 32 36 34 35)

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
# Banner
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
# Install steps
# ===============================
progress_bar "Updating Termux packages..." pkg update -y && pkg upgrade -y
progress_bar "Setting up storage access..." termux-setup-storage
progress_bar "Installing Termux repositories..." pkg install tur-repo -y && pkg install x11-repo -y
progress_bar "Installing Termux-X11..." pkg install termux-x11-nightly -y
progress_bar "Installing proot-distro..." pkg install proot-distro -y

if proot-distro list | grep -q "ubuntu"; then
    echo -e "\e[33mUbuntu already installed. Skipping...\e[0m"
else
    progress_bar "Installing Ubuntu..." proot-distro install ubuntu
fi

# Username/password prompt
echo -e "\n\e[36mCreate your Ubuntu user account:\e[0m"
while true; do
    read -p "Enter a username (lowercase only): " username
    if [[ "$username" =~ ^[a-z]+$ ]]; then
        break
    else
        echo "❌ Username must be lowercase only."
    fi
done
read -s -p "Enter a password: " password
echo

# Setup Ubuntu user
progress_bar "Configuring Ubuntu user..." proot-distro login ubuntu --user root -- bash -c "
apt update -y && apt install -y sudo
if ! id -u $username >/dev/null 2>&1; then
    useradd -m -s /bin/bash $username
    echo \"$username:$password\" | chpasswd
    usermod -aG sudo $username
    echo '$username ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
fi
"

# Ubuntu updates + desktop
progress_bar "Updating Ubuntu system..." proot-distro login ubuntu --user $username -- bash -c "sudo apt update -y && sudo apt upgrade -y"
progress_bar "Installing GNOME Desktop..." proot-distro login ubuntu --user $username -- bash -c "sudo apt install -y gnome-session gnome-terminal nautilus dbus-x11 fonts-dejavu xdg-utils"
progress_bar "Installing Firefox + Chromium..." proot-distro login ubuntu --user $username -- bash -c "sudo apt install -y firefox chromium-browser"

echo -e "\n\e[32m✅ Installation complete! Run './start-gnome.sh' to launch GNOME.\e[0m"
