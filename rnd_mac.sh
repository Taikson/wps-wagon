#!/bin/sh


SEQ="0 1 2"
RNS=""
for S in $SEQ;do
	RNS=$RNS":"$(head /dev/urandom | tr -dc "0123456789ABCDEF" | head -c2)

done

echo 00:60:2F$RNS
