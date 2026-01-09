#!/usr/bin/perl -X

$digidav="https://storage.rcs-rds.ro/dav";

print "Detecting mount of Digi Storage.... ";
my $path = qx/ mount | grep "$digidav" | awk '{ print \$3 }'/;
$path = trim ($path);

if ( length $path > 0) {
  print "Digi Storage mount detected at: $path\n";
  print "Do you want to unmount $path ?\n";
  print "Please use \"Yes\" or \"No\": ";
  chomp ($resp = <STDIN>);
  if ($resp eq "Yes"){
    print "Unmounting $path\n";
    qx /umount $path/;
  }
  elsif ($resp eq "No"){
   print "Please give us the path to unmount: ";
   chomp ($path2 = <STDIN>);
   if (-d $path2) {
     print "Path $path2 exists trying to unmount:\n";
     qx /umount $path2/;
   }
   else {
     print "Path does not exist, please run again script\n";
     exit 1;
   }
  }
  else {
  print "Your input was not correct: Yes or No\n";
  exit 1;
  }
} else {
  print "Nothing found!\n";
  print "Please give us the path to unmount: ";
  chomp ($path3 = <STDIN>);
  if (-d $path3) {
    print "Path $path3 exists trying to unmount:\n";
    qx /umount $path3/;
  }
  else {
    print "Path does not exist, please run again script\n";
    exit 1;
  }
}

sub trim { return $_[0] =~ s/^\s+|\s+$//rg; }#!/usr/bin/perl -X

$digidav="https://storage.rcs-rds.ro/dav";

print "Detecting mount of Digi Storage.... ";
my $path = qx/ mount | grep "$digidav" | awk '{ print \$3 }'/;
$path = trim ($path);

if ( length $path > 0) {
  print "Digi Storage mount detected at: $path\n";
  print "Do you want to unmount $path ?\n";
  print "Please use \"Yes\" or \"No\": ";
  chomp ($resp = <STDIN>);
  if ($resp eq "Yes"){
    print "Unmounting $path\n";
    qx /umount $path/;
  }
  elsif ($resp eq "No"){
   print "Please give us the path to unmount: ";
   chomp ($path2 = <STDIN>);
   if (-d $path2) {
     print "Path $path2 exists trying to unmount:\n";
     qx /umount $path2/;
   }
   else {
     print "Path does not exist, please run again script\n";
     exit 1;
   }
  }
  else {
  print "Your input was not correct: Yes or No\n";
  exit 1;
  }
} else {
  print "Nothing found!\n";
  print "Please give us the path to unmount: ";
  chomp ($path3 = <STDIN>);
  if (-d $path3) {
    print "Path $path3 exists trying to unmount:\n";
    qx /umount $path3/;
  }
  else {
    print "Path does not exist, please run again script\n";
    exit 1;
  }
}

sub trim { return $_[0] =~ s/^\s+|\s+$//rg; }
