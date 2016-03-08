#!/bin/sh
# print "processes per user" bar chart
# source: blog.sleeplessbeastie.eu/2014/11/25/how-to-create-simple-bar-charts-in-terminal-using-awk/
# Debian/GNU awk: /usr/bin/awk -> /etc/alternatives/awk -> /usr/bin/gawk

# get usernames
processes=$(ps hax -o user)

# sort and count usernames
user_processes=$(echo "$processes" | sort | uniq -c)

# character used to print bar chart
barchr="+"

# current min, max values [from 'ps' output]
vmin=1
vmax=$(echo "$user_processes" | awk 'BEGIN {max=0} {if($1>max) max=$1} END {print max}')

# range of the bar graph
dmin=1
dmax=56

# color steps
cstep1="\033[32m"
cstep2="\033[33m"
cstep3="\033[31m"
cstepc="\033[0m"

# generate output
echo "$user_processes" | awk --assign dmin="$dmin" --assign dmax="$dmax" \
                             --assign vmin="$vmin" --assign vmax="$vmax" \
                             --assign cstep1="$cstep1" --assign cstep2="$cstep2" --assign cstep3="$cstep3" --assign cstepc="$cstepc"\
                             --assign barchr="$barchr" \
                             'BEGIN {printf("%15s %7s %2s%54s\n","username","p-count","|<", "bar chart >|")}
                              {
                                x=int(dmin+($1-vmin)*(dmax-dmin)/(vmax-vmin));
                                printf("%15s %7s ",$2,$1);
                                for(i=1;i<=x;i++)
                                {
                                    if (i >= 1 && i <= int(dmax/3))
                                      {printf(cstep1 barchr cstepc);}
				    else if (i > int(dmax/3) && i <= int(2*dmax/3))
                                      {printf(cstep2 barchr cstepc);}
                                    else
                                      {printf(cstep3 barchr cstepc);}
                                };
                                print ""
                              }'