# Hướng dẫn cài đặt Terraform

## Trên Windows

1. Truy cập trang tải về: [https://www.terraform.io/downloads.html](https://www.terraform.io/downloads.html)
2. Tải file `.zip` phù hợp với hệ điều hành Windows.
3. Giải nén file vừa tải.
4. Thêm đường dẫn thư mục chứa file `terraform.exe` vào biến môi trường `PATH`.
5. Kiểm tra cài đặt bằng lệnh sau trong Command Prompt:
   ```
   terraform -version
   ```

## Trên Linux

1. Mở Terminal.
2. Tải Terraform bằng lệnh:
   ```
   wget https://releases.hashicorp.com/terraform/1.8.4/terraform_1.8.4_linux_amd64.zip
   ```
3. Giải nén file vừa tải:
   ```
   unzip terraform_1.8.4_linux_amd64.zip
   ```
4. Di chuyển file `terraform` vào thư mục `/usr/local/bin`:
   ```
   sudo mv terraform /usr/local/bin/
   ```
5. Kiểm tra cài đặt:
   ```
   terraform -version
   ```

# Hướng dẫn cài đặt Google Cloud SDK

## Trên Windows

1. Truy cập trang tải về: [https://cloud.google.com/sdk/docs/install](https://cloud.google.com/sdk/docs/install)
2. Tải file cài đặt cho Windows.
3. Chạy file cài đặt và làm theo hướng dẫn.
4. Sau khi cài đặt xong, mở Command Prompt và kiểm tra bằng lệnh:
   ```
   gcloud --version
   ```

## Trên Linux

1. Mở Terminal.
2. Tải và chạy script cài đặt:
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