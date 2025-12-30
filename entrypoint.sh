#!/bin/bash

# 1. Thiết lập Munge Key (Chìa khóa xác thực giữa các node)
# Chúng ta ghi đè key mỗi lần khởi động để đảm bảo đồng bộ 100%
echo "secret-key-for-phenikaa-hpc-lab-auto-generated" > /etc/munge/munge.key
chown munge:munge /etc/munge/munge.key
chmod 400 /etc/munge/munge.key

# 2. Khởi động Munge
service munge start

# 3. Khởi động SSH
/usr/sbin/sshd

# 4. FIX QUYỀN THƯ MỤC SHARED (Quan trọng)
# Đảm bảo user practice_hpc có thể ghi vào thư mục shared mount từ máy host
chown -R practice_hpc:practice_hpc /home/practice_hpc/shared

# 5. Khởi động Slurm dựa trên hostname
if [ "$HOSTNAME" == "login_node" ]; then
    echo "--> Starting Slurm Controller (Head Node)..."
    slurmctld
    # Giữ container chạy và hiện log
    echo "--> System Ready. SSH port 2222 exposed."
    tail -f /var/log/slurm-llnl/slurmctld.log
else
    echo "--> Starting Slurm Daemon (Compute Node)..."
    slurmd
    tail -f /var/log/slurm-llnl/slurmd.log
fi