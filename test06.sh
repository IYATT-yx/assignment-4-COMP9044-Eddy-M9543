#!/usr/bin/env bash

echo "Test 6: reads Eddy commands from the specified file"

compare()
{
    eddy_output="$1"
    sed_output="$2"

    if [ "$eddy_output" = "$sed_output" ];
    then
        echo "Match: Yes"
        echo "-------------------------------"
    else
        echo "Match: No"
        exit 1
    fi
}

run()
{
    eddy_output=$(echo "$input" | python3 ./eddy.py -f commands.eddy)
    if [ $? -ne 0 ];
    then
        echo "Command failed"
        exit 1
    fi

    sed_output=$(echo "$input" | sed -E -f commands.eddy)

    cat commands.eddy
    compare "$eddy_output" "$sed_output"
}

input=$(seq 1 100)

echo 4q > commands.eddy
echo /2/d >> commands.eddy
run

echo /2/d > commands.eddy
echo 4q >> commands.eddy
run

echo /2$/,/8$/d > commands.eddy
echo 4,6p >> commands.eddy
run

echo 4,6p > commands.eddy
echo /2$/,/8$/d >> commands.eddy
run

echo "s/5/##/" > commands.eddy
echo "\$q" >> commands.eddy
run

echo "\$q" > commands.eddy
echo "s/5/##/" >> commands.eddy
run