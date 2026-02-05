#!/usr/bin/env bash

if [ -z "$SKIP_TEST" ]
then
    # Redirect input from the terminal to capture user input
    exec < /dev/tty

    echo "Do you want to run the tests before pushing? [y/N]"
    read -r run_tests

    # Default to 'no' if the user presses Enter or inputs anything other than 'y'/'Y'
    if [ -z "$run_tests" ] || ([ "$run_tests" != "y" ] && [ "$run_tests" != "Y" ]); then
        echo "Skipping tests..."
    else
        echo "Running pre-push hook"

        ./bin/run-rspec.bash

        # $? stores the exit value of the last command
        if [ $? -ne 0 ]; then
            echo "Tests must pass before pushing!"
            exit 1
        fi
    fi
fi