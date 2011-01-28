use inc::Module::Install;
name 'Module-Install-HTML5Manifest';
all_from 'lib/Module/Install/HTML5Manifest.pm';
readme_from 'lib/Module/Install/HTML5Manifest.pm';
readme_markdown_from 'lib/Module/Install/HTML5Manifest.pm';
githubmeta;

# requires '';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
