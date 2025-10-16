# Hướng dẫn cài đặt và sử dụng Terraform & Google Cloud SDK

## 1. Cài đặt Terraform

### Trên Windows

1. Truy cập [https://www.terraform.io/downloads.html](https://www.terraform.io/downloads.html)
2. Tải file `.zip` phù hợp với Windows.
3. Giải nén file vừa tải.
4. Thêm đường dẫn thư mục chứa `terraform.exe` vào biến môi trường `PATH`.
5. Kiểm tra cài đặt:
   ```
   terraform -version
   ```

### Trên Linux

1. Mở Terminal.
2. Tải Terraform:
   ```
   wget https://releases.hashicorp.com/terraform/1.8.4/terraform_1.8.4_linux_amd64.zip
   ```
3. Giải nén:
   ```
   unzip terraform_1.8.4_linux_amd64.zip
   ```
4. Di chuyển file `terraform` vào `/usr/local/bin`:
   ```
   sudo mv terraform /usr/local/bin/
   ```
5. Kiểm tra cài đặt:
   ```
   terraform -version
   ```

---

## 2. Cài đặt Google Cloud SDK

### Trên Windows

1. Truy cập [https://cloud.google.com/sdk/docs/install](https://cloud.google.com/sdk/docs/install)
2. Tải file cài đặt cho Windows.
3. Chạy file cài đặt và làm theo hướng dẫn.
4. Kiểm tra cài đặt:
   ```
   gcloud --version
   ```

### Trên Linux

1. Mở Terminal.
2. Tải và cài đặt:
   ```
   curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-456.0.0-linux-x86_64.tar.gz
   tar -xzvf google-cloud-sdk-456.0.0-linux-x86_64.tar.gz
   ./google-cloud-sdk/install.sh
   ```
3. Khởi tạo SDK:
   ```
   ./google-cloud-sdk/bin/gcloud init
   ```
4. Kiểm tra cài đặt:
   ```
   gcloud --version
   ```

---

## 3. Đăng nhập Google Cloud để Terraform truy cập tài nguyên

```
gcloud auth application-default login
```

---

## 4. Sử dụng Terraform với GCP

### Khởi tạo Terraform

Di chuyển vào thư mục môi trường (ví dụ: `dev`):

```
cd terraform/environments/dev
terraform init
```

Terraform sẽ tải provider Google và khởi tạo backend (GCS bucket lưu state).

### Xem trước kế hoạch triển khai

```
terraform plan
```

Lệnh này chỉ hiển thị danh sách tài nguyên sẽ được tạo, sửa hoặc xóa.

### Triển khai hạ tầng

```
terraform apply
```

Nhập `yes` để xác nhận và bắt đầu tạo tài nguyên trên GCP.

### Kiểm tra kết quả

Sau khi apply thành công, Terraform sẽ in ra các outputs (ví dụ: `vpc_name`, `subnet_name`). Có thể xác minh trên GCP Console → VPC Networks.

### Hủy (xóa) toàn bộ tài nguyên khi không còn cần thiết

```
terraform destroy
```

⚠️ Lệnh này sẽ xóa tất cả tài nguyên được Terraform quản lý trong môi trường đó.

---

## 5. Một số lệnh hữu ích

| Lệnh                 | Mô tả                                        |
| -------------------- | -------------------------------------------- |
| terraform fmt        | Format lại code Terraform theo chuẩn         |
| terraform validate   | Kiểm tra tính hợp lệ của file .tf            |
| terraform output     | Hiển thị các giá trị output sau khi apply    |
| terraform state list | Xem danh sách tài nguyên đang được quản lý   |
| terraform refresh    | Cập nhật state hiện tại với thực tế trên GCP |
