FROM ubuntu:22.04

# Tránh hỏi input khi cài đặt
ENV DEBIAN_FRONTEND=noninteractive

# 1. Cài đặt các gói cần thiết
RUN apt-get update && apt-get install -y \
    slurm-wlm \
    munge \
    openssh-server \
    sudo \
    python3 \
    python3-pip \
    nano \
    vim \
    iputils-ping \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 2. Tạo User 'practice_hpc' với UID cố định (1001)
#    Mật khẩu: phenikaa
RUN useradd -m -u 1001 -s /bin/bash practice_hpc && \
    echo "practice_hpc:phenikaa" | chpasswd && \
    usermod -aG sudo practice_hpc

# 3. Cấu hình SSH để cho phép login bằng password
RUN mkdir /var/run/sshd
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
# Fix lỗi SSH "Missing privilege separation directory" trên một số bản Docker cũ
RUN mkdir -p /run/sshd

# 4. Tạo các thư mục cần thiết cho Slurm/Munge
RUN mkdir -p /var/lib/slurm-llnl /var/log/slurm-llnl /run/munge /home/practice_hpc/shared && \
    chown -R slurm:slurm /var/lib/slurm-llnl /var/log/slurm-llnl && \
    chown -R munge:munge /run/munge

# 5. Copy file cấu hình vào image
COPY slurm.conf /etc/slurm-llnl/slurm.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Port SSH, Slurmctld, Slurmd
EXPOSE 22 6817 6818

ENTRYPOINT ["/entrypoint.sh"]