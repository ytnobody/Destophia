use inc::Module::Install;
name 'Destophia';
all_from 'lib/Destophia.pm';

requires 'Context::Micro';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
