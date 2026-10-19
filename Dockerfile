# ---------- Nexvion static site (Nginx) ----------
FROM nginx:1.27-alpine

LABEL maintainer="nexvion" app="nexvion-web"

# Remove default site, add our config
RUN rm -rf /usr/share/nginx/html/* /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Website files
COPY index.html products.html payment.html /usr/share/nginx/html/
COPY style.css products.css payment.css /usr/share/nginx/html/
COPY script.js payment.js logo.png /usr/share/nginx/html/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
