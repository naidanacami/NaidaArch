#!/usr/bin/env bash

highlight_colours=('#D370A3' '#6D9E3F' '#6095C5' '#B58858' '#3BA275' '#AC7BDE')
highlight="${highlight_colours[$(($RANDOM % ${#highlight_colours[@]}))]}ff"