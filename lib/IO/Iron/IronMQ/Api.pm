package IO::Iron::IronMQ::Api;

## no critic (Documentation::RequirePodAtEnd)
## no critic (Documentation::RequirePodSections)

use 5.008_001;
use strict;
use warnings FATAL => 'all';

# Global Creator
BEGIN {
	# No exports.
}

# Global Destructor
END {
}

=head1 NAME

IO::Iron::IronMQ::Api - IronMQ API reference for Perl Client Libraries!

=head1 VERSION

Version 0.07

=cut

our $VERSION = '0.07';


=head1 SYNOPSIS

This package is for internal use of IO::Iron::IronMQ::Client/Queue packages.


=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=cut

=head2 Operate message queues

=head3 IRONMQ_LIST_MESSAGE_QUEUES

/projects/{Project ID}/queues

=cut

sub IRONMQ_LIST_MESSAGE_QUEUES {
	return {
			'action_name'  => 'IRONMQ_LIST_MESSAGE_QUEUES',
			'href'         => '{Protocol}://{Host}:{Port}{Host Path Prefix}/projects/{Project ID}/queues',
			'action'       => 'GET',
			'return'       => 'LIST',
			'retry'        => 0,
			'require_body' => 0,
			'paged'        => 1,
			'per_page'     => 100,
			'url_escape'   => { '{Project ID}' => 1 },
			'log_message'  => '(project={Project ID}). Listed message queues.',
		};
}

=head3 IRONMQ_GET_INFO_ABOUT_A_MESSAGE_QUEUE

/projects/{Project ID}/queues/{Queue Name}

=cut

sub IRONMQ_GET_INFO_ABOUT_A_MESSAGE_QUEUE {
	return {
			'action_name'  => 'IRONMQ_GET_INFO_ABOUT_A_MESSAGE_QUEUE',
			'href'         => '{Protocol}://{Host}:{Port}{Host Path Prefix}/projects/{Project ID}/queues/{Queue Name}',
			'action'       => 'GET',
			'return'       => 'HASH',
			'retry'        => 1,
			'require_body' => 0,
			'url_escape'   => { '{Project ID}' => 1, '{Queue Name}' => 1 },
			'log_message'  => '(project={Project ID}, queue={Queue Name}). Got info about a message queue.',
		};
}

=head3 IRONMQ_UPDATE_A_MESSAGE_QUEUE

/projects/{Project ID}/queues/{Queue Name}

=cut

sub IRONMQ_UPDATE_A_MESSAGE_QUEUE {
	return {
			'action_name'  => 'IRONMQ_UPDATE_A_MESSAGE_QUEUE',
			'href'         => '{Protocol}://{Host}:{Port}{Host Path Prefix}/projects/{Project ID}/queues/{Queue Name}',
			'action'       => 'POST',
			'return'       => 'MESSAGE',
			'retry'        => 1,
			'require_body' => 1,
			'request_fields' => { 'subscribers' => 1, 'push_type' => 1, 'retries' => 1, 'retries_delay' => 1 },
			'url_escape'   => { '{Project ID}' => 1, '{Queue Name}' => 1 },
			'log_message'  => '(project={Project ID}, queue={Queue Name}). Updated a message queue.',
		};
}

=head3 IRONMQ_DELETE_A_MESSAGE_QUEUE

/projects/{Project ID}/queues/{Queue Name}

=cut

sub IRONMQ_DELETE_A_MESSAGE_QUEUE {
	return {
			'action_name'  => 'IRONMQ_DELETE_A_MESSAGE_QUEUE',
			'href'         => '{Protocol}://{Host}:{Port}{Host Path Prefix}/projects/{Project ID}/queues/{Queue Name}',
			'action'       => 'DELETE',
			'return'       => 'MESSAGE',
			'retry'        => 1,
			'require_body' => 0,
			'url_escape'   => { '{Project ID}' => 1, '{Queue Name}' => 1 },
			'log_message'  => '(project={Project ID}, queue={Queue Name}). Deleted message queue.',
		};
}

=head3 IRONMQ_CLEAR_ALL_MESSAGES_FROM_A_QUEUE

/projects/{Project ID}/queues/{Queue Name}/clear

=cut

sub IRONMQ_CLEAR_ALL_MESSAGES_FROM_A_QUEUE {
	return {
			'action_name'  => 'IRONMQ_CLEAR_ALL_MESSAGES_FROM_A_QUEUE',
			'href'         => '{Protocol}://{Host}:{Port}{Host Path Prefix}/projects/{Project ID}/queues/{Queue Name}/clear',
			'action'       => 'POST',
			'return'       => 'MESSAGE',
			'retry'        => 1,
			'require_body' => 1,
			'request_fields' => {},
			'url_escape'   => { '{Project ID}' => 1, '{Queue Name}' => 1 },
			'log_message'  => '(project={Project ID}, queue={Queue Name}). Cleared all messages from the queue.',
		};
}

=head3 IRONMQ_SET_ALERTS_TO_A_QUEUE

/projects/{Project ID}/queues/{Queue Name}/alerts/

=cut

sub IRONMQ_SET_ALERTS_TO_A_QUEUE {
	return {
			'action_name'  => 'IRONMQ_SET_ALERTS_TO_A_QUEUE',
			'href'         => '{Protocol}://{Host}:{Port}{Host Path Prefix}/projects/{Project ID}/queues/{Queue Name}/alerts',
			'action'       => 'POST',
			'return'       => 'MESSAGE',
			'retry'        => 1,
			'require_body' => 1,
			'request_fields' => { 'alerts' => 1 },
			'url_escape'   => { '{Project ID}' => 1, '{Queue Name}' => 1 },
			'log_message'  => '(project={Project ID}, queue={Queue Name}). Set alerts to the queue.',
		};
}

=head2 Operate messages

=head3 IRONMQ_ADD_MESSAGES_TO_A_QUEUE

/projects/{Project ID}/queues/{Queue Name}/messages

=cut

sub IRONMQ_ADD_MESSAGES_TO_A_QUEUE {
	return {
			'action_name'    => 'IRONMQ_ADD_MESSAGES_TO_A_QUEUE',
			'href'           => '{Protocol}://{Host}:{Port}{Host Path Prefix}/projects/{Project ID}/queues/{Queue Name}/messages',
			'action'         => 'POST',
			'return'         => 'HASH',
			'retry'          => 1,
			'require_body'   => 1,
			'request_fields' => { 'messages' => 1 },
			'url_escape'     => { '{Project ID}' => 1, '{Queue Name}' => 1 },
			'log_message'    => '(project={Project ID}, queue={Queue Name}). Pushed messages to the queue.',
		};
}

=head3 IRONMQ_GET_MESSAGES_FROM_A_QUEUE

/projects/{Project ID}/queues/{Queue Name}/messages

=cut

sub IRONMQ_GET_MESSAGES_FROM_A_QUEUE {
	return {
			'action_name'    => 'IRONMQ_GET_MESSAGES_FROM_A_QUEUE',
			'href'           => '{Protocol}://{Host}:{Port}{Host Path Prefix}/projects/{Project ID}/queues/{Queue Name}/messages',
			'action'         => 'GET',
			'return'         => 'HASH',
			'retry'          => 1,
			'require_body'   => 0,
			'url_params'     => { 'n' => 1, 'timeout' => 1 },
			'url_escape'     => { '{Project ID}' => 1, '{Queue Name}' => 1 },
			'log_message'    => '(project={Project ID}, queue={Queue Name}). Pulled messages from the queue.',
		};
}

=head3 IRONMQ_PEEK_MESSAGES_ON_A_QUEUE

/projects/{Project ID}/queues/{Queue Name}/messages/peek

=cut

sub IRONMQ_PEEK_MESSAGES_ON_A_QUEUE {
	return {
			'action_name'    => 'IRONMQ_PEEK_MESSAGES_ON_A_QUEUE',
			'href'           => '{Protocol}://{Host}:{Port}{Host Path Prefix}/projects/{Project ID}/queues/{Queue Name}/messages/peek',
			'action'         => 'GET',
			'return'         => 'HASH',
			'retry'          => 1,
			'require_body'   => 0,
			'url_params'     => { 'n' => 1 },
			'url_escape'     => { '{Project ID}' => 1, '{Queue Name}' => 1 },
			'log_message'    => '(project={Project ID}, queue={Queue Name}). Peeked at messages on the queue.',
		};
}

=head3 IRONMQ_DELETE_A_MESSAGE_FROM_A_QUEUE

/projects/{Project ID}/queues/{Queue Name}/messages/{Message ID}

=cut

sub IRONMQ_DELETE_A_MESSAGE_FROM_A_QUEUE {
	return {
			'action_name'    => 'IRONMQ_DELETE_A_MESSAGE_FROM_A_QUEUE',
			'href'           => '{Protocol}://{Host}:{Port}{Host Path Prefix}/projects/{Project ID}/queues/{Queue Name}/messages/{Message ID}',
			'action'         => 'DELETE',
			'return'         => 'MESSAGE',
			'retry'          => 1,
			'require_body'   => 0,
			'url_escape'     => { '{Project ID}' => 1, '{Queue Name}' => 1 },
			'log_message'  => '(project={Project ID}, queue={Queue Name}, message_id={Message ID}). Deleted a message from the queue.',
		};
}

=head3 IRONMQ_DELETE_MULTIPLE_MESSAGES_FROM_A_QUEUE

/projects/{Project ID}/queues/{Queue Name}/messages

=cut

sub IRONMQ_DELETE_MULTIPLE_MESSAGES_FROM_A_QUEUE {
	return {
			'action_name'    => 'IRONMQ_DELETE_MULTIPLE_MESSAGES_FROM_A_QUEUE',
			'href'           => '{Protocol}://{Host}:{Port}{Host Path Prefix}/projects/{Project ID}/queues/{Queue Name}/messages',
			'action'         => 'DELETE',
			'return'         => 'MESSAGE',
			'retry'          => 1,
			'require_body'   => 1,
			'request_fields' => { 'ids' => 1 },
			'url_escape'     => { '{Project ID}' => 1, '{Queue Name}' => 1 },
			'log_message'    => '(project={Project ID}, queue={Queue Name}). Deleted messages from the queue.',
		};
}

=head3 IRONMQ_TOUCH_A_MESSAGE_ON_A_QUEUE

/projects/{Project ID}/queues/{Queue Name}/messages/{Message ID}/touch

=cut

sub IRONMQ_TOUCH_A_MESSAGE_ON_A_QUEUE {
	return {
			'action_name'    => 'IRONMQ_TOUCH_A_MESSAGE_ON_A_QUEUE',
			'href'           => '{Protocol}://{Host}:{Port}{Host Path Prefix}/projects/{Project ID}/queues/{Queue Name}/messages/{Message ID}/touch',
			'action'         => 'POST',
			'return'         => 'MESSAGE',
			'retry'          => 1,
			'require_body'   => 1,
			'request_fields' => {},
			'url_escape'     => { '{Project ID}' => 1, '{Queue Name}' => 1 },
			'log_message'    => '(project={Project ID}, queue={Queue Name}, message_id={Message ID}). Touched a message on the queue.',
		};
}

=head3 IRONMQ_RELEASE_A_MESSAGE_ON_A_QUEUE

/projects/{Project ID}/queues/{Queue Name}/messages/{Message ID}/release

=cut

sub IRONMQ_RELEASE_A_MESSAGE_ON_A_QUEUE {
	return {
			'action_name'    => 'IRONMQ_RELEASE_A_MESSAGE_ON_A_QUEUE',
			'href'           => '{Protocol}://{Host}:{Port}{Host Path Prefix}/projects/{Project ID}/queues/{Queue Name}/messages/{Message ID}/release',
			'action'         => 'POST',
			'return'         => 'MESSAGE',
			'retry'          => 1,
			'require_body'   => 1,
			'request_fields' => { 'delay' => 1 },
			'url_escape'     => { '{Project ID}' => 1, '{Queue Name}' => 1 },
			'log_message'    => '(project={Project ID}, queue={Queue Name}, message_id={Message ID}). Released a message on the queue.',
		};
}

# TODO Push queue stuff missing.

=head1 AUTHOR

Mikko Koivunalho, C<< <mikko.koivunalho at iki.fi> >>


=head1 BUGS

Please report any bugs or feature requests to C<bug-io-iron at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=IO-Iron>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc IO::Iron::IronMQ::Client


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

Cool idea, "message queue in the cloud": http://www.iron.io/.

=head1 TODO

=over 4

=back


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

1; # End of IO::Iron::IronMQ::Api
