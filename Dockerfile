FROM debian:bullseye

RUN apt-get update && apt-get install -y apache2-data

EXPOSE 8000

COPY lib6502.so /usr/lib/

RUN mkdir /app
WORKDIR /app
COPY vfs-run /app/

VOLUME /app/siteroot

COPY siteroot/src/DOCKER.SYS /app/siteroot/BOOT.SYS
COPY siteroot/vfs/System/logout.prg /app/siteroot/System/
COPY siteroot/vfs/System/Widgets/nav-pane.widget /app/siteroot/System/Widgets/
COPY siteroot/vfs/System/Images /app/siteroot/System/Images/
COPY siteroot/vfs/sys.rc /app/siteroot/System/folder.rc
COPY siteroot/vfs/admin.rc /app/siteroot/Admin/folder.rc
COPY siteroot/vfs/Admin/*.prg /app/siteroot/Admin/
COPY siteroot/vfs/System/SHELL.SYS /app/siteroot/System/
COPY siteroot/vfs/System/*.OVL /app/siteroot/System/
COPY siteroot/vfs/Apps/*.prg /app/siteroot/Apps/

CMD ["/app/vfs-run"]
