package MenuOption::GetAnimalsByLeftDate;

use strict;
use warnings;
use JSON;
use POSIX qw(strftime);

use parent "MenuOption";

sub new {
    my ($class) = @_;
    return $class->SUPER::new("View history of left animals");
}

sub execute {
    my ($self, $queryPipe, $responsePipe) = @_;

    print("\n\n---History of left animals---\nNote: This list does not include animals which have left but are now added!\n\n");
    my $queryFilehandle = $self->sendRequestToServer("getAnimalsByLeftDate|{}", $queryPipe);
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
        my $dateLeft = strftime("%d/%m/%Y %H:%M:%S", localtime($animalHashRef->{dateLeft}));
        print("Releasing of $animalHashRef->{type} with name '$animalHashRef->{name}' was performed on $dateLeft.\n");
    }
}

1;