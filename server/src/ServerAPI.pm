package ServerAPI;

use strict;
use warnings;
use JSON;
use Adapter;

my %functions = (
    addAnimal => \&addAnimal,
    removeAnimal => \&removeAnimal,
    geldAnimal => \&geldAnimal,
    getAnimalsByAddedDate => \&getAnimalsByAddedDate,
    getAnimalsByLeftDate => \&getAnimalsByLeftDate,
    getAnimalsByGeldDate => \&getAnimalsByGeldDate,
    getAnimal => \&getAnimal,
    getAllAnimals => \&getAllAnimals
);

sub executeFunction {
    my ($functionName, $payload) = @_;
    if(defined($functions{$functionName})) {
        my $result = $functions{$functionName}->($payload);
        return to_json($result);
    }

    my $errorResponse = {
        error => "No function for processing the request was found!"
    };

    return to_json($errorResponse);    
}

sub addAnimal {
    my ($payload) = @_;

    my $adapter = Adapter->getInstance();
    return $adapter->addAnimal($payload);
}

sub removeAnimal {
    my ($payload) = @_;

    my $adapter = Adapter->getInstance();
    return $adapter->removeAnimal($payload);
}

sub geldAnimal {
    my ($payload) = @_;

    my $adapter = Adapter->getInstance();
    return $adapter->geldAnimal($payload);
}

sub getAnimalsByAddedDate {
    my $criteria = "dateAdded";
    my $adapter = Adapter->getInstance();
    return $adapter->getAnimalsByCriteria($criteria);
}

sub getAnimalsByLeftDate {
    my $criteria = "dateLeft";
    my $adapter = Adapter->getInstance();
    return $adapter->getAnimalsByCriteria($criteria);
}

sub getAnimalsByGeldDate {
    my $criteria = "dateGeld";
    my $adapter = Adapter->getInstance();
    return $adapter->getAnimalsByCriteria($criteria);
}

sub getAnimal {
    my ($payload) = @_;

    my $adapter = Adapter->getInstance();
    return $adapter->getAnimal($payload);
}

sub getAllAnimals {
    my $adapter = Adapter->getInstance();
    return $adapter->getAllAnimals();
}

1;