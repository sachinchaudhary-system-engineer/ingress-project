FROM nginx:alpine

COPY code/index.html /usr/share/nginx/html/index.html

EXPOSE 80
