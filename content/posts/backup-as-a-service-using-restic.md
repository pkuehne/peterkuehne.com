---
title: "Backup as a Service Using Restic"
date: 2020-01-29
draft: false
toc: true
categories: ["home network"]
tags:
    - backup
    - restic
    - ansible
series: []
---

Making backups of your work is one of those things that we all know we should do, but get lazy about actually setting up[^time]. Things are easier these days, particularly on Windows, where you can have your Documents folder automatically backed up to the cloud. You can also install GoogleDrive, DropBox, NextCloud as drives in Windows and have them sync automatically as well.

When it comes to backing up configuration data on my Linux servers, things are a bit more complicated for me. I don't want to install my GoogleDrive, etc accounts there. Having all the files (including passwords and other sensitive information) stored on someone else's cloud server is also a bit suspect. On the other hand, having all data backed up to my NAS was out of the question too[^nas]. A good backup solution should be off-site, in case anything happens.

So in the end, the solution required:

* Syncing with a cloud provider
* Encryption
* Can be automated via ansible

And the solution is:

## Restic

[Restic] is a single executable tool that can create encrypted backups, has incremental backup strategies and supports multiple different storage providers.

All of restic's backups are encrypted by default and it is important to keep the password in a safe place, because the contents cannot be retrieved without it. By default the password has to be supplied interactively, but restic also supports reading the password from a file. Obviously, care must be taken to keep this file from falling into the wrong hands. Mine is readable only by `root`, which is the only user that should be iniating restic backups anyway, but we'll come to that.

The beauty of restic is that backups are incremental, so if there are no new or changed files, restic will not transfer anything to the "repository" where the backups are kept. This vastly reduces the overhead of both storage and traffic when backing up large files or directories.

Lastly the support for different providers means that restic can handle a basic filesystem backup location (on a mounted network drive for example) but also Amazon S3 backups. This is the option that I went for. AWS has simple APIs, a really good user management system to restrict access and an unbeatable uptime and stability guarantee.

## Installing Restic

Let's talk about how to install restic using Ansible, which is always my weapon of choice for setting up my servers. Restic releases can be downloaded from [github] and need to be unzipped and placed in `/usr/local/bin` (or wherever you prefer to have non-system executables).

<!-- markdownlint-disable -->
{{< highlight yaml >}}
- name: Ensure directories exist
  become: yes
  file:
    path: '{{item}}'
    state: directory
    owner: ansible
    group: ansible
    mode: '0776'
  loop: ['{{app_dir}}', '{{download_dir}}', '{{config_dir}}', '{{bin_dir}}']

- name: Download restic
  get_url:
    url: 'https://github.com/restic/restic/releases/download/v{{version}}/{{ restic_file }}.bz2'
    dest: '{{ download_dir }}/{{ restic_file }}.bz2'
    owner: ansible
    group: ansible
    mode: '0664'
  register: restic_downloaded

- name: Ensure bzip2 is installed
  become: yes
  apt:
    name: 'bzip2'
    state: 'present'
  when: restic_downloaded is changed

- name: Unpack restic
  command:
    cmd: 'bunzip2 --keep {{ download_dir }}/{{ restic_file }}.bz2'
    creates: '{{ download_dir }}/{{ restic_file }}'
  register: restic_unpacked

- name: Install restic in /usr/local/bin/
  become: yes
  copy:
    src: '{{ download_dir }}/{{ restic_file }}'
    dest: '/usr/local/bin/restic'
    mode: '0755'
    remote_src: true
  when: restic_unpacked is changed

{{< / highlight >}}
<!-- markdownlint-restore-->

This short section of my role uses the `get_url` command, the advantage is that if the file already exists locally, it isn't downloaded again. The same goes for the `command` task, which uses the `creates` directive to skip unzipping the file if unzipped file already exists. Lastly we don't install restic in the bin directory if we didn't unzip a new version. You could argue that this makes reverting versions harder and that's true, in those cases, remove the `when` directive.

At this point restic is installed but doesn't do anything yet[^playtime].

## Backing up a list of directories

Restic has a great feature whereby it can read the list of directories/files to backup from an input file. What this means for me is that I can set up a common file, something like `/opt/backup/sources.lst` that any other ansible role can append to with the `lineinfile` command. Now restic doesn't need to know about other roles and those roles don't need to know anything about restic. They just have to agree on where this file is. As with all shared variables, that goes into the `host_vars.yaml`

<!-- markdownlint-disable -->
{{< highlight yaml >}}
- name: Ensure sources file exists
  become: yes
  file:
    path: '{{config_dir}}/sources.lst'
    state: touch
    owner: ansible
    group: ansible
    mode: '0644'
    modification_time: preserve
    access_time: preserve
{{< / highlight >}}
<!-- markdownlint-restore-->

The lines about `modification_time` and `access_time` help with not marking the play as changed every time it is run, as `touch` would update both of these otherwise.

## Setting up periodic backups

Backups are no good if they aren't run of course, so I setup a cron job in ansible to periodically run a script to backup the files/directories in the `sources.lst`. The script is relatively straight-forward and is presented here as a template, where filenames and directories are substituted by ansible based on variables in the playbook or the host's vars file.

<!-- markdownlint-disable -->
{{< highlight bash >}}
set -e

if [[ ! -s {{config_dir}}/sources.lst ]]
then
    echo "Sources are empty"
    exit 0
fi
export AWS_ACCESS_KEY_ID={{restic_aws_key}}
export AWS_SECRET_ACCESS_KEY={{restic_aws_secret}}
/usr/local/bin/restic -r s3:s3.amazonaws.com/{{backup_bucket}} backup --files-from {{config_dir}}/sources.lst --password-file {{config_dir}}/password.txt

{{< / highlight >}}
<!-- markdownlint-restore-->

## Amazon AWS S3 bucket

There are as usual, plenty of tutorials online about how to setup an S3 bucket, but let's cover the highlights. The bucket should be completely private, so only your account has access to it. Create a new IAM user[^iam] that only has permission to read and update this specific bucket. After creating the user, you'll be presented with the *access_key* and *secret_key*, which you'll need to store in a safe place. These are used to substitute in for the `restic_aws_key` and `restic_aws_secret` in the script above.

The last thing that needs to be done is to actually initialize the repository. There are ways to do this in Ansible, but since this is only ever done once, I simply did it directly on the command line using `sudo`.

## Conclusion

Once the repo is initialized, the playbook can be run to update all the servers with the new *restic* role. Then the various roles can start adding their desired backup location to the `sources.lst` file and these will be picked up automatically by the cron job and thence read by restic to push an encrypted backup to your S3 bucket. Et voila.

[Restic]: https://restic.readthedocs.io/
[github]: https://github.com/restic/restic/releases
[^time]: I've been lazy about this for about 3 years now...
[^nas]: I'm perpetually worried about my NAS actually failing
[^playtime]: Though you can play around with it to familiarise yourself of course
[^iam]: Mine's called `restic`, no surprise there
