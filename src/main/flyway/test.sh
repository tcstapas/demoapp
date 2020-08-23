SCHEMAS="source;operation"
IFS=';' read -ra schemaList <<< "$SCHEMAS"
for schema in "${schemaList[@]}"
do
  echo $schema
done