# SFTP based dropzone

Create a secure dropzone with SFTP. It requires an addition to the host's SSH daemon configuration, a specific configuration to the home-directory and rights with basic Unix added to functional accounts.

### Note:
This example is created and tested on a clean Debian machine on a non-ACL activated file system using local storage. The expectation is that this setup will work on all POSIX compliant Unix systems and all known Linux distributions, independent of the Linux flavor. The SSH daemon used is OpenSSH 7.9p1-10+deb10u1 (native OpenSSH server on Debian 10).


## SSH daemon configuration
Explination of the config:
- Match to the primary or secondary group of a user.
- Chroot to /home/user-account
- No X11 forwarding to the client
- No Tcp forwarding, forward and remote forwarding is disabled.
- No TTY, which results in no shell binding.
- No tunneling.
- Force exclusive use of the internal SFTP facility.

```
Match group sftponly
     ChrootDirectory /home/%u
     X11Forwarding no
     AllowTcpForwarding no
     PermitTTY no
     PermitTunnel no
     ForceCommand internal-sftp
```

## Secured account preparation:
Specific configured home-dir for exclusive sftp dropzone user, nologin shell, specific functional primary group, exclusive sftp-only rights as secondary right. The SSH will be chrooted here.

```bash
# Group for the dropzone user.
groupadd dropzone1

# Group ownership pushes the exclusive right to only allow for sftp for the
# associated user user.
groupadd sftponly

useradd \
    --create-home \
    --home-dir /home/sftponlydropzone1 \
    --shell /usr/sbin/nologin \
    --gid dropzone1 \
    --groups sftponly \
    sftponlydropzone1
```

## Secure home-dir:
root owned, due to chroot, group matching primary group associated to this dropzone and stripped from others to read. Only a user with the proper dropzone1 group as a primary or secondary group can access the dropzone. Make a dedicated drop zone directory with sufficient write perms.
```bash
chown root:dropzone1 /home/sftponlydropzone1
chmod 750 /home/sftponlydropzone1
mkdir /home/sftponlydropzone1/drop
chown root:dropzone1 /home/sftponlydropzone1/drop
chmod 770 /home/sftponlydropzone1/drop
```

## Reader/writer account:
A reader/write user account with a dropzone1 secondary group associated to it. This authorizes the user to access the dropzones using the the dropzone1 as primary group.
```bash
useradd \
    --create-home \
    --shell /bin/bash \
    --groups dropzone1 \
    sftpreadinguser
```

## Avoiding leakages
Avoid data leakages via the Other perms on the reader directory.
```bash
chmod 750 /home/sftpreadinguser

passwd sftponlydropzone1
passwd sftpreadinguser
```
