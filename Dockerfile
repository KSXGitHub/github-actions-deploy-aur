FROM archlinux/base

RUN pacman -Sy && \
    pacman -Sy --noconfirm openssh \
      git fakeroot binutils gcc awk binutils xz \
      libarchive bzip2 coreutils file findutils \
      gettext grep gzip sed ncurses

RUN mkdir -p /root/.ssh
RUN touch /root/.ssh/known_hosts
COPY ssh_config /root/.ssh/config
RUN chmod 600 /root/.ssh/* -R

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
