#!/usr/bin/env bash

# Check if Nginx is installed and install it if not
if ! [ -x "$(command -v nginx)" ]; then
    sudo apt-get update
    sudo apt-get -y install nginx
fi

# Create necessary directories if they don't exist
sudo mkdir -p /data/web_static/{releases/test,shared}

# Create a fake HTML file with content
echo "<html>
  <head>
  </head>
  <body>
    Holberton School
  </body>
</html>" | sudo tee /data/web_static/releases/test/index.html

# Create or recreate symbolic link
sudo rm -rf /data/web_static/current
sudo ln -s /data/web_static/releases/test/ /data/web_static/current

# Give ownership to the ubuntu user and group recursively
sudo chown -R ubuntu:ubuntu /data/

# Update Nginx configuration to serve content
nginx_config="/etc/nginx/sites-available/default"
nginx_content="server {
    listen 80 default_server;
    server_name _;

    location /hbnb_static {
        alias /data/web_static/current/;
        index index.html;
    }
}"
# Append or replace Nginx configuration
if grep -q "location /hbnb_static" "$nginx_config"; then
    sudo sed -i "s|location /hbnb_static.*|${nginx_content}|g" "$nginx_config"
else
    echo "$nginx_content" | sudo tee -a "$nginx_config"
fi

# Restart Nginx
sudo systemctl restart nginx

