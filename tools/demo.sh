#!/bin/bash
# Checks the original log and the tampered copy against the contract.
tools/check_log.sh sample_logs/flight_001.csv
echo
tools/check_log.sh sample_logs/flight_001_tampered.csv
