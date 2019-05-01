package MenuOption;

use strict;
use warnings;
use JSON;
use Fcntl;
use POSIX qw(strftime);

sub new {
    my ($class, $name) = @_;
    return bless({ name => $name}, $class);
}

sub execute {
    ...
}

sub isTerminating {
    my ($self) = @_;
    return 0;
}

sub getName {
    my ($self) = @_;
    return $self->{name};
}

sub setName {
    my ($self, $name) = @_;
    $self->{name} = $name;
}

sub promptForAnimalCredentials {
    my ($self) = @_;
    print("\nEnter animal's name: ");
    chomp(my $name = <STDIN>);
    print("\nEnter animal's type: ");
    chomp(my $type = <STDIN>);

    my $payload = {
        name => $name,
        type => $type
    };

    return to_json($payload);
}

sub sendRequestToServer {
    my ($self, $data, $queryPipe) = @_;

    my $timeout = 10;
    local $SIG{ALRM} = sub {
        die "\nWaiting for server response reached timeout! Please check wether the server is running.\n";
    };

    alarm($timeout);
    
    my $queryFilehandle;
    sysopen($queryFilehandle, $queryPipe, O_WRONLY) or die "Error when trying to send request to server: $!";
    $queryFilehandle->autoflush(1);
    print $queryFilehandle "$data\n";
    return $queryFilehandle;
}

sub getResponseFromServer {
    my ($self, $responsePipe) = @_;
    my $responseFilehandle;
    sysopen($responseFilehandle, $responsePipe, O_RDONLY) or die "Error when trying to receive response from server: $!";
    my $response;

    while(1) {
        chomp(my $responseCandidate = <$responseFilehandle>);
        if($responseCandidate) {
            $response = $responseCandidate;
            last;
        }
    }

    close($responseFilehandle);
    alarm(0);

    return ($response);
}

sub printAnimalInfo {
    my ($self, $animalHashRef) = @_;
    print "\nAnimal name: $animalHashRef->{name}\n";
    print "Animal type: $animalHashRef->{type}\n";
    my $dateAdded = strftime("%d/%m/%Y %H:%M:%S", localtime($animalHashRef->{dateAdded}));
    print "Date added: $dateAdded\n";
    if($animalHashRef->{dateGeld}) {
        my $dateGeld = strftime("%d/%m/%Y %H:%M:%S", localtime($animalHashRef->{dateGeld}));
        print "Date geld: $dateGeld\n";
    }
}

1;