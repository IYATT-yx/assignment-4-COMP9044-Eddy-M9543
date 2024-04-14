#!/usr/bin/env bash

echo "Test 4: s command: any non-whitespace character may be used to delimit a substitute command."

input=$(seq 1 30)
patterns=(
    "sX2Xt/oX"
    "s.2.two.g"
    "5s#5#five#g"
    "3,28s%4%four%"
    "5,1s^5^five^"
    "3,/2/s!8!eight!"
    "3,/9/s_7_seven_"
    "/6/,/6/sa6asixa"
    "/5/,3sz5zfivez"
    "/5/,14sq1qoneqg"
    "/5/,5sQ5QfiveQ"
    "/5/,/9/sg[67]gsix_or_seveng"
    "/9/,/5/su1{2}uelevenu"
    "/5/,/5/s<5<five<"
    "\$sm30m03m"
    "\$,6sn30n#003n"
    "\$,\$s!30!003#!"
    "10,\$s_2{2}_!333_"
    "/2/,\$sv1{2}v11^1v"
    "\$,/3/sh30h0*00h"
    "30,\$sR30R11%1R"
)

for pattern in "${patterns[@]}";
do
    eddy_output=$(echo "$input" | python3 ./eddy.py --patterns "$pattern")
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
