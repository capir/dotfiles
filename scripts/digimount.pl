#!/usr/bin/perl -X

$digidav="https://storage.rcs-rds.ro/dav";
print "Please give us the directory path where you want to mount the DigiStorage account: ";
chomp ($path = <STDIN>);
print "Cheking the path:..... ";

check_path ($path);

sub check_path ()
{
 $i = 1;
  $p = $_[0];
  if (-d "$p"){
    print "$p is OK!\n";
  }
  else {
    if ($i > 2) {
      print "something went wrong creating the path: $p\n;";
      exit 1;
    }
    else {
      $i = $i + 1;
      print "Path $p does not exists, we try to create it: ";
      system ("mkdir -p $p");
      check_path($p);
    }
  }
}
print "Mounting Digi Storage Account to $path\n";
system ("mount.davfs $digidav $path");
print "Displaying mount if it worked\n";
system ("mount | grep $path");
