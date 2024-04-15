#!/usr/bin/env bash

echo "Test 5: multiple Eddy commands can be supplied separated by semicolons ;."

input=$(seq 1 100)
patterns=(
    "4q;/2/d"
    "/2/d;4q"
    "/2$/,/8$/d;4,6p"
    "4,6p;/2$/,/8$/d"
    "s/5/##/;\$q"
    "\$q;s/5/##/"
    "/2/p;s/2/*/"
    "s/2/*/;/2/p"
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
        # exit 1
    fi
done
