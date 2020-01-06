# Group for the dropzone user.
groupadd dropzone1

# Group ownership pushes the exclusive right to only allow for sftp for the
# associated user user.
groupadd sftponly

# Secured account: Specific configured home-dir for exclusive sftp dropzone
# user, nologin shell, specific functional primary group, exclusive sftp-only
# rights as secondary right. The SSH will be chrooted here.
useradd \
    --create-home \
    --home-dir /home/sftponlydropzone1 \
    --shell /usr/sbin/nologin \
    --gid dropzone1 \
    --groups sftponly \
    sftponlydropzone1

# Secure home-dir: root owned, due to chroot, group matching primary group
# associated to this dropzone and stripped from others to read. Only a user
# with the proper dropzone1 group as a primary or secondary group can access
# the dropzone. Make a dedicated drop zone directory with sufficient write
# perms.
chown root:dropzone1 /home/sftponlydropzone1
chmod 750 /home/sftponlydropzone1
mkdir /home/sftponlydropzone1/drop
chown root:dropzone1 /home/sftponlydropzone1/drop
chmod 770 /home/sftponlydropzone1/drop

# A reader/write user account with a dropzone1 secondary group associated to
# it. This authorizes the user to access the dropzones using the the dropzone1
# as primary group.
useradd \
    --create-home \
    --shell /bin/bash \
    --groups dropzone1 \
    sftpreadinguser

# Avoid data leakages via the Other perms on the reader directory.
chmod 750 /home/sftpreadinguser

# Set account passwords
passwd sftponlydropzone1
passwd sftpreadinguser

