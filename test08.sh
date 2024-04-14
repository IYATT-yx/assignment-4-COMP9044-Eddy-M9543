#!/usr/bin/env bash

echo "Test 8: whitespace can appear before and/or after commands and addresses. '#' can be used as a comment character."

input=$(seq 1 30)
patterns1=(
    " 3, 17  d  # comment"
    "/2/d # delete  ;  4  q # quit"
    "s/4/#7#/"
    "s/4/#7#/ # substitute"

)

patterns2=(
    " 3, 17  d  # comment"
    "/2/d # delete  
      4  q # quit"
    "s/4/#7#/"
    "s/4/#7#/ # substitute"
)


length=${#patterns1[@]}

for ((i=0; i<length; ++i))
do
    eddy_output=$(echo "$input" | python3 ./eddy.py --patterns "${patterns1[i]}")
    if [ $? -ne 0 ];
    then
        echo "Command failed"
        exit 1
    fi

    sed_output=$(echo "$input" | sed -E "${patterns2[i]}")

    echo "${patterns1[i]}"
    if [ "$eddy_output" = "$sed_output" ];
    then
        echo "Match: Yes"
        echo "-------------------------------"
    else
        echo "Match: No"
        exit 1
    fi
done