# =============================================================================
# DOCKERFILE CHO KEYCLOAK SSO HUB (RENDER & PRODUCTION)
# =============================================================================
FROM quay.io/keycloak/keycloak:24.0 as builder

# Thiết lập cờ tối ưu hóa build
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true
ENV KC_DB=postgres

# Đóng gói giao diện sso-hub tùy biến và cấu hình realm vào image
COPY idp/themes/ /opt/keycloak/themes/
COPY idp/realm-export.json /opt/keycloak/data/import/realm-export.json

# Tối ưu hóa trước (Pre-build Quarkus runtime)
RUN /opt/keycloak/bin/kc.sh build

# Stage 2: Runtime image tinh gọn
FROM quay.io/keycloak/keycloak:24.0
COPY --from=builder /opt/keycloak/ /opt/keycloak/

USER root
COPY entrypoint.sh /opt/keycloak/entrypoint.sh
RUN chmod +x /opt/keycloak/entrypoint.sh
USER 1000

ENTRYPOINT ["/opt/keycloak/entrypoint.sh"]

