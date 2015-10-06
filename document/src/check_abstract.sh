#/bin/bash
if [ "$(detex Abstract.tex | wc -w)" -gt "350" ]
then
    echo "Abstract too long."
    exit 1
fi

