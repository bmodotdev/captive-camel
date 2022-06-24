#!/usr/bin/env -S perl -T

package script::CaptiveCamel;

use strict;
use warnings;
use v5.34;

use feature qw(say state signatures);
no warnings qw(experimental::signatures);

use sigtrap 'handler', sub {}, qw(INT);

use List::Util          ();
use Params::Validate    ();
use YAML::PP            ();

use constant COMMANDS_PATH  => '/etc/captive-camel/commands.yaml';
use constant EXEC_PATH      => qw(/usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin);
use constant HELP_OPTS      => qw(h help ?);
use constant MATCH_TYPES    => qw(exact prefix);
use constant PROMPT_DEFAULT => '> ';
use constant EXIT_SUCCESS   => 0;

++$|;
$ENV{PATH} = join ':', (EXEC_PATH);

# Modulino
exit __PACKAGE__->new->run() unless caller;

sub new ($class) {

    my $config  = load_config();
    my %self    = validate_config( $config );

    return bless \%self, $class;
}

sub run ($self) {

    while (1) {
        print $self->{prompt};

        # Read
        my $line = <<>> || last;
        next unless $line =~ /\A ([\?\w\s=-]+) \Z/xms;
        my $valid_line = $1;

        # Trim
        $valid_line =~ s/^\s+|\s+$//g;
        my @words = split(/\s+/, $valid_line);
        next unless scalar @words;

        $self->process_line( @words );
    }

    return EXIT_SUCCESS;
}


sub process_line ($self, @words) {

    # Run exit option
    if ( $self->{exit} && $words[0] eq 'exit' ) {
        exit EXIT_SUCCESS;
    }

    # Run help option
    if ( $self->{help} && List::Util::first { $_ eq $words[0] } (HELP_OPTS) ) {
        return $self->print_help();
    }

    # Parse
    for my $command (@{ $self->{commands} }) {
        next unless ( $command->{match} eq $words[0] );
        return $command->{exec}
            ? $self->_exec( split(/\s+/, $command->{exec}) )
            : $self->_exec(  $command->{match} eq 'exact' ? $command->{match} : @words );
    }

    return;
}

sub print_help ($self) {
    print "Available commands:\n"
        . join("\n", map { "\t$_->{match}" } @{ $self->{commands} })
        . ( $self->{exit} ? "\n\texit\n" : "\n" );
}

sub _exec ($self, @words) {

    my $cmd     = shift @words;
    my $path    = List::Util::first { -e $_ . '/' . $cmd } (EXEC_PATH);
    return unless $path;

    my $full_path = sprintf '%s/%s', $path, $cmd;
    return system($full_path, @words);
}

sub load_config {
    return YAML::PP::LoadFile( COMMANDS_PATH )
        || die "Failed to load yaml: $!";
}

sub validate_config ($config) {

    my $bool_re = qr/\A (?:0|1) \Z/x;

    state $spec = {
        help => {
            type        => Params::Validate::BOOLEAN,
            optional    => 1,
            default     => 1,
            regex       => $bool_re,
        },
        exit => {
            type        => Params::Validate::BOOLEAN,
            optional    => 1,
            default     => 1,
            regex       => $bool_re,
        },
        commands => {
            type        => Params::Validate::ARRAYREF,
            callbacks   => {
                deeply  => \&_validate_commands,
            },
        },
        prompt => {
            type        => Params::Validate::SCALAR,
            optional    => 1,
            default     => PROMPT_DEFAULT,
        },
    };

    return Params::Validate::validate_with(
        params  => $config,
        spec    => $spec,
    );
}

sub _validate_commands ($commands, @) {

    scalar @{ $commands }
        || die 'The configuration contains no commands. Use /bin/false or /bin/noshell';

    my $string_re = qr/\A [\w\s=-]+ \Z/x;

    state $spec = {
        exec => {
            type        => Params::Validate::SCALAR,
            optional    => 1,
            regex       => $string_re,
            untaint     => 1,
        },
        match => {
            type        => Params::Validate::SCALAR,
            regex       => $string_re,
            untaint     => 1,
        },
        match_type => {
            type        => Params::Validate::SCALAR,
            untaint     => 1,
            callbacks   => {
                'Ensure known “match_type”' => sub { List::Util::first { $_ eq $_[0] } (MATCH_TYPES) },
            }
        },
    };

    my @validated_commands = map {
        Params::Validate::validate_with(
            params  => $_,
            spec    => $spec,
        )
    } @{ $commands };

    return \@validated_commands;
}

1;

=pod

=encoding utf8

=head1 NAME

=head1 SYNOPSIS

=head1 METHODS

=head1 COPYRIGHT

=cut
