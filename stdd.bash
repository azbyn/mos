#!/bin/bash


for f in $(find srcs -name \*.d); do
    echo $f
    cat $f | perl -pe 's/std(\W)/stdd$1/g' > "$f._"
    mv "$f._" $f
    cat $f | perl -pe 's/unistdd(\W)/unistd$1/g' > "$f._"
    mv "$f._" $f
done
