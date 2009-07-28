package App::ZofCMS::Plugin::GoogleTime;

use warnings;
use strict;

our $VERSION = '0.0102';

use WWW::Google::Time;
use base 'App::ZofCMS::Plugin::Base';


sub _key {
    'plug_google_time'
}
sub _defaults {
    ua => LWP::UserAgent->new(
        agent    => "Opera 9.5",
        timeout  => 30,
    ),
    location => undef,
}
sub _do {
    my ( $self, $conf, $t, $q, $config ) = @_;

    $conf->{location} = $conf->{location}->( $t, $q, $config )
        if ref $conf->{location} eq 'CODE';

    return
        unless defined $conf->{location}
            and length $conf->{location};


    my $g_time = WWW::Google::Time->new( ua => $conf->{ua} );

    if ( ref $conf->{location} eq 'ARRAY' ) {
        my @results;

        for ( @{ $conf->{location} } ) {
            my $time = $g_time->get_time( $_ );

            if ( defined $time ) {
                push @results, {
                    time => ( sprintf "%s, %s (%s) in %s",
                        @{ $g_time->data }{ qw/day_of_week  time  time_zone where/ } ),

                    hash => $g_time->data,
                };
            }
            else {
                push @results, { error => $g_time->error };
            }

            $t->{t}{plug_google_time} = \@results;
        }
    }
    else {
        my $time = $g_time->get_time( $conf->{location} );
        if ( defined $time) {
            $t->{t}{plug_google_time} = sprintf "%s, %s (%s) in %s",
                        @{ $g_time->data }{ qw/day_of_week  time  time_zone where/ };

            $t->{t}{plug_google_time_hash} = $g_time->data;
        }
        else {
            $t->{t}{plug_google_time_error} = $g_time->error;
        }
    }
}


1;
__END__

=head1 NAME

App::ZofCMS::Plugin::GoogleTime - plugin to get times for different locations using Google

=head1 SYNOPSIS

In ZofCMS Template or Main Config File:

    plugins => [
        qw/GoogleTime/
    ],

    plug_google_time => {
        location => 'Toronto',
    },

In HTML::Template file:

    <tmpl_if name='plug_google_time_error'>
        <p class="error">Got error: <tmpl_var escape='html' name='plug_google_time_error'></p>
    <tmpl_else>
        <p>Time: <tmpl_var escape='html' name='plug_google_time'></p>
    </tmpl_if>

=head1 DESCRIPTION

The module is a plugin for L<App::ZofCMS> that provides means to obtain times for different
locations using Google.

This documentation assumes you've read L<App::ZofCMS>, L<App::ZofCMS::Config> and
L<App::ZofCMS::Template>

=head1 FIRST-LEVEL ZofCMS TEMPLATE AND MAIN CONFIG FILE KEYS

=head2 C<plugins>

    plugins => [
        qw/GoogleTime/
    ],

B<Mandatory>. You must specify the plugin in the list of plugins to execute.

=head2 C<plug_google_time>

    plug_google_time => {
        location => 'Toronto',
        ua => LWP::UserAgent->new(
            agent    => "Opera 9.5",
            timeout  => 30,
            max_size => 2000,
        ),
    },

=head3 C<location>

    plug_google_time => {
        location => 'Toronto',
    }

    plug_google_time => {
        location => [
            'Toronto',
            'New York',
        ],
    }

    plug_google_time => {
        location => sub {
            my ( $t, $q, $config ) = @_;
            return 'Toronto';
        },
    }

B<Mandatory>. Specifies location(s) for which you wish to obtain times.
The value can be either a direct string, an arrayref or a subref.
When value is a subref, its C<@_> will contain
(in that order): ZofCMS Template hashref, query parameters hashref and L<App::ZofCMS::Config>
object. The return value of the sub will be assigned to C<location> argument
as if it was already there.

The single string vs. arrayref values affect the output format (see section below).

=head3 C<ua>

    plug_google_time => {
        ua => LWP::UserAgent->new(
            agent    => "Opera 9.5",
            timeout  => 30,
        ),
    },

B<Optional>. Takes an L<LWP::UserAgent> object as a value; this object will be used for
accessing Google. B<Defaults to:>

    LWP::UserAgent->new(
        agent    => "Opera 9.5",
        timeout  => 30,
    ),

=head1 PLUGIN'S OUTPUT

    # location argument set to a string
    <tmpl_if name='plug_google_time_error'>
        <p class="error">Got error: <tmpl_var escape='html' name='plug_google_time_error'></p>
    <tmpl_else>
        <p>Time: <tmpl_var escape='html' name='plug_google_time'></p>
    </tmpl_if>


    # location argument set to an arrayref
    <ul>
        <tmpl_loop name='plug_google_time'>
        <li>
            <tmpl_if name='error'>
                Got error: <tmpl_var escape='html' name='error'>
            <tmpl_else>
                Time: <tmpl_var escape='html' name='time'>
            </tmpl_if>
        </li>
        </tmpl_loop>
    </ul>

Plugin will set C<< $t->{t}{plug_google_time} >> (where C<$t> is ZofCMS Template
hashref) to either a string or an
arrayref when C<location> plugin's argument is set to a string or arrayref respectively. Thus,
for arrayref values you'd use a C<< <tmpl_loop> >> plugins will use three variables
inside that loop: C<error>, C<time> and C<hash>; the C<error> variable will be present when
an error occured during title fetching. The C<time> will be the formated string of the
time including the location. The C<hash> variable will contain a hashref that is the
output of C<data()> method of L<WWW::Google::Time> module. Order
for arrayrefs will be the same as the order in C<location> argument.

If C<location> argument was set to a single string, then C<{plug_google_time}> will contain
the formated time of the location, C<{plug_google_time_error}> will be set if an error
occured and C<{plug_google_time_hash}> will contain the
output of C<data()> method of L<WWW::Google::Time> module.

=head1 AUTHOR

'Zoffix, C<< <'zoffix at cpan.org'> >>
(L<http://haslayout.net/>, L<http://zoffix.com/>, L<http://zofdesign.com/>)


=head1 BUGS

Please report any bugs or feature requests to C<bug-app-zofcms-plugin-googletime at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=App-ZofCMS-Plugin-GoogleTime>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc App::ZofCMS::Plugin::GoogleTime

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=App-ZofCMS-Plugin-GoogleTime>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/App-ZofCMS-Plugin-GoogleTime>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/App-ZofCMS-Plugin-GoogleTime>

=item * Search CPAN

L<http://search.cpan.org/dist/App-ZofCMS-Plugin-GoogleTime/>

=back



=head1 COPYRIGHT & LICENSE

Copyright 2009 'Zoffix, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

