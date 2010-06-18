#!/bin/bash
# Religion-Bible-Regex-Builder  Religion-Bible-Regex-Config  Religion-Bible-Regex-Lexer  Religion-Bible-Regex-Reference
export ROOTDIR='../../'
perl -I$ROOTDIR/Religion-Bible-Regex-Config -I$ROOTDIR/Religion-Bible-Regex-Builder t/generate-test-report.pl >/var/www/test/testenv/Religion-Bible-Regex-Builder-tests.html
