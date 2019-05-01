package MenuOptions;

use strict;
use warnings;

use MenuOption::AddAnimal;
use MenuOption::RemoveAnimal;
use MenuOption::GeldAnimal;
use MenuOption::GetAnimal;
use MenuOption::GetAnimalsByAddedDate;
use MenuOption::GetAnimalsByLeftDate;
use MenuOption::GetAnimalsByGeldDate;
use MenuOption::GetAllAnimals;
use MenuOption::Exit;

our %options = (
    1 => MenuOption::AddAnimal->new(),
    2 => MenuOption::RemoveAnimal->new(),
    3 => MenuOption::GeldAnimal->new(),
    4 => MenuOption::GetAnimal->new(),
    5 => MenuOption::GetAnimalsByAddedDate->new(),
    6 => MenuOption::GetAnimalsByLeftDate->new(),
    7 => MenuOption::GetAnimalsByGeldDate->new(),
    8 => MenuOption::GetAllAnimals->new(),
    9 => MenuOption::Exit->new(),
);

sub getMenuOption {
    my ($option) = @_;
    return $options{$option};
}

1;