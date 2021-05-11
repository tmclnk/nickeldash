#!/usr/bin/env bash
set -eu
set -o pipefail

BUCKET=${BUCKET:-mybucket}
################################################################################
# Error Handling
################################################################################
trap 'catch $? $LINENO' ERR
catch() {
    >&2 echo "Error $1 occurred on $2"
    logger -t nickeldash "Error $1 occurred on $2"
    exit "$1"
}

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"
xargs -0 aws cloudwatch get-metric-widget-image --metric-widget < prod-failures.json \
    | jq -r .MetricWidgetImage \
    | base64 --decode \
    | convert -transparent white -background none png:- -rotate -16 -resize 60% png:- \
    | composite -compose over -size 100x100 -geometry +740+305 png:- lookatthis.png png:- \
    | convert png:- -fill white -undercolor '#00000080' -gravity South -annotate +0+5 " $(date) " png:- \
    | convert png:- -fill white -undercolor '#00000080' -font Courier-Bold -pointsize 60 -gravity South -annotate +0+30 "LOOK AT THIS ERROR GRAPH" composite.png


# | convert png:- -scale 50%  composite.png
aws s3 cp index.html s3://$BUCKET/nickeldash/ --expires "$(date --date 'now + 1 minute' +%FT%T%z)"
aws s3 cp composite.png s3://$BUCKET/nickeldash/ --expires "$(date --date 'now + 4 minute' +%FT%T%z)"

