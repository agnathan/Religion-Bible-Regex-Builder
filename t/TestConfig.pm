package t::TestConfig;
use Test::Base 0.51 -Base;

use lib "../Religion-Bible-Regex-Config/lib";
use lib "../Religion-Bible-Regex-Builder/lib";

use Religion::Bible::Regex::Config;
use Religion::Bible::Regex::Builder;

use YAML::Loader;
use utf8;
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");

#delimiters('===', '+++');

$^W = 0;

