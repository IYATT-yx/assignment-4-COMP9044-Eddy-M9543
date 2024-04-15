#!/usr/bin/env bash

echo "Test 9: multiple Eddy commands can be supplied separated by newlines. "

input=$(seq 1 100)
patterns=(
    "4q
    /2/d"

    "/2/d
    4q"

    "/2$/,/8$/d
    4,6p"

    "4,6p
    /2$/,/8$/d"

    "s/5/##/
    \$q"

    "\$q
    s/5/##/"

    "1,/.1/p;/5/,/9/s/.//
    /.2/,/.9/p;85q"

    "1,/.1/p
    /5/,/9/s/.//
    /.2/,/.9/p
    85q"

    "/5/,/9/s/.//
    p"
)

for pattern in "${patterns[@]}";
do
    eddy_output=$(echo "$input" | python3 ./eddy.py -n "$pattern")
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


patterns=(
    "10p
    \$p"
)

for pattern in "${patterns[@]}";
do
    eddy_output=$(python3 ./eddy.py -n "$pattern" < dictionary.txt)
    if [ $? -ne 0 ];
    then
        echo "Command failed"
        exit 1
    fi

    sed_output=$(sed -E -n "$pattern" < dictionary.txt)

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