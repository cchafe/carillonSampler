# run me from /home/cc/git-tam/raspbian

cp sample.service /home/cc/.config/systemd/user/
cd
systemctl --user daemon-reload
systemctl --user stop  sample.service
systemctl --user disable  sample.service
systemctl --user enable  sample.service

