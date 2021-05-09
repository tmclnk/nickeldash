#!/usr/bin/env bash

logger -it nickeldash start

cd /home/tom/nickeldash
xargs -0 aws cloudwatch get-metric-widget-image --metric-widget < metric.json \
    | jq -r .MetricWidgetImage \
    | base64 --decode \
    | convert -transparent white -background none png:- -rotate -16 -resize 60% ./rotate.png

composite -compose over -size 100x100 -geometry +740+305 rotate.png lookatthis.png composite.png

aws s3 cp index.html s3://dev-a-cdn.smart-square.com/nickeldash/
aws s3 cp composite.png s3://dev-a-cdn.smart-square.com/nickeldash/

logger -it nickeldash end
