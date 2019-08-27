#! /bin/bash
cd /tmp/work
./opendsscmd "$1"
tar -czf result.tar.gz -C /tmp/OpenDSS .
