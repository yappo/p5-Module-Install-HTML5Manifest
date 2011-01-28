use strict;
use warnings;
use Test::More;
use File::Spec;

my $example = File::Spec->catfile('t', 'Example');
chdir $example;
`$^X Makefile.PL`;
`make html5manifest`;

my $manifest = do {
    open my $fh, '<', 'example.manifest' or die "Can'ot open file example.manifest: $!";
    local $/;
    <$fh>;
};

is($manifest, <<MANIFEST);
CACHE MANIFEST

NETWORK:
/api
/foo/bar.cgi

CACHE:
/site.css # gJ3zRAFSFdM1CkHh+6NmKw
/site.js # UM9XLY422f6yb7XbiXe2Jw
MANIFEST

`make distclean`;

done_testing;
