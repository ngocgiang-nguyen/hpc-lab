Hướng dẫn thực hành HPC (Phenikaa Lab)
Đây là môi trường giả lập hệ thống siêu máy tính (HPC) chạy trên Docker. Hệ thống bao gồm:

1 Login Node: Nơi bạn đăng nhập và gửi lệnh.

2 Compute Nodes: Nơi các tác vụ thực sự được tính toán.

Shared Storage: Thư mục chia sẻ dữ liệu giữa các máy.

1. Cài đặt & Khởi chạy
Yêu cầu: Máy tính đã cài đặt Docker Desktop.

Bước 1: Clone repository này về máy.

Bash

git clone <link-repo-cua-ban>
cd hpc-lab
Bước 2: Khởi chạy hệ thống (Chỉ cần 1 lệnh).

Bash

docker-compose up -d --build
Lần chạy đầu tiên sẽ mất khoảng 5-10 phút để tải và cài đặt môi trường.

Bước 3: Kiểm tra hệ thống đã chạy chưa.

Bash

docker ps
Bạn cần thấy 3 container: hpc_login, hpc_node1, hpc_node2 đang ở trạng thái Up.

2. Truy cập hệ thống (SSH)
Sử dụng Terminal (hoặc PowerShell, CMD) để remote vào hệ thống:

Lệnh: ssh -p 2222 practice_hpc@localhost

Mật khẩu: phenikaa