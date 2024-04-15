#!/usr/bin/env bash

echo "Test 2: d command"

input=$(seq 1 100)
patterns=(
    "d"
    "5d"
    "3,5d"
    "5,1d"
    "3,/2/d"
    "3,/9/d"
    "/6/,/6/d"
    "/5/,3d"
    "/5/,14d"
    "/5/,5d"
    "/5/,/9/d"
    "/9/,/5/d"
    "\$d"
    "\$,6d"
    "\$,\$d"
    "10,\$d"
    "/2/,\$d"
    "\$,/3/d"
    "30,\$d"
)

for pattern in "${patterns[@]}";
do
    eddy_output=$(echo "$input" | python3 ./eddy.py "$pattern")
    if [ $? -ne 0 ];
    then
        echo "Command failed"
        exit 1
    fi

    sed_output=$(echo "$input" | sed -E "$pattern")

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