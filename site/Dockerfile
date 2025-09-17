# Use lightweight Nginx image
FROM nginx:stable-alpine

# Remove default nginx index
RUN rm -rf /usr/share/nginx/html/*

# Copy site contents
COPY . /usr/share/nginx/html

# Expose default Nginx port
EXPOSE 80

# Start nginx (default CMD from base image runs nginx)
