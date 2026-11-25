#!/bin/sh
http=$(grep -rl "package:http" lib | grep -v -e core/api -e _repository.dart || true)
material=$(grep -rl "package:flutter/material" lib | grep -e _model.dart -e _repository.dart -e core/api || true)
status=0
if [ -n "$http" ]; then
  printf '%s\n' "$http"
  status=1
fi
if [ -n "$material" ]; then
  printf '%s\n' "$material"
  status=1
fi
exit $status
