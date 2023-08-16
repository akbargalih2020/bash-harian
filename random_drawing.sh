#!/bin/bash
value=""
for v in {1..100} ; do
##if you want using cat file with multiple string just use $(cat [name_file])
	value+="$v,"
done

IFS="," read -ra values <<< "$value"
yr=${values[RANDOM % ${#values[@]}]}
echo "$yr"
