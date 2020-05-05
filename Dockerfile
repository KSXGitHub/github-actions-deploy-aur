FROM archlinux/base

COPY entrypoint.sh /entrypoint.sh

COPY "$INPUT_FILENAME" the_input_file

ENTRYPOINT ["/entrypoint.sh"]
