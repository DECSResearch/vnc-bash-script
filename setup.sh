#!/bin/bash
echo "Starting VNC installation script..."

echo "Updating..."
sudo apt update

# Install lightdm
echo "Initiating package installations"
sudo apt install -y lightdm

# Install x11vnc
sudo apt install -y x11vnc

echo "Required packages have been successfully installed (-_-)"
echo "..."
echo "..."
echo "Creating VNC service script"

# Create the x11vnc systemd service file
sudo bash -c 'cat > /lib/systemd/system/x11vnc.service <<EOF
[Unit]
Description=x11vnc service
After=display-manager.service network.target syslog.target

[Service]
Type=simple
ExecStart=/usr/bin/x11vnc -forever -display :0 -auth guess -passwd vncAccess
ExecStop=/usr/bin/killall x11vnc
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF'

# Reload systemd manager configuration
echo "Reloading systemd manager configuration..."
sudo systemctl daemon-reload

# Enable the x11vnc service
echo "Enabling the x11vnc service..."
sudo systemctl enable x11vnc.service

# Start the x11vnc service
echo "Starting the x11vnc service..."
sudo systemctl start x11vnc.service

# Check the status of the x11vnc service
echo "Checking the status of the x11vnc service..."
sudo systemctl status x11vnc.service

echo "VNC installation script completed @=(-_-)=@"