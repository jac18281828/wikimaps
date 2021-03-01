#!/usr/bin/env /bin/sh

set -e

ALLTAG=gmt_wiki_all:1.0
WORKDIR=wiki
PROJECT=niledelta
TAG="gmt_${WORKDIR}_${PROJECT}:1.0"

IMAGEID=$(docker build -q -<<EOF
FROM ${ALLTAG}

ARG PROJECT=${PROJECT}

ENV LANG=C.UTF-8 \
    TZ=CDT6CST

WORKDIR /wiki/${PROJECT}

CMD ./${PROJECT}.sh --east 33 --sleep

EOF
)

PDF=../pdf

CONTAINER=$(docker run -d --rm -t ${IMAGEID})

for EAST in 33;
do

    OUTPUT=/${WORKDIR}/${PROJECT}/${PROJECT}_${EAST}.pdf

    if [ ! -d ${PDF} ]
    then
        mkdir -p ${PDF}
    fi

    FILE="NOTFOUND"
    while [ "NOTFOUND" = "${FILE}" ]
    do
        sleep 1
        #docker logs ${CONTAINER}
        FILE=$(docker exec ${CONTAINER} /bin/sh -c "if [ ! -s ${OUTPUT} ]; then echo NOTFOUND; fi")
    done

    sleep 5

    echo cp ${CONTAINER}:${OUTPUT} ${PDF}
    docker cp ${CONTAINER}:${OUTPUT} ${PDF}
done
