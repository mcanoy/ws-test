# This image provides a base for building and running Spring Boot applications.
# It builds using maven and runs the resulting artifacts on Websphere Liberty 

FROM websphere-traditional:8.5.5.14-profile

MAINTAINER Kevin McAnoy <kmcanoy@redhat.com>

LABEL io.openshift.s2i.scripts-url=image:///usr/local/s2i \
      io.s2i.scripts-url=image:///usr/local/s2i \
      io.k8s.description="Platform for building and running spring boot applications on IBM WebSphere" \
      io.k8s.display-name="Websphere 8.5.5.14" \
      io.openshift.expose-services="9043/tcp:http, 9443/tcp:https" \
      io.openshift.tags="runner, builder, websphere" \
      io.openshift.s2i.destination="/tmp"

ENV STI_SCRIPTS_PATH="/usr/local/s2i" \ 
    WORKDIR="/usr/local/workdir" \
    WLP_DEBUG_ADDRESS="7777" \
    JOLOKIA_PORT="8778" \
    ENABLE_DEBUG="false" \ 
    ENABLE_JOLOKIA="true" \
    S2I_DESTINATION="/tmp" \
    JOLOKIA_VERSION="1.3.5"

# Copy the S2I scripts from the specific language image to $STI_SCRIPTS_PATH
COPY ./.s2i/bin/ $STI_SCRIPTS_PATH 

RUN useradd -u 1001 -r -g 0 -s /sbin/nologin \
      -c "Default Application User" default && \
    chown -R 1001:0 /config && \
    chmod -R g+rw /config && \
    chown -R 1001:0 /opt/IBM/WebSphere/AppServer/profiles/AppSrv01/servers/server1 && \
    chmod -R g+rw /opt/IBM/WebSphere/AppServer/profiles/AppSrv01/servers/server1 && \
    chown -R 1001:0 /opt/IBM/WebSphere/AppServer/profiles/AppSrv01/logs/server1 && \
    chmod -R g+rw /opt/IBM/WebSphere/AppServer/profiles/AppSrv01/logs/server1 && \
    chown -R 1001:0 /work/start_server && \
    chmod -R g+rw /work/start_server && \
    mkdir -p $WORKDIR/artifacts && \
    mkdir -p $WORKDIR/config && \
    chown -R 1001:0 $WORKDIR && \
    chmod -R g+rw $WORKDIR && \
    ln $STI_SCRIPTS_PATH/assemble-runtime $STI_SCRIPTS_PATH/assemble    

COPY ./placeholder.txt $WORKDIR/artifacts 
COPY ./placeholder.txt $WORKDIR/config 

WORKDIR $WORKDIR

EXPOSE $WLP_DEBUG_ADDRESS
#EXPOSE $JOLOKIA_PORT

USER 1001

CMD ["/work/start_server"]
