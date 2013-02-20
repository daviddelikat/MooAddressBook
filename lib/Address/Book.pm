
package Address::Book;

use YAML;
use Moo;

use Address::Entry;

=head1 NAME

 Address::Book - a list of Address::Entry objects

=head1 SYNOPSIS

 Address::Book->createEntry( name => $name, ... );
 Address::Book->deleteEntry( $name );
 Address::Book->getEntry( $name );
 Address::Book->getAll;

=head1 PROPERTIES

=head2 entries

 a hash array of address data; key is the name in the entry

=cut

has entries => (
    is => 'ro',
    default => sub { +{ } },
);

=head2 filename

 the name of the fileto store the data in

=cut

has filename => (
    is => 'ro',
    default => sub { '.myaddressbook' },
);

=head1 FUNCTIONS

=head2 BUILD

 load all the data for the entries

=cut

around BUILDARGS => sub {
    my $self = shift;
    return entries => LoadFile($self->filename) if -r $self->filename;
    return ();
};

=head2 DESTROY

 save all the data for the list

=cut

sub DESTROY {
   my $self = shift;
   DumpFile($self->filename,$self->entries);
}

=head2 createEntry

 create a new entry in the address book

=cut

sub createEntry {
    my $self = shift;
    my $entry = Address::Entry->new(shift);
    if( $self->entries->{$entry->key} ) {
        die 'entry exists';
    }
    $self->entries->{$entry->key} = $entry->serialize;
    return 1;
}

=head2 delEntry

 delete an entry fromt he book

=cut

sub delEntry {
    my $self = shift;
    my $key = shift;
    unless( $self->entries->{$key} ) {
        die 'entry does not exist';
    }
    delete $self->entries->{$key};
    return 1;
}

=head2 getEntry

 get a single entry from the book

=cut

sub getEntry {
    my $self = shift;
    my $key = shift;
    unless( $self->entries->{$key} ) {
        die 'entry does not exist';
    }
    return Address::Book->deserialize( $self->entries->{$key} );
}

=head2 getAll

 get a cursor for accessing the whole list of entries

=cut

sub getAll {
    my $self = shift;
    my @all = values %{ $self->entries };
    return bless [ sub { shift @all } ], 'Address::Book::Cursor';
}

=head2 Address::Book::Cursor::next

 implements a simple cursor using a closure

=cut

sub Address::Book::Cursor::next {
     my $self = shift;
     return $self->[0]->();
}

1;

