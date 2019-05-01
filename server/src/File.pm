package File;

use strict;
use warnings;
use Fcntl;

sub new {
    my ($class, $filename) = @_;
    my $self = bless({}, $class);
    $self->setFilename($filename);
    return $self;
}

sub setFilename {
    my ($self, $filename) = @_;
    $self->{filename} = $filename;
}

sub getFilename {
    my ($self) = @_;
    return $self->{filename};
}

sub readContent {
    my ($self) = @_;

    my $filename = $self->getFilename();
    if(!$self->_exists()) {
        return (undef, "File '$filename' does not exist!");
    }

    my $readHandle = $self->_open("r");
    if(!defined($readHandle)) {
        return (undef, "Error when trying to read file '$filename': $!");
    }

    my $content = join("", <$readHandle>);
    $readHandle->close();
    return ($content, undef);
}

sub writeContent {
    my ($self, $content) = @_;

    my $filename = $self->getFilename();
    my $writeHandle = $self->_open("w");
    if(!defined($writeHandle)) {
        return "Error when trying to write to file '$filename': $!";
    }

    $writeHandle->print($content);
    $writeHandle->close();
    return undef;
}

sub _exists {
    my ($self) = @_;
    if(-e $self->getFilename()) {
        return 1;
    }
    return 0;
}

sub _open {
    my ($self, $mode) = @_;
    my $openMode = ($mode eq "r") ? O_RDONLY : O_WRONLY|O_CREAT|O_TRUNC;
    my $status = sysopen(my $fh, $self->getFilename(), $openMode);
    if(!$status) {
        return undef;
    }
    
    return $fh;
}

1;