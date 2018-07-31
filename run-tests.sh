#!/bin/bash
# exit when any command fails
set -e

ANTLR_JAR="antlr4.jar"

# allow input from stdin to test alternatives.
GRAMMAR=$1
START_RULE=$2
TEST_FILE=$3

if [ ! -n "$GRAMMAR" ]; then
  GRAMMAR="Vyper"  
fi

if [ ! -n "$START_RULE" ]; then
  START_RULE="sourceUnit"
fi

TEST_FILES_DIR="./samples"
ERROR_PATTERN="mismatched|extraneous|error|viable|'no method'"

RED="\033[0;31m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
NC='\033[0m' # No Color



if [ ! -e "$ANTLR_JAR" ]; then
  curl http://www.antlr.org/download/antlr-4.7-complete.jar -o "$ANTLR_JAR"
fi

mkdir -p target/

# Generates some build files; *.tokens and *.java in /src/ dir
java -jar $ANTLR_JAR $GRAMMAR.g4 -o src/

# Generates a lot of files with names like `SolidityParser$PragmaValueContext.class` in /target dir
javac -classpath $ANTLR_JAR src/*.java -d target/

echo "Test file: $TEST_FILE"
if [ -n "$TEST_FILE" ]; then
  echo -e "${BLUE}Grammar: $GRAMMAR; Start Rule: $START_RULE; Test file: $TEST_FILE${NC}"
  java -classpath "$ANTLR_JAR":target/ org.antlr.v4.gui.TestRig "$GRAMMAR" "$START_RULE" < $TEST_FILE 2>&1 #|
else
  # Try parsing each file in samples/
  echo -e "${BLUE}Grammar: $GRAMMAR; Start Rule: $START_RULE; ${NC}"
  for TEST_FILE in ${TEST_FILES_DIR}/*.vy; do
    echo -e "${BLUE}Testing $TEST_FILE${NC}"
    java -classpath "$ANTLR_JAR":target/ org.antlr.v4.gui.TestRig "$GRAMMAR" "$START_RULE" < $TEST_FILE 2>&1 #|
      # Only print the first error
   #   grep -m 1 -E "$ERROR_PATTERN" && echo -e "${RED}TESTS FAIL!${NC}" || echo -e "$TEST_FILE: TESTS PASS!"
  done
fi

# To run the viz: 
# 
# java -cp antlr4.jar:target org.antlr.v4.gui.TestRig "Python3" "file_input" -gui < python_test.py
