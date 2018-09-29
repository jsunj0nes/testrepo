FROM haproxy:1.8
COPY generate-config.sh /
ENTRYPOINT ["/generate-config.sh"]
CMD ["haproxy", "-f", "/usr/local/etc/haproxy/haproxy.cfg"]
EXPOSE 6443 1936