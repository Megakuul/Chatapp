FROM nginx:latest

COPY ./build/web /usr/share/nginx/html

WORKDIR /usr/share/nginx/html

CMD 'echo "API_URL=$API_URL" > /usr/share/nginx/html/assets/assets/chatapp.conf.env'

CMD ["nginx", "-g", "daemon off;"]