FROM        prom/busybox:latest
MAINTAINER  The Prometheus Authors <prometheus-developers@googlegroups.com>

COPY amtool                       /bin/amtool
COPY alertmanager                 /bin/alertmanager
COPY doc/examples/simple.yml      /etc/alertmanager/alertmanager.yml
COPY template/*                   /etc/alertmanager/template/

EXPOSE     9093
VOLUME     [ "/alertmanager" ]
WORKDIR    /etc/alertmanager
ENTRYPOINT [ "/bin/alertmanager" ]
CMD        [ "--storage.path=/alertmanager" ]
