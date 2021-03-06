# $Id: Symbol.pm,v 1.6 2002/10/22 07:45:21 lapp Exp $
#
# BioPerl module for Bio::Symbol::Symbol
#
# Cared for by Jason Stajich <jason@bioperl.org>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Symbol::Symbol - A biological symbol

=head1 SYNOPSIS

    use Bio::Symbol::Symbol;
    my $thymine = new Bio::Symbol::Symbol(-name => 'Thy',
					  -token=> 'T');
    my $a = new Bio::Symbol::Symbol(-token => 'A' );
    my $u = new Bio::Symbol::Symbol(-token => 'U' );
    my $g = new Bio::Symbol::Symbol(-token => 'G' );

    my $M = new Bio::Symbol::Symbol(-name  => 'Met',
				    -token => 'M',
				    -symbols => [ $a, $u, $g ]);

    my ($name,$token) = ($a->name, $a->token);
    my @symbols       = $a->symbols;
    my $matches       = $a->matches;

=head1 DESCRIPTION

Symbol represents a single token in the sequence. Symbol can have
multiple synonyms or matches within the same Alphabet, which
makes possible to represent ambiguity codes and gaps.

Symbols can be also composed from ordered list other symbols. For
example, codons can be represented by single Symbol using a
compound Alphabet made from three DNA Alphabets.

This module was implemented for the purposes of meeting the
BSANE/BioCORBA spec 0.3 only.

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to
the Bioperl mailing list.  Your participation is much appreciated.

  bioperl-l@bioperl.org              - General discussion
  http://bioperl.org/MailList.shtml  - About the mailing lists

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
of the bugs and their resolution. Bug reports can be submitted via
email or the web:

  bioperl-bugs@bioperl.org
  http://bugzilla.bioperl.org/

=head1 AUTHOR - Jason Stajich

Email jason@bioperl.org

Describe contact details here

=head1 CONTRIBUTORS

Additional contributors names and emails here

=head1 APPENDIX

The rest of the documentation details each of the object methods.
Internal methods are usually preceded with a _

=cut


# Let the code begin...


package Bio::Symbol::Symbol;
use vars qw(@ISA);
use strict;

# Object preamble - inherits from Bio::Root::Root

use Bio::Symbol::SymbolI;
use Bio::Symbol::Alphabet;
use Bio::Root::Root;

@ISA = qw( Bio::Root::Root Bio::Symbol::SymbolI  );

=head2 new

 Title   : new
 Usage   : my $obj = new Bio::Symbol::Symbol();
 Function: Builds a new Bio::Symbol::Symbol object 
 Returns : Bio::Symbol::Symbol
 Args    : -name    => descriptive name (string) [e.g. Met]
           -token   => Shorthand token (string)  [e.g. M]
           -symbols => Symbols that make up this symbol (array) [e.g. AUG]
           -matches => Alphabet in the event symbol is an ambiguity
                       code.

=cut

sub new {
  my($class,@args) = @_;
  my $self = $class->SUPER::new(@args);
  $self->{'_symbols'} = [];

  my ($name, $token, $symbols,
      $matches) = $self->_rearrange([qw(NAME TOKEN SYMBOLS 
					MATCHES)],
				    @args);
  $token && $self->token($token);
  $name && $self->name($name);
  $symbols && ref($symbols) =~ /array/i && $self->symbols(@$symbols);
  $matches && $self->matches($matches); 
  return $self;
}

=head2 name

 Title   : name
 Usage   : my $name = $symbol->name();
 Function: Get/Set Descriptive name for Symbol
 Returns : string
 Args    : (optional) string

=cut

sub name {
   my ($self,$value) = @_;
   if( $value ) {
       $self->{'_name'} = $value;
   }
   return $self->{'_name'} || '';
}

=head2 token

 Title   : token
 Usage   : my $token = $self->token();
 Function: Get/Set token for this symbol
 Example : Letter A,C,G,or T for a DNA alphabet Symbol
 Returns : string
 Args    : (optional) string

=cut

sub token{
   my ($self,$value) = @_;
   if( $value ) {
       $self->{'_token'} = $value;
   }
   return $self->{'_token'} || '';
}

=head2 symbols

 Title   : symbols
 Usage   : my @symbols = $self->symbols();
 Function: Get/Set Symbols this Symbol is composed from
 Example : Ambiguity symbols are made up > 1 base symbol
 Returns : Array of Bio::Symbol::SymbolI objects
 Args    : (optional) Array of Bio::Symbol::SymbolI objects


=cut

sub symbols{
   my ($self,@args) = @_;
   if( @args ) {
       $self->{'_symbols'} = [@args];
   } 
   return @{$self->{'_symbols'}};
}

=head2 matches

 Title   : matches
 Usage   : my $matchalphabet = $symbol->matches();
 Function: Get/Set (Sub) alphabet of symbols matched by this symbol
           including the symbol itself (i.e. if symbol is DNA
           ambiguity code W then the matches contains symbols for W
           and T)
 Returns : Bio::Symbol::AlphabetI
 Args    : (optional) Bio::Symbol::AlphabetI

=cut

sub matches{
   my ($self,$matches) = @_;
   
   if( $matches ) {
       if( ! $matches->isa('Bio::Symbol::AlphabetI') ) {
	   $self->warn("Must pass in a Bio::Symbol::AlphabetI object to matches function");
	   # stick with previous value
       } else { 
	   $self->{'_matches'} = $matches;
       }
   }
   return $self->{'_matches'};
}

=head2 equals

 Title   : equals
 Usage   : if( $symbol->equals($symbol2) ) { }
 Function: Tests if a symbol is equal to another 
 Returns : Boolean
 Args    : Bio::Symbol::SymbolI

=cut

sub equals{
   my ($self,$symbol2) = @_;
   # Let's just test based on Tokens for now 
   # Doesn't handle DNA vs PROTEIN accidential comparisons
   return  $self->token eq $symbol2->token;
}


1;
