FROM archlinux/base

RUN pacman -Sy && \
    pacman -Sy --noconfirm --needed openssh sudo \
      git fakeroot binutils gcc awk binutils xz \
      libarchive bzip2 coreutils file findutils \
      gettext grep gzip sed ncurses util-linux

COPY entrypoint.sh /entrypoint.sh
COPY build.sh /build.sh
COPY ssh_config /ssh_config

ENTRYPOINT ["/entrypoint.sh"]
