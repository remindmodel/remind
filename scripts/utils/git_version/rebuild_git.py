#!/bin/python3
import subprocess
import sys
import os


# check if run from a git repo
try:
    subprocess.check_output(['git', 'rev-parse', '--is-inside-work-tree'])
except subprocess.CalledProcessError:
    print("This script must be run from within a git repository.")
    sys.exit()

print("Change to repo root directory...")
current_dir = os.getcwd()
root_dir = subprocess.check_output(['git', 'rev-parse', '--show-toplevel']).decode().strip()
os.chdir(root_dir)

# check if repo is clean
try:
    subprocess.check_output(['git', 'diff', '--quiet'])
    subprocess.check_output(['git', 'diff', '--cached', '--quiet'])
except subprocess.CalledProcessError:
    print("Repository has uncommitted changes. Please commit or stash them before running this script.")
    sys.exit()

# read git_info.txt file
print("Parse git_info.txt file...")
with open(os.path.join(current_dir, 'git_info.txt'), 'r') as f:
    git_info = f.readlines()

# get commit hash from line after "{[( LAST LOCAL COMMIT )]}":
err_str = "Unexpected format in git_info.txt. "
iter_lines = iter(git_info)
line = next(iter_lines)
assert line.strip() == "{[( LOCAL BRANCH )]}", err_str + "First line of git_info.txt should be '{[( LOCAL BRANCH )]}'"
local_branch = next(iter_lines).strip()
print("Found local branch:", local_branch)
assert next(iter_lines).strip() == "{[( LAST LOCAL COMMIT )]}", err_str + "Third line of git_info.txt should be '{[( LAST LOCAL COMMIT )]}'"
commit_hash = next(iter_lines).strip()
print("Found commit hash:", commit_hash)
assert next(iter_lines).strip() == "{[( LAST REMOTE COMMIT )]}", err_str + "Fifth line of git_info.txt should be '{[( LAST REMOTE COMMIT )]}'"
remote_commit_hash = next(iter_lines).strip()
print("Found remote commit hash:", remote_commit_hash)

# try from local commit
print()
print("Trying to rebuild from local commit...")

print("Check if commit exists in repo...")
mode = None
try:
    subprocess.check_call(['git', 'cat-file', '-e', commit_hash + '^{commit}'])
except subprocess.CalledProcessError:
    print("Commit hash not found in repo. Switching to remote mode.")
    mode = 'remote'
    print("Trying to rebuild from remote commit...")

    print("Check if remote commit already exists in repo...")
    try:
        subprocess.check_call(['git', 'cat-file', '-e', remote_commit_hash + '^{commit}'])
        print("Remote commit hash found in repo. Checking out remote commit", remote_commit_hash)
        subprocess.check_call(['git', 'checkout', remote_commit_hash])
    except subprocess.CalledProcessError:
        print("Remote commit hash not found in repo.")
        print("Adding remote temp_remindmodel...")
        subprocess.check_call(['git', 'remote', 'add', 'temp_remindmodel', 'https://github.com/remindmodel/remind.git'])
        print("Fetching latest changes from remote...")
        subprocess.check_call(['git', 'fetch', 'temp_remindmodel'])
        print("Checking for remote commit hash...")
        try:
            subprocess.check_call(['git', 'cat-file', '-e', remote_commit_hash + '^{commit}'])
        except subprocess.CalledProcessError:
            print("Remote commit hash not found in remote. Exiting.")
            sys.exit()
        print("Remote commit hash found. Checking out remote commit", remote_commit_hash)
        subprocess.check_call(['git', 'checkout', remote_commit_hash])
        print("Remove remote temp_remindmodel")
        subprocess.check_call(['git', 'remote', 'remove', 'temp_remindmodel'])

if mode is None:
    print("Check if local branch exists in repo")
    branches = subprocess.check_output(['git', 'branch', '-a']).decode().strip().split('\n')
    branches = [b.strip().lstrip('* ') for b in branches]
    if local_branch in branches:
        print("Check if commit is HEAD of local branch")
        head_hash = subprocess.check_output(['git', 'rev-parse', local_branch]).decode().strip()
        if head_hash == commit_hash:
            print("Commit is HEAD of local branch. Checking out local branch", local_branch)
            subprocess.check_call(['git', 'checkout', local_branch])
            mode = 'local'
        else:
            print("Commit is not HEAD of local branch.")
    else:
        print("Local branch not found in repo.")

if mode is None:
    print("Checkout commit directly.")
    subprocess.check_call(['git', 'checkout', commit_hash])
    mode = 'local'

def apply_patch(file_name):
    subprocess.check_call(['git', 'apply', '--whitespace=nowarn', '--allow-empty', os.path.join(current_dir, file_name)])
if mode == 'local':
    print("Apply local git patch file")
    apply_patch('git_diff_local.patch')
elif mode == 'remote':
    print("Apply remote git patch file")
    apply_patch('git_diff_remote.patch')
print("Apply untracked files patch")
try:
    apply_patch('git_diff_untracked.patch')
except subprocess.CalledProcessError:
    print("Error applying untracked files patch.")
    print("Skip this patch.")
    print("Maybe the same files still exist in the repo. If you wish to have the exact same state as before, please remove untracked files from the repo and try again.")

print("Change back to original directory...")
os.chdir(current_dir)

print("Rebuild complete.")
