#!/usr/bin/env bash

echo "Test 3: s command"

input=$(seq 1 100)
patterns=(
    "s/2/two/"
    "s/2/two/g"
    "5s/5/five/g"
    "3,28s/4/four/"
    "5,1s/5/five/"
    "3,/2/s/8/eight/"
    "3,/9/s/7/seven/"
    "/6/,/6/s/6/six/"
    "/5/,3s/5/five/"
    "/5/,14s/1/one/g"
    "/5/,5s/5/five/"
    "/5/,/9/s/[67]/six_or_seven/"
    "/9/,/5/s/1{2}/eleven/"
    "/5/,/5/s/5/five/"
    "\$s/30/03/"
    "\$,6s/30/#003/"
    "\$,\$s/30/003#/"
    "10,\$s/2{2}/!333/"
    "/2/,\$s/1{2}/11^1/"
    "\$,/3/s/30/0*00/"
    "30,\$s/30/11%1/"
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
