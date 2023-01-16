FROM nginx:1.23.3 as build

ENV NGINX_VERSION=1.23.3

LABEL maintainer="Ishtiyaq Husain <ishtiyq.husain@gmail.com>" Description="This is nginx web server with Google brotli compression" Vendor="Ishtiyaq Husain" Version="1.23.3"

RUN apt-get update \
  && apt -y --no-install-recommends install build-essential git wget libpcre3 libpcre3-dev zlib1g zlib1g-dev openssl libssl-dev

RUN wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
  && tar zxvf nginx-${NGINX_VERSION}.tar.gz \
  && rm nginx-${NGINX_VERSION}.tar.gz \
  && git clone https://github.com/google/ngx_brotli.git \
  && cd ngx_brotli \
  && git submodule update --init \
  && cd /nginx-${NGINX_VERSION} \
  && ./configure --with-compat --add-dynamic-module=../ngx_brotli \
  && make modules \
  && cp objs/*.so /etc/nginx/modules \
  && chmod 644 /etc/nginx/modules/*.so


FROM nginx:1.23.3

COPY --from=build /nginx-${NGINX_VERSION}/objs/*.so /etc/nginx/modules/
COPY nginx.conf /etc/nginx/nginx.conf

# Forward request logs to Docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
  && ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]
