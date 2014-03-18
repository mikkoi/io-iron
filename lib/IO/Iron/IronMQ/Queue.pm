package IO::Iron::IronMQ::Queue;

## no critic (Documentation::RequirePodAtEnd)
## no critic (Documentation::RequirePodSections)
## no critic (ControlStructures::ProhibitPostfixControls)

use 5.008_001;
use strict;
use warnings FATAL => 'all';

# Global creator
BEGIN {
	# Export Nothing
}

# Global destructor
END {
}

=head1 NAME

IO::Iron::IronMQ::Queue - IronMQ (Message Queue) Client (Queue).

=head1 VERSION

Version 0.07

=cut

our $VERSION = '0.07';

=head1 SYNOPSIS

Please see IO::Iron::IronMQ::Queue for usage.

=head1 REQUIREMENTS

=cut

use Log::Any qw($log);
use Hash::Util qw{lock_keys unlock_keys};
use Carp::Assert::More;
use English '-no_match_vars';

use IO::Iron::Common;
use IO::Iron::IronMQ::Api;


=head1 SUBROUTINES/METHODS

=head2 new

=over

=item Creator function.

=back

=cut

sub new {
	my ( $class, $params ) = @_;
	$log->tracef( 'Entering new(%s, %s)', $class, $params );
	my $self;
	my @self_keys = ( ## no critic (CodeLayout::ProhibitQuotedWordLists)
		'ironmq_client',         # Reference to IronMQ client
		'id',                    # IronMQ queue id
		'name',                  # Queue name
		'connection',            # Reference to REST client
		'last_http_status_code', # After successfull network operation, the return value is here.
	);
	lock_keys( %{$self}, @self_keys );
	$self->{'ironmq_client'} = defined $params->{'ironmq_client'} ? $params->{'ironmq_client'} : undef;
	$self->{'id'}   = defined $params->{'id'}   ? $params->{'id'}   : undef;
	$self->{'name'} = defined $params->{'name'} ? $params->{'name'} : undef;
	$self->{'connection'} = defined $params->{'connection'} ? $params->{'connection'} : undef;
	assert_isa( $self->{'connection'}, 'IO::Iron::Connection', 'self->{\'connection\'} is IO::Iron::Connection.' );
	assert_isa( $self->{'ironmq_client'}, 'IO::Iron::IronMQ::Client', 'self->{\'ironmq_client\'} is IO::Iron::IronMQ::Client.' );
	assert_nonblank( $self->{'id'}, 'self->{\'id\'} is defined and is not blank.' );
	assert_nonblank( $self->{'name'}, 'self->{\'name\'} is defined and is not blank.' );

	unlock_keys( %{$self} );
	my $blessed_ref = bless $self, $class;
	lock_keys( %{$self}, @self_keys );

	$log->tracef( 'Exiting new: %s', $blessed_ref );
	return $blessed_ref;
}

=head2 id

=over

=item Set or get id.

=back

=cut

sub id {
	my ( $self, $id ) = @_;
	$log->tracef( 'Entering id(%s)', $id );
	if ( defined $id ) {
		$self->{'id'} = $id;
		$log->tracef( 'Exiting id:%s', 1 );
		return 1;
	}
	else {
		$log->tracef( 'Exiting id:%s', $self->{'id'} );
		return $self->{'id'};
	}
}

=head2 name

=over

=item Set or get name.

=back

=cut

sub name {
	my ( $self, $name ) = @_;
	$log->tracef( 'Entering name(%s)', $name );
	if ( defined $name ) {
		$self->{'name'} = $name;
		$log->tracef( 'Exiting name:%s', 1 );
		return 1;
	}
	else {
		$log->tracef( 'Exiting name:%s', $self->{'name'} );
		return $self->{'name'};
	}
}

=head2 push

=over

=item Params: one or more IO::Iron::IronMQ::Message objects.

=item Return: message id(s) returned from IronMQ (if in list context),
or number of messages.

=back

=cut

sub push { ## no critic (Subroutines::ProhibitBuiltinHomonyms)
	# TODO Limit the total size!
	my ( $self, @messages ) = @_;
	foreach my $message (@messages) {
		assert_isa( $message, 'IO::Iron::IronMQ::Message',
			'message is IO::Iron::IronMQ::Message.' );
	}
	$log->tracef( 'Entering push(%s)', @messages );

	my $queue_name = $self->name();
	my $connection = $self->{'connection'};
	my @message_contents;
	foreach my $message (@messages) {
		my ( $msg_body, $msg_timeout, $msg_delay, $msg_expires_in ) = (
			$message->{'body'},  $message->{'timeout'},
			$message->{'delay'}, $message->{'expires_in'},
		);
		my $message_content = {};
		$message_content->{'body'}       = $msg_body;
		$message_content->{'timeout'}    = $msg_timeout if defined $msg_timeout;
		$message_content->{'delay'}      = $msg_delay if defined $msg_delay;
		$message_content->{'expires_in'} = $msg_expires_in if defined $msg_expires_in;
		push @message_contents, $message_content;
	}
	my %item_body = ( 'messages' => \@message_contents );

	my ( $http_status_code, $response_message ) =
	  $connection->perform_iron_action(
		IO::Iron::IronMQ::Api::IRONMQ_ADD_MESSAGES_TO_A_QUEUE(),
		{
			'{Queue Name}' => $queue_name,
			'body'         => \%item_body,
		}
	  );
	$self->{'last_http_status_code'} = $http_status_code;

	my ( @ids, $msg );
	@ids = ( @{ $response_message->{'ids'} } );    # message ids.
	$msg = $response_message->{'msg'};    # Should be "Messages put on queue."
	$log->debugf( 'Pushed IronMQ Message(s) (queue name=%s; message id(s)=%s).',
		$self->{'name'}, ( join q{,}, @ids ) );
	if (wantarray) {
		$log->tracef( 'Exiting push: %s', ( join q{:}, @ids ) );
		return @ids;
	}
	else {
		if ( scalar @messages == 1 ) {
			$log->tracef( 'Exiting push: %s', $ids[0] );
			return $ids[0];
		}
		else {
			$log->tracef( 'Exiting push: %s', scalar @ids );
			return scalar @ids;
		}
	}
}

=head2 pull

=over 

=item Params: n (number of messages), 
timeout (timeout for message processing in the user program)

=item Return: list of IO::Iron::IronMQ::Message objects, 
empty list if no messages available.

=back

=cut

sub pull {
	my ( $self, $params ) = @_;
	$log->tracef( 'Entering pull(%s)', $params );

	my $queue_name = $self->name();
	my $connection = $self->{'connection'};
	my %query_params;
	$query_params{'{n}'}       = $params->{'n'}       if $params->{'n'};
	$query_params{'{timeout}'} = $params->{'timeout'} if $params->{'timeout'};
	my ( $http_status_code, $response_message ) =
	  $connection->perform_iron_action(
		IO::Iron::IronMQ::Api::IRONMQ_GET_MESSAGES_FROM_A_QUEUE(),
		{
			'{Queue Name}' => $queue_name,
			%query_params
		}
	  );
	$self->{'last_http_status_code'} = $http_status_code;

	my @pulled_messages;
	my $messages = $response_message->{'messages'};    # messages.
	foreach ( @{$messages} ) {
		my $msg = $_;
		$log->debugf( 'Pulled IronMQ Message (queue name=%s; message id=%s).',
			$self->{'name'}, $msg->{'id'} );
		my $message = IO::Iron::IronMQ::Message->new(
			{
				'body'           => $msg->{'body'},
				'timeout'        => $msg->{'timeout'},
				'id'             => $msg->{'id'},
				'reserved_count' => $msg->{'reserved_count'},
			}
		);
		CORE::push @pulled_messages,
		  $message;    # using CORE routine, not this class method.
	}
	$log->debugf( 'Pulled %d IronMQ Messages (queue name=%s).',
		scalar @pulled_messages, $self->{'name'} );
	$log->tracef( 'Exiting pull: %s',
		@pulled_messages ? @pulled_messages : '[NONE]' );
	return @pulled_messages;
}

=head2 peek

=over

=item Params: [none]

=item Return: list of IO::Iron::IronMQ::Message objects, 
empty list if no messages available.

=back

=cut

sub peek {
	my ( $self, $params ) = @_;
	$log->tracef( 'Entering peek(%s)', $params );

	my $queue_name = $self->name();
	my $connection = $self->{'connection'};
	my %query_params;
	$query_params{'{n}'} = $params->{'n'} if $params->{'n'};
	my ( $http_status_code, $response_message ) =
	  $connection->perform_iron_action(
		IO::Iron::IronMQ::Api::IRONMQ_PEEK_MESSAGES_ON_A_QUEUE(),
		{
			'{Queue Name}' => $queue_name,
			%query_params
		}
	  );
	$self->{'last_http_status_code'} = $http_status_code;

	my @peeked_messages;
	my $messages = $response_message->{'messages'};    # messages.
	foreach ( @{$messages} ) {
		my $msg = $_;
		$log->debugf( 'peeked IronMQ Message (queue name=%s; message id=%s.',
			$self->{'name'}, $msg->{'id'} );
		my $message = IO::Iron::IronMQ::Message->new(
			{
				'body'    => $msg->{'body'},
				'timeout' => $msg->{'timeout'},
				'id'      => $msg->{'id'},
			}
		);
		CORE::push @peeked_messages,
		  $message;    # using CORE routine, not this class method.
	}
	$log->tracef( 'Exiting peek: %s',
		@peeked_messages ? @peeked_messages : '[NONE]' );
	return @peeked_messages;
}

=head2 delete

=over

=item Params: one or more message ids.

=item Return: the deleted message ids (if in list context), or the
number of messages deleted.

=back

=cut

sub delete { ## no critic (Subroutines::ProhibitBuiltinHomonyms)
	my ( $self, @message_ids ) = @_;
	assert_positive(scalar @message_ids, 'There is one or more message ids.');
	$log->tracef( 'Entering delete(%s)', @message_ids );

	my $queue_name = $self->name();
	my $connection = $self->{'connection'};
	my %item_body  = ( 'ids' => \@message_ids );

	my ( $http_status_code, $response_message ) =
	  $connection->perform_iron_action(
		IO::Iron::IronMQ::Api::IRONMQ_DELETE_MULTIPLE_MESSAGES_FROM_A_QUEUE(),
		{
			'{Queue Name}' => $queue_name,
			'body'         => \%item_body,
		}
	  );
	$self->{'last_http_status_code'} = $http_status_code;

	my $msg = $response_message->{'msg'};    # Should be 'Deleted'
	$log->debugf( 'Deleted IronMQ Message(s) (queue name=%s; message id(s)=%s.',
		$queue_name, ( join q{,}, @message_ids ) );
	if (wantarray) {
		$log->tracef( 'Exiting push: %s', ( join q{:}, @message_ids ) );
		return @message_ids;
	}
	else {
		if ( scalar @message_ids == 1 ) {
			$log->tracef( 'Exiting push: %s', $message_ids[0] );
			return $message_ids[0];
		}
		else {
			$log->tracef( 'Exiting push: %s', scalar @message_ids );
			return scalar @message_ids;
		}
	}
}

=head2 release

=over

=item Params: Message id.

=item Return: 1

=back

=cut

sub release {
	my ( $self, $msg_id, $msg_delay ) = @_;
	assert_nonblank( $msg_id, 'msg_id is a non null string.' );
	$log->tracef( 'Entering release(%s)', $msg_id, $msg_delay );
	$msg_delay = defined $msg_delay ? $msg_delay : 0;
	assert_nonnegative_integer( $msg_delay, 'msg_delay is a non negative integer.' );

	my $queue_name = $self->name();
	my $connection = $self->{'connection'};
	my %item_body;
	$item_body{'delay'} = $msg_delay if $msg_delay;
	my ( $http_status_code, $response_message ) =
	  $connection->perform_iron_action(
		IO::Iron::IronMQ::Api::IRONMQ_RELEASE_A_MESSAGE_ON_A_QUEUE(),
		{
			'{Queue Name}' => $queue_name,
			'{Message ID}'  => $msg_id,
			'body'         => \%item_body,
		}
	  );
	$self->{'last_http_status_code'} = $http_status_code;
	$log->debugf(
		'Released IronMQ Message(s) (queue name=%s; message id=%s; delay=%d)',
		$queue_name, $msg_id, $msg_delay ? $msg_delay : 0 );

	$log->tracef( 'Exiting release: %s', 1 );
	return 1;
}

=head2 touch

=over

=item Params: Message id.

=item Return: 1 if successful, 0 if failed to touch.

=back

=cut

sub touch {
	my ( $self, $msg_id ) = @_;
	assert_nonblank( $msg_id, 'msg_id is a non null string.' );
	$log->tracef( 'Entering touch(%s)', $msg_id );

	my $queue_name = $self->name();
	my $connection = $self->{'connection'};
	my %item_body;
	my ( $http_status_code, $response_message ) =
	  $connection->perform_iron_action(
		IO::Iron::IronMQ::Api::IRONMQ_TOUCH_A_MESSAGE_ON_A_QUEUE(),
		{
			'{Queue Name}' => $queue_name,
			'{Message ID}'  => $msg_id,
			'body'         => \%item_body,    # Empty body.
		}
	  );
	$self->{'last_http_status_code'} = $http_status_code;
	$log->debugf( 'Touched IronMQ Message(s) (queue name=%s; message id(s)=%s.',
		$queue_name, $msg_id );

	$log->tracef( 'Exiting touch: %s', 1 );
	return 1;
}

=head2 clear

=over

=item Params: [None].

=item Return: 1.

=back

=cut

sub clear {
	my ($self) = @_;
	$log->tracef('Entering clear()');

	my $queue_name = $self->name();
	my $connection = $self->{'connection'};
	my %item_body;
	my ( $http_status_code, $response_message ) =
	  $connection->perform_iron_action(
		IO::Iron::IronMQ::Api::IRONMQ_CLEAR_ALL_MESSAGES_FROM_A_QUEUE(),
		{
			'{Queue Name}' => $queue_name,
			'body'         => \%item_body,    # Empty body.
		}
	  );
	$self->{'last_http_status_code'} = $http_status_code;
	my $msg = $response_message->{'msg'};    # Should be 'Cleared'
	$log->debugf( 'Cleared IronMQ Message queue %s.', $queue_name );

	$log->tracef( 'Exiting clear: %s', 1 );
	return 1;
}

=head2 size

=over

=item Params: [none]

=item Return: queue size (integer).

=back

=cut

sub size {
	my ($self) = @_;
	$log->tracef('Entering size().');

	my $queue_name = $self->name();
	my $connection = $self->{'connection'};
	my ( $http_status_code, $response_message ) =
	  $connection->perform_iron_action(
		IO::Iron::IronMQ::Api::IRONMQ_GET_INFO_ABOUT_A_MESSAGE_QUEUE(),
		{ '{Queue Name}' => $queue_name, } );
	$self->{'last_http_status_code'} = $http_status_code;
	my $size = $response_message->{'size'};
	$log->debugf( 'Queue size is %s.', $size );

	$log->tracef( 'Exiting size(): %s', $size );
	return $size;
}

=head1 AUTHOR

Mikko Koivunalho, C<< <mikko.koivunalho at iki.fi> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-io-iron at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=IO-Iron>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc IO::Iron::IronMQ::Queue


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=IO-Iron>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/IO-Iron>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/IO-Iron>

=item * Search CPAN

L<http://search.cpan.org/dist/IO-Iron/>

=back


=head1 ACKNOWLEDGMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2013 Mikko Koivunalho.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1;    # End of IO::Iron::IronMQ::Queue
