#!/bin/bash
# 1. Ghi một script vào thư mục per-boot. Tất cả script ở đây sẽ TỰ ĐỘNG CHẠY MỖI KHI MÁY KHỞI ĐỘNG (Bất kể là bật lần đầu hay Stop/Start lại).
cat << 'SCRIPT' > /var/lib/cloud/scripts/per-boot/01-setup-podman.sh
#!/bin/bash

# Kiểm tra xem Podman đã được cài chưa?
if ! command -v podman &> /dev/null; then
    echo "Podman is not install. Starting install Podman ..."
    
    # Gỡ sạch Docker cũ để tránh xung đột (nếu có)
    apt-get purge -y docker-engine docker docker.io docker-ce docker-ce-cli
    apt-get autoremove -y --purge
    rm -rf /var/lib/docker /var/lib/containerd /etc/docker /var/run/docker.sock
    
    # Cài đặt Podman và Nginx
    apt-get update -y
    apt-get install -y podman podman-compose nginx
    echo "Install Podman and Nginx successfully!"
else
    echo "Podman is installed !"
fi
SCRIPT

# 2. Cấp quyền thực thi cho script vừa tạo
chmod +x /var/lib/cloud/scripts/per-boot/01-setup-podman.sh

# 3. Kích hoạt chạy script luôn cho lần boot đầu tiên này
/var/lib/cloud/scripts/per-boot/01-setup-podman.sh
