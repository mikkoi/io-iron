package IO::Iron::PolicyBase;

## no critic (Documentation::RequirePodAtEnd)
## no critic (Documentation::RequirePodSections)

use 5.010_000;
use strict;
use warnings FATAL => 'all';

# Global creator
BEGIN {
    # Inherit nothing
}

# Global destructor
END {
}

=head1 NAME

IO::Iron::PolicyBase - Base package (inherited) for IO::Iron::IronMQ/Cache/Worker::Policy packages.

=cut

# VERSION: generated by DZP::OurPkgVersion

=head1 SYNOPSIS

This class is for internal use only.

=cut

#    package IO::Iron::Policy;
#    # Global creator
#    BEGIN {
#        use parent qw( IO::Iron::PolicyBase ); # Inheritance
#    }

use Log::Any  qw{$log};
use Hash::Util 0.06 qw{lock_keys unlock_keys};
use Carp;
use Carp::Assert;
use Carp::Assert::More;
use English '-no_match_vars';
use File::Spec ();
use Params::Validate qw(:all);
use Exception::Class (
      'IronPolicyException' => {
        fields => ['policy', 'candidate'],
      }
  );

use IO::Iron::Common ();
use IO::Iron::PolicyBase::CharacterGroup ();

=head1 METHODS

=cut

# INTERNAL METHODS
# For use in the inheriting subclass

=head2 IRON_CLIENT_DEFAULT_POLICIES

Default policies for all clients.
These policies allow everything.

=cut

# TODO policy charset, list possible alternatives: 
sub IRON_CLIENT_DEFAULT_POLICIES {
    my %default_policies =
            (
            'definition' => {
                'character_set' => 'ascii', # The only supported character set!
                'character_groups' => {
                    '[:mychars:]' => 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ',
                    '[:mydigits:]' => '0123456789',
                },
            },
            'queue' => { 'name' => [ '[[:graph:]]{1,}' ], },
            'cache' => { 'name' => [ '[[:graph:]]{1,}' ], 'item_key' => [ '[[:graph:]]{1,}' ]},
            'worker' => { 'name' => [ '[[:graph:]]{1,}' ], },
            );
    return %default_policies;
}

sub _do_alt {
    my $self = shift;
    my %params = validate(
        @_, {
            'str' => { type => SCALAR, }, # name/key name.
        }
    );
    my $str = $params{'str'};
    $log->tracef('Entering _do_alt(%s)', $str);
    assert(length $str > 0, 'String length > 0.');
    my @processed_alts;
    if( $str =~ /^([[:graph:]]*)(\[:[[:graph:]]+:\]\{[[:digit:]]+\,[[:digit:]]+\})([[:graph:]]*)$/sx
            || ($str =~ /^([[:graph:]]*)(\[:[[:graph:]]+:\]\{([[:digit:]]+)\})([[:graph:]]*)$/sx && $3 > 1)
            ) {
        $log->tracef('We need to do recursion.', $str);
        my $preceeding_part = $1;
        my $group_part = $2;
        my $succeeding_part = defined $4 ? $4 : $3;
        $log->tracef('$preceeding_part=%s;$group_part=%s;$succeeding_part=%s;',
            $preceeding_part, $group_part, $succeeding_part);
        my @alternatives = _make_ones($preceeding_part, $group_part, $succeeding_part);
        foreach (@alternatives) {
            push @processed_alts, $self->_do_alt('str' => $_);
        }
    }
    else {
        $log->tracef('We need to create the alternatives.', $str);
        if( $str =~ /^([[:graph:]]*)(\[:[[:graph:]]+:\]\{1\})([[:graph:]]*)$/sx ) {
            my @alts;
            my $preceeding_part = $1;
            my $group_part = $2;
            my $succeeding_part = $3;
            $log->tracef('$preceeding_part=%s;$group_part=%s;$succeeding_part=%s;',
                $preceeding_part, $group_part, $succeeding_part);
            if($group_part =~ /^(\[:[[:graph:]]+:\])\{([[:digit:]]+)\}$/sx) {
                my $group = $1;
                my $lowest_amount = $2;
                my $highest_amount = $3;
                $log->tracef('$group=%s;$lowest_amount=%s;$highest_amount=%s;',
                    $group, $lowest_amount, $highest_amount);
                foreach ($self->_get_character_group_alternatives('character_group' => $group)) {
                    push @alts, $preceeding_part . $_ . $succeeding_part;
                }
            }
            $log->tracef('@alts=%s;', \@alts);
            foreach (@alts) {
                push @processed_alts, $self->_do_alt('str' => $_);
            }
        }
        else {
            push @processed_alts, $str;
        }
    }
    $log->tracef('Exiting _do_alt():%s', \@processed_alts);
    return @processed_alts;
}

sub _make_ones {
    my $preceeding_part = $_[0];
    my $group_part = $_[1];
    my $succeeding_part = $_[2];
    $log->tracef('_make_ones():$preceeding_part=%s;$group_part=%s;$succeeding_part=%s;',
        $preceeding_part, $group_part, $succeeding_part);
    $log->tracef('$group_part=%s;', $group_part);
    my @alternatives;
    if($group_part =~ /^(\[:[[:graph:]]+:\])\{([[:digit:]]+)\,([[:digit:]]+)\}$/msx) {
        my $group = $1;
        my $lowest_amount = $2;
        my $highest_amount = $3;
        $log->tracef('$group=%s;$lowest_amount=%s;$highest_amount=%s;',
            $group, $lowest_amount, $highest_amount);
        for($lowest_amount..$highest_amount) {
            my $group_str = $group . '{1}';
            push @alternatives, $preceeding_part . $group_str x $_ . $succeeding_part;
        }
    }
    elsif($group_part =~ /^(\[:[[:graph:]]+:\])\{([[:digit:]]+)\}$/msx) {
        my $group = $1;
        my $lowest_amount = $2;
        my $highest_amount = $2;
        $log->tracef('$group=%s;$lowest_amount=%s;$highest_amount=%s;',
            $group, $lowest_amount, $highest_amount);
        for(my $i = $lowest_amount; $i < $highest_amount + 1; $i++) {
            my $group_str = $group . '{1}';
            push @alternatives, $preceeding_part . $group_str x $i . $succeeding_part;
        }
    }
    else {
        $log->fatalf('Illegal string \'%s\'.', $group_part);
    }
    $log->tracef('@alternatives=%s;', \@alternatives);
    return @alternatives;
}

sub _get_character_group_alternatives {
    my $self = shift;
    my %params = validate(
        @_, {
            'character_group' => { type => SCALAR, regex => qr/^[[:graph:]]+$/msx, }, # name/key name.
        },
    );
    #assert_nonempty($params{'character_group'}, 'Parameter character_group has value.');
    my $chars;

    # Predefined groups (subset of POSIX) first!
    $chars = IO::Iron::PolicyBase::CharacterGroup::group(
            'character_group' => $params{'character_group'});
    if(!$chars) {
        $chars =
            $self->{'policy'}->{'definition'}->{'character_groups'}
            ->{$params{'character_group'}};
    }
    if($chars) {
        $log->tracef('$chars=%s;', $chars);
    }
    else {
        $log->fatalf('Character group \'%s\' not defined.', $params{'character_group'});
        croak("Character group \'$params{'character_group'}\' not defined.");
    }
    return split //msx, $chars;
}

# Return all possible alternatives

=head2 alternatives

Return all possible alternatives.

Parameters:

=over 8

=item required_policy, name/key name

=back

=cut

sub alternatives {
    my $self = shift;
    my %params = validate(
        @_, {
            'required_policy' => { type => SCALAR, }, # name/key name.
        }
    );
    assert_hashref( $self->{'policy'}, '\$self->{required_policy} is a reference to a list.');
    $log->tracef('Entering alternatives(%s)', \%params);

    my @alternatives;
    my $templates = $self->{'policy'}->{$params{'required_policy'}};
    assert_listref($templates, '$templates is a reference to a list');
    my @template_alternatives;
    foreach (@{$templates}) {
        $log->tracef('alternatives(): Template:\"%s\".)', $_);
        @template_alternatives = $self->_do_alt('str' => $_);
    }
#    assert_listref($templates, "\$templates is a reference to a list");
#    foreach (@{$templates}) {
#        $log->tracef('alternatives(): Comparing with template:\"%s\".)', $_);
#        if($params{'candidate'} =~ /^$_$/xgs) {
#            $validity = 1;
#            last;
#        }
#    }
    $log->tracef('Exiting alternatives():%s', \@template_alternatives);
    return @template_alternatives;
}

=head2 is_valid_policy

Is this policy valid?

Parameters:

=over 8

=item policy, name/key name.

=item candidate, proposed string.

=back

Return: Boolean.

=cut

sub is_valid_policy {
    my $self = shift;
    my %params = validate(
        @_, {
            'policy' => { type => SCALAR, }, # name/key name.
            'candidate' => { type => SCALAR, }, # string to check.
        }
    );
    assert_listref( $self->{'policy'}, '\$self->{policy} is a reference to a list.');
    $log->tracef('Entering is_valid_policy(%s)', \%params);
    my $validity = 0;
    my $templates = $self->{'policy'}->{$params{'policy'}};
    assert_listref($templates, "\$templates is a reference to a list");
    foreach (@{$templates}) {
        $log->tracef('is_valid_policy(): Comparing with template:\"%s\".)', $_);
        if($params{'candidate'} =~ /^$_$/xgs) {
            $validity = 1;
            last;
        }
    }
    $log->tracef('Exiting is_valid_policy():%d', $validity);
    return $validity;
}

# This method throws an exception of type IronPolicyException.

=head2 validate_with_policy

Validate a candidate string. Same as method is_valid_policy() but this method throws an exception of type IronPolicyException if the validation fails.

Parameters:

=over 8

=item policy, name/key name.

=item candidate, proposed string.

=back

Return: Boolean True if validation is successfull, otherwise throws an exception.

=cut

sub validate_with_policy {
    my $self = shift;
    my %params = validate(
        @_, {
            'policy' => { type => SCALAR, }, # name/key name.
            'candidate' => { type => SCALAR, }, # string to check.
        }
    );
    assert_hashref( $self->{'policy'}, '\$self->{policy} is a reference to a hash.');
    $log->tracef('Entering validate_with_policy(%s)', \%params);
    my $validity = 0;
    my $templates = $self->{'policy'}->{$params{'policy'}};
    assert_listref($templates, '\$templates is a reference to a list');
    foreach (@{$templates}) {
        $log->tracef('validate_with_policy(): Comparing with template:\"%s\".)', $_);
        if($params{'candidate'} =~ /^$_$/xgsm) {
            $validity = 1;
            last;
        }
    }
    if($validity == 0) {
        $log->tracef('Throwing exception in validate_with_policy(): policy=%s, candidate=%s', $params{'policy'}, $params{'candidate'});
        IronPolicyException->throw(
                policy => $params{'policy'},
                candidate => $params{'candidate'},
                error => 'IronPolicyException: policy=' . $params{'policy'}
                    . ' candidate=' . $params{'candidate'},
                );
    }
    $log->tracef('Exiting validate_with_policy():%d', $validity);
    return $validity;
}

=head2 get_policies

Get the policies from file or use the defaults.

The configuration is constructed as follows:

=over 8

=item 1. The global defaults.

=item 5. The policies file specified when instantiating the client library overwrites everything before it according to the file hierarchy.

=item 6. Return only the policies connected to this client (specify in derived class with method _THIS_POLICY).

=back

Return: ref to policies.

=cut

sub get_policies { ## no critic (Subroutines::RequireArgUnpacking)
    my $self = shift;
    my %params = validate(
        @_, {
            'policies' => { type => SCALAR|UNDEF, optional => 0, },
        }
    );
    $log->tracef('Entering get_policies(%s)', \%params);
    my %all_policies = IRON_CLIENT_DEFAULT_POLICIES(); ## Preset default policies.
    $log->tracef('Default policies: %s', \%all_policies);
    if(defined $params{'policies'}) { # policies file specified when creating the object, if given.
        IO::Iron::Common::_read_iron_config_file(\%all_policies,
                File::Spec->file_name_is_absolute($params{'policies'})
                ? $params{'policies'} : File::Spec->catfile(File::Spec->curdir(), $params{'policies'})
                );
    }
    my %policies = %{$all_policies{$self->_THIS_POLICY()}};
    $log->tracef('Exiting get_policies: %s', \%policies);
    return \%policies;
}


=head1 AUTHOR

Mikko Koivunalho, C<< <mikko.koivunalho at iki.fi> >>


=head1 BUGS

Please report any bugs or feature requests to C<bug-io-iron at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=IO-Iron>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc IO::Iron::PolicyBase


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
And well implemented.


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

1; # End of IO::Iron::PolicyBase
