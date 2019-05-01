#!/usr/bin/perl

use strict;
use warnings;
use Fcntl;
use POSIX qw(mkfifo);
use File::Spec;
use ServerAPI;
use JSON;

my $rootDir = File::Spec->rootdir();
my $queryPipe = File::Spec->catfile($rootDir, "tmp", "query_pipe");
my $responsePipe = File::Spec->catfile($rootDir, "tmp", "response_pipe");
my $queryFileHandle;
my $responseFileHandle;

mkfifo($queryPipe, 0755);
mkfifo($responsePipe, 0755);

print("Server is running and listening...\n");
while(1) {
    sysopen($queryFileHandle, $queryPipe, O_RDONLY) or die "Error when trying to receive query from client: $!";
    my $line = <$queryFileHandle>;
    if($line) {
        chomp($line);
        my ($function, $payload_json) = split(/\|/, $line, 2);
        my $payloadHashRef = from_json($payload_json);
        my $response = ServerAPI::executeFunction($function, $payloadHashRef);
        sysopen($responseFileHandle, $responsePipe, O_WRONLY) or die "Error when trying to send response to client: $!";
        $responseFileHandle->autoflush(1);
        print $responseFileHandle "$response\n";
        close($responseFileHandle);
    }
    close($queryFileHandle);
}