#!/usr/bin/env bash

echo "Test 7: input files can be specified on the command line"

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
    eddy_output=$(python3 ./eddy.py -f commands.eddy input1.txt input2.txt)
    if [ $? -ne 0 ];
    then
        echo "Command failed"
        exit 1
    fi

    sed_output=$(sed -E -f commands.eddy  input1.txt input2.txt)

    cat commands.eddy
    compare "$eddy_output" "$sed_output"
}

echo 4q > commands.eddy
echo /2/d >> commands.eddy
seq 1 2 > input1.txt
seq 1 5 > input2.txt
run

echo 4q > commands.eddy
echo /2/d >> commands.eddy
seq 1 5 > input1.txt
seq 1 2 > input2.txt
run

echo /2/d > commands.eddy
echo 4q >> commands.eddy
seq 1 2 > input1.txt
seq 1 5 > input2.txt
run

echo /2/d > commands.eddy
echo 4q >> commands.eddy
seq 1 5 > input1.txt
seq 1 2 > input2.txt
run
