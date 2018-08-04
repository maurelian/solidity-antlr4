#!/bin/bash
# exit when any command fails
set -e

ANTLR_JAR="antlr4.jar"
GRAMMAR=$1
START_RULE=$2
TEST_FILE=$3

java -cp antlr4.jar:target org.antlr.v4.gui.TestRig "$1" "$2" -gui < "./$3"
