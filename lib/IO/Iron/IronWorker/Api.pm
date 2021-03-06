package IO::Iron::IronWorker::Api;

## no critic (Documentation::RequirePodAtEnd)
## no critic (Documentation::RequirePodSections)

use 5.010_000;
use strict;
use warnings;

# Global Creator
BEGIN {
	# No exports.
}

# Global Destructor
END {
}

=for stopwords IronWorker API Mikko Koivunalho

=cut

# ABSTRACT: IronWorker API reference for Perl Client Libraries!

# VERSION: generated by DZP::OurPkgVersion


=head1 SYNOPSIS

This package is for internal use of IO::Iron::IronWorker::Client/Queue packages.


=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=cut

=head2 Code Packages

=head3 IRONWORKER_LIST_CODE_PACKAGES

/projects/{Project ID}/codes

=cut

sub IRONWORKER_LIST_CODE_PACKAGES {
	return {
			'action_name'    => 'IRONWORKER_LIST_CODE_PACKAGES',
			'href'           => '{Protocol}://{Host}:{Port}/{API Version}/projects/{Project ID}/codes',
			'action'         => 'GET',
			'return'         => 'LIST:codes',
			'retry'          => 0,
			'require_body'   => 0,
			'paged'          => 1,
			'per_page'       => 100,
			'url_escape'     => { '{Project ID}' => 1 },
			'log_message'    => '(project={Project ID}). Listed code packages.',
		};
}

=head3 IRONWORKER_UPLOAD_OR_UPDATE_A_CODE_PACKAGE

/projects/{Project ID}/codes

=cut

sub IRONWORKER_UPLOAD_OR_UPDATE_A_CODE_PACKAGE {
	return {
			'action_name'    => 'IRONWORKER_UPLOAD_OR_UPDATE_A_CODE_PACKAGE',
			'href'           => '{Protocol}://{Host}:{Port}/{API Version}/projects/{Project ID}/codes',
			'action'         => 'POST',
			'return'         => 'HASH',
			'retry'          => 1,
			'require_body'   => 1,
			'request_fields' => { 'name' => 1, 'file' => 1, 'file_name' => 1, 'runtime' => 1, 'config' => 1, 'max_concurrency' => 1, 'retries' => 1, 'retries_delay' => 1 },
			'url_escape'     => { '{Project ID}' => 1 },
			'content_type'   => 'multipart',
			'log_message'    => '(project={Project ID}). Uploaded or updated a code package.',
		};
}

=head3 IRONWORKER_GET_INFO_ABOUT_A_CODE_PACKAGE

/projects/{Project ID}/codes/{Code ID}

=cut

sub IRONWORKER_GET_INFO_ABOUT_A_CODE_PACKAGE {
	return {
			'action_name'    => 'IRONWORKER_GET_INFO_ABOUT_A_CODE_PACKAGE',
			'href'           => '{Protocol}://{Host}:{Port}/{API Version}/projects/{Project ID}/codes/{Code ID}',
			'action'         => 'GET',
			'return'         => 'HASH',
			'retry'          => 1,
			'require_body'   => 0,
			'url_escape'     => { '{Project ID}' => 1, '{Code ID}' => 1 },
			'log_message'    => '(project={Project ID}, code={Code ID}). Got info about a code package.',
		};
}

=head3 IRONWORKER_DELETE_A_CODE_PACKAGE

/projects/{Project ID}/codes/{Code ID}

=cut

sub IRONWORKER_DELETE_A_CODE_PACKAGE {
	return {
			'action_name'  => 'IRONWORKER_DELETE_A_CODE_PACKAGE',
			'href'         => '{Protocol}://{Host}:{Port}/{API Version}/projects/{Project ID}/codes/{Code ID}',
			'action'       => 'DELETE',
			'return'       => 'MESSAGE',
			'retry'        => 1,
			'require_body' => 0,
			'url_escape'   => { '{Project ID}' => 1, '{Code ID}' => 1 },
			'log_message'  => '(project={Project ID}, code={Code ID}). Deleted a code package.',
		};
}

=head3 IRONWORKER_DOWNLOAD_A_CODE_PACKAGE

/projects/{Project ID}/codes/{Code ID}/download

=cut

sub IRONWORKER_DOWNLOAD_A_CODE_PACKAGE {
	return {
			'action_name'    => 'IRONWORKER_DOWNLOAD_A_CODE_PACKAGE',
			'href'           => '{Protocol}://{Host}:{Port}/{API Version}/projects/{Project ID}/codes/{Code ID}/download',
			'action'         => 'GET',
			'return'         => 'BINARY',
			'retry'          => 1,
			'require_body'   => 0,
			'url_params'     => { 'revision' => 1 },
			'url_escape'     => { '{Project ID}' => 1, '{Code ID}' => 1 },
			'log_message'    => '(project={Project ID}, code={Code ID}). Downloaded a code package.',
		};
}

=head3 IRONWORKER_LIST_CODE_PACKAGE_REVISIONS

/projects/{Project ID}/codes/{Code ID}/revisions

=cut

sub IRONWORKER_LIST_CODE_PACKAGE_REVISIONS {
	return {
			'action_name'    => 'IRONWORKER_LIST_CODE_PACKAGE_REVISIONS',
			'href'           => '{Protocol}://{Host}:{Port}/{API Version}/projects/{Project ID}/codes/{Code ID}/revisions',
			'action'         => 'GET',
			'return'         => 'LIST:revisions',
			'retry'          => 1,
			'require_body'   => 0,
			'paged'          => 1,
			'per_page'       => 100,
			'url_escape'     => { '{Project ID}' => 1, '{Code ID}' => 1 },
			'log_message'    => '(project={Project ID}, code={Code ID}). Listed code package revisions.',
		};
}

=head2 Tasks

=head3 IRONWORKER_LIST_TASKS

/projects/{Project ID}/tasks

=cut

sub IRONWORKER_LIST_TASKS {
	return {
			'action_name'    => 'IRONWORKER_LIST_TASKS',
			'href'           => '{Protocol}://{Host}:{Port}/{API Version}/projects/{Project ID}/tasks',
			'action'         => 'GET',
			'return'         => 'LIST:tasks',
			'retry'          => 1,
			'require_body'   => 0,
			'paged'          => 1,
			'per_page'       => 100,
			'url_params'     => { 'code_name' => 1, 'queued' => 1, 'running' => 1, 'complete' => 1, 'error' => 1, 'cancelled' => 1, 'killed' => 1, 'timeout' => 1, 'from_time' => 1, 'to_time' => 1 },
			'url_escape'     => { '{Project ID}' => 1, 'code_name' => 1 },
			'log_message'    => '(project={Project ID}). Listed tasks.',
		};
}

=head3 IRONWORKER_QUEUE_A_TASK

/projects/{Project ID}/tasks

=cut

sub IRONWORKER_QUEUE_A_TASK {
	return {
			'action_name'    => 'IRONWORKER_QUEUE_A_TASK',
			'href'           => '{Protocol}://{Host}:{Port}/{API Version}/projects/{Project ID}/tasks',
			'action'         => 'POST',
			'return'         => 'HASH',
			'retry'          => 1,
			'require_body'   => 1,
			'request_fields' => { 'tasks' => 1 },
			'url_escape'     => { '{Project ID}' => 1 },
			'log_message'    => '(project={Project ID}). Queued tasks.',
		};
}

=head3 IRONWORKER_QUEUE_A_TASK_FROM_A_WEBHOOK

/projects/{Project ID}/tasks/webhook

=cut

sub IRONWORKER_QUEUE_A_TASK_FROM_A_WEBHOOK {
	return {
			'action_name'    => 'IRONWORKER_QUEUE_A_TASK_FROM_A_WEBHOOK',
			'href'           => '{Protocol}://{Host}:{Port}/{API Version}/projects/{Project ID}/tasks/webhook',
			'action'         => 'POST',
			'return'         => 'HASH',
			'retry'          => 1,
			'require_body'   => 1,
			'url_params'     => { 'code_name' => 1 },
			'url_escape'     => { '{Project ID}' => 1 },
			'log_message'    => '(project={Project ID}). Queued tasks.',
		}; # Request body will be passed along as the payload for the task.
}



=head3 IRONWORKER_GET_INFO_ABOUT_A_TASK

/projects/{Project ID}/tasks/{Task ID}

=cut

sub IRONWORKER_GET_INFO_ABOUT_A_TASK {
	return {
			'action_name'    => 'IRONWORKER_GET_INFO_ABOUT_A_TASK',
			'href'           => '{Protocol}://{Host}:{Port}/{API Version}/projects/{Project ID}/tasks/{Task ID}',
			'action'         => 'GET',
			'return'         => 'HASH',
			'retry'          => 1,
			'require_body'   => 0,
			'url_escape'     => { '{Project ID}' => 1, '{Task ID}' => 1 },
			'log_message'    => '(project={Project ID}, code={Task ID}). Got info about a task.',
		};
}

=head3 	IRONWORKER_GET_A_TASKS_LOG

/projects/{Project ID}/tasks/{Task ID}/log

=cut

sub IRONWORKER_GET_A_TASKS_LOG {
	return {
			'action_name'    => 'IRONWORKER_GET_A_TASKS_LOG',
			'href'           => '{Protocol}://{Host}:{Port}/{API Version}/projects/{Project ID}/tasks/{Task ID}/log',
			'action'         => 'GET',
			'return'         => 'PLAIN_TEXT',
			'retry'          => 1,
			'require_body'   => 0,
			'url_escape'     => { '{Project ID}' => 1, '{Task ID}' => 1 },
			'log_message'    => '(project={Project ID}, code={Task ID}). Got a task\'s log.',
		}; # Return plain text, not JSON!
}

=head3 IRONWORKER_CANCEL_A_TASK

/projects/{Project ID}/tasks/{Task ID}/cancel

=cut

sub IRONWORKER_CANCEL_A_TASK {
	return {
			'action_name'    => 'IRONWORKER_CANCEL_A_TASK',
			'href'           => '{Protocol}://{Host}:{Port}/{API Version}/projects/{Project ID}/tasks/{Task ID}/cancel',
			'action'         => 'POST',
			'return'         => 'MESSAGE',
			'retry'          => 1,
			'require_body'   => 0,
			'url_escape'     => { '{Project ID}' => 1, '{Task ID}' => 1,  },
			'log_message'    => '(project={Project ID}, task={Task ID}). Cancelled a task.',
		};
}

=head3 IRONWORKER_SET_A_TASKS_PROGRESS

/projects/{Project ID}/tasks/{Task ID}/progress

=cut

sub IRONWORKER_SET_A_TASKS_PROGRESS {
	return {
			'action_name'    => 'IRONWORKER_SET_A_TASKS_PROGRESS',
			'href'           => '{Protocol}://{Host}:{Port}/{API Version}/projects/{Project ID}/tasks/{Task ID}/progress',
			'action'         => 'POST',
			'return'         => 'MESSAGE',
			'retry'          => 1,
			'require_body'   => 1,
			'request_fields' => { 'percent' => 1, 'msg' => 1 },
			'url_escape'     => { '{Project ID}' => 1, '{Task ID}' => 1 },
			'log_message'    => '(project={Project ID}, code={Task ID}). Set task\'s progress.',
		};
}

=head3 IRONWORKER_RETRY_A_TASK

/projects/{Project ID}/tasks/{Task ID}/retry

=cut

sub IRONWORKER_RETRY_A_TASK {
	return {
			'action_name'    => 'IRONWORKER_RETRY_A_TASK',
			'href'           => '{Protocol}://{Host}:{Port}/{API Version}/projects/{Project ID}/tasks/{Task ID}/retry',
			'action'         => 'POST',
			'return'         => 'MESSAGE',
			'retry'          => 1,
			'require_body'   => 1,
			'request_fields' => { 'delay' => 1 },
			'url_escape'     => { '{Project ID}' => 1, '{Task ID}' => 1 },
			'log_message'    => '(project={Project ID}, code={Task ID}, delay={delay}). Task queued for retry.',
		};
}

=head2 Scheduled Tasks

=head3 IRONWORKER_LIST_SCHEDULED_TASKS

/projects/{Project ID}/schedules

=cut

sub IRONWORKER_LIST_SCHEDULED_TASKS {
	return {
			'action_name'    => 'IRONWORKER_LIST_SCHEDULED_TASKS',
			'href'           => '{Protocol}://{Host}:{Port}/{API Version}/projects/{Project ID}/schedules',
			'action'         => 'GET',
			'return'         => 'LIST:schedules',
			'retry'          => 1,
			'require_body'   => 0,
			'paged'          => 1,
			'per_page'       => 100,
			'url_escape'     => { '{Project ID}' => 1 },
			'log_message'    => '(project={Project ID}). Listed scheduled tasks.',
		};
}

=head3 IRONWORKER_SCHEDULE_A_TASK

/projects/{Project ID}/tasks

=cut

sub IRONWORKER_SCHEDULE_A_TASK {
	return {
			'action_name'    => 'IRONWORKER_SCHEDULE_A_TASK',
			'href'           => '{Protocol}://{Host}:{Port}/{API Version}/projects/{Project ID}/schedules',
			'action'         => 'POST',
			'return'         => 'HASH',
			'retry'          => 1,
			'require_body'   => 1,
			'request_fields' => { 'schedules' => 1 },
			'url_escape'     => { '{Project ID}' => 1 },
			'log_message'    => '(project={Project ID}). Scheduled task.',
		};
}

=head3 IRONWORKER_GET_INFO_ABOUT_A_SCHEDULED_TASK

/projects/{Project ID}/schedules/{Schedule ID}

=cut

sub IRONWORKER_GET_INFO_ABOUT_A_SCHEDULED_TASK {
	return {
			'action_name'    => 'IRONWORKER_GET_INFO_ABOUT_A_SCHEDULED_TASK',
			'href'           => '{Protocol}://{Host}:{Port}/{API Version}/projects/{Project ID}/schedules/{Schedule ID}',
			'action'         => 'GET',
			'return'         => 'HASH',
			'retry'          => 1,
			'require_body'   => 0,
			'url_escape'     => { '{Project ID}' => 1, '{Schedule ID}' => 1,  },
			'log_message'    => '(project={Project ID}, schedule={Schedule ID}). Got info about scheduled task.',
		};
}

=head3 IRONWORKER_CANCEL_A_SCHEDULED_TASK

/projects/{Project ID}/schedules/{Schedule ID}/cancel

=cut

sub IRONWORKER_CANCEL_A_SCHEDULED_TASK {
	return {
			'action_name'    => 'IRONWORKER_CANCEL_A_SCHEDULED_TASK',
			'href'           => '{Protocol}://{Host}:{Port}/{API Version}/projects/{Project ID}/schedules/{Schedule ID}/cancel',
			'action'         => 'POST',
			'return'         => 'MESSAGE',
			'retry'          => 1,
			'require_body'   => 0,
			'url_escape'     => { '{Project ID}' => 1, '{Schedule ID}' => 1,  },
			'log_message'    => '(project={Project ID}, schedule={Schedule ID}). Canceled scheduled task.',
		};
}

=head2 Stacks

=head3 IRONWORKER_LIST_OF_AVAILABLE_STACKS

/stacks

=cut

sub IRONWORKER_LIST_OF_AVAILABLE_STACKS {
	return {
			'action_name'    => 'IRONWORKER_LIST_OF_AVAILABLE_STACKS',
			'href'           => '{Protocol}://{Host}:{Port}/{API Version}/stacks',
			'action'         => 'GET',
			'return'         => 'LIST', # Return as JSON.
			'retry'          => 0,
			'require_body'   => 0,
			'paged'          => 0,
			'url_escape'     => { },
			'log_message'    => '(). Listed stacks.',
		};
}

1;

