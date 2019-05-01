package MenuOption::GetAnimal;

use strict;
use warnings;
use JSON;

use parent "MenuOption";

sub new {
    my ($class) = @_;
    return $class->SUPER::new("View information about an animal");
}

sub execute {
    my ($self, $queryPipe, $responsePipe) = @_;

    print("\n\n---Viewing information about animal---\n\n");
    my $payload = $self->promptForAnimalCredentials();
    my $queryFilehandle = $self->sendRequestToServer("getAnimal|$payload", $queryPipe);
    my $response = $self->getResponseFromServer($responsePipe);

    $self->printResult($response);
    close($queryFilehandle);
}

sub printResult {
    my ($self, $response) = @_;
    my $hashRef = from_json($response);

    if($hashRef->{error}) {
        print "\n$hashRef->{error}\n";
        return;
    }

    $self->printAnimalInfo($hashRef);
}

1;