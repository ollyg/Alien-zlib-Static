use strict;
use warnings;
use IPC::Cmd qw/can_run/;

use Alien::Base::ModuleBuild '0.025';

my $addcc = "";
$addcc = "CC=cc " if ( (!can_run('gcc')) && can_run('cc') );

my $class;
if ($^O eq 'MSWin32') {
  print "Enabling Windows hacks...\n";
  $class = Alien::Base::ModuleBuild->subclass( class => 'Alien::OpenSSL::Static::Builder',
                                               code => <<'EOC' );

use Carp;
use File::Spec;
use Env qw(@PATH);

# Look for MinGW
for my $INC (grep !ref, @INC) {
  my $dir = File::Spec->rel2abs(File::Spec->catdir($INC, qw(auto MinGw bin)));
  push @PATH, $dir if -d $dir;
}

sub alien_extract_archive {
  my ($self, $archive) = @_;

  print "Extracting archive '$archive'...\n";
  print "tar may report some errors now, they are harmless and can be ignored!\n";
  $self->alien_do_system(['tar', '-xzf', $archive]);
  my (undef, undef, $dir) = File::Spec->splitpath($archive);
  $dir =~ s/\.tar\.gz$//;
  -d $dir or croak "Archive extraction failed";
  print "Done\n";
  return $dir
}
EOC

}
else {
  $class = 'Alien::Base::ModuleBuild';
}

my $minver = '1.1.0f';

my $builder = $class->new (
    sign => 1,
    module_name => 'Alien::OpenSSL::Static',
    license => 'perl',
    configure_requires => {
        'Alien::Base::ModuleBuild' => '0.025',
        'Module::Build' => '0.38',
        'Test::More' => 0,
    },
    requires => {
        'perl' => '5.8.1',
        'Alien::Base' => '0.025',
    },
    dist_author => 'Johanna Amann <johanna@icir.org>',
    alien_name => 'openssl',
    alien_repository => {
        protocol => 'ftp',
        host => 'ftp.openssl.org',
        location => '/source/',
        pattern  => qr/^openssl-([\d\.]+\w?).tar\.gz$/,
    },
    alien_version_check => '%{pkg_config} --atleast-version '
      . $minver .' %n && %{pkg_config} --modversion %n',
    alien_msys => 1,
    alien_stage_install => 0,
    alien_build_commands => [
        $addcc.'sh config no-shared --prefix=%s',
        $addcc.'make',
    ],
    alien_test_commands => [
        $addcc.'make test',
    ],
    alien_install_commands => [
        'make install_sw',
    ],
    meta_merge => {
        resources => {
            homepage => 'https://github.com/ollyg/alien-openssl-static',
            bugtracker => 'https://github.com/ollyg/alien-openssl-static/issues',
            repository  => 'git://github.com/ollyg/alien-openssl-static.git',
        },
    },
    script_files => [
      'bin/openssl-env'
    ],
);

my %args = $builder->args;

my $version;
$version = $args{version} if(exists $args{version});

if ( defined($version) ) {
    my $location = "/source/openssl-".$version.".tar.gz";
    print "Downloading from $location\n";
    $builder->alien_version_check('%{pkg_config} --exact-version '
      . $version .' %n && %{pkg_config} --modversion %n');
    $builder->alien_repository->{pattern} = qr#\Qopenssl-$version.tar.gz\E$#;
    print $builder->alien_repository->{pattern}."\n";

}

$builder->create_build_script;
