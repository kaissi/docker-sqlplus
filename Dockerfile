# Copyright 2018 Marcos Rafael Kaissi Barbosa
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# https://hub.docker.com/r/frolvlad/alpine-glibc/tags/

FROM frolvlad/alpine-glibc:alpine-3.8_glibc-2.28
MAINTAINER Marcos Rafael Kaissi Barbosa <mrkaissi@gmail.com>
ARG VERSION
ARG CREATION_DATE
LABEL version="${VERSION}" \
	  creationDate="${CREATION_DATE}"
ENV ORACLE_HOME /usr/lib/oracle/11.2/client64
ENV LD_LIBRARY_PATH ${ORACLE_HOME}/lib
ARG TZ="Etc/UTC"
ENV TZ ${TZ}
COPY bin/instantclient-linux.x64-11.2.0.4.0.zip ${ORACLE_HOME}/instantclient_11_2.zip
COPY entrypoint /usr/local/sqlplus/
COPY sqlplus /usr/local/sqlplus/scripts.d/sqlplus
RUN apk add --no-cache --update -U \
        curl \
        dumb-init \
        libaio \
        tzdata \
    && cp /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo "${TZ}" > /etc/timezone \
    && mkdir -p ${LD_LIBRARY_PATH} \
    && mkdir -p ${ORACLE_HOME}/bin \
    && unzip ${ORACLE_HOME}/instantclient_11_2.zip -d ${ORACLE_HOME} \
    && mv ${ORACLE_HOME}/instantclient_11_2/* ${LD_LIBRARY_PATH} \
    && rm -f ${ORACLE_HOME}/instantclient_11_2.zip \
    && rm -rf ${ORACLE_HOME}/instantclient_11_2 \
    && mv ${LD_LIBRARY_PATH}/sqlplus ${ORACLE_HOME}/bin/ \
    && mv ${LD_LIBRARY_PATH}/adrci ${ORACLE_HOME}/bin/ \
    && mv ${LD_LIBRARY_PATH}/genezi ${ORACLE_HOME}/bin/ \
    && mv ${LD_LIBRARY_PATH}/wrc ${ORACLE_HOME}/bin/ \
    && mv ${LD_LIBRARY_PATH}/uidrvci ${ORACLE_HOME}/bin/ \
    && ln -s ${ORACLE_HOME}/bin/sqlplus /usr/bin/sqlplus \
    && ln -s /usr/local/sqlplus/entrypoint /usr/local/bin/entrypoint \
    && echo "export ORACLE_HOME=${ORACLE_HOME}" >> /etc/bash.bashrc \
    && echo 'export PATH=${ORACLE_HOME}/bin:${PATH}' >> /etc/bash.bashrc \
    && echo 'export ORACLE_SID=XE' >> /etc/bash.bashrc
VOLUME ["/usr/local/sqlplus/scripts.d"]
ENTRYPOINT ["/usr/bin/dumb-init", "--", "entrypoint"]
CMD ["sqlplus", "-H"]
