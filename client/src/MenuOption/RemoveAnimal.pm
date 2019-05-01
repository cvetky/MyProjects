package MenuOption::RemoveAnimal;

use strict;
use warnings;
use JSON;

use parent "MenuOption";

sub new {
    my ($class) = @_;
    return $class->SUPER::new("Remove animal");
}

sub execute {
    my ($self, $queryPipe, $responsePipe) = @_;

    print("\n\n---Removing animal---\n\n");
    my $payload = $self->promptForAnimalCredentials();
    my $queryFilehandle = $self->sendRequestToServer("removeAnimal|$payload", $queryPipe);
    my $response = $self->getResponseFromServer($responsePipe);

    $self->printResult($response);
    close($queryFilehandle);
}

sub printResult {
    my ($self, $response) = @_;
    my $hashRef = from_json($response);

    if($hashRef->{success}) {
        print "\n$hashRef->{success}\n";
    } else {
        print "\n$hashRef->{error}\n";
    }
}

1;