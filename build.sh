#!/bin/bash
# exit when any command fails
set -e

ANTLR_JAR="antlr4.jar"
GRAMMAR=$1

mkdir -p src/
mkdir -p target/


if [ ! -e "$ANTLR_JAR" ]; then
  curl http://www.antlr.org/download/antlr-4.7-complete.jar -o "$ANTLR_JAR"
fi

# Default to Vyper
if [ ! -n "$GRAMMAR" ]; then
  GRAMMAR="Vyper"  
fi

# Option to build all grammar files
if [ $GRAMMAR == "all" ]; then
  for GRAMMAR_FILE in *.g4; do
    echo "Building ${GRAMMAR_FILE}"
    java -jar $ANTLR_JAR $GRAMMAR_FILE -o src/
    javac -classpath $ANTLR_JAR src/*.java -d target/
  done
else
  # build specified grammar
  GRAMMAR_FILE="${GRAMMAR}.g4"
  echo "Building ${GRAMMAR_FILE}"
  java -jar $ANTLR_JAR $GRAMMAR_FILE -o src/
  javac -classpath $ANTLR_JAR src/*.java -d target/
fi
echo "Done"