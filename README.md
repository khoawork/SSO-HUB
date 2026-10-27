# 🛡️ SSO Identity Hub (Centralized Authentication with Keycloak 24)

Hệ thống máy chủ định danh và xác thực tập trung **Single Sign-On (SSO)** chuẩn công nghiệp dựa trên nền tảng **Keycloak 24**, **OAuth 2.0** và **OpenID Connect (OIDC)**.

Hệ thống quản lý và đồng bộ phiên đăng nhập một lần (SSO) cho toàn bộ hệ sinh thái:
- 🎨 **Trung Tâm Công Nghiệp Sáng Tạo** (React SPA + Flask Backend - OIDC PKCE Flow)
- ☕ **Là Việt** (Next.js 16 App Router - Confidential Client Flow)

---

## 🏗️ Kiến Trúc Hệ Thống (Architecture)

```mermaid
flowchart TB
    subgraph Clients ["1. Hệ Sinh Thái Ứng Dụng (Connected Clients)"]
        CIC["Trung Tâm Sáng Tạo<br/>(React SPA + Flask API)"]
        Laviet["Là Việt<br/>(Next.js App Router)"]
    end

    subgraph Hub ["2. Máy Chủ SSO Hub (Keycloak Identity Provider)"]
        Keycloak["Keycloak 24 IAM Server<br/>Cổng: 8888 (Realm: sso-platform)"]
        CustomTheme["Giao diện Tối giản Clean UX/UI<br/>(themes/sso-hub)"]
        Postgres[("PostgreSQL Database<br/>(Users, Roles, Sessions)")]
        RedisCache[("Redis Cache")]
        
        Keycloak --- CustomTheme
        Keycloak --- Postgres
        Keycloak --- RedisCache
    end

    CIC <-->|OIDC Auth Code + PKCE (S256)| Keycloak
    Laviet <-->|OIDC Confidential Back-Channel| Keycloak
```

---

## 📂 Cấu Trúc Repository

```text
sso-hub-smar/
├── .gitignore                      # Bảo vệ tuyệt đối file bí mật (.env, database data, logs)
├── .env.example                    # Template biến môi trường mẫu
├── CREDENTIALS.md                  # Danh mục đầy đủ tài khoản, mật khẩu, secrets và endpoints
├── README.md                       # Tài liệu hướng dẫn sử dụng máy chủ SSO Hub
├── docker-compose.yml              # Cụm container Docker: Keycloak 24, Postgres 16, Redis, Nginx
├── idp/
│   ├── realm-export.json           # Cấu hình Realm sso-platform, Clients (app-a, app-b) và Users
│   └── themes/sso-hub/             # Bộ giao diện Đăng nhập Clean UX/UI (template.ftl, login.ftl)
└── gateway/
    └── nginx.conf                  # Cấu hình Reverse Proxy Nginx
```

---

## 🚀 Hướng Dẫn Khởi Chạy Nhanh (Quick Start)

### 1. Chuẩn bị biến môi trường
Tạo file `.env` từ file mẫu:
```powershell
cp .env.example .env
```

### 2. Cấu hình file `hosts` (Local Domains)
Mở file `C:\Windows\System32\drivers\etc\hosts` (hoặc `/etc/hosts`) với quyền Administrator và thêm:
```text
127.0.0.1 idp.sso.test
```

### 3. Khởi động máy chủ SSO
```powershell
docker compose up -d
```
> *⏱️ Chờ khoảng 25-30 giây để Keycloak hoàn tất kết nối cơ sở dữ liệu và nạp cấu hình Realm `sso-platform`.*

---

## 🔑 Thông Tin Đăng Nhập & Endpoints

Chi tiết đầy đủ xem tại [CREDENTIALS.md](CREDENTIALS.md):

| Hệ thống / Vai trò | Đường dẫn (URL) | Tài khoản | Mật khẩu |
| :--- | :--- | :--- | :--- |
| **Keycloak Admin Console** | `http://localhost:8888/admin` | `admin` | `admin` *(hoặc `admin_secret_pass`)* |
| **User Thử Nghiệm 1** | Cổng SSO Hub | `alice` (hoặc `alice@creative.com`) | `123456` |
| **User Thử Nghiệm 2** | Cổng SSO Hub | `bob` (hoặc `bob@laviet.com`) | `123456` |

### Các Endpoint Cốt Lõi (OIDC Discovery):
- **OIDC Discovery**: `http://localhost:8888/realms/sso-platform/.well-known/openid-configuration`
- **JWKS Certs (Public Key)**: `http://localhost:8888/realms/sso-platform/protocol/openid-connect/certs`
- **Token Endpoint (POST)**: `http://localhost:8888/realms/sso-platform/protocol/openid-connect/token`
- **Logout Endpoint**: `http://localhost:8888/realms/sso-platform/protocol/openid-connect/logout`


---

## ☁️ Hướng Dẫn Deploy Lên Render.com

Kho mã nguồn đã tích hợp sẵn **\Dockerfile\**, **\entrypoint.sh\** và **ender.yaml\** (Blueprint) để triển khai tự động lên Render:

### Cách 1: Sử dụng Render Blueprint (Khuyên dùng - 1 Click)
1. Đăng nhập vào [Render.com](https://dashboard.render.com).
2. Chọn **Blueprints** -> Bấm **New Blueprint Instance**.
3. Chọn Repository \khoawork/SSO-HUB\.
4. Render sẽ tự động phát hiện file ender.yaml\ và tạo sẵn:
   - Cơ sở dữ liệu PostgreSQL (\sso-postgres\).
   - Web Service chạy Keycloak (\sso-hub\) từ Dockerfile.
5. Bấm **Apply**. Quá trình build và khởi chạy mất khoảng 3-5 phút.

### Cách 2: Tạo thủ công Web Service trên Render
1. Tạo một **PostgreSQL Database** trên Render (ví dụ tên \sso-db\). Sao chép mục **Internal Database URL**.
2. Tạo một **Web Service** mới -> Kết nối với repo \SSO-HUB\ -> Chọn **Docker** runtime.
3. Trong phần **Environment Variables**, thêm:
   - \DATABASE_URL\: Dán chuỗi kết nối PostgreSQL vừa tạo ở bước 1.
   - \KEYCLOAK_ADMIN\: \dmin   - \KEYCLOAK_ADMIN_PASSWORD\: \Mật khẩu quản trị của bạn   - \KC_PROXY\: \edge   - \KC_HTTP_ENABLED\: \	rue   - \KC_HOSTNAME_STRICT\: \alse4. Bấm **Create Web Service**. Hệ thống sẽ tự động chuyển đổi định dạng kết nối JDBC và nạp Realm \sso-platform\.
