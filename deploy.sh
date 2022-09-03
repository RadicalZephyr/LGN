#!/bin/sh

DEPLOY_DIR="$HOME/Zomboid/Workshop/LGN"
mkdir -p $DEPLOY_DIR

cp -vr LICENSE preview.png Contents $DEPLOY_DIR
echo Generating workshop.txt from README.md and header.txt...
pandoc -t phpbb.lua README.md | sed -E 's/^(.*)/description=\1/' - | cat header.txt - > $DEPLOY_DIR/workshop.txt
