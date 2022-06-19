FROM ubuntu:jammy

RUN : \
    && apt-get update \
    && DEBIAN_FRONTEND=nointeractive apt-get install -y --no-install-recommends \
        python3 \
        python3-venv \
    && apt-get clean \
    && rm -rf /var/lib/apt/list/* \
    && :

COPY requirements.txt /tmp/
ENV PATH=/venv/bin:$PATH
RUN : \
    && python3 -m venv venv \
    && pip --no-cache-dir install -r /tmp/requirements.txt \
    && :

WORKDIR /root

COPY .dbt/ .dbt/
COPY dbt_project.yml dbt_project.yml
COPY packages.yml packages.yml 
COPY dbt_project/ dbt_project/

RUN dbt deps
