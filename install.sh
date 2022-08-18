#!bin/bash

BIN=/usr/local/bin
SCRIPTPATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
DIR=${SCRIPTPATH::${#SCRIPTPATH}-11}
SRC=$DIR/src
EXEC=$SRC/build/PP.build/Release/PP.build/Objects-normal/x86_64/Binary/PP
SERVICES=$HOME/Library/Services
WORKFLOW=$SERVICES/pp.workflow
CONTENT=$WORKFLOW/Contents
MOVABLE=0

echo "Building & Archiving..."
echo "Target folder: $SRC"

cd $SRC && xcodebuild archive -quiet && echo "Archived!"

echo "Building the workflow..."
echo "Looking for the executable Point&Paste..."

if [[ -x "$EXEC" ]] && file "$EXEC" | grep -q 'Mach-O'; then
    echo "Archive found: $EXEC\n\n"
    MOVABLE=1
else
    echo "\n\n\nArchive not found: You first need to build & archive the src folder\n\n\n"
fi

if [[ $MOVABLE == 1 ]]; then
    mkdir "$WORKFLOW" && mkdir "$CONTENT"
    mv $EXEC $BIN
    mv $DIR/PPWorkflow/document.wflow $CONTENT
    mv $DIR/PPWorkflow/Info.plist $CONTENT
    echo "Installed!"
fi
