#!/bin/bash

game=$1
if [[ $game = "" || $game = "standard" ]]; then
  game=standard
  executable=../standard/standard
else
  executable=../$game/$game
fi

if [[ ! -f $executable ]]; then
  echo "Please build the $game executable before running the rules snapshot tests.  Test failed."
  exit 1
fi

cp $executable ./$game
chmod +x ./$game

echo -n "Regenerating $game rules..."

cp ../$game/${game}_intro.html .
./$game genrules ${game}_intro.html ${game}.css ${game}.html &> engine-output.txt
if [[ $? != 0 ]]; then
  echo "executable crashed. -- Test failed."
  cat engine-output.txt
  rm -f ./engine-output.txt
  rm -f ${game}_intro.html
  rm -f ${game}.html
  rm -f ./${game}
  exit 1
fi

rm -f ./engine-output.txt

# Clean up the Last Change: timestamp line so that comparisons can work
sed -e 's/Last Change:.*$/Last Change: __STRIPPED_FOR_COMPARISON__/' ${game}.html > ${game}.html.strip

diff -ur rules/${game}.html ${game}.html.strip &> rules-difference.txt
if [[ $? != 0 ]]; then
  echo "output differed. -- Test failed."
  cat rules-difference.txt
  rm -f rules-difference.txt
  rm -f ${game}_intro.html
  rm -f ${game}.html
  rm -f ${game}.html.strip
  rm -f ./${game}
  exit 1
fi

echo "identical. -- Test succeeded."
rm -f rules-difference.txt
rm -f engine-output.txt
rm -f ${game}.html
rm -f ${game}_intro.html
rm -f ${game}.html.strip
rm -f ./$game
exit 0
