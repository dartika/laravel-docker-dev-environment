FROM mysql:5.6

# Set the timezone.
RUN cp /usr/share/zoneinfo/Europe/Madrid /etc/localtime