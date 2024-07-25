#! /bin/bash


#!/bin/bash

for i in **.zig # or whatever other pattern...
do
  if ! grep -q Copyright $i
  then
    cat ./scripts/license-header.txt $i >$i.new && mv $i.new $i
  fi
done
