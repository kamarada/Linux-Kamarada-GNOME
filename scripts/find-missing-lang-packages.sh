#!/bin/bash

# List installed packages
INSTALLED_PACKAGES=$(rpm -qa --qf '%{name}\n' | sort)

# For each installed package
for PACKAGE in $INSTALLED_PACKAGES
do
    # If the package is not a language package itself
    if [[ "$PACKAGE" != *-lang ]]
    then
        # Search for the corresponding lang package
        LANG_PACKAGE="$PACKAGE-lang"
        zypper search --match-exact $LANG_PACKAGE > /dev/null 2>&1
        # If there is a corresponding lang package
        if [ $? -eq 0 ]
        then
            # Check if the lang package is installed
            if [[ "$INSTALLED_PACKAGES" != *"$LANG_PACKAGE"* ]]
            then
                # If the lang package is not installed, list it
                echo $LANG_PACKAGE
            fi
        fi
    fi
done
