FROM python:3.8 as builder
COPY requirements.txt /tmp/requirements.txt
WORKDIR tmp
RUN pip install --user -r requirements.txt

FROM python:3.8-slim as test
COPY dev-requirements.txt /tmp/dev-requirements.txt
WORKDIR tmp
COPY --from=builder /root/.local /root/.local
RUN pip install --user -r dev-requirements.txt
ENV PATH=/root/.local/bin:$PATH

FROM python:3.8-slim
ENV PYTHONUNBUFFERED 1

# lib for uwsgi in python-slim
RUN apt-get update && apt-get install -y libxml2 && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=builder /root/.local /usr/src/user/.local
ENV PATH=/usr/src/user/.local/bin:$PATH

RUN mkdir -p /src /docker-entrypoint.d /usr/src/ \
    && useradd --home-dir /usr/src/user --uid 1000 user \
    && chown -R user:root /src && chmod -R g+rwX /src \
    && chown -R user:root /docker-entrypoint.d && chmod -R g+rwX /docker-entrypoint.d \
    && chown -R user:root /usr/src/user && chmod -R g+rwX /usr/src/user

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

WORKDIR /src
ENTRYPOINT ["/docker-entrypoint.sh"]
EXPOSE 80
COPY src/ /src/

USER user
CMD uwsgi --http :80 --module app.wsgi --master --enable-threads --uid 1000