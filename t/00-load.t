use Test::More tests => 3;

BEGIN {
    use_ok('WWW::Google::Time');
    use_ok('App::ZofCMS::Plugin::Base');
    use_ok( 'App::ZofCMS::Plugin::GoogleTime' );
}

diag( "Testing App::ZofCMS::Plugin::GoogleTime $App::ZofCMS::Plugin::GoogleTime::VERSION, Perl $], $^X" );
