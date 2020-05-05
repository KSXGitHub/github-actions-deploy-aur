FROM archlinux/base

COPY entrypoint.sh /entrypoint.sh

COPY "$INPUT_FILENAME" /input_file

ENTRYPOINT ["/entrypoint.sh"]
