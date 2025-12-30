FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Cài đặt packages
# KHÔNG CẦN dos2unix vì ta viết script trực tiếp
RUN apt-get update && apt-get install -y \
    slurm-wlm munge openssh-server sudo python3 python3-pip nano \
    && rm -rf /var/lib/apt/lists/*

# 2. Tạo User
RUN useradd -m -u 1001 -s /bin/bash practice_hpc && \
    echo "practice_hpc:phenikaa" | chpasswd && \
    usermod -aG sudo practice_hpc

# 3. Setup thư mục & SSH
# FIX LỖI 1: Tạo symlink từ /etc/slurm sang /etc/slurm-llnl
# Để dù slurm tìm ở đâu cũng thấy file config
RUN mkdir -p /var/run/sshd /var/lib/slurm-llnl /var/log/slurm-llnl /run/munge /home/practice_hpc/shared && \
    chown -R slurm:slurm /var/lib/slurm-llnl /var/log/slurm-llnl && \
    chown -R munge:munge /run/munge && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    ln -s /etc/slurm-llnl /etc/slurm

COPY slurm.conf /etc/slurm-llnl/slurm.conf

# 4. TẠO ENTRYPOINT TRỰC TIẾP (Đã thêm lệnh fix lỗi log)
RUN printf '#!/bin/bash\n\
\n\
# Tạo key munge\n\
echo "secret-key-gen" > /etc/munge/munge.key\n\
chown munge:munge /etc/munge/munge.key\n\
chmod 400 /etc/munge/munge.key\n\
service munge start\n\
\n\
# Khởi động SSH\n\
/usr/sbin/sshd\n\
\n\
# Fix quyền thư mục shared\n\
chown -R practice_hpc:practice_hpc /home/practice_hpc/shared\n\
\n\
# FIX LỖI 2: Tạo trước file log rỗng để lệnh tail không bị chết\n\
touch /var/log/slurm-llnl/slurmctld.log\n\
touch /var/log/slurm-llnl/slurmd.log\n\
chown slurm:slurm /var/log/slurm-llnl/*.log\n\
\n\
if [ "$HOSTNAME" == "login_node" ]; then\n\
    echo "--> Starting Slurm Controller..."\n\
    slurmctld\n\
    # Chờ 1 chút để chắc chắn process chạy\n\
    sleep 2\n\
    # Nếu slurmctld chết, container sẽ exit để ta biết lỗi\n\
    if ! pgrep slurmctld > /dev/null; then\n\
        echo "ERROR: slurmctld failed to start! Check logs:"\n\
        cat /var/log/slurm-llnl/slurmctld.log\n\
        exit 1\n\
    fi\n\
    tail -f /var/log/slurm-llnl/slurmctld.log\n\
else\n\
    echo "--> Starting Slurm Daemon..."\n\
    slurmd\n\
    sleep 2\n\
    tail -f /var/log/slurm-llnl/slurmd.log\n\
fi\n' > /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 22 6817 6818
ENTRYPOINT ["/entrypoint.sh"]