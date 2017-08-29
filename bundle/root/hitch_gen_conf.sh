#!/bin/bash

CF="$1"
CL="$2"

if [ -z "$CF" -o -z "$CL" ]; then
	echo "Usage: $0 CONFIGFILE CERT_LOCATION"
	exit 1
fi

if ! grep -q "^{{PEMFILES}}" "$CF"; then
	exit 0
fi

cp "$CF" "$CF.orig"

sed '/^{{PEMFILES}}/,$d' "$CF.orig" > "$CF"

ls -1 "$CL" | while read line; do
	echo "pem-file = \"`readlink -f $line`\"" >> "$CF"
done

sed '1,/^{{PEMFILES}}/d' "$CF.orig" >> "$CF"

rm "$CF.orig"
