package MenuOption::Exit;

use strict;
use warnings;

use parent "MenuOption";

sub new {
    my ($class) = @_;
    return $class->SUPER::new("Exit");
}

sub execute {
    my ($self, $queryPipe, $responsePipe) = @_;

    print("\nExit successful!\n");
}

sub isTerminating {
    my ($self) = @_;
    return 1;
}

1;