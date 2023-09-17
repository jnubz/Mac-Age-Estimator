#!/bin/sh

#  Author: Jared Nay
#  Purpose: Use macOS system profiler to check model year and calculate estimated age.
#+ This was designed for use with Datto RMM since Serial Numbers are randomized and no
#+ longer provide a reliable estimate.
#  Version: 20230917

#get logged user
LoggedUser="$(stat -f "%Su" /dev/console)"

# check if root detected. script stops if true
if [ "$LoggedUser" == "root" ]
then
 echo "Root User Detected. Operation Ended."
 exit 1
else
 echo "Running as user: $LoggedUser"
fi

# Function to get the hardware model year
hardware_year () {
    local hardware_mod=$(defaults read \
        /Users/$LoggedUser/Library/Preferences/com.apple.SystemProfiler.plist 'CPU Names' \
        | cut -sd '"' -f 4 \
        | uniq)
    local year=$(echo "$hardware_mod" | grep -oE '[0-9]{4}')
    echo "$year"
}

# Function to check if the machine is more than 3 years old
check_machine_age () {
    local current_year=$(date +"%Y")
    local machine_year=$(hardware_year)
    local age=$((current_year - machine_year))
    if [[ ! -z "age" && $age -gt 3 ]]; then
      echo '<-Start Result->'
      echo "WARNING: This machine is more than 3 years old!"
      echo '<-End Result->'
  		exit 1
    else
      echo '<-Start Result->'
      echo "This machine is less than 3 years old."
      echo '<-End Result->'
    fi
}

# Call the hardware_model function and store the result in a variable
model=$(hardware_year)

# Print the hardware model year
echo "Hardware model year: $model"

# Check the machine age
check_machine_age