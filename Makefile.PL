use inc::Module::Install;
name 'Destophia';
all_from 'lib/Destophia.pm';

requires 'Context::Micro';
requires 'JSON';
requires 'Plack';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';

install_script 'bin/destophia-setup';

auto_set_repository;
auto_include;
WriteAll;
