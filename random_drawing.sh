#!/bin/bash
value=""
for v in {1..100} ; do
	value+="$v,"
done

IFS="," read -ra values <<< "$value"
yr=${values[RANDOM % ${#values[@]}]}
echo "$yr"
