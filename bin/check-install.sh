#!/bin/sh
# This scripts checks for essential installation 
# CentOS 7.9.2009 (Core) to make it deployment ready
#
echo "*************************************"
echo "Checking CentOS Version"
echo "*************************************"
lsb_release -a | grep -i "Description"
echo ""

echo "*************************************"
echo "Linking (if does not exist) "
echo "/CAD/apps/etc/silicon.csh to /etc/profile.d/silicon.csh"
echo "*************************************"
if [ -f /etc/profile.d/silicon.csh ];
  then
    echo "CHECK: /etc/profile.d/silicon.csh  EXISTS "
    echo ""
  else
    #ln -s /CAD/apps7/etc/silicon.csh /etc/profile.d/silicon.csh 
    echo "ERROR: /etc/profile.d/silicon.csh DOES NOT EXIST......"
    echo ""
fi
#
echo "*********************************************"
echo "CHECK /home/local/docs & /home/local/simulation"
echo " Make sure the permissions is [drwxrwsr-t root localsim ]"
echo "*********************************************"
#Check if /home/local exists
if [ -d /home/local/simulation ];
 then
   echo "CHECK: /home/local/simulation EXISTS, with the following permissions:"
   ls -ld /home/local/simulation | awk  '{print "["$1 " "$3 " "$4"]"}'
   echo ""
 else
   echo "ERROR: /home/local/simulation DOES NOT EXIST"
   echo ""
fi

# check if /home/local/docs
if [ -d /home/local/docs ];
 then
   echo "CHECK: /home/local/docs EXISTS"
   echo ""
 else
   echo "ERROR: /home/local/docs DOES NOT EXIST"
   echo ""
fi

echo "*************************************"
echo "NETWORK STATUS"
echo "*************************************"
ethdev=`nmcli connection show --active | grep ethernet | awk '{print $1}'`
autocon=
echo "AUTO-CONNECT-STATUS: `nmcli -f name,autoconnect c s | grep $ethdev`"
echo "METHOD: `nmcli -g ipv4.method connection show $ethdev`"
echo "IPV4: `nmcli -g ipv4.addresses connection show $ethdev`"
echo "GATEWAY: `nmcli -g ipv4.gateway connection show $ethdev`"
echo "DNS: `nmcli -g ipv4.dns connection show $ethdev`"
echo ""
echo ""


echo "*************************************"
echo "CHECKING IF HOSTNAME IS IN /etc/hosts"
echo "*************************************"
myhost=$(hostname)
if grep -q $myhost /etc/hosts ; then
  echo "CHECK: Hostname $myhost exists in /etc/hosts."
  echo ""
else
  echo "ERROR:Hostname $myhost **DOES NOT** exists in /etc/hosts."
  echo ""
fi

echo "*************************************"
echo "CHECKING THE NIS SERVER = srv01.vlsi.silicon.ac.in" 
echo "*************************************"
ypwhich
echo ""

echo "*************************************"
echo "CHECK ALL THE MOUNTS"
echo "Make sure the following are on the list:"
echo "/home/nfs1, /home/nfs2, /CAD, /PDK"
echo "*************************************"
mount -l -t nfs | awk '{print $3}'
mount -l -t nfs4 | awk '{print $3}'
echo ""

#echo "*************************************"
#echo " CHECKING FOR PERL MODULE Shell.pm "
#echo " Required for the Perl scripts." 
#echo " NOTE: The firsrt time cpan is run,"
#echo " it neds to get configured."
#echo " Choose defaults and rerun 'cpan Shell'"
#echo "*************************************"
# Was due to pwd command in siproj but looks like I may not
# need it.
#cpan Shell

echo "*************************************"
echo "CHECKING INSTALLED PACKAGES"
echo "*************************************"
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
    echo "**NOT INSTALLED** $i"
    #yum install -y $i	# Installs without asking
  fi
done

## NOTE: The update part from the original scripts is not
## used right now.
#updatedb
echo "*************************************"
echo "DONE CHECKING" 
echo "*************************************"

