#!/bin/bash

checkHostname(){
  newHostname=$1
  curentHostname=$(hostname)
  if ["$curentHostname" == "$newHostname"]; then
    echo "Hostname is already set to $newHostname"
  else
    sudo hostnamectl set-hostname $newHostname
    echo "Hostname changed to $newHostname"
}

installVnc(){
  check_status() {
  if [ $? -ne 0 ]; then
    echo "Error: $1 failed to execute." >&2
    exit 1
  else
    echo "$1 executed successfully."
  fi
}

echo "Starting the script..."

# Update package lists
echo "Updating package lists..."
sudo apt update
check_status "apt update"

# Install lightdm if not already installed
if dpkg -l | grep -q lightdm; then
  echo "lightdm is already installed."
else
  echo "Installing lightdm..."
  sudo apt install -y lightdm
  check_status "lightdm installation"
fi

# Install x11vnc if not already installed
if dpkg -l | grep -q x11vnc; then
  echo "x11vnc is already installed."
else
  echo "Installing x11vnc..."
  sudo apt install -y x11vnc
  check_status "x11vnc installation"
fi

# Create the x11vnc systemd service file
if [ ! -f /lib/systemd/system/x11vnc.service ]; then
  echo "Creating the x11vnc systemd service file..."
  sudo bash -c 'cat > /lib/systemd/system/x11vnc.service <<EOFSERVICE
[Unit]
Description=x11vnc service
After=display-manager.service network.target syslog.target

[Service]
Type=simple
ExecStart=/usr/bin/x11vnc -forever -display :0 -auth guess -passwd password
ExecStop=/usr/bin/killall x11vnc
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOFSERVICE'
  check_status "Creating x11vnc service file"
else
  echo "x11vnc service file already exists."
fi

# Reload systemd manager configuration
echo "Reloading systemd manager configuration..."
sudo systemctl daemon-reload
check_status "systemd daemon-reload"

# Enable the x11vnc service
echo "Enabling the x11vnc service..."
sudo systemctl enable x11vnc.service
check_status "Enabling x11vnc service"

# Start the x11vnc service
echo "Starting the x11vnc service..."
sudo systemctl start x11vnc.service
check_status "Starting x11vnc service"

# Check the status of the x11vnc service
echo "Checking the status of the x11vnc service..."
sudo systemctl status x11vnc.service
check_status "Checking status of x11vnc service"

echo "Script completed."

}

uninstallVnc(){
  echo "Uninstalling x11vnc..."
  sudo apt remove -y x11vnc
  if [ $? -eq 0 ]; then
    echo "x11vnc uninstalled successfully."
  else
    echo "Failed to uninstall x11vnc."
    exit 1
  fi
}


#This is where the script actually starts
if [ -n "$1" ] && [ -n "$2" ]; then
    command=$1
    serviceName=$2

    if [ "$command" == "hostname" ]; then
        checkHostname "$serviceName"
    elif [ "$command" == "uninstall" ] && ["$serviceName" == "vnc"] ; then
        uninstallVnc
    elif [ "$command" == "install" ] && ["$serviceName" == "vnc"] ; then
        installVnc
    else
        echo "Invalid arguments. Please use available options."
        echo "Usage: ./vncscript1.sh [command(hostname, install, uninstall)] [service(vnc)/new hostname]"
        exit 1
    fi 
elif [ -z "$1" ] && [ -n "$2" ]; then
    echo "Error: Give both arguments or run through general menu."
    exit 1
elif [ -n "$1" ] && [ -z "$2" ]; then
    echo "Error: Give both arguments or run through general menu."
    exit 1
else
    echo "VNC guided installation v0.1"

    echo "Available options:"
    echo "1. Manage hostname"
    echo "2. Install VNC"
    echo "3. Uninstall VNC"
    echo "4. Exit"

    read -p "Enter your choice: " choice

    case $choice in
      1)
        echo"Enter new hostname: " 
        read newHostname
        checkHostname "$newHostname"
        ;;
      2)
        installVnc
        ;;
      3)
        uninstallVnc
        ;;
      4)
        exit 0
        ;;
      *)
        echo "Invalid choice"
        exit 0
        ;;
    esac
fi


echo "Script completed"
