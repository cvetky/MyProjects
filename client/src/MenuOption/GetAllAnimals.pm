package MenuOption::GetAllAnimals;

use strict;
use warnings;
use JSON;

use parent "MenuOption";

sub new {
    my ($class) = @_;
    return $class->SUPER::new("View all animals");
}

sub execute {
    my ($self, $queryPipe, $responsePipe) = @_;

    print("\n\n---List of all animals---\n\n");
    my $queryFilehandle = $self->sendRequestToServer("getAllAnimals|{}", $queryPipe);
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

    my $counter = 1;
    print "\n";
    my $animalsArray = $hashRef->{animals};
    for my $animalHashRef (@$animalsArray) {
        print("\n~~~Animal $counter~~~\n");
        $self->printAnimalInfo($animalHashRef);
        $counter++;
    }
}

1;