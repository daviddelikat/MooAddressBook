
package Address::Entry;

use Moo;

=head1 NAME

 Address::Entry - a single address entry

=head1 SYNOPSIS

 Address::Entry->listFull;     # print all fields in the entry
 Address::Entry->listShort;    # print a one line summary of the entry
 Address::Entry->serialize;    # return a string that can be restored to an objecat
 Address::Entry->deserialize($serialised string);    # convert the string into an entry

=head1 PROPERTIES

=head2 name

 the name of the person this entry is for

=cut

has name => (
    is => 'ro',
    required => 1,
);

=head2 address

 persons street address

=cut

has address => (
    is => 'ro',
    predicate => 'has_address',
);

=head1 FUNCTIONS

=head2 key

 the key for this entry

=cut

sub key {
    my $self = shift;
    return $self->name;
}

=head2 serialize

=cut

sub serialize {
   my $class = shift;
   my $string = shift;
   my $data;
   for my $piece ( split /;/, $string ) {
       my($name,$value) = split /=/, $piece,2;
       next unless $name;
       $data->{$name} = $value;
   }
   return $class->new($data);
}

=head2 deserialize string

=cut

sub deserialize {
    my $self = shift;
    my $result = 'name='.$self->name;
    if( $self->has_address ) {
        $result .= ';address='.$self->address;
    }
    return $result;
}

=head2 listShort

=cut

sub listShort {
   my $self = shift;
   if( $self->has_address ) {
       print $self->name," lives at ",$self->address,"\n";
   } else {
       print "entry for ",$self->name,"\n";
   }
}

=head2 listFull

=cut

sub listFull {
   my $self = shift;
   print " Name:    ", $self->name, "\n";
   print " Address: ", $self->address,"\n" if $self->has_address;
}

1;

