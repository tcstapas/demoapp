#!/bin/bash

# Define your function here
get_max_version () {
   declare -p version_array
   version_array[0]='00'
   version_array[1]='00'
   version_array[2]='00'
   MAX_MAJOR=0
   MAX_MINOR='00'
   MAX_HOTFIX='00'
   for sqlfile in `ls -R | grep .sql`
   do
     #echo $sqlfile
     IFS='__' read -ra parts <<< "$sqlfile"
     for part in "${parts[@]}"; do
        part1=$part
        break
     done

     IFS='.' read -ra versions <<< "$part1"
     vlen=${#versions[@]}

     #echo "Length = "$vlen
     if [[ $vlen != "5" ]]; then
       continue
     fi
     count=0
     for version in "${versions[@]}"; do
       ver=`echo $version | sed -e "s/V//g"`
       #echo $ver
       if [[ $count  == "0" ]]; then
         MAJOR=$ver
         #echo "MAJOR = "$MAJOR
       elif [[ $count  == "1" ]]; then
         MINOR=$ver
         #echo "MAJOR = "$MINOR
       elif [[ $count  == "2" ]]; then
         HOTFIX=$ver
         #echo "HOT FIX = "$HOTFIX
       fi
       count=$((count+1))
      done

      if [[ $MAX_MAJOR -lt $MAJOR ]]; then
        MAX_MAJOR=$MAJOR
      fi

      if [[ $MAX_MINOR -lt $MINOR ]]; then
        MAX_MINOR=$MINOR
      fi

      if [[ $MAX_HOTFIX -lt $HOTFIX ]]; then
        MAX_HOTFIX=$HOTFIX
      fi
   done
   version_array[0]=$MAX_MAJOR
   version_array[1]=`printf "%02d" $MAX_MINOR`
   version_array[2]=`printf "%02d" $MAX_HOTFIX`
}

cd release/source
declare -a version_array
version_array=(0 00 00)
get_max_version version_array

echo ${version_array[0]}
echo ${version_array[1]}
echo ${version_array[2]}

#echo "=============================="
#for version in "${version_array[@]}"
#do
#  echo $version
#done

cd -
