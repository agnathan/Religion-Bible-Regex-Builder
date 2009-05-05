package Religion::Bible::Regex::Builder;

use warnings;
use strict;
use Carp;

use version; our $VERSION = qv('0.0.3');

# Input files are assumed to be in the UTF-8 strict character encoding.
use utf8;
binmode(STDOUT, ":utf8");

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

require Exporter;
our @ISA = qw(Exporter);
our %EXPORT_TAGS = ( 'all' => [ qw( ) ] );
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw(

);

sub new {
    my $class = shift;
    my $config = shift;
    my $self = {};
    bless $self, $class;

    # Get the Configurations for building these regular expressions
    my %bookconfig = $self->_process_config($config);

    #################################################################################### 
    #	Définitions par défaut des expressions régulières avec références bibliques
    #  
    # 	La fonction '_set_regex' a trois paramètres.
    #		1. Un nom unique pour cette expression régulière
    #		2. Une experssion régulière
    #		3. Si la paramètre deux est 'undef', une experssion régulière comme defaut 
    #################################################################################### 
    
    my $spaces = qr/([\s ]*)/;

    #################################################################################### 
    #	Définitions des chiffres
    #################################################################################### 
    # chapitre : c'est un nombre qui indique un chapitre
    my $chapitre = qr/\d{1,3}/;
    $self->_set_regex(	'chapitre', 
			$bookconfig{'chapitre'}, 
            $chapitre
		    );

    # verset : c'est un nombre qui indique un verset
    my $verset = qr/\d{1,3}[abcdes]?/;
    $self->_set_regex(	'verset', 
			$bookconfig{'verset'}, 
			$verset
		    );

    # chiffre : c'est un nombre qui indique un chapitre ou verset 
    my $chiffre = qr/\d{1,3}[abcdes]?/;
    $self->_set_regex(	'chiffre', 
			$bookconfig{'chiffre'}, 
			$chiffre
		    );


    #################################################################################### 
    # Définitions de la ponctuation	
    #################################################################################### 
    # cv_separateur : vous pouvez trouver ce entre un chapitre et un verset
    my $cv_separateur = qr/(?::|\.)/;
    $self->_set_regex(	'cv_separateur', 
			$bookconfig{'cv_separateur'}, 
			$cv_separateur	
		    );

    # separateur : cette sépare deux références bibliques
    my $separateur = qr/\bet\b/;
    $self->_set_regex(	'separateur', 
			$bookconfig{'separateur'}, 
			$separateur	
		    );

    # cl_separateur : cette sépare deux références bibliques et que le deuxième référence est un référence d'un chaptire
    my $cl_separateur = qr/;/;
    $self->_set_regex(	'cl_separateur', 
			$bookconfig{'cl_separateur'}, 
			$cl_separateur	
		    );

    # vl_separateur : cette sépare deux références bibliques et que le deuxième référence est un référence d'un verset
    my $vl_separateur = qr/,/;
    $self->_set_regex(	'vl_separateur', 
			$bookconfig{'vl_separateur'}, 
			$vl_separateur		
		    );

    my $intervale = qr/(?:-|–|−)/;
    # tiret : ce correspond à tous les types de tiret
    $self->_set_regex(	'intervale', 
			$bookconfig{'intervale'}, 
			$intervale	
		    );
    # reference_separateurs : ce correspond à tous les types de separateur entre références biblque 
    my $cl_ou_vl_separateur = qr/(?:$self->{cl_separateur}|$self->{vl_separateur}|$self->{separateur})/;
    $self->_set_regex(	'cl_ou_vl_separateurs', 
			$bookconfig{'cl_ou_vl_separateurs'}, 
			$cl_ou_vl_separateur	
		    );


    #################################################################################### 
    # Définitions de les expressions avec intervales 
    #################################################################################### 

    my $intervale_chiffre = qr/
        # Intervale Verset, Ex '-4', '-45'
        $spaces     # Spaces
        $self->{'intervale'} # Interval
        $spaces     # Spaces
        $self->{'chiffre'} # Chiffre
    /x;

    # intervale_chiffre : deux chapitre avec un tiret entre
    # Par exemple: '-2', '–9', ou ' - 4'
    $self->_set_regex(	'intervale_chiffre', 
			$bookconfig{'intervale_chiffre'},  
		    $intervale_chiffre	
		    );

    my $cv_separateur_chiffre = qr/
        # CV Separator Verset
        $spaces# Spaces
        $self->{'cv_separateur'} # CV Separator
        $spaces# Spaces
        $self->{'chiffre'}
    /x;

    # cv_separateur_chiffre : deux chapitre avec un tiret entre
    # Par exemple: ':2', '.9', ou ' : 4'
    $self->_set_regex(	'cv_separateur_chiffre', 
			$bookconfig{'cv_separateur_chiffre'}, 
		    $cv_separateur_chiffre	
		    );

    #################################################################################### 
    # Définitions de les references numiques 
    #################################################################################### 

    #######################################################################################################
    # Les mots donne contexte aux référence biblique
    # Par Exemple: 
    #   chapitre_mots: 'voir la chapitre'
    #   texte: voir la chapitre 9
    # 
    #   Avec cette texte 'voir la chapitre' comme chapitre_mots le 9 peu être indentifié comme un chapitre
    #######################################################################################################
   
    # reference_contexte_mots_avant : les mots qui indique que le prochain référence est un chapitre référence
    my $reference_mots = qr/(?:dans|voir aussi)/;
    $self->_set_regex(	'reference_mots', 
			$bookconfig{'reference_mots'}, 
            $reference_mots			
    );

    # chapitre_contexte_mots_avant : les mots qui indique que le prochain référence est un chapitre référence
    my $chapitre_mots = qr/(?:dans le chapitre)/;
    $self->_set_regex(	'chapitre_mots', 
			$bookconfig{'chapitre_mots'}, 
            $chapitre_mots			
    );

    # verset_contexte_mots_avant : les mots qui indique que le prochain référence est un verset référence
    my $verset_mots = qr/(?:vv?\.)/;
    $self->_set_regex(	'verset_mots', 
			$bookconfig{'verset_mots'},  
            $verset_mots
    );

    # voir_contexte_mots_avant : les mots qui indique que le prochain référence est un verset référence
    my $voir_mots = qr/(?:voir)/;
    $self->_set_regex(	'voir_mots', 
			$bookconfig{'voir_mots'},  
            $voir_mots
    );


    #################################################################################### 
    # Définitions de les expressions avec livres 
    #################################################################################### 

    # livres_numerique : Ceci est une liste de tous les livres qui commencent par un chiffre 
    my $livres_numerique = qr/
        Samuel|S|Rois|R|Chroniques|Ch|Corinthiens|Co|Thessaloniciens|Th|Timothée|Ti|Pierre|P|Jean|Jn|Esras|Es|Maccabees|Ma|Psalm|Ps
    /x;

    $self->_set_regex(	'livres_numerique', 
			$bookconfig{'livres_numerique'}, 
            $livres_numerique
    );

    my $livres_numerique_protect = "";
    if (defined($self->{'livres_numerique'})) {
        $livres_numerique_protect = qr/(?!(?:[\s ]*(?:$livres_numerique)))/;
    }
    $self->_set_regex(   'livres_numerique_protect',
            $bookconfig{'livres_numerique_protect'},
            $livres_numerique_protect
    );

    
    my $livres = qr/
        Genèse|Genese|Exode|Lévitique|Levitique|Nombres|Deutéronome|Deuteronome|Josué|Josue|Juges|Ruth|1[\s ]*Samuel|2[\s ]*Samuel|1[\s ]*Rois|2[\s ]*Rois|1[\s ]*Chroniques|2[\s ]*Chroniques|Esdras|Néhémie|Nehemie|Esther|Job|Psaume|Psaumes|Proverbes|Ecclésiaste|Ecclesiaste|Cantique[\s ]*des[\s ]*Cantiqu|Ésaïe|Esaie|Jérémie|Jeremie|Lamentations|Ézéchiel|Ezechiel|Daniel|Osée|Osee|Joël|Joel|Amos|Abdias|Jonas|Michée|Michee|Nahum|Habacuc|Sophonie|Aggée|Aggee|Zacharie|Malachie|Matthieu|Marc|Luc|Jean|Actes|Romains|1[\s ]*Corinthiens|2[\s ]*Corinthiens|Galates|Éphésiens|Ephesiens|Philippiens|Colossiens|1[\s ]*Thessaloniciens|2[\s ]*Thessaloniciens|1[\s ]*Timothée|1[\s ]*Timothee|2[\s ]*Timothée|2[\s ]*Timothee|Tite|Philémon|Philemon|Hébreux|Hebreux|Jacques|1[\s ]*Pierre|2[\s ]*Pierre|1[\s ]*Jean|2[\s ]*Jean|3[\s ]*Jean|Jude|Apocalypse
/x;

    # livres : le nom complet de tous les livres, avec et sans accents
    $self->_set_regex(	'livres', 
			$bookconfig{'livres'}, 
            $livres
    );

    my $abbreviations = qr/
        Ge|Ex|Lé|No|De|Dt|Jos|Jug|Jg|Ru|1[\s ]*S|2[\s ]*S|1[\s ]*R|2[\s ]*R|1[\s ]*Ch|2[\s ]*Ch|Esd|Né|Est|Job|Ps|Ps|Pr|Ec|Ca|Esa|Esa|És|Jér|Jé|La|Ez|Éz|Da|Os|Joe|Joë|Am|Ab|Jon|Mic|Mi|Na|Ha|Sop|So|Ag|Za|Mal|Ma|Mt|Mc|Mr|Lu|Jn|Ac|Ro|1[\s ]*Co|2[\s ]*Co|Ga|Ep|Ép|Ph|Col|1[\s ]*Th|2[\s ]*Th|1[\s ]*Ti|2[\s ]*Ti|Ti|Tit|Phm|Hé|Ja|1[\s ]*Pi|2[\s ]*Pi|1[\s ]*Jn|2[\s ]*Jn|3[\s ]*Jn|Jude|Jud|Ap|1[\s ]*Es|2[\s ]*Es|Tob|Jdt|Est|Sag|Sir|Bar|Aza|Sus|Bel|Man|1[\s ]*Ma|2[\s ]*Ma|3[\s ]*Ma|4[\s ]*Ma|2[\s ]*Ps
/x;
    
    # abbreviations : le nom complet de tous les abbreviations, avec et sans accents
    $self->_set_regex(	'abbreviations', 
			$bookconfig{'abbreviations'}, 
            $abbreviations
    );

    # livres_et_abbreviations : la liste de tous les livres et les abréviations
    my $livres_et_abbreviations = qr/(?:$self->{'livres'}|$self->{'abbreviations'})/;
    $self->_set_regex(	'livres_et_abbreviations', 
			$bookconfig{'livres_et_abbreviations'}, 
            $livres_et_abbreviations
		    );

    # contexte_mots : Tous les mots qui viennent avant une référence biblique. Des mots différents peut 
    #                fournir des contextes différents. Par exemple, 'voir le chapitre' fournit une 
    #                contexte et le chapitre 'Matthew' fournit une référence explicite contexte
    my $contexte_mots = qr/
      (?: # Contexte Mots
        $self->{'livres_et_abbreviations'}  # Livres et abbreviations
        |
        $self->{'chapitre_mots'}   # Chapitre mots
        |
        $self->{'verset_mots'}  # Verset mots
        |
        $self->{'reference_mots'} # Voir mots
      )
    /x;

    $self->_set_regex(	'contexte_mots', 
			$bookconfig{'contexte_mots'}, 
            $contexte_mots
		    );

    #livre2abre : une table de changement du livre à l'abréviation
    $self->_set_hash(	'book2key', 
			$bookconfig{'book2key'}, 
            {}
    );
    
    #abre2livres : une table de changement du abréviation à livre
    $self->_set_hash(	'abbr2key', 
			$bookconfig{'abbr2key'}, 
			{}
		    );

    #livre2abre : une table de changement du livre à l'abréviation
    $self->_set_hash(	'key2book', 
			$bookconfig{'key2book'}, 
            {}
    );
    
    #abre2livres : une table de changement du abréviation à livre
    $self->_set_hash(	'key2abbr', 
			$bookconfig{'key2abbr'}, 
			{}
		    );


    # livres_avec_un_chapitre :  la liste de tous les livres avec un seul chapitre
    my $livres_avec_un_chapitre = qr/Ab|Abdias|2Jn|2Jean|Phm|Philemon|Philémon|Jud|Jude|3Jn|3Jean/;
    $self->_set_regex(	'livres_avec_un_chapitre', 
			$bookconfig{'livres_avec_un_chapitre'}, 
            $livres_avec_un_chapitre
		    );

    #######################################################################################################
    # full_reference_protection : Il s'agit d'une expression régulière complexe. Ne pas changer, sauf si vous savez ce que vous faites.

    my $cv_list = qr/
        $self->{'chiffre'} # LC, '22'
        $self->{'livres_numerique_protect'}
        (?: # Choose between CV and Interval
          (?:
            (?:# LCC: Ge 22-24
              $self->{'intervale_chiffre'}
              (?:# LCCV: Ge 22-23:46
                $self->{'cv_separateur_chiffre'}
                (?: # LCCVV:Ge 22-23:46-49
                    $self->{'intervale_chiffre'}
                )?
              )?
            )
          |
            (?:# LCV:Ge 1:1
              $self->{'cv_separateur_chiffre'}
              (?: # LCVV:Ge 22-23:46-49
                $self->{'intervale_chiffre'}
                (?:# LCVCV:Ge 22:23-46:49
                  $self->{'cv_separateur_chiffre'}
                )?
              )?
            )
          )
        )?
    /x; 

    # cv_list : Combines LC, LCC, LCCV, LCCVV and LCV, LCVV, LCVCV
    $self->_set_regex(	'cv_list', 
			$bookconfig{'cv_list'},
	        $cv_list	
		    );


    # reference_biblique_list : Cette expression régulière correspond à une liste de références bibliques 
    #				ex. '1 Ti 1.19 ; Ge 1:1, 2:16-18' or '1 Ti 1.19 ; 2Ti 2:16-18'
    my $reference_biblique = qr/
    (?:
      $self->{'contexte_mots'}
      $spaces # Spaces
      (?: # Chapitre Verset liste
        $self->{'cv_list'}
      )
      (?: # Reference List
        $spaces # Spaces
        $self->{'cl_ou_vl_separateurs'}
        $spaces # Spaces
        $self->{'livres_numerique_protect'}
        (?: # Chapitre Verset liste
          $self->{'cv_list'}
        )
      )*
    )
    /x;

    $self->_set_regex(	'reference_biblique', 
			$bookconfig{'reference_biblique'}, 
		    $reference_biblique
		    );

    # reference_biblique_list : Cette expression régulière correspond à une liste de références bibliques 
    #				ex. '1 Ti 1.19 ; Ge 1:1, 2:16-18' or '1 Ti 1.19 ; 2Ti 2:16-18'
    my $reference_biblique_list = qr/
    (?:
      $self->{'contexte_mots'}
      $spaces # Spaces
      (?: # Chapitre Verset liste
        $self->{'cv_list'}
      )
      (?: # Reference List
        $spaces # Spaces
        $self->{'cl_ou_vl_separateurs'}
        $spaces # Spaces
        (?:$self->{'contexte_mots'})?
        $spaces # Spaces
        (?: # Chapitre Verset liste
          $self->{'cv_list'}
        )
      )*
    )
    /x;

    $self->_set_regex(	'reference_biblique_list', 
			$bookconfig{'reference_biblique_list'}, 
		    $reference_biblique_list
		    );

    return $self;
}


################################################################################
# Helper functions for internal use
################################################################################
sub _set_regex {
    my ($self, $key, $regex, $default_regex) = @_;
	if (defined($regex)) {
        my $result = qr/$regex/;	        # Evaluate that line
        if ($@) {                       	# Check for compile or run-time errors.
            croak "Invalid regex:\n $regex";
        } else {
            $self->{$key} = $result;
        }
    } elsif (defined($regex) && $regex eq ''){
       return; 
	} else {
		$self->{$key} = $default_regex; 
	}
}

sub _set_hash {
    my ($self, $key, $hash, $default_hash) = @_;
    if (defined($hash)) {
            $self->{$key} = $hash;
    } else {
        $self->{$key} = $default_hash;
    }

}

################################################################################
# les fonctions qui se préoccupe de la configuration
################################################################################
sub _process_config {
    my $self = shift;
    my $config = shift;
    my %retval;

    while ( my ($key, $value) = each(%{$config->{config}{regex}}) ) {
        if ($key =~ m/definitions/) {
            $self->_init_data_structures($value, $config, \%retval);
        } elsif ($value =~ m/^(?:fichier|file):/) {
            $retval{$key} = $self->_build_regexes_from_file($value);
        } elsif (defined(ref $value) && ref $value eq "HASH") {
            $retval{$key} = $self->_process_config($value);
        } else {
            $retval{$key} = $value;    
        }
    }
    return %retval;
}

sub _build_regexes_from_file {
    my $self = shift;
    my $value = shift;
    my @list;

    # Enleve le phrase 'fichier:' ou 'file:'
    $value =~ s/^(?:fichier|file)://g;
    
    open(*LIST, "<:encoding(UTF-8)", $value) or croak "Couldn't open \'$value\' for reading: $!\n";
    while(<LIST>) {
        chomp;                  # no newline
        s/[^\\]#.*//;           # no comments si il y a un '\' devant le '#' il n'est pas un commentarie
        s/^\s+//;               # no leading white
        s/\s+$//;               # no trailing white
        next unless length;     # anything left?
        push @list, $_;
    }
    close (LIST);
    return "(?:" . join_regex(\@list) . ")";
}

sub _join_regex {
	my $array_ref = shift;
	if (defined($array_ref)) {
		return join("|", @{$array_ref});
	} else { 
		return;
	}
}


################################################################################
# _init_data_structures
# 
# Creates the following mappings:
#   An array of all match book names (book names to search for in a document)
#   An array of all match abbreviation (abbreviations to search for in a document)
#   An array of all book names that begin with a number
#   A hash mapping from match book name to the primary key
#   A hash mapping from match abbreviation to the primary key
#
#   The primary key is the number which starts the entry in the abbr config file
#   For example with this configuration the primary key is '1'
#    1: 
#      Match:
#        Book: ['Genèse', 'Genese']
#        Abbreviation: ['Ge']
#      Normalized: 
#        Book: Genèse
#        Abbreviation: Ge
#
################################################################################
sub _init_data_structures {
    my $self = shift;
    my $path_to_config_file = shift;
    my $config = shift;
    my $retval = shift;

    my $bookconfig = $config->{bookconfig};
    my $regex;
    my (@livres, @livres_numerique, @abbreviations);    # Array for all match books and another for match books starting with a number
    my (%book2key, %abbr2key, %key2abbr, %key2book);    # Mappings between match books and abbreviations and the primary key
    
    # Loop through each number and gather the books
    while( my ($key, $value) = each %{$bookconfig} ) {
        # Loop through 
        foreach my $livre (@{$value->{Match}{Book}}) {
            push @livres, $livre;
            push @livres_numerique, $livre if ($livre =~ m/^\d+/);
            $book2key{$livre} = $key;
        }
        # Loop through 
        foreach my $abbreviation (@{$value->{Match}{Abbreviation}}) {
            push @abbreviations, $abbreviation;
            $abbr2key{$abbreviation} = $key;
        }
        $key2abbr{$key} = $value->{Normalized}{Abbreviation};
        $key2book{$key} = $value->{Normalized}{Book};
    }
     
    $retval->{'livres'} = join_regex(\@livres);
    $retval->{'abbreviations'} = join_regex(\@abbreviations);
    $retval->{'livres_numerique'} = join_regex(\@livres_numerique);

    $retval->{'livres_array'} = \@livres;
    $retval->{'abbreviations_array'} = \@abbreviations;
    $retval->{'livres_numerique_array'} = \@livres_numerique;

    $retval->{'book2key'}   = \%book2key;
    $retval->{'abbr2key'}   = \%abbr2key;
    $retval->{'key2book'}   = \%key2book;
    $retval->{'key2abbr'}   = \%key2abbr;
    $retval->{'bookconfig'} = $bookconfig;
}


1; # Magic true value required at end of module
__END__

=head1 NAME

Religion::Bible::Regex::Builder - builds regular expressions that match Bible References


=head1 VERSION

This document describes Religion::Bible::Regex::Builder version 0.9.1


=head1 SYNOPSIS

use Religion::Bible::Regex::Builder;

use warnings;

use Religion::Bible::Regex::Config;
use Religion::Bible::Regex::Builder;

my $configfile = 'config.yml';

my $c = new Religion::Bible::Regex::Config($configfile);
my $r = new Religion::Bible::Regex::Builder($c);
my $text = "Ge 1:1, Mt 6:33, see page 4:5 and Jn 3:16";
$text =~ s/$r->{reference_biblique}/<ref id="$&">$&<\/ref>/g;

print $text . "\n";

--------
This prints:
<ref id="Ge 1:1">Ge 1:1</ref>, <ref id="Mt 6:33">Mt 6:33</ref>, see page 4:5 and <ref id="Jn 3:16">Jn 3:16</ref>

  
=head1 DESCRIPTION

This module builds highly configurable regular expressions for parsing Bible references.
The goal of this project is to make higher level Bible viewing, editing and tagging tools easier to create.
The configuration files are in YAML format.


=head1 FUNCTIONS

=head2 new

Builds the set of regular expressions for parsing Bible references.

Parameters:
    1. A Religion::Bible::Regex::Config object which gives configurations
       such as the Books and Abbreviations to recognize, key phrases which 
       mark the beginning of a verse or list of verses, etc ...


=head1 INTERFACE 

=for author to fill in:
    Write a separate section listing the public components of the modules
    interface. These normally consist of either subroutines that may be
    exported, or methods that may be called on objects belonging to the
    classes provided by the module.


=head1 DIAGNOSTICS

=for author to fill in:
    List every single error and warning message that the module can
    generate (even the ones that will "never happen"), with a full
    explanation of each problem, one or more likely causes, and any
    suggested remedies.

=over

=item C<< Error message here, perhaps with %s placeholders >>

[Description of error here]

=item C<< Another error message here >>

[Description of error here]

[Et cetera, et cetera]

=back


=head1 CONFIGURATION AND ENVIRONMENT

=for author to fill in:
    A full explanation of any configuration system(s) used by the
    module, including the names and locations of any configuration
    files, and the meaning of any environment variables or properties
    that can be set. These descriptions must also include details of any
    configuration language used.
  
Religion::Bible::Regex::Builder requires no configuration files or environment variables.


=head1 DEPENDENCIES

=for author to fill in:
    A list of all the other modules that this module relies upon,
    including any restrictions on versions, and an indication whether
    the module is part of the standard Perl distribution, part of the
    module's distribution, or must be installed separately. ]

None.


=head1 INCOMPATIBILITIES

=for author to fill in:
    A list of any modules that this module cannot be used in conjunction
    with. This may be due to name conflicts in the interface, or
    competition for system or program resources, or due to internal
    limitations of Perl (for example, many modules that use source code
    filters are mutually incompatible).

None reported.


=head1 BUGS AND LIMITATIONS

=for author to fill in:
    A list of known problems with the module, together with some
    indication Whether they are likely to be fixed in an upcoming
    release. Also a list of restrictions on the features the module
    does provide: data types that cannot be handled, performance issues
    and the circumstances in which they may arise, practical
    limitations on the size of data sets, special cases that are not
    (yet) handled, etc.

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-religion-bible-regex-builder@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


=head1 AUTHOR

Daniel Holmlund  C<< <holmlund.dev@gmail.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2009, Daniel Holmlund C<< <holmlund.dev@gmail.com> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
