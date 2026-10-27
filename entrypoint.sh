#!/bin/sh
set -e

# =============================================================================
# KEYCLOAK RENDER ENTRYPOINT SCRIPT
# =============================================================================

# 1. Tự động chuyển đổi DATABASE_URL từ Render sang định dạng JDBC của Keycloak
if [ -n "$DATABASE_URL" ] && [ -z "$KC_DB_URL" ]; then
    echo ">> [Render] Phát hiện DATABASE_URL từ Render, đang chuyển đổi sang định dạng Keycloak JDBC..."
    
    # Tách protocol, user:pass và host:port/db
    DB_USERPASS=$(echo "$DATABASE_URL" | sed -e 's,^[^:]*://\([^@]*\)@.*,\1,g')
    DB_HOSTPORTDB=$(echo "$DATABASE_URL" | sed -e 's,^[^:]*://[^@]*@\(.*\),\1,g')

    if [ -z "$KC_DB_USERNAME" ]; then
        export KC_DB_USERNAME=$(echo "$DB_USERPASS" | cut -d: -f1)
    fi
    if [ -z "$KC_DB_PASSWORD" ]; then
        export KC_DB_PASSWORD=$(echo "$DB_USERPASS" | cut -d: -f2)
    fi

    export KC_DB_URL="jdbc:postgresql://${DB_HOSTPORTDB}"
    export KC_DB="postgres"
    echo ">> [Render] Đã cấu hình KC_DB_URL: ${KC_DB_URL}"
fi

# 2. Cấu hình cổng HTTP phù hợp với biến PORT của Render
HTTP_PORT="${PORT:-8080}"
echo ">> [Render] Keycloak khởi chạy trên cổng HTTP: ${HTTP_PORT}"

# 3. Khởi động Keycloak với chế độ import realm và proxy edge
exec /opt/keycloak/bin/kc.sh start \
    --http-port="${HTTP_PORT}" \
    --http-enabled=true \
    --proxy=edge \
    --hostname-strict=false \
    --import-realm \
    "$@"
