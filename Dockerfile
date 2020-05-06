FROM archlinux/base

RUN pacman -Sy && \
    pacman -Sy --noconfirm openssh \
      git fakeroot binutils gcc awk binutils xz \
      libarchive bzip2 coreutils file findutils \
      gettext grep gzip sed ncurses

COPY entrypoint.sh /entrypoint.sh
COPY ssh_config /ssh_config

ENTRYPOINT ["/entrypoint.sh"]
