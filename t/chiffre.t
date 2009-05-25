use t::TestConfig;
use Data::Dumper;

plan tests => 1 * blocks;

filters {
    yaml => [config => 'dumper'],
#    perl => [strict => eval => 'dumper'],
};

sub config { 
    my $c = new Religion::Bible::Regex::Config(shift); 
    new Religion::Bible::Regex::Builder($c)->{chiffre};
}   

run_is yaml => 'perl';

__END__
=== chiffre is not set
--- yaml
---
--- perl
qr/(?-xism:\d{1,3}[abcdes]?)/
=== chiffre is set to the default ','
--- yaml
---
regex:
  chiffre: \d{1,3}[abcdes]?
--- perl
qr/(?-xism:\d{1,3}[abcdes]?)/
=== chiffre is set to something other than the default ','
--- yaml
---
regex:
  chiffre: \d{1,4}[abcdes]?
--- perl
qr/(?-xism:\d{1,4}[abcdes]?)/
