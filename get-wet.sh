#!/bin/bash
set -euo pipefail

# Wet-ID        First-Date      Name
# BWBR0002656   2002-01-01      Burgerlijk wetboek 1
# BWBR0003045   2002-04-23      Burgerlijk wetboek 2
# BWBR0005291   2002-01-01      Burgerlijk wetboek 3

# URL="wget https://wetten.overheid.nl/${WET}/YYYY-MM-DD/0/txt"
export WET="BWBR0005291"
export BASEURL="https://wetten.overheid.nl/${WET}"
export DATUM="2002-01-01"

while true; do
    curl "https://wetten.overheid.nl/${WET}/${DATUM}/0/txt" -o "${WET}.txt"

    ENDDATE=`grep "^Geldend van" ${WET}.txt  | head -1 | awk '{print $5}' | sed -E 's/([0-9]+)-([0-9]+)-([0-9]+)/\3-\2-\1/' | tr -d `

    if [ "$ENDDATE" = "heden" ]; then
        NEWDATE=heden
    else
        NEWDATE=`date -d "${ENDDATE} +1 day" +%Y-%m-%d`
    fi

    echo "Enddate: '$ENDDATE'"
    echo "NewDate: '$NEWDATE'"

    git add ${WET}.txt
    GIT_COMMITTER_DATE="`date -d ${DATUM}`" git commit --date "`date -d ${DATUM}`" -m "${WET}-geldend_van_${DATUM}_tot_${NEWDATE}"
    mv "${WET}.txt" "${WET}.${DATUM}-${ENDDATE}.txt"

    if [ "$ENDDATE" = "heden" ]; then
        echo "Last version..."
        exit 1;
    fi

    export DATUM=${NEWDATE}
    echo "New fetch date: '$DATUM'"
done
