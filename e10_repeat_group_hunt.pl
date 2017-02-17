#!/usr/bin/perl
#use strict;
use DBI;

# Global variables
my $dbh;
my $username="xxxxx";
my $password="yyyyy";
my $dsn="DBI:mysql:database=e2k";
my $cquery;
my @unique_first_groups;
my @row;
my $fgroup;
my $mcount;

# Open the report file
open (RFILE,'>group_hunt_report.txt') or die $!;


# Connect to the database
$dbh=DBI->connect($dsn,$username,$password) or die "\n\nCan't connect to the DB ($DBI::errstr)";

# Prepare a SQL statement
$cquery=$dbh->prepare_cached("SELECT msg_count,first_group1,first_group2,first_group3 FROM e10_normal_traffic") or die "Couldn't prepare statement: " . $dbh->errstr;
# Run the query
$cquery->execute() or die "Couldn't execute statement: " . $cquery->errstr;
# Run through each result
while (@row=$cquery->fetchrow_array)
 {
 $mcount=$row[0];
 if ($mcount>0) {add_to_group_list($row[1]);}
 if ($mcount>1) {add_to_group_list($row[2]);}
 if ($mcount>2) {add_to_group_list($row[3]);}
 }

$ucount=@unique_first_groups;
# Prepare a SQL statement
$cquery=$dbh->prepare_cached("SELECT * FROM e10_normal_traffic 
WHERE first_group1=? OR first_group2=? OR first_group3=?") or die "Couldn't prepare statement: " . $dbh->errstr;

# Run through each unique first group
my $b,$c,$icount;
my @orow;
for ($b=0;$b<$ucount;$b++)
 {
 # Run the query
 $cquery->execute($unique_first_groups[$b],$unique_first_groups[$b],$unique_first_groups[$b]) or die "Couldn't execute statement: " . $cquery->errstr;
 $icount=0;
 while (@row=$cquery->fetchrow_array)
  {
  # Only print the info if more than 1 result found
  if ($icount>0)
   {
   	
   if ($icount==1)
    {
   	print RFILE "\n\n$orow[1] $orow[4] $orow[5]";
    if ($orow[8]>0)
     {
     print RFILE " $orow[9] $orow[10]";	
     }
    if ($orow[8]>1)
     {
     print RFILE " $orow[11] $orow[12]";	
     }   
    if ($orow[8]>2)
     {
     print RFILE " $orow[13] $orow[14]";	
     }  
    print RFILE " $orow[3]";
    }	
   	
   print RFILE "\n$row[1] $row[4] $row[5]";
   if ($row[8]>0)
    {
    print RFILE " $row[9] $row[10]";	
    }
   if ($row[8]>1)
    {
    print RFILE " $row[11] $row[12]";	
    }   
   if ($row[8]>2)
    {
    print RFILE " $row[13] $row[14]";	
    }  
   print RFILE " $row[3]";
   }	
  if ($icount==0) {@orow=@row;}
  $icount++;	
  }
 }

# Clear the database results
$cquery->finish;
# All done so disconnect from the database
$dbh->disconnect or warn "\n\nDisconnection error ($DBI::errstr)";
close (RFILE);


print "\n\n\nDone !\n\n";

###############################################################################################

sub add_to_group_list
{
my $a=0;
my $count=@unique_first_groups;
my $tb=$_[0];
for ($a=0;$a<$count;$a++)	
 {
 if ($unique_first_groups[$a] eq $tb) {return;}
 }
push (@unique_first_groups,$tb);		
}
