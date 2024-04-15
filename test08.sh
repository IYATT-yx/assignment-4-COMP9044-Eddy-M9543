#!/usr/bin/env bash

echo "Test 8: whitespace can appear before and/or after commands and addresses. '#' can be used as a comment character."

input=$(seq 1 100)
patterns1=(
    " 3, 17  d  # comment"
    "/2/d # delete  ;  4  q # quit"
    "s/4/#7#/"
    "s/4/#7#/ # substitute"
    "  /1$/  ,   /^2/    d # comment"
    "/2/    d # comment;# comment;4    q"
)

patterns2=(
    " 3, 17  d  # comment"
    "/2/d # delete  
      4  q # quit"
    "s/4/#7#/"
    "s/4/#7#/ # substitute"
    "  /1$/  ,   /^2/    d # comment"
    "/2/    d # comment
    # comment
    4    q"
)

for ((i=0; i<${#patterns1[@]}; ++i))
do
    eddy_output=$(echo "$input" | python3 ./eddy.py "${patterns1[$i]}")
    if [ $? -ne 0 ];
    then
        echo "Command failed"
        exit 1
    fi

    sed_output=$(echo "$input" | sed -E "${patterns2[$i]}")

    echo "${patterns1[$i]}"
    if [ "$eddy_output" = "$sed_output" ];
    then
        echo "Match: Yes"
        echo "-------------------------------"
    else
        echo "Match: No"
        exit 1
    fi
done