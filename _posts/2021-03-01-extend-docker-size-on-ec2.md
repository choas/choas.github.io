---
layout:  post
title:   Extend Docker size on EC2
date:    2021-03-01 20:10 +0100
image:   sajad-nori-sIX4eDtak7k-unsplash.jpg
credit:  https://unsplash.com/photos/sIX4eDtak7k
tags:    docker ec2
excerpt: In this blog post I describe how to extend the size of Docker on an EC2 instance.
---

> Docker is a set of platform as a service (PaaS) products that use OS-level virtualization to deliver software in packages called containers. -- [Wikipedia: Docker](https://en.wikipedia.org/wiki/Docker_(software))

I have started an AWS machine to build Dockerfiles. The advantage is that the necessary Docker images are downloaded _amazingly_ 🤩 fast on AWS. The other advantage is that the whole thing can run without blocking my working machine.
Unfortunately, I had selected a default machine with only 8 GByte. Writing a Dockerfile which first runs a build process and then the proper image can fill up the disk quickly. Therefore, I had to cleaned up everything before I started the next build. If I forget it, then the build started and stopped after a certain amount of time with "no space left". Originally this solution should make things faster and not cause additional work.

One advantage of cloud computing is that you can simply [mount](https://devopscube.com/mount-ebs-volume-ec2-instance/) an additional disk into the system. But this alone does not help, since Docker still uses the directory from the 8 GByte disk.

## Move the Docker directory

Of course, you will find a solution for this on [Stackoverflow](https://stackoverflow.com/a/52537027):

```bash
systemctl stop docker
mv /var/lib/docker /newvolume/docker-data
ln -s /newvolume/docker-data /var/lib/docker
systemctl start docker
```

- stop Docker
- move the Docker directory to the new hard disk
- create a link
- start Docker again

After that, docker images should show all images. But since Docker was stopped, the respective images have to be restarted.

## Mounting an EBS volume

These are the commands to mount an EBS volume with EC2. I have copied them from [How to Attach and Mount an EBS volume to EC2 Linux Instance](https://devopscube.com/mount-ebs-volume-ec2-instance/) as a backup:

```bash
lsblk
sudo file -s /dev/xvdf
sudo mkfs -t ext4 /dev/xvdf
sudo mkdir /newvolume
sudo mount /dev/xvdf /newvolume/
cd /newvolume
df -h .
```

… and don’t forget to auto mount the volume in `/etc/fstab`:

```text
/dev/xvdf   /newvolume   ext4   defaults,nofail   0   0
```

## Summary

Don't worry if you need more disk space. Just create another volume, mount it and move the docker directory.
