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
   for sqlfile in `ls -R`
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

hput() {
    eval "$1""$2"='$3'
}

hget() {
    eval echo '${'"$1$2"'#hash}'
}

hschemaget(){
  sequence=`hget $1 $2 $3`
  if [[ -z "$sequence" ]]; then
    sequence=1
  else
    sequence=$((sequence+1))
  fi
  eval echo $sequence
}

hschemarelget(){
  sequence=`hget $1 $2 $3`
  eval echo $sequence
}

#FILE_NAME="src/main/flyway/baseddl/source/table/Create_table_XXXX.sql src/main/flyway/baseddl/source/table/Create_table_YYYY.sql src/main/flyway/baseddl/source/view/Create_view_VVVV.sql"
FILE_NAME=$@
echo "FILE NAME "$FILE_NAME
IFS=' ' read -ra FileList <<< "$FILE_NAME"
FILE_LENGTH=${#Filelist[@]}
FILES_ADDED='0'
base_branch=FileList[$FILE_LENGTH-1]
for file in "${FileList[@]}";
do
  echo "file "$file
  if [[ $file != *".sql"* ]]; then
    continue
  fi
  SCHEMAS="source;operation"
  IFS='/' read -ra directorylist <<< "$file"
  echo $directorylist
  len=${#directorylist[@]}
  echo "length = "$len
  echo ${directorylist[$len-2]}
  SQL_FILE_NAME=${directorylist[$len-1]}
  objectName=''
  echo "SQL FILE NAME " $SQL_FILE_NAME
  if [[ $SQL_FILE_NAME == *"table"* ]]; then
    index='03'
    objectName="table"
  elif [[ $SQL_FILE_NAME == *"view"* ]]; then
    index='04'
    objectName="view"
  elif [[ $SQL_FILE_NAME == *"pipe"* ]]; then
    index='05'
    objectName="pipe"
  fi

  if [[ "$file" == *"baseddl"* ]]; then
    IFS=';' read -ra schemaList <<< "$SCHEMAS"
    for schema in "${schemaList[@]}"
    do
      echo $schema
      if [[ "$file" == *"$schema"* ]]; then
        seq=0
        echo "Index = "$index
        if [[ $index == "03" ]]; then
          seq=`hschemaget $schema table`
          echo "seq = " $seq
          hput $schema table $seq
        elif [[  $index == "04" ]]; then
          seq=`hschemaget $schema view`
          hput $schema view $seq
        fi
        echo "Final seq = " $seq
        echo "It's a Flyway schema"
        echo "Current directory " $pwd
        mkdir -p release/$schema/$objectName
        cd release/$schema/$objectName
        filecount=`ls | wc -l`
        filecount=`echo $filecount | sed -e 's/^[[:space:]]*//'`
        echo "File Count="$filecount
        cd -
        if [[ "$filecount" == "0" ]]; then
          echo "File count is zero"
          if [[ "$base_branch" == "develop" ]]; then
            MAJOR=1
            MINOR='00'
            HOTFIX='00'
          elif [[ "$base_branch" == "release" ]]; then
            MAJOR=0
            MINOR='01'
            HOTFIX='00'
          elif [[ "$base_branch" == "hotfix" ]]; then
            MAJOR=0
            MINOR='00'
            HOTFIX='01'
          fi
          NEW_FILE_NAME=V$MAJOR.$MINOR.$HOTFIX.$index.1__$SQL_FILE_NAME
          echo "New File Name : " $NEW_FILE_NAME
          cp baseddl/$schema/$objectName/$SQL_FILE_NAME release/$schema/$objectName/$NEW_FILE_NAME
        else
          echo "Exiting file is there"
          cd release/$schema
          echo $PWD
          declare -a version_array
          version_array=(0 00 00)
          get_max_version version_array
          MAX_MAJOR=${version_array[0]}
          MAX_MINOR=${version_array[1]}
          MAX_HOTFIX=${version_array[2]}

          echo "MAX MAJOR "$MAX_MAJOR

          if [[ "$base_branch" == *"develop"* ]]; then
            MAX_MAJOR_HASH=`hschemarelget $schema MAX_MAJOR`
            echo "SCHEMA "$schema
            echo "MAX MAJOR ... "$MAX_MAJOR
            if [[ ! -z $MAX_MAJOR_HASH ]]; then
              MAX_MAJOR=$((MAX_MAJOR_HASH))
            else
              MAX_MAJOR=$((MAX_MAJOR+1))
              hput $schema MAX_MAJOR $MAX_MAJOR
            fi
            MAX_MINOR='00'
            MAX_HOTFIX='00'
          fi

          if [[ "$base_branch" == *"release"* ]]; then
            MAX_MINOR_HASH=`hschemarelget $schema MAX_MINOR`
            if [[ ! -z $MAX_MINOR_HASH ]]; then
              MAX_MINOR=$((MAX_MINOR_HASH))
            else
              MAX_MINOR=$((MAX_MINOR+1))
              hput $schema MAX_MINOR $MAX_MINOR
            fi
          fi

          if [[ "$base_branch" == *"hotfix"* ]]; then
            MAX_HOTFIX_HASH=`hschemarelget $schema MAX_HOTFIX`
            if [[ ! -z $MAX_HOTFIX_HASH ]]; then
              MAX_HOTFIX=$((MAX_HOTFIX_HASH))
            else
              MAX_HOTFIX=$((MAX_HOTFIX+1))
              hput $schema MAX_HOTFIX $MAX_HOTFIX
            fi
          fi

          echo "MAX MAJOR = " $MAX_MAJOR " MAX_MINOR="$MAX_MINOR " MAX_HOTFIX = "$MAX_HOTFIX
          echo "Index = "$index " Seq "$seq " SQL_FILE_NAME = "$SQL_FILE_NAME
          NEW_FILE_NAME=V$MAX_MAJOR.$MAX_MINOR.$MAX_HOTFIX.$index.$seq"__"$SQL_FILE_NAME
          echo "NEW FILE NAME = " $NEW_FILE_NAME
          cd $objectName
          echo "Current Directory "$PWD
          echo "cp ../../../baseddl/$schema/$objectName/$SQL_FILE_NAME $NEW_FILE_NAME"
          cp ../../../baseddl/$schema/$objectName/$SQL_FILE_NAME $NEW_FILE_NAME
          cd ../../..
          FILES_ADDED='1'
        fi
      fi
    done
  fi
done

if [[ "$FILES_ADDED" == "1" ]]; then
  git add .
  git commit -m "Added Flyway compatible files"
  git push
fi