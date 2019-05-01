package Adapter;

use strict;
use warnings;
use File::Spec;
use File;
use JSON;

my $instance = undef;

sub getInstance {
    my ($class) = @_;

    if(!defined($instance)) {
        $instance = bless({}, $class);
        my $filename = File::Spec->catfile("animals", "animals.json");
        $instance->setFile($filename);
        $instance->initializeAnimals();
    }

    return $instance;
}

sub setFile {
    my ($self, $filename) = @_;
    $self->{file} = File->new($filename);
}

sub getFile {
    my ($self) = @_;
    return $self->{file};
}

sub initializeAnimals {
    my ($self) = @_;
    my ($content, $message) = $self->getFile()->readContent();
    if(!$content) {
        $self->{animals} = [];
        return;
    }

    my $animalsHashRef = from_json($content);
    $self->{animals} = $animalsHashRef->{animals};
}

sub saveAnimals {
    my ($self) = @_;
    my $animalsHashRef = {
        animals => $self->{animals}
    };

    my $content = to_json($animalsHashRef);
    my $message = $self->getFile()->writeContent($content);

    if(defined($message)) {
        return { error => $message };
    }

    return {};
}

sub addAnimal {
    my ($self, $payload) = @_;

    my $name = $payload->{name};
    my $type = $payload->{type};

    my $errorHashRef = $self->validateAnimalNameAndType($name, $type);
    if(defined($errorHashRef->{error})) {
        return $errorHashRef;
    }

    if($self->isThereAnimal($name, $type)) {
        my $animalHashRef = $self->_getAnimal($payload);
        if(!$animalHashRef->{dateLeft}) {
            return { error => "There is already a $type with name '$name' in the list!" };
        }
        return $self->handleReturnedLeftAnimal($animalHashRef);
    }

    my $currentTime = time();
    my $animalHashRef = {
        name => $name,
        type => $type,
        dateAdded => "$currentTime"
    };
    push(@{$self->{animals}}, $animalHashRef);

    $errorHashRef = $self->saveAnimals();
    if(defined($errorHashRef->{error})) {
        return $errorHashRef;
    }

    return { success => "Animal added successfully." };
}

sub validateAnimalNameAndType {
    my ($self, $name, $type) = @_;

    if(!$name || !$type) {
        my $errorHashRef = { error => "Animal's name and type cannot be empty!" };
        return $errorHashRef;
    }

    return {};
}

sub isThereAnimal {
    my ($self, $name, $type) = @_;

    my @foundAnimals = grep { $_->{name} eq $name && $_->{type} eq $type } @{$self->{animals}};
    return scalar(@foundAnimals);
}

sub _getAnimal {
    my ($self, $payload) = @_;

    my $name = $payload->{name};
    my $type = $payload->{type};

    for my $animalHashRef (@{$self->{animals}}) {
        my $isAnimalFound = $animalHashRef->{name} eq $name && $animalHashRef->{type} eq $type;
        return $animalHashRef if($isAnimalFound);
    }

    return { error => "No $type with name '$name' was found." };
}

sub handleReturnedLeftAnimal {
    my ($self, $animalHashRef) = @_;
    my $currentTime = time();
    $animalHashRef->{dateAdded} = "$currentTime";
    $animalHashRef->{dateLeft} = "";

    my $errorHashRef = $self->saveAnimals();
    if(defined($errorHashRef->{error})) {
        return $errorHashRef;
    }

    return { success => "Animal added successfully." };
}

sub removeAnimal {
    my ($self, $payload) = @_;

    my $name = $payload->{name};
    my $type = $payload->{type};

    my $errorHashRef = $self->updateExistingAnimalDate($payload, "dateLeft");
    if(defined($errorHashRef->{error})) {
        return $errorHashRef;
    }

    return { success => "Animal removed successfully." };
}

sub geldAnimal {
    my ($self, $payload) = @_;

    my $name = $payload->{name};
    my $type = $payload->{type};

    if($self->isThereAnimal($name, $type) && $self->_getAnimal($payload)->{dateGeld}) {
        return { error => "The $type with name '$name' has already been geld!" };
    }

    my $errorHashRef = $self->updateExistingAnimalDate($payload, "dateGeld");
    if(defined($errorHashRef->{error})) {
        return $errorHashRef;
    }

    return { success => "Animal geld successfully." };
}

sub updateExistingAnimalDate {
    my ($self, $payload, $dateType) = @_;

    my $name = $payload->{name};
    my $type = $payload->{type};

    my $errorHashRef = $self->validateAnimalNameAndType($name, $type);
    if(defined($errorHashRef->{error})) {
        return $errorHashRef;
    }

    if(!$self->isThereAnimal($name, $type) || $self->_getAnimal($payload)->{dateLeft}) {
        return { error => "No $type with name '$name' was found!" };
    }

    my $animalHashRef = $self->_getAnimal($payload);
    my $currentTime = time();
    $animalHashRef->{$dateType} = "$currentTime";

    $errorHashRef = $self->saveAnimals();
    if(defined($errorHashRef->{error})) {
        return $errorHashRef;
    }

    return {};
}

sub getAnimal {
    my ($self, $payload) = @_;
    my $hashRef = $self->_getAnimal($payload);

    if(defined($hashRef->{error})) {
        return $hashRef;
    }

    if($hashRef->{dateLeft}) {
        return { error => "No $payload->{type} with name '$payload->{name}' was found." }
    }

    return $hashRef;
}

sub getAnimalsByCriteria {
    my ($self, $criteria) = @_;

    my $matchCriteriaCondition = 

    my @animalsMatchingCriteria = grep {
        $criteria eq "dateLeft" ? $_->{$criteria} : $_->{$criteria} && !$_->{dateLeft}
    } @{$self->{animals}};

    my @sortedAnimalsByCriteria = sort { $a->{$criteria} <=> $b->{$criteria} } @animalsMatchingCriteria;

    if(!@sortedAnimalsByCriteria) {
        return { error => "No animals were found for the specified request." };
    }

    return { animals => \@sortedAnimalsByCriteria };
}

sub getAllAnimals {
    my ($self) = @_;

    my @availableAnimals = ();
    for my $animalHashRef (@{$self->{animals}}) {
        push(@availableAnimals, $animalHashRef) if(!$animalHashRef->{dateLeft});
    }

    if(!@availableAnimals) {
        return { error => "There are no animals registered in the system." };
    }

    return { animals => \@availableAnimals };
}

1;