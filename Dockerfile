ARG NGINX_VERSION=1.29.8

FROM nginx:${NGINX_VERSION} AS build

LABEL maintainer="Ishtiyaq Husain <ishtiyq.husain@gmail.com>" \
      description="nginx with Google brotli compression" \
      vendor="Ishtiyaq Husain"

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
      build-essential \
      cmake \
      git \
      wget \
      libpcre2-dev \
      zlib1g-dev \
      libssl-dev \
  && rm -rf /var/lib/apt/lists/*

  RUN wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
  && tar zxf nginx-${NGINX_VERSION}.tar.gz \
  && rm nginx-${NGINX_VERSION}.tar.gz \
  && git clone --recurse-submodules https://github.com/google/ngx_brotli.git \
  && cmake -S ngx_brotli/deps/brotli -B ngx_brotli/deps/brotli/out \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_SHARED_LIBS=OFF \
      -DCMAKE_INSTALL_PREFIX=./out \
  && cmake --build ngx_brotli/deps/brotli/out --config Release --target brotlienc brotlicommon -j$(nproc) \
  && cd nginx-${NGINX_VERSION} \
  && ./configure --with-compat --add-dynamic-module=../ngx_brotli \
  && make modules -j$(nproc)


FROM nginx:${NGINX_VERSION}
ARG NGINX_VERSION

COPY --from=build /nginx-${NGINX_VERSION}/objs/*.so /etc/nginx/modules/
COPY nginx.conf /etc/nginx/nginx.conf

RUN ln -sf /dev/stdout /var/log/nginx/access.log \
  && ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80
STOPSIGNAL SIGTERM
CMD ["nginx", "-g", "daemon off;"]