#!/bin/bash
shopt -s nullglob
mkdir -p rollup/{1,5}
for f in results/*.csv
do
	newfile="${f##*/}"
	echo "Rolling up! - $f -> $newfile"
    ruby rollup.rb ${f} 1 > "./rollup/1/${newfile}"
	ruby rollup.rb ${f} 5 > "./rollup/5/${newfile}"
done
