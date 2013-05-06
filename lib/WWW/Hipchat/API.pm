package WWW::Hipchat::API;

=pod

=head1 NAME

WWW::Hipchat::API - Very basic Hipchat API interface, at the moment

=head1 SYNOPSIS

 my $hipchat = WWW::Hipchat::API->new( auth_token => $auth_token);
 my $response = $hipchat->send(
     'room_id'    => $room_id,
     'color'      => $color,
     'from'       => $from,
     'message'    => $message,
 );

=head1 DESCRIPTION

This module allows you to send a message to a Hipchat room via the Hipchat API.  It is very basic, at the moment.

=head1 METHODS

=cut

# https://www.hipchat.com/docs/api/method/rooms/message
use 5.010;
use strict;
use warnings;

our $VERSION = '0.1';

use LWP::UserAgent;


=pod

=over

=item new( %params )

The C<new> constructor lets you create a new B<WWW::Hipchat::API> object.

Returns a new B<WWW::Hipchat::API> or dies on error.

  my $hipchat   = WWW::Hipchat::API->new( auth_token => '<HIPCHAT API AUTH TOKEN>' );

=back

=cut

sub new {
	my $class = shift;
	my %passed_params = @_;
	my %hipchat_params = ( # Setting some defaults
		hipchat_api => 'https://api.hipchat.com/v1',
		action      => '/rooms/message',
		notify      =>  0,
		color       => 'yellow',
		from        => 'Hipchat API',
	);
	
	my $self = \%hipchat_params;
	while ( my($key,$value) = each %passed_params ) {
		$self->{$key} = $value;
	}
	
	$self->{ua} = LWP::UserAgent->new();
	bless $self, $class;
	
	die "You need to pass a Hipchat API Auth Token" unless defined $self->{auth_token};
	
	return $self;
}

=pod

=over

=item send( %params )

This method sends a message to a room.  It returns "Success!" or the output of the failure.

	my $response  = $hipchat->send(
		'room_id'    => 'Room 1',
		'color'      => 'green',
		'from'       => 'Hipchat User',
		'notify'     => 1,
		'message'    => "Hello, world!"
	);
	
	if ($response !~ /Success!/) {
	    print $response,"\n";
	}

=over 4

=item room_id

The room_id is the id or name of the room where the message will be sent.  This parameter is required.

=item color

This is the color of the background of the message.  Options are "yellow", "red", "green", "purple", "gray", or "random". (default: yellow)

=item from

Name that will apppear to be sending the message. Must be less than 15 characters. This parameter is required.

=item notify

Set to 1 to trigger a notification for people in the room. (default is 0: do not notify)

=item message

This is the message that will be sent to the room. 10,000 character max.  This parameter is required

=back

=back

=cut

sub send {
	my $self = shift;
	my %params = @_;
	
	# Do something here
	while ( my($key,$value) = each %params ) {
		$self->{$key} = $value;
	}
	die "Missing room_id and/or message\n" unless defined $self->{'room_id'} && defined $self->{'message'};
	
	my $response = $self->{ua}->post(
	    $self->{'hipchat_api'} . $self->{'action'},
	    Content => {
		'auth_token' => $self->{'auth_token'},
		'notify'     => $self->{'notify'},
		'color'      => $self->{'color'},
		'room_id'    => $self->{'room_id'},
		'from'       => $self->{'from'},
		'message'    => $self->{'message'},
	    }
	);

	if ($response->is_success) {
	    return "Success!";
	}
	else {
	    return $response->status_line;
	}
}

1;

=pod

=head1 REFERENCE

HipChat API documentation for rooms/message - C<< https://www.hipchat.com/docs/api/method/rooms/message >>

=head1 AUTHOR

Copyright 2012 Jeremy Fluhmann.

=cut
