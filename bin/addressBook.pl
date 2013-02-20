#!/opt/local/bin/perl

use Getopt::Long;

use lib 'lib';

use Address::Book;

=head1 NAME

 addressBook.pl -- command line tooll interface for simpleaddress book

=head1 SYNOPSIS

 addressBook.pl -createEntry
 addressBook.pl -listEntry
 addressBook.pl -delEntry
 addressBook.pl -listAll

=head1 DESCRIPTION

 This distribution provides an alien wrapper for libyaml. It requires a C
 compiler. That's all!

=head1 FUNCTIONS

=head2 askUser prompt validate

 Ask the user for some information

 prompt - the string to prompt the user for the needed input

 validate - anonymous sub to validate the input; if none given then no validation

=cut

sub askUser {
    my($prompt,$validate) = @_;
    my($result,$valid);
    until($valid) {
        print $prompt;
	$result = <>;
	chomp $result;
	if( $validate ) {
	    $valid = $validate->($result);
	} else {
	    $valid = 1;
	}
    } continue {
        print "'$result' is not valid for this field\n";
    }
    return $result;
}

=head2 askUserForName prompt

 ask the user to enter a name using the given prompt
 thename must be 1 or more characters

=cut

sub askUserForName {
    my $prompt = shift;
    return askUser( $prompt, sub { length $_[0] > 0; } );
}

=head2 createEntry

 Add a new entry to the address book

 Prompt the user for each field

=cut

sub createEntry {
    print "Adding a new entry\n";
    my $data;
    $data->{name} = askUserForName("Enter a name for this entry: ");
    $data->{address} = askUser("Enter address for new entry: ");
    delete $data->{address} unless $data->{address};
    if( Address::Book->createEntry( $data ) ) {
        print "Successfully added $name entry\n";
    } else {
        print "Failed to add $name entry $@\n";
    }
}

=head2 delEntry

 Delete an entry to the address book

 Prompt the user for name

=cut

sub delEntry {
    print "Delete an entry\n";
    my $data;
    $data->{name} = askUserForName("What is the naem for the entry to delete? ");
    my $confirm = askUser("Please confirm delete entry named $name [y/n] ",
    		sub { $_[0] =~ /^[yn]$/i } );
    if( $confirm =~ /n/i ) {
        print "Canceled delete entry $name\n";
    } elsif( Address::Book->deleteEntry( $data ) ) {
        print "Successfully deleted $name entry\n";
    } else {
        print "Failed to delete $name entry $@\n";
    }
}

=head2 listEntry

 List an entry

 Prompt the user for name

=cut

sub listEntry {
    print "List an entry\n";
    my $data;
    $data->{name} = askUserForName("Enter the name of teh entry to list: ");
    if( my $entry = Address::Book->getEntry( $data ) ) {
        $entry->listFull;
    } else {
        print "Failed to list $name entry $@\n";
    }
}

=head2 listAll

 List all entries

 wait for user after every 10 entries

=cut

sub listAll {
    print "List all entries\n";
    my $cursor = Address::Book->getAll;
    my $counter = 0;
    while( my $entry = $cursor->next ) {
        $entry->listShort;
	if( $counter ++ == 10 ) {
	    $counter = 0;
	    askUser("more");
	}
    } continue {
        print "\n"; # blank line between records
    }
    print "Finished listing\n";
}

GetOptions(
    listAll => sub { listAll() },
    listEntry => sub { listEntry() },
    createEntry => sub { createEntry() },
    delEntry => sub { delEntry() },
);

