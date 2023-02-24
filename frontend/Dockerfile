FROM nginx:latest

COPY ./build/web /usr/share/nginx/html

WORKDIR /usr/share/nginx/html

ENV API_URL=$API_URL

CMD sh -c 'echo "API_URL=$API_URL" > /usr/share/nginx/html/assets/assets/chatapp.conf.env && nginx -g "daemon off;"'