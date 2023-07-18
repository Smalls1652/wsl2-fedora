FROM docker.io/library/fedora:38

ARG BUILD_SEED

COPY ./config-scripts/ /tmp/config-scripts/
COPY ./default-bash-profile/ /tmp/default-bash-profile/

RUN chmod +x /tmp/config-scripts/*.sh

RUN /tmp/config-scripts/01_packages.sh
RUN /tmp/config-scripts/02_bash-config.sh
RUN /tmp/config-scripts/03_wsl.sh

RUN rm -rf /tmp/config-scripts
