#!/data/data/com.termux/files/usr/bin/bash

export DEBIAN_FRONTEND=noninteractive

# Colors
green="\e[32m"
red="\e[31m"
yellow="\e[33m"
cyan="\e[36m"
end="\e[0m"

# Spinner function with step numbers
spinner() {
    local pid=$1
    local step=$2
    local total=$3
    local message=$4
    local spin='|/-\'
    local i=0
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) %4 ))
        printf "\r[${step}/${total}] $message ${cyan}${spin:$i:1}${end}"
        sleep 0.2
    done
    wait $pid
    if [ $? -eq 0 ]; then
        printf "\r[${step}/${total}] $message ${green}✅${end}\n"
    else
        printf "\r[${step}/${total}] $message ${red}❌ (check install.log)${end}\n"
        exit 1
    fi
}

# Banner
echo -e "$green"
echo " ________________    ___ ___ ._____________ "
echo "\__    ___/  _  \  /   |   \|   \______   \\"
echo "  |    | /  /_\  \/    ~    \   ||       _/"
echo "  |    |/    |    \    Y    /   ||    |   \\"
echo "  |____|\____|__  /\___|_  /|___||____|_  /"
echo "                \/       \/             \/ "
echo -e "$end"
echo -e "$yellow Support Me IG: @f.r.e.e.c_   YT: @v5rn $end"
echo -e "\n${red}⚠️  This entire process will take 20–30 minutes. Please be patient.${end}"
sleep 4
clear

# Number of steps
TOTAL=8
STEP=1

# Install Steps
(pkg update -y && pkg upgrade -y) > install.log 2>&1 & spinner $! $STEP $TOTAL "Updating Termux packages..."; STEP=$((STEP+1))
(termux-setup-storage -y) >> install.log 2>&1 & spinner $! $STEP $TOTAL "Setting up storage..."; STEP=$((STEP+1))
(pkg install -y tur-repo x11-repo) >> install.log 2>&1 & spinner $! $STEP $TOTAL "Installing Termux repositories..."; STEP=$((STEP+1))
(pkg install -y termux-x11-nightly) >> install.log 2>&1 & spinner $! $STEP $TOTAL "Installing Termux-X11..."; STEP=$((STEP+1))
(pkg install -y proot-distro) >> install.log 2>&1 & spinner $! $STEP $TOTAL "Installing proot-distro..."; STEP=$((STEP+1))

if proot-distro list | grep -q "ubuntu"; then
    echo -e "[${STEP}/${TOTAL}] Ubuntu already installed. Skipping..."
else
    (proot-distro install ubuntu) >> install.log 2>&1 & spinner $! $STEP $TOTAL "Installing Ubuntu..."
fi
STEP=$((STEP+1))

# ------------------------------
# USERNAME + PASSWORD INPUT
# ------------------------------
echo -e "\n${cyan}👉 Create your Ubuntu user account:${end}"
while true; do
    read -p "Enter a username (lowercase only): " username
    [[ "$username" =~ ^[a-z]+$ ]] && break || echo "❌ Username must be lowercase only!"
done
read -s -p "Enter a password: " password
echo
echo -e "${green}✅ Username and password saved.${end}"

# Create user inside Ubuntu
proot-distro login ubuntu --user root -- bash -c "
apt update -y && apt install -y sudo
if ! id -u $username >/dev/null 2>&1; then
    useradd -m -s /bin/bash $username
    echo \"$username:$password\" | chpasswd
    usermod -aG sudo $username
    echo '$username ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
fi
"

(proot-distro login ubuntu --user $username -- bash -c "sudo apt update -y && sudo apt upgrade -y") >> install.log 2>&1 & spinner $! $STEP $TOTAL "Updating Ubuntu system..."; STEP=$((STEP+1))
(proot-distro login ubuntu --user $username -- bash -c "sudo apt install -y gnome-session gnome-terminal nautilus dbus-x11 fonts-dejavu xdg-utils") >> install.log 2>&1 & spinner $! $STEP $TOTAL "Installing GNOME Desktop..."; STEP=$((STEP+1))
(proot-distro login ubuntu --user $username -- bash -c "sudo apt install -y firefox chromium-browser") >> install.log 2>&1 & spinner $! $STEP $TOTAL "Installing browsers..."; STEP=$((STEP+1))

echo -e "\n${green}✅ Installation complete! Run './start-gnome.sh' to launch GNOME.${end}"
