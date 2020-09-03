hinit() {
    rm -f /tmp/hashmap.$2
}

hput() {
    echo "$2  $3 = $4"
    echo "$3 $4" >> /tmp/hashmap.$2
}

hget() {
    echo "$2  $3 "
    grep "^$3 " /tmp/hashmap.$2 | awk '{ print $3 };'
}
