#!/usr/bin/env bash

echo "Test 5: multiple Eddy commands can be supplied separated by semicolons ;."

input=$(seq 1 30)
patterns1=(
    "4q"
    "/2/d"
    "/2$/,/8$/d"
    "4,6p"
    "s/5/##/"
    "\$q"
)

patterns2=(
    "/2/d"
    "4q"
    "4,6p"
    "/2$/,/8$/d"
    "\$q"
    "s/5/##/"
)

length=${#patterns1[@]}

for ((i=0; i<length; ++i))
do
    eddy_output=$(echo "$input" | python3 ./eddy.py --patterns "${patterns1[i]};${patterns2[i]}")
    if [ $? -ne 0 ];
    then
        echo "Command failed"
        exit 1
    fi

    sed_output=$(echo "$input" | sed -E -e "${patterns1[i]}" -e "${patterns2[i]}")

    echo "${patterns1[i]};${patterns2[i]}"
    if [ "$eddy_output" = "$sed_output" ];
    then
        echo "Match: Yes"
        echo "-------------------------------"
    else
        echo "Match: No"
        exit 1
    fi
done
