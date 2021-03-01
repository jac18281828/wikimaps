#!/usr/bin/env /bin/bash

set -e

DEBTAG='gmt_bedrock_asiaminor:1.0'

docker build --tag ${DEBTAG} asiaminor/

ALLTAG='gmt_wiki_all:1.0'

docker build --tag ${ALLTAG} -f- . <<EOF

FROM ${DEBTAG}

WORKDIR /wiki

COPY niledelta niledelta/

CMD /bin/bash
EOF

for dir in niledelta
do
    echo $dir ...
    (cd $dir && sh ./build.sh)
done
          
