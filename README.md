# 🖥️ **HPC Practice Lab (Phenikaa University)**

Môi trường giả lập **Hệ thống Siêu máy tính (High Performance Computing – HPC)** chạy trên **Docker**, phục vụ mục đích **giảng dạy và thực hành**.

Hệ thống mô phỏng kiến trúc HPC cơ bản, giúp sinh viên làm quen với:

- Kiến trúc Login Node / Compute Node

- Làm việc qua SSH

- Chia sẻ dữ liệu giữa các node

- Quy trình gửi và chạy tác vụ tính toán

## 🏗️ Kiến trúc hệ thống

Hệ thống gồm:

- **1 Login Node**

  👉 Nơi người dùng đăng nhập và gửi lệnh

- **2 Compute Nodes**

  👉 Nơi các tác vụ tính toán được thực thi

- **Shared Storage**

  👉 Thư mục chia sẻ dữ liệu giữa Login Node và các Compute Nodes

```
User
 │
 │  SSH (port 2222)
 ▼
Login Node
 │
 ├── Compute Node 1
 ├── Compute Node 2
 │
 └── Shared Storage
```

## ⚙️ Yêu cầu hệ thống

- Đã cài đặt Docker Desktop

- Hệ điều hành: Windows / Linux / macOS

- RAM khuyến nghị: ≥ 8GB


## 🚀 Cài đặt & Khởi chạy

### Bước 1: Clone repository

```
git clone https://github.com/ngocgiang-nguyen/hpc-lab.git
cd hpc-lab
```

### Bước 2: Khởi chạy toàn bộ hệ thống

```
docker-compose up -d --build
```

⏳ Lần chạy đầu tiên có thể mất 5–10 phút để Docker tải image và thiết lập môi trường.

### Bước 3: Kiểm tra các container
```docker ps```

Bạn cần thấy 3 container ở trạng thái Up:

```
hpc_login
hpc_node1
hpc_node2
```

## 🔐 Truy cập hệ thống qua SSH

Đăng nhập vào Login Node bằng SSH:

```ssh -p 2222 practice_hpc@localhost```

Thông tin đăng nhập

```
Username: practice_hpc

Password: phenikaa
```

📌 Sau khi đăng nhập thành công, bạn đang ở Login Node, sẵn sàng gửi các lệnh tính toán.

## 📁 Shared Storage

Thư mục dùng chung giữa Login Node và Compute Nodes

Phù hợp để:

- Upload dữ liệu

- Chạy chương trình

- Lưu kết quả tính toán

(Vị trí cụ thể được cấu hình trong docker-compose.yml, hiện tại đang là thư mục hpc-lab/workspace)
