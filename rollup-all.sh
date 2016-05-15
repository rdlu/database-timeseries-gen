#!/bin/bash
OUTPUT=(10 15 30 60)

shopt -s nullglob
rm -rf rollup/
for i in ${OUTPUT[@]}
do
	mkdir -p rollup/{${i},${i}d}
	for f in results/*.csv
	do
		newfile="${f##*/}"
		echo "Rolling up! - $f -> $newfile"
		ruby rollup.rb ${f} ${i} > "./rollup/${i}d/${newfile}"
		sed 's/\./,/g' "./rollup/${i}d/${newfile}" > "./rollup/${i}/${newfile}"
	done
done