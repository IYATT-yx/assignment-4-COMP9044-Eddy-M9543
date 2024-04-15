#!/usr/bin/env bash

echo "Test 1: q command"

input=$(seq 1 100)
patterns=(
    "q"
    "20q"
    "\$q"
    "/8/q"
    "/.1/q"
    "/^.+5$/q"
    "14q"
    "/13/q"
    "/^2/q"
    "/.10/q"
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


patterns=(
    '/r.*v/q'
    "/b.6b/q"
)

for pattern in "${patterns[@]}";
do
    eddy_output=$(python3 ./eddy.py "$pattern" < dictionary.txt)
    if [ $? -ne 0 ];
    then
        echo "Command failed"
        exit 1
    fi

    sed_output=$(sed -E "$pattern" < dictionary.txt)

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