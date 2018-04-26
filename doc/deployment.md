### configuring systemd 
sudo vi /etc/systemd/system/nimblein.service
copy following code 

```
[Unit]
Description=Puma HTTP Server
After=network.target

# Uncomment for socket activation (see below)
# Requires=puma.socket

[Service]
# Foreground process (do not use --daemon in ExecStart or config.rb)
#Type=simple
Type=forking

# Preferably configure a non-privileged user
User=teknuk
Group=teknuk
# The path to the puma application root
# Also replace the "<WD>" place holders below with this path.
WorkingDirectory=/home/teknuk/camp_one_production/current

# Helpful for debugging socket activation, etc.
# Environment=PUMA_DEBUG=1

# The command to start Puma. This variant uses a binstub generated via
# `bundle binstubs puma --path ./sbin` in the WorkingDirectory
# (replace "<WD>" below)
# ExecStart=<WD>/sbin/puma -b tcp://0.0.0.0:9292 -b ssl://0.0.0.0:9293?key=key.pem&cert=cert.pem
# Variant: Use config file with `bind` directives instead:
# ExecStart=/home/teknuk/camp_one_production/current/sbin/puma -C /home/teknuk/camp_one_production/shared/puma.rb
ExecStart=/home/teknuk/.rvm/wrappers/nimblein/bundle exec puma -C /home/teknuk/camp_one_production/shared/puma.rb --daemon
ExecStop=/home/teknuk/.rvm/wrappers/nimblein/bundle exec pumactl -S /home/teknuk/camp_one_production/shared/tmp/pids/puma.state -F /home/teknuk/camp_one_production/shared/puma.rb stop 
PIDFile=/home/teknuk/camp_one_production/shared/tmp/pids/puma.pid
Restart=always

[Install]
WantedBy=multi-user.target
```

Add executable permission
`sudo chmod +x nimblein.service`

Now you can start/stop/restart and check status like
`sudo service nimblein start`

## Adding SSL using lets encrypt
Ref: https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-16-04

### Installing Certbot
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get update
sudo apt-get install python-certbot-nginx

* Make sure you have configured nginx and https is allowed through firewall

### Generating SSL
sudo certbot --nginx -d yourdomain.com

20180118 Error: Client with the currently selected authenticator does not support any combination of challenges that will satisfy the CA.
Workaround: sudo certbot --authenticator standalone --installer nginx --pre-hook "service nginx stop" --post-hook "service nginx start" -d yourdomain.com
Ref: https://github.com/certbot/certbot/issues/5405



