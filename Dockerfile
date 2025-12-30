FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Cài đặt packages
RUN apt-get update && apt-get install -y \
    slurm-wlm munge openssh-server sudo python3 python3-pip nano \
    && rm -rf /var/lib/apt/lists/*

# 2. Tạo User
RUN useradd -m -u 1001 -s /bin/bash practice_hpc && \
    echo "practice_hpc:phenikaa" | chpasswd && \
    usermod -aG sudo practice_hpc

# 3. Setup thư mục & SSH
# FIX LỖI PATH: Tạo sẵn thư mục /etc/slurm để tránh lỗi "No such file"
RUN mkdir -p /var/run/sshd /var/lib/slurm-llnl /var/log/slurm-llnl /run/munge /home/practice_hpc/shared /etc/slurm && \
    chown -R slurm:slurm /var/lib/slurm-llnl /var/log/slurm-llnl && \
    chown -R munge:munge /run/munge && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Copy file vào vị trí mặc định của Ubuntu
COPY slurm.conf /etc/slurm-llnl/slurm.conf

# 4. TẠO ENTRYPOINT (Script khởi động)
# Sử dụng printf để tạo file script chuẩn Linux
RUN printf '#!/bin/bash\n\
\n\
# --- FIX LỖI 1: MUNGE KEY ---\n\
# Key phải dài hơn 32 ký tự. Chuỗi dưới đây là 64 ký tự.\n\
echo "phenikaa-hpc-lab-secret-key-must-be-very-long-to-work-correctly-with-munge-service" > /etc/munge/munge.key\n\
chown munge:munge /etc/munge/munge.key\n\
chmod 400 /etc/munge/munge.key\n\
service munge start\n\
\n\
# --- FIX LỖI 2: SLURM CONFIG PATH ---\n\
# Copy hoặc link file config sang đúng chỗ Slurm đang tìm (/etc/slurm)\n\
cp /etc/slurm-llnl/slurm.conf /etc/slurm/slurm.conf\n\
\n\
# Khởi động SSH\n\
mkdir -p /run/sshd\n\
ssh-keygen -A\n\
/usr/sbin/sshd\n\
\n\
# Fix quyền thư mục chia sẻ\n\
chown -R practice_hpc:practice_hpc /home/practice_hpc/shared\n\
\n\
# Tạo log file rỗng để tránh lỗi tail\n\
touch /var/log/slurm-llnl/slurmctld.log /var/log/slurm-llnl/slurmd.log\n\
chown slurm:slurm /var/log/slurm-llnl/*.log\n\
\n\
# Khởi động Slurm\n\
if [ "$HOSTNAME" == "login_node" ]; then\n\
    echo "--> Starting Slurm Controller..."\n\
    slurmctld\n\
    sleep 2\n\
    # Kiểm tra xem nó có chết không\n\
    if ! pgrep slurmctld > /dev/null; then\n\
        echo "ERROR: slurmctld died properly. Showing logs:"\n\
        cat /var/log/slurm-llnl/slurmctld.log\n\
    fi\n\
    # Giữ container sống để SSH vào debug\n\
    tail -f /dev/null\n\
else\n\
    echo "--> Starting Slurm Daemon..."\n\
    slurmd\n\
    tail -f /dev/null\n\
fi\n' > /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 22 6817 6818
ENTRYPOINT ["/entrypoint.sh"]