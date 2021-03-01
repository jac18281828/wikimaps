#!/usr/bin/env /bin/sh


WEST=29
EAST=35
SOUTH=29.5
NORTH=32

if [ "--east" = "$1" ]
then
    shift;
    if [ -n "$1" ]
    then
        EAST=$1; shift
    else
        echo "Easting required"
        exit 1
    fi
fi

WIDTH=15c

PROJECTION=-JM10/${WIDTH}

OPT="-V --FONT_ANNOT_PRIMARY=10p"

PEN=0.25p,200/200/200
LINE=-W${PEN}
LAND=255/255/204
LAKE="51/204/255"
TRANS=15
SCALEBAR="f30/30/40/50M"

VERSION=$(gmt --version)

if [ ! -x $(which gmt) ]
then
    echo GMT required
    exit 1
fi

VERSION=$(gmt --version)

if [ "${VERSION}" = [0-5]* ]
then
    gmt --version
    echo gmt 6 reqired
    exit 1
fi

gmt gtd2cpt --show-sharedir

# ETOPO1_Bed_g_gmt4.grd is the NETCDF encoded ETOPO1 dataset downloaded for GMT4 Bedrock
BEDROCK=ETOPO1_asiaminor.grd

if [ -f /bedrock/${BEDROCK} ]
then
    ETOPO1=/bedrock/${BEDROCK}
else
    ETOPO1=../ETOPO1_Bed_g_gmt4.grd
fi

if [ ! -f ${ETOPO1} ]
then
    echo "ETOPO1 GRID file is required"
    exit 1
fi

gmt set PS_LINE_CAP=ROUND PS_LINE_JOIN=ROUND PS_SCALE_X=1 PS_SCALE_Y=1 MAP_ORIGIN_X=1c MAP_ORIGIN_Y=1c

BASEMAP='-B2dg3d -B+gwhite'

gmt begin niledelta_${EAST}

    gmt basemap -R${WEST}/${EAST}/${SOUTH}/${NORTH} ${PROJECTION} ${OPT} ${BASEMAP} 
    gmt makecpt -Ccopper -T-10/200
    gmt grdimage ${ETOPO1} -n+c -I+a45+nt1 ${PROJECTION} -R${WEST}/${EAST}/${SOUTH}/${NORTH} ${OPT}

    gmt coast -R${WEST}/${EAST}/${SOUTH}/${NORTH}  ${PROJECTION} ${OPT} -G${LAND}@${TRANS}
    
    gmt coast -R${WEST}/${EAST}/${SOUTH}/${NORTH} ${PROJECTION} ${OPT} -S${LAKE}
    gmt coast -R${WEST}/${EAST}/${SOUTH}/${NORTH} ${PROJECTION} ${OPT} ${LINE} 
    gmt coast -R${WEST}/${EAST}/${SOUTH}/${NORTH} ${PROJECTION} ${OPT} -Ia/0.5p,${LAKE}
    # national bounds
    #    gmt coast -R${WEST}/${EAST}/${SOUTH}/${NORTH} ${PROJECTION} ${OPT} -N1/1.25p,225/225/225
    # water bounds
    gmt coast -R${WEST}/${EAST}/${SOUTH}/${NORTH} ${PROJECTION} ${OPT} -L${SCALEBAR} -N3/0.25p,${LAKE}

    #-F+f11p,Helvetica-Bold+jCB
    #-F+f10p,Palatino-Roman+jCB    
    # cat caps.dat | gmt text -F+f10p -R${WEST}/${EAST}/${SOUTH}/${NORTH} ${PROJECTION} ${OPT}
    if [ -f city.dat ]
    then
        cat city.dat | gmt text -Dj6p -R${WEST}/${EAST}/${SOUTH}/${NORTH} ${PROJECTION} ${OPT} -F+f10p,Palatino-Roman+jCB    
        cat city.dat | gmt plot -Sc2p -R${WEST}/${EAST}/${SOUTH}/${NORTH} ${PROJECTION} ${OPT}
    fi

    if [ -f battle.dat ]
    then
    
        cat battle.dat | gmt text -Dj6p -R${WEST}/${EAST}/${SOUTH}/${NORTH} ${PROJECTION} ${OPT} -F+f10p,Palatino-Roman+jCB    
        cat battle.dat | gmt plot -S+4p -R${WEST}/${EAST}/${SOUTH}/${NORTH} ${PROJECTION} ${OPT}
    fi

    if [ -f place.dat ]
    then
        cat place.dat | gmt text -Dj6p -R${WEST}/${EAST}/${SOUTH}/${NORTH} ${PROJECTION} ${OPT} -F+f6p,Palatino-Roman+jCB
    fi


gmt end
# try gmt end show

ls -l niledelta_${EAST}.pdf

if [ "--sleep" = "$1" ]
then
    sleep 20
fi

