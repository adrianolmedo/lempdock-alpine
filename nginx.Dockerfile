FROM nginx:stable-alpine3.17

# Add non-root user
ARG USERNAME
ARG USER_UID
ARG USER_GID=${USER_UID}
RUN addgroup -g ${USER_GID} -S ${USERNAME} \
	&& adduser -D -u ${USER_UID} -S ${USERNAME} -s /bin/sh ${USERNAME} \
#	&& adduser ${USERNAME} www-data \
    && apk add --update vim

# Setting vim configuration for root user
COPY ./nginx/root/. /root

## Add permissions for non-root user
RUN touch /var/run/nginx.pid \
    && chown -R ${USERNAME}:${USERNAME} /var/cache/nginx \
    && chown -R ${USERNAME}:${USERNAME} /var/log/nginx \
    && chown -R ${USERNAME}:${USERNAME} /etc/nginx/conf.d \
    && chown -R ${USERNAME}:${USERNAME} /var/run/nginx.pid

# Switch to non-root user
USER ${USERNAME}

COPY ./nginx/etc/nginx/conf.d/default.conf /etc/nginx/conf.d/

# Setting vim configuration for non-root user
COPY ./nginx/home/non-root/. /home/${USERNAME}
