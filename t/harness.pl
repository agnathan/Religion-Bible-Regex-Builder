use TAP::Harness;
use TAP::Formatter::HTML;

my @tests = glob( 't/*.t' );
# my $harness = TAP::Harness->new({ formatter_class => 'TAP::Formatter::HTML',
#                                   merge => 1 });
# prints HTML to STDOUT by default

# or if you really don't want STDERR merged in:
my $harness = TAP::Harness->new({ formatter_class => 'TAP::Formatter::HTML', verbosity => -2 });

# to use a custom formatter:
# my $fmt = TAP::Formatter::HTML->new;
# $fmt->inline_js( '$(div.summary).hide()' );

 # to use a custom formatter:
 my $fmt = TAP::Formatter::HTML->new;
 $fmt->css_uris(['reports/default_page.css','reports/default_report.css'] )
     ->js_uris(['reports/jquery-1.4.2.min.js', 'reports/jquery.tablesorter-2.0.3.min.js','reports/default_report.js'])
     ->inline_js( '$(div.summary).hide()' );

# my $harness = TAP::Harness->new({ formatter => $fmt, merge => 1 });
# my $harness = TAP::Harness->new({ formatter => $fmt, verbosity => -2 });
# my $harness = TAP::Harness->new({ verbosity => -2 });

# to output HTML to a file[handle]:
$harness->runtests( @tests );
# $fmt->output_fh( $fh );
$fmt->output_file( 'foo.html' );

# you can use your own customized templates too:
# $fmt->template('custom.tt2')
#    ->template_processor( Template->new )
#    ->force_inline_css(0)
#    ->force_inline_js(0);
