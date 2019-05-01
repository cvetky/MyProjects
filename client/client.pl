#!/usr/bin/perl

use strict;
use warnings;
use Fcntl;
use File::Spec;
use MenuOptions;

my $rootDir = File::Spec->rootdir();
my $queryPipe = File::Spec->catfile($rootDir, "tmp", "query_pipe");
my $responsePipe = File::Spec->catfile($rootDir, "tmp", "response_pipe");

print "\n_____ARS MANAGER v1.0_____\n\n";
while(1) {
    showMenu();
    my $option;
    while(1) {
        print "\nYour option: ";
        chomp($option = <STDIN>);
        if($option =~ /^[1-9]$/) {
            last;
        } else {
            print "\nInvalid option! It must be a number between 1 and 9!\n";
        }
    }

    my $menuOption = MenuOptions::getMenuOption($option);
    $menuOption->execute($queryPipe, $responsePipe);
    last if($menuOption->isTerminating());
}

sub showMenu {
    print "\nMain Menu:\n";
    foreach my $menuOptionNumber (sort(keys(%MenuOptions::options))) {
        print "\t$menuOptionNumber. ".MenuOptions::getMenuOption($menuOptionNumber)->getName()."\n";
    }
}

