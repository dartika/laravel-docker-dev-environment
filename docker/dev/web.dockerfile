FROM nginx:1.13-alpine

ADD ./vhost.conf /etc/nginx/conf.d/default.conf

# Set the timezone.
RUN apk add -U tzdata && cp /usr/share/zoneinfo/Europe/Madrid /etc/localtime