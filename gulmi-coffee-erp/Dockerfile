# ============================================================
# Gulmi Coffee ERP & CRM — Docker Image
# Base: nginx:alpine (lightweight ~20MB)
# ============================================================

FROM nginx:alpine

LABEL maintainer="Gulmi Coffee Pvt. Ltd. <it@gulmicoffee.com.np>"
LABEL version="1.0"
LABEL description="Gulmi Coffee ERP & CRM System — Full Stack"

# Remove default nginx config and default html
RUN rm /etc/nginx/conf.d/default.conf
RUN rm -rf /usr/share/nginx/html/*

# Copy custom nginx config
COPY docker/nginx.conf /etc/nginx/conf.d/gulmi-erp.conf

# Copy ERP application
COPY src/index.html /usr/share/nginx/html/index.html

# Create customer portal as separate entry (same file, aliased)
COPY src/index.html /usr/share/nginx/html/portal.html

# Copy health check page
COPY docker/healthcheck.html /usr/share/nginx/html/health.html

# Expose HTTP port
EXPOSE 80

# Health check — ping /health every 30s
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost/health || exit 1

# Start nginx in foreground (required for Docker)
CMD ["nginx", "-g", "daemon off;"]
