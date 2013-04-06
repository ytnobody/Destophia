package Destophia::Setup;
use strict;
use warnings;
use utf8;
use File::Spec;
use File::Basename 'dirname';

my $data;
my %template;

sub setup {
    my ($class, $distname, $author) = @_;
    $author ||= $ENV{USER} || $ENV{USERNAME} || 'yourname';
    $data = '';
    %template = ();
    $data .= $_ while <DATA>;
    seek DATA, 0, 0;
    my $distname_hyphened = $distname; 
    $distname_hyphened =~ s[::][-]g;
    my $distfile = File::Spec->catfile( 'lib', split('::', $distname.'.pm') );
    $data =~ s[__DISTNAME__][$distname]g;
    $data =~ s[__DISTNAME_HYPHENED__][$distname_hyphened]g;
    $data =~ s[__DISTFILE__][$distfile]g;
    $data =~ s[__AUTHOR__][$author]g;
    %template = map { (split /\n\=\=\=\n/, $_) } split /\n\* /, $data;
    my $root = File::Spec->rel2abs($distname_hyphened);
    create_dir($root);
    puke_file($root, $_) for keys %template;
}

sub puke_file {
    my ($root, $file) = @_;
    my $path = File::Spec->catfile($root, $file);
    my $dir = dirname($path);
    create_dir($dir);
    printf "creating file %s\n", $path;
    open my $fh, '>', $path or die $!;
    print $fh $template{$file};
    close $fh;
}

sub create_dir {
    my $dir = shift;
    my $target = File::Spec->catdir($dir);
    return if -d $dir;
    while (1) {
        printf "creating directory %s\n", $target;
        my @dirs = File::Spec->splitdir($target);
        my $updir = File::Spec->catdir( map { $dirs[$_]} 0 .. $#dirs-1 );
        if (-e $updir) {
            mkdir $target or die $!;
            last if $target eq $dir;
            $target = $dir;
        }
        else {
            printf "Trying to create %s\n", $updir;
            $target = $updir;
        }
    }
}

1;

__DATA__

* app.psgi
===
use strict;
use warnings;
use utf8;
use File::Spec;
use File::Basename 'dirname';
use lib ( File::Spec->catdir( File::Spec->rel2abs(dirname(__FILE__)), 'lib' ) );
use __DISTNAME__;

__DISTNAME__->bootstrap;
__DISTNAME__->app;

* Makefile.PL
===
use 5.006;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => '__DISTNAME__',
    AUTHOR           => q{__AUTHOR__},
    VERSION_FROM     => '__DISTFILE__',
    ABSTRACT_FROM    => '__DISTFILE__',
    LICENSE          => 'Artistic_2_0',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.008,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
        'Destophia' => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => '__DISTNAME_HIPHENED__-*' },
);

* __DISTFILE__
===
package __DISTNAME__;
use warnings;
use strict;
use utf8;
use Destophia;

my $config = +{
};

my $routing = +{
    qr'^/$' => '__DISTNAME__::index',
};

my $c = Destophia->new(config => $config);
$c->router(%$routing);

sub foo {
    my $self = shift;
    $c->entry(foo => sub {'foobar'});
}

sub index {
    my ($class, $c, $req, $action) = @_;
    +{
        class   => $class,
        message => 'hello, world!',
        foo     => $class->foo,
    };
}

# no change these methods !!!
sub bootstrap { $c->bootstrap }
sub app { $c->app }

1;

* t/000_use.t
===
use strict;
use warnings;
use Test::More tests => 1;

BEGIN { use_ok __DISTNAME__ };

done_testing;

* t/001_index.t
===
use strict;
use warnings;
use utf8;
use Test::More;
use Plack::Test;
use JSON;
use HTTP::Request::Common;
use __DISTNAME__;

__DISTNAME__->bootstrap;

test_psgi __DISTNAME__->app, sub {
    my $cb = shift;
    my $res = $cb->(GET '/');
    ok $res->is_success;
    my $json = JSON->new->utf8->decode($res->content);
    is_deeply $json, {
        class   => '__DISTNAME__',
        message => 'hello, world!',
        foo     => 'foobar',
    };
};

done_testing;
