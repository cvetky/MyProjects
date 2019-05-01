package MenuOption::GetAnimalsByAddedDate;

use strict;
use warnings;
use JSON;
use POSIX qw(strftime);

use parent "MenuOption";

sub new {
    my ($class) = @_;
    return $class->SUPER::new("View history of added animals");
}

sub execute {
    my ($self, $queryPipe, $responsePipe) = @_;

    print("\n\n---History of added animals---\n\n");
    my $queryFilehandle = $self->sendRequestToServer("getAnimalsByAddedDate|{}", $queryPipe);
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

    print "\n";
    my $animalsArray = $hashRef->{animals};
    for my $animalHashRef (@$animalsArray) {
        my $dateAdded = strftime("%d/%m/%Y %H:%M:%S", localtime($animalHashRef->{dateAdded}));
        print("Addition of $animalHashRef->{type} with name '$animalHashRef->{name}' was performed on $dateAdded.\n");
    }
}

1;