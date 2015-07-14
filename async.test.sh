#!/usr/bin/env zsh

. ./async.zsh

simple_echo() {
	echo hi
}

git_status() {
	git status --porcelain
}

error_echo() {
	echo "I will print some errors, yay!"
	1234
	return 666
}

simple_result() {
	print
	print -l -- $1: $3
}

result() {
	print
	print -l -r -- "Compelted job: '$1'" "Return code: $2" "Duration: $4 seconds" "Stdout: '${3//$'\n'/\n}'" "Stderr: '${5//$'\n'/\n}'"
}


async_init

# Test a simple echo...
async_start_worker async
async_job async simple_echo
async_job async git status
sleep 0.2
async_process_results async simple_result

# Test uniqueness
async_start_worker async2 unique
# Only the first one will run!
# The second cannot run due to unique constraint.
async_job async2 git_status
async_job async2 git_status
async_job async2 error_echo
sleep 0.2
# Only results for first git status
async_process_results async2 result

# Cleanup
async_stop_worker async async2 || echo "ERROR: Could not clean up workers"
async_stop_worker nonexistent && echo "ERROR: Sucess cleaning up nonexistent worker"
