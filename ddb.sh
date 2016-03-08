#!/bin/sh
# print how much data has been written to the file or device using percentage value
# dd output will overwrite printed data at the end
#
# sample usage:
# ddb.sh infile outfile

# command arguments
file_from=$1
file_to=$2

# defaults settings
bs="20M"

# character used to print bar chart
barchr="+"

# current min, max values
vmin=1
vmax=100

# range of the bar graph
dmin=1
dmax=40

if [ -e "$file_from" ]; then
  if [ -b "$file_from" ]; then
    file_from_size=$(blockdev --getsize64 $file_from)
  else
    file_from_size=$(stat --format "%s" $file_from)
  fi

  $(which dd) if=${file_from} of=${file_to} bs=${bs} &

  # read process ID
  process=$!

  # execute until the process exists
  while [ "$(kill -0 $process 2>/dev/null; echo $?)" -eq "0" ]; do
    if [ -e "/proc/${process}/io" ]; then
      # get number of written bytes
      written_data=$(cat /proc/${process}/io | awk '/wchar/ {print $2}')

      percent=$(expr 100 \* $written_data / $file_from_size)

      # generate output
      awk --assign dmin="$dmin" --assign dmax="$dmax" \
          --assign vmin="$vmin" --assign vmax="$vmax" \
          --assign percent="$percent" \
          --assign barchr="$barchr" \
          'BEGIN {
            x=int(dmin+(percent-vmin)*(dmax-dmin)/(vmax-vmin));
            printf "%4i %% [", percent
            for(i=1;i<=dmax;i++){if(i <= x) printf barchr; else printf " "};
            printf "]\r"
            if(x == dmax)
              printf "\033[0K"
          }'

      # wait 1 second
      sleep 1
    else
      break
    fi
  done
fi
