package Alien::zlib::Static;

use strict;
use warnings;

our $VERSION = '0.10';

use parent 'Alien::Base';

1;

__END__

=head1 NAME

Alien::zlib::Static - Alien wrapper for zlib

=head1 SYNOPSIS

  use strict;
  use warnings;

  use Module::Build;
  use Alien::zlib::Static;

  my $cflags = Alien::zlib::Static->cflags;
  my $ldflags = Alien::zlib::Static->libs;

  my $builder = Module::Build->new(
    module_name => 'my_lib',
    extra_compiler_flags => $cflags,
    extra_linker_flags => $ldflags,
    configure_requires => {
      'Alien::zlib::Static' => 0
    },
  );

  $builder->create_build_script;

=head1 ABSTRACT

Alien wrapper for zlib

=head1 DESCRIPTION

This library provides an alien wrapper for zlib.

