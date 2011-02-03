package Module::Install::HTML5Manifest;
use strict;
use warnings;
use base qw(Module::Install::Base);
our $VERSION = '0.01';

use Data::Dumper;
use HTML5::Manifest;
use MIME::Base64 qw/ encode_base64 decode_base64 /;

sub html5_manifest {
    my($self, %args) = @_;
    $self->admin->copy_package('HTML5::Manifest', $INC{'HTML5/Manifest.pm'});

    if ($args{with_gzfile}) {
        eval "require IO::Compress::Gzip";
        $@ and die 'you should install IO::Compress::Gzip';
    }

    local $Data::Dumper::Indent = 0;
    my $base64 = encode_base64( Dumper( \%args ) );
    $base64 =~ s/[\r\n]//g;

    $self->Makefile->postamble(<<EOM);
html5manifest:
\techo "ok"
\tperl -Mlib=inc -MModule::Install::HTML5Manifest -e 'Module::Install::HTML5Manifest->generate("$base64")'
EOM
}

sub generate {
    my($class, $base64) = @_;

    my $args = eval 'my ' . decode_base64($base64); ## no critic
    my $skipfile = delete $args->{manifest_skip};
    my $skip = [];

    open my $fh, '<', $skipfile or die "Can't open file $skipfile: $!";
    while (<$fh>) {
        chomp;
        push @{ $skip }, qr{$_};
    }

    my $generate_to = delete $args->{generate_to};

    my $manifest = HTML5::Manifest->new(
        use_digest => $args->{use_digest},
        htdocs     => $args->{htdocs_from},
        network    => $args->{network_list},
        skip       => $skip,
    );

    open my $to_fh, '>', $generate_to or die "Can't open file $generate_to: $!";
    print $to_fh $manifest->generate;
    close $to_fh;

    if ($args->{with_gzfile}) {
        require IO::Compress::Gzip;
        IO::Compress::Gzip::gzip($generate_to => "$generate_to.gz")
            or die "gzip failed: $IO::Compress::Gzip::GzipError\n";
    }
}

1;
__END__

=head1 NAME

Module::Install::HTML5Manifest - HTML5 application cache manifest file generator for Module::Install

=head1 SYNOPSIS

=head2 simple usage

in your Makefile.PL

    use Module::Install::HTML5Manifest;
    
    use inc::Module::Install;
    name 'Example';
    all_from 'lib/Example.pm';

    html5_manifest
        htdocs_from   => 'htdocs',
        manifest_skip => 'html5manifest.skip',
        generate_to   => 'example.manifest',
        with_gzfile   => 1, # create .gz file
        network_list  => [qw( /api /foo/bar.cgi )],
        use_digest    => 1,
        ;
    
    WriteAll;

in your html5manifest.skip

    \.txt$
    tmp/

run shell commands

    $ perl Makefile.PL
    $ make html5manifest
    $ cat example.manifest

=head1 DESCRIPTION

Module::Install::HTML5Manifest is generate HTML5 application cache manifest file.

=head1 AUTHOR

Kazuhiro Osawa E<lt>yappo {at} shibuya {dot} plE<gt>

=head1 SEE ALSO

L<HTML5::Manifest>, L<http://www.w3.org/TR/html5/offline.html>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
