FROM archlinux/base

RUN echo '::group::Building docker image'

RUN echo '::group::Installing pacman packages'
RUN pacman -Sy && \
    pacman -Sy --noconfirm --needed openssh sudo \
      git fakeroot binutils gcc awk binutils xz \
      libarchive bzip2 coreutils file findutils \
      gettext grep gzip sed ncurses util-linux
RUN echo '::endgroup::'

RUN echo '::group::Copying necessary files'
COPY entrypoint.sh /entrypoint.sh
COPY build.sh /build.sh
COPY ssh_config /ssh_config
RUN echo '::endgroup::'

RUN echo '::endgroup::'

ENTRYPOINT ["/entrypoint.sh"]
