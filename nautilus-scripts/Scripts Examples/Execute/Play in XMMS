#!/bin/sh
#
# Jani Soila 2001
# Public domain

# Gets arguments sorts them in alphabetical order
# and adds the list to xmms playlist.

# get arguments in array

i=0
for n ;
do
  a[$((i++))]=$n ;
done

# sort array

for (( i=0; $i<(${#a[@]}-1); i++ )) ;
do
  for (( j=i+1; $j<(${#a[@]}); j++ )) ;
  do
    if [[ ${a[$j]} < ${a[$i]} ]] ;
    then
      t=${a[$j]};
      a[$j]=${a[$i]};
      a[$i]=$t;
    fi
  done
done

# launch xmms with sorted list

xmms -e "${a[@]}"
