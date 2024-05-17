sudo rpm --import https://openresty.org/package/pubkey.gpg
sudo zypper ar -g --refresh --check "https://openresty.org/package/sles/openresty.repo"
sudo zypper mr --gpgcheck-allow-unsigned-repo openresty
sudo zypper install -y openresty
