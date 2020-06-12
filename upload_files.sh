#!/bin/bash

set -euo pipefail

count_bucket=$1
source=$2
dest=$3
temp=$(mktemp -d)

total_files=$(find $source -type f|wc -l)
let count_per_bucket=$(( ($total_files + $count_bucket - 1) / $count_bucket  ))
echo "Number of bucket: $count_bucket and number of files/bucket: $count_per_bucket"

# Create bucket folders
for i in $(seq 1 $count_bucket)
do
    mkdir -p $temp/bucket$i
done

# Move files to buckets
counter=0
bucket=1

for file in $(find $source -type f)
do
    if [ $counter -lt $count_per_bucket ]
    then
	cp "$file" "$temp/bucket$bucket/"
	let counter=$(( $counter + 1 ))
    else
	let bucket=$(( $bucket + 1 ))
	cp "$file" "$temp/bucket$bucket/"
	counter=1
    fi
done

# Sync files to dest
echo -n "Sync files to destination $dest..."
rsync -az $temp/* $dest
echo "done."

# clean up the temporary folder
rm -rf $temp
