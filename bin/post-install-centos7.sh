#!/bin/sh
#
if [ $# -ne 1 ]
then
  echo " "
  echo "Usage: post-install-centos7.sh <option>"
  echo "NOTE: BEFORE RUNNING THIS SCRIPT PLEASE MAKE SURE"
  echo "      IP ADDRESS AND HOSTNAME IS SET"
  echo " "
  echo " YOU CAN FOLLOW THE FOLLOWING SEQUENCE: "
  echo "  1) addhosts:  Adds hostnames to /etc/hosts"
  echo "  2) pkg:       Install all the necessary packages"
  echo "  3) mkmnt:     Makes all the mount points /CAD etc"
  echo "  4) fstab:     appends the NFS mounts to /etc/fstab"
  echo "  5) link:      Creates the soft links silicon.csh and cron.daily.silicon"
  echo "  6) nis:       Sets up the NIS server"
  echo "  7) localsim:  sets up /home/local/simulation"
  echo "  8) localdoc:  creates /home/local/docs"
  echo " "
  echo " CHECK INSTALLATION with /CAD/cad-pub/bin/check-install.sh" 
  echo " "
  exit 1
fi

if [ $1 == "addhosts" ] || [ $1 == "all" ]
then
  echo "#################################"
  echo "# CHECKING /etc/hosts #"
  echo "#################################"
  # CHeck if the current host is in /etc/hosts
  thishost=`hostname`
  if grep -q $thishost /etc/hosts ; then
    echo "This host exists in /etc/hosts"
  else
    echo "This host **DOES NOT** exists in /etc/hosts adding ..."
    ethdev=`nmcli connection show --active | grep ethernet | awk '{print $1}'`
    ipaddr=`nmcli -g ipv4.addresses connection show $ethdev`
    echo "$ipaddr $thishost" >> /etc/hosts
  fi
  # Check if servers are on /etc/hosts
  echo "Checking if servers are in /etc/hosts"
  if grep -q srv02.vlsi.silicon.ac.in /etc/hosts ; then
    echo "/etc/hosts seems to populated with the following:"
    cat /etc/hosts
  else
    echo "ADDING hostnames in /etc/hosts"
    cat >> /etc/hosts <<EOF
192.168.11.221  srv01.vlsi.silicon.ac.in srv01
192.168.11.229  srv02.vlsi.silicon.ac.in srv02 srv02.silicon.ac.in cdslicserv mgclicsrv.vlsi.silicon.ac.in mgclicserv
192.168.11.237  srv03.vlsi.silicon.ac.in srv03
EOF
  fi
fi


if [ $1 == "mkmnt" ] || [ $1 == "all" ]
then
  echo "#################################"
  echo "# CHECKING MOUNTS /CAD /PDK /home/nfs1 /home/nfs2 #"
  echo "#################################"
  if [ ! -d /CAD ] ; then
    mkdir /CAD
    chown nfsnobody:nfsnobody /CAD
  else
    echo "Directory /CAD exists.. Checking permissions"
    perm=`ls -ald /CAD | awk '{print $3$4}'`
    if [ $perm == "nfsnobodynfsnobody" ] ; then
      echo "Permision looks fine .. check below.."
      ls -ald /CAD
    else
      chown nfsnobody:nfsnobody /CAD
    fi
  fi
  if [ ! -d /PDK ] ; then
    mkdir /PDK
    chown nfsnobody:nfsnobody /PDK
  else
    echo "Directory /PDK exists.. Checking permissions"
    perm=`ls -ald /PDK | awk '{print $3$4}'`
    if [ $perm == "nfsnobodynfsnobody" ] ; then
      echo "Permision looks fine .. check below.."
      ls -ald /PDK
    else
      chown nfsnobody:nfsnobody /PDK
    fi
  fi
  if [ ! -d /home/nfs1 ] ; then
    mkdir /home/nfs1
    chown nfsnobody:nfsnobody /home/nfs1
  else
    echo "Directory /PDK exists.. Checking permissions"
    perm=`ls -ald /home/nfs1 | awk '{print $3$4}'`
    if [ $perm == "nfsnobodynfsnobody" ] ; then
      echo "Permision looks fine .. check below.."
      ls -ald /home/nfs1
    else
      chown nfsnobody:nfsnobody /home/nfs1
    fi
  fi
  if [ ! -d /home/nfs2 ] ; then
    mkdir /home/nfs2
    chown nfsnobody:nfsnobody /home/nfs2
  else
    echo "Directory /PDK exists.. Checking permissions"
    perm=`ls -ald /home/nfs2 | awk '{print $3$4}'`
    if [ $perm == "nfsnobodynfsnobody" ] ; then
      echo "Permision looks fine .. check below.."
      ls -ald /home/nfs2
    else
      chown nfsnobody:nfsnobody /home/nfs2
    fi
  fi
fi


if [ $1 == "fstab" ] || [ $1 == "all" ]
then
  echo "#################################"
  echo "# ADDING MOUNT POINTS TO /etc/fstab #"
  echo "#################################"
  if grep -q "srv01:/home/nfs1" /etc/fstab ; then
    echo "/etc/fstab looks fine .. check"
  else
    cat >> /etc/fstab <<EOF
# NFS mounts from srv01.vlsi.silicon.ac.in
srv01:/home/nfs1  /home/nfs1      nfs     noatime,rsize=32768,wsize=32768
srv01:/home/nfs2  /home/nfs2      nfs     noatime,rsize=32768,wsize=32768
srv03:/cad/CAD1        /CAD            nfs     noatime,rsize=32768,wsize=32768
srv03:/pdk/PDK1        /PDK            nfs     noatime,rsize=32768,wsize=32768
EOF
  fi 
mount -a
fi

if [ $1 == "pkg" ] || [ $1 == "all" ]
then
  echo "CHECKING AND INSTALLING PACKAGES:"
pckarr=( \
  environment-modules tree tigervnc-server subversion git \
  numpy python-matplotlib tcl tk ypbind rpcbind \
  glibc glibc.i686 elfutils-libelf ksh mesa-libGL \ 
  mesa-libGLU motif libXp libpng libjpeg-turbo \
  expat glibc-devel gdb xorg-x11-fonts-misc \
  xorg-x11-fonts-ISO8859-1-75dpi redhat-lsb \
  libXScrnSaver apr apr-util compat-db47 \
  xorg-x11-server-Xvfb mesa-dri-drivers openssl-devel \ 
  cronie-anacron \
)

for i in  ${pckarr[*]}
 do
  isinstalled=$(rpm -q $i)
  #echo Package  $i 
  if [ !  "$isinstalled" == "package $i is not installed" ];
   then
    echo "--installed** $i"
  else
    echo "**NOT INSTALLED** INSTALLLING $i"
    yum install -y $i	# Installs without asking
  fi
 done

fi


if [ $1 == "link" ] || [ $1 == "all" ]
then
  echo "Linking silicon.sh and cron.daily.silicon"
  # Link silicon.csh
  if [ ! -f /etc/profile.d/silicon.csh ]
  then
    ln -s /CAD/apps7/etc/silicon.csh /etc/profile.d/.
  fi
  #Link cron.daily
  if [ ! -f /etc/cron.daily/cron.daily.silicon ]
  then
    ln -s /CAD/apps7/bin/cron.daily.silicon /etc/cron.daily/.
  fi
fi


if [ $1 == "nis" ] || [ $1 == "all" ]
then
  if [ "$nissrv" == "srv01.vlsi.silicon.ac.in" ] ; then
    nissrv=`ypwhich`
    echo "NIS Server is set to $nissrv"
  else
    thishost=`hostname`
    if [ ! $thishost == "srv01.vlsi.silicon.ac.in" ] ; then
      echo "SETTING UP NIS CLIENT"
      # Setup NIS client
      ypdomainname vlsi.silicon.ac.in
      echo "NISDOMAIN=vlsi.silicon.ac.in" >> /etc/sysconfig/network
      authconfig --enablenis --nisdomain=vlsi.silicon.ac.in --nisserver=srv01.vlsi.silicon.ac.in --update
      systemctl start rpcbind ypbind
      systemctl enable rpcbind ypbind

      echo "NIS SERVER SET TO:"
      ypwhich
    else
      echo "This is the NIS server so client cannot be set here"
    fi
  fi
fi


if [ $1 == "localsim" ] || [ $1 == "all" ]
then
  echo "SETTING UP /home/local/simulation..."
  if [ ! -d /home/local/simulation ]
  then
    mkdir -p /home/local/simulation
  fi
  chgrp localsim /home/local/simulation
  chmod g=swrx,+t /home/local/simulation

  # set quota for the /home/local/simulation
  if grep -q "01:/home/local/simulation" /etc/projects ; then
    echo ""
  else
    echo 01:/home/local/simulation >> /etc/projects
    echo localsim:01 >> /etc/projid
  fi
  # Now set the quota
  echo "Adding quota for /home/local/simulation..."
  xfs_quota -x -c 'project -s localsim' /home
  xfs_quota -x -c 'limit -p bsoft=95G bhard=100G localsim' /home
  echo ""
  echo "Quota report for /home..."
  xfs_quota -x -c 'report -h' /home
fi


if [ $1 == "localdoc" ] || [ $1 == "all" ]
then
  echo "CREATING /home/local/doc"
  if [ ! -d /home/local/docs ]
  then
    mkdir -p /home/local/docs
  fi
fi
