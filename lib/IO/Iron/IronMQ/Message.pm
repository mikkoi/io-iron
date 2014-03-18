package IO::Iron::IronMQ::Message;

## no critic (Documentation::RequirePodAtEnd)
## no critic (Documentation::RequirePodSections)

use 5.008_001;
use strict;
use warnings FATAL => 'all';

# Global creator
BEGIN {
}

# Global destructor
END {
}

=head1 NAME

IO::Iron::IronMQ::Message - IronMQ (Message Queue) Client (Message).

=head1 VERSION

Version 0.07

=cut

our $VERSION = '0.07';


=head1 SYNOPSIS

Please see IO::Iron::IronMQ::Client for usage.

=head1 REQUIREMENTS

=cut

use Log::Any  qw($log);
use Hash::Util qw{lock_keys unlock_keys};
use Carp::Assert::More;
use English '-no_match_vars';

# CONSTANTS for this module

# DEFAULTS

=head1 SUBROUTINES/METHODS

=head2 new

Creator function.

=cut

sub new {
	my ($class, $params) = @_;
	$log->tracef('Entering new(%s, %s)', $class, $params);
	my $self;
	my @self_keys = ( ## no critic (CodeLayout::ProhibitQuotedWordLists)
			'body',                        # Message body (free text), can be empty.
			'timeout',                     # When reading from queue, after timeout (in seconds), item will be placed back onto queue.
			'delay',                       # The item will not be available on the queue until this many seconds have passed.
			'expires_in',                  # How long in seconds to keep the item on the queue before it is deleted.
			'id',                          # Message id from IronMQ queue (after message has been pulled/peeked).
			'reserved_count',              # FIXME item reserved_count
	);
	lock_keys(%{$self}, @self_keys);
	$self->{'body'} = defined $params->{'body'} ? $params->{'body'} : undef;
	$self->{'timeout'} = defined $params->{'timeout'} ? $params->{'timeout'} : undef;
	$self->{'delay'} = defined $params->{'delay'} ? $params->{'delay'} : undef;
	$self->{'expires_in'} = defined $params->{'expires_in'} ? $params->{'expires_in'} : undef;
	$self->{'id'} = defined $params->{'id'} ? $params->{'id'} : undef;
	$self->{'reserved_count'} = defined $params->{'reserved_count'} ? $params->{'reserved_count'} : undef;
	# All of the above can be undefined, except the body: the message can not be empty.
	assert_defined( $self->{'body'}, 'body is defined and is not blank.' );
	# If timeout, delay or expires_in are undefined, the IronMQ defaults (at the server) will be used.

	unlock_keys(%{$self});
	my $blessed_ref = bless $self, $class;
	lock_keys(%{$self}, @self_keys);

	$log->tracef('Exiting new: %s', $blessed_ref);
	return $blessed_ref;
}

=head2 body

Set or get body.

=cut

sub body {
	my ($self, $msg_body) = @_;
	$log->tracef('Entering body()');
	if( defined $msg_body ) {
		$self->{'body'} = $msg_body;
		return 1;
	}
	else {
		return $self->{'body'};
	}
}

=head2 timeout

Set or get timeout.

=cut

sub timeout {
	my ($self, $msg_timeout) = @_;
	$log->tracef('Entering timeout()');
	if( defined $msg_timeout ) {
		$self->{'timeout'} = $msg_timeout;
		return 1;
	}
	else {
		return $self->{'timeout'};
	}
}

=head2 delay

Set or get delay.

=cut

sub delay {
	my ($self, $msg_delay) = @_;
	$log->tracef('Entering delay()');
	if( defined $msg_delay ) {
		$self->{'delay'} = $msg_delay;
		return 1;
	}
	else {
		return $self->{'delay'};
	}
}

=head2 expires_in

Set or get expires_in.

=cut

sub expires_in {
	my ($self, $msg_expires_in) = @_;
	$log->tracef('Entering expires_in()');
	if( defined $msg_expires_in ) {
		$self->{'expires_in'} = $msg_expires_in;
		return 1;
	}
	else {
		return $self->{'expires_in'};
	}
}

=head2 id

Set or get id.

=cut

sub id {
	my ($self, $msg_id) = @_;
	$log->tracef('Entering id()');
	if( defined $msg_id ) {
		$self->{'id'} = $msg_id;
		return 1;
	}
	else {
		return $self->{'id'};
	}
}

=head2 reserved_count

Return: reserved_count

=cut

sub reserved_count {
	my ($self) = @_;
	$log->tracef('Entering reserved_count()');
	return $self->{'reserved_count'};
}



=head1 AUTHOR

Mikko Koivunalho, C<< <mikko.koivunalho at iki.fi> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-io-iron at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=IO-Iron>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc IO::Iron::IronMQ


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

1; # End of IO::Iron::IronMQ::Message
