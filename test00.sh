#!/usr/bin/env bash

echo "Test 0: p command, -n option"

input=$(seq 1 30)
patterns=(
    "p"
    "5p"
    "3,5p"
    "5,1p"
    "3,/2/p"
    "3,/9/p"
    "/6/,/6/p"
    "/5/,3p"
    "/5/,14p"
    "/5/,5p"
    "/5/,/9/p"
    "/9/,/5/p"
    "\$p"
    "\$,6p"
    "\$,\$p"
    "10,\$p"
    "/2/,\$p"
    "\$,/3/p"
    "30,\$p"
)

for pattern in "${patterns[@]}";
do
    eddy_output=$(echo "$input" | python3 ./eddy.py -n --patterns "$pattern")
    if [ $? -ne 0 ];
    then
        echo "Command failed"
        exit 1
    fi

    sed_output=$(echo "$input" | sed -E -n "$pattern")

    echo "$pattern"
    if [ "$eddy_output" = "$sed_output" ];
    then
        echo "Match: Yes"
        echo "-------------------------------"
    else
        echo "Match: No"
        exit 1
    fi
done