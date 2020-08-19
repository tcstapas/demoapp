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
FILE_NAME=$1
IFS=' ' read -ra FileList <<< "$FILE_NAME"
for file in "${FileList[@]}";
do
  echo "file "$file
  if [[ $file != *".sql"* ]]; then
    continue
  fi
  base_branch="develop"
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
    index=3
    objectName="table"
  elif [[ $SQL_FILE_NAME == *"view"* ]]; then
    index=4
    objectName="view"
  elif [[ $SQL_FILE_NAME == *"pipe"* ]]; then
    index=5
    objectName="pipe"
  fi

  if [[ "$file" == *"flyway"* ]]; then
    IFS=';' read -ra schemaList <<< "$SCHEMAS"
    for schema in $schemaList
    do
      if [[ "$file" == *"$schema"* ]]; then
        seq=0
        echo "Index = "$index
        if [[ $index == "3" ]]; then
          seq=`hschemaget $schema table`
          echo "seq = " $seq
          hput $schema table $seq
        elif [[  $index == "4" ]]; then
          seq=`hschemaget $schema view`
          hput $schema view $seq
        fi
        echo "Final seq = " $seq
        echo "It's a Flyway schema"
        echo "Current directory " $pwd
        cd release/$schema/$objectName
        filecount=`ls | wc -l`
        filecount=`echo $filecount | sed -e 's/^[[:space:]]*//'`
        echo "File Count="$filecount
        cd -
        if [[ "$filecount" == "0" ]]; then
          echo "File count is zero"
          if [[ "$base_branch" == "develop" ]]; then
            MAJOR=1
            MINOR=0
            HOTFIX=0
          elif [[ "$base_branch" == "release" ]]; then
            MAJOR=0
            MINOR=1
            HOTFIX=0
          elif [[ "$base_branch" == "hotfix" ]]; then
            MAJOR=0
            MINOR=0
            HOTFIX=1
          fi

          NEW_FILE_NAME=V$MAJOR.$MINOR.$HOTFIX.$index.1__$SQL_FILE_NAME
          echo "New File Name : " $NEW_FILE_NAME
          cp baseddl/$schema/$objectName/$SQL_FILE_NAME release/$schema/$objectName/$NEW_FILE_NAME
        else
          echo "Exiting file is there"
          MAX_MAJOR=0
          MAX_MINOR=0
          MAX_HOTFIX=0

          cd release/$schema/$objectName
          for sqlfile in `ls`
          do
            echo $sqlfile
            IFS='__' read -ra parts <<< "$sqlfile"
            for part in "${parts[@]}"; do
               part1=$part
               break
            done

            IFS='.' read -ra versions <<< "$part1"
            vlen=${#versions[@]}
            echo "Length = "$vlen
            count=0
            for version in "${versions[@]}"; do
              ver=`echo $version | sed -e "s/V//g"`
              echo $ver
              if [[ $count  == "0" ]]; then
                MAJOR=$ver
                echo "MAJOR = "$MAJOR
                if [[ "$base_branch" == "develop" ]]; then
                  MAJOR=$ver;
                fi
              elif [[ $count  == "1" ]]; then
                MINOR=$ver
                if [[ "$base_branch" == "release" ]]; then
                  MINOR=$ver;
                fi
              elif [[ $count  == "2" ]]; then
                HOTFIX=$ver
                if [[ "$base_branch" == "hotfix" ]]; then
                  HOTFIX=$ver;
                fi
              fi
              count=$((count+1))
            done

            if [[ $MAX_MAJOR < $MAJOR ]]; then
              MAX_MAJOR=$MAJOR
            fi

            if [[ $MAX_MINOR < $MINOR ]]; then
              MAX_MINOR=$MINOR
            fi

            if [[ $MAX_HOTFIX < $HOTFIX ]]; then
              MAX_HOTFIX=$HOTFIX
            fi
          done

          if [[ "$base_branch" == *"develop"* ]]; then
            MAX_MAJOR_HASH=`hschemarelget $schema MAX_MAJOR`
            if [[ ! -z $MAX_MAJOR_HASH ]]; then
              MAX_MAJOR=$((MAX_MAJOR_HASH))
            else
              MAX_MAJOR=$((MAX_MAJOR+1))
              hput $schema MAX_MAJOR $MAX_MAJOR
            fi
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

          echo "MAJOR = " $MAX_MAJOR " MAX_MINOR="$MAX_MINOR " MAX_HOTFIX = "$MAX_HOTFIX
          echo "Index = "$index " Seq "$seq " SQL_FILE_NAME = "$SQL_FILE_NAME
          NEW_FILE_NAME=V$MAX_MAJOR.$MAX_MINOR.$MAX_HOTFIX.$index.$seq"__"$SQL_FILE_NAME
          echo "NEW FILE NAME = " $NEW_FILE_NAME
          echo "Current Directory "$PWD
          echo "cp ../../../baseddl/$schema/$objectName/$SQL_FILE_NAME $NEW_FILE_NAME"
          cp ../../../baseddl/$schema/$objectName/$SQL_FILE_NAME $NEW_FILE_NAME
        fi
      fi
    done
  fi
done