#!/usr/bin/perl
#use strict;
use DBI;

# Global variables
my $dbh;
my $username="xxxxx";
my $password="yyyyy";
my $dsn="DBI:mysql:database=e2k";
my $cquery;
my @stations=("ART","EZI","PCD","ULX","YHF");
my $highest;
my $lowest;
my $msg_count;
my $this_count;

# Connect to the database
$dbh=DBI->connect($dsn,$username,$password) or die "\n\nCan't connect to the DB ($DBI::errstr)";

# Prepare a SQL statement
$cquery=$dbh->prepare_cached("SELECT msg_count,group_count1,group_count2,group_count3 FROM e10_normal_traffic 
WHERE callsign=? AND msg_count >0
") or die "Couldn't prepare statement: " . $dbh->errstr;

open (RFILE,">e10_high_low.txt") or die $!;

my $a;
my $station_count=@stations;
my @row;
for ($a=0;$a<$station_count;$a++)
 {
 $highest=0;
 $lowest=1000;	
 print "\n\n$stations[$a]";
 # Run the query
 $cquery->execute($stations[$a]) or die "Couldn't execute statement: " . $cquery->errstr;
 # Run through each result
 while (@row=$cquery->fetchrow_array)
  {  	
  # Get the message count
  $msg_count=$row[0];  
  # 1 message
  $this_count=$row[1];
  if ($this_count>$highest) {$highest=$this_count};
  if ($this_count<$lowest) {$lowest=$this_count};
  # 2 messages
  if ($msg_count>1)
   {
   $this_count=$row[2];
   if ($this_count>$highest) {$highest=$this_count};
   if ($this_count<$lowest) {$lowest=$this_count};  	
   }
  # 3 messages
  if ($msg_count>2)
   {
   $this_count=$row[3];
   if ($this_count>$highest) {$highest=$this_count};
   if ($this_count<$lowest) {$lowest=$this_count};  	
   }   
  }
  
 print RFILE "\n\n$stations[$a]"; 
 print RFILE "\nLowest Group Count $lowest"; 
 print RFILE "\nHigest Group Count $highest" 
 }

# Clear the database results
$cquery->finish;
# All done so disconnect from the database
$dbh->disconnect or warn "\n\nDisconnection error ($DBI::errstr)";
close RFILE;
print "\n\n\nDone !\n\n";