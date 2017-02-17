#!/usr/bin/perl
#use strict;
use DBI;
use GD::Graph::bars;

# Global variables
my $dbh;
my $username="xxxxx";
my $password="yyyyy";
my $dsn="DBI:mysql:database=e2k";
my $cquery;
my @stations=("ART","EZI","PCD","ULX","YHF");
my $msg_count;
my $this_count;
my $this_group;
my $unique_count;
my @msg_counts;
my @first_groups;
my $total;
my $average;
my @gcounts;
my @count_axis;
my $ts;
my $common_group;

# Connect to the database
$dbh=DBI->connect($dsn,$username,$password) or die "\n\nCan't connect to the DB ($DBI::errstr)";

# Prepare a SQL statement
$cquery=$dbh->prepare_cached("SELECT msg_count,group_count1,group_count2,group_count3,first_group1,first_group2,first_group3 FROM e10_normal_traffic 
WHERE callsign=? AND msg_count>0") or die "Couldn't prepare statement: " . $dbh->errstr;

my $a,$b;
my $station_count=@stations;
my @row;
my $total_count;

for ($b=0;$b<201;$b++)
 {
 $count_axis[$b]=$b;	
 }
 
# Run through each station
for ($a=0;$a<$station_count;$a++)
 {
 my @data;
 my @group_count_counters;
 $unique_count=0;
 $total_count=0;
 $total=0;
 print "\n\n$stations[$a]";

 # Run the query
 $cquery->execute($stations[$a]) or die "Couldn't execute statement: " . $cquery->errstr;
 # Run through each result
 while (@row=$cquery->fetchrow_array)
  {
  $total_count++;
  # Get the message count
  $msg_count=$row[0];  
  # 1 message
  $this_count=$row[1];
  $this_group=$row[4];
  
  
  if (check_exists($this_count,$this_group)==-1)
   {
   $group_count_counters[$this_count]++;   
   $msg_counts[$unique_count]=$this_count;
   $first_groups[$unique_count]=$this_group;
   $unique_count++;
   $total=$total+$this_count;
   }

  # 2 messages
  if ($msg_count>1)
   {
   $this_count=$row[2];
   $this_group=$row[5];
   $total_count++;
   if (check_exists($this_count,$this_group)==-1)
    {
    $group_count_counters[$this_count]++;
    $msg_counts[$unique_count]=$this_count;
    $first_groups[$unique_count]=$this_group;
    $unique_count++;
    $total=$total+$this_count;
    }
   }
   
  # 3 messages
  if ($msg_count>2)
   {
   $this_count=$row[3];
   $this_group=$row[6];
   $total_count++;
   if (check_exists($this_count,$this_group)==-1)
    {
    $group_count_counters[$this_count]++;
    $msg_counts[$unique_count]=$this_count;
    $first_groups[$unique_count]=$this_group;
    $unique_count++;
    $total=$total+$this_count;
    } 
   } 
  }
  
 $common_group=0;
 for ($b=0;$b<201;$b++)
  {
  if ($group_count_counters[$b]>$common_group) {$common_group=$b};	
  }
  
 # Open the report file
 $filename=">";
 $filename=$filename.$stations[$a];
 $filename=$filename."_report.txt";
 open (RFILE,$filename) or die $!;
   
 $average=$total/$unique_count;
 print RFILE "\nSearched $total_count messages and found $unique_count unique ones the average group count was $average groups"; 
 print RFILE "\nThe most common group count was $common_group";

 @data=(\@count_axis,\@group_count_counters);
 $ts=$stations[$a];
 my $title="Group Count Distribution in E10 ";
 $title=$title.$ts;
 $title=$title." Messages";
 my $file_name=">";
 $file_name=$file_name.$ts;
 $file_name=$file_name."_e10_gc_distr.png";

 my $mygraph = GD::Graph::bars->new(600, 500);
 $mygraph->set(
     x_label     => 'Group Count',
     y_label     => 'Number of times a message has had this group count',
     title       => $title,
     y_max_value => 25,
     transparent => 0,
    
     x_tick_number=>1,
     x_min_value=>1,
     x_max_value=>200,
     
     x_label_position=>0.5,
     r_margin=>50
    
 ) or warn $mygraph->error;


 my $myimage = $mygraph->plot(\@data) or die $mygraph->error;

 open(IMG,$file_name) or die $1;
   binmode IMG;
   print IMG $myimage->png;
 close(IMG);	
 
 close(RFILE);

 }

# Clear the database results
$cquery->finish;
# All done so disconnect from the database
$dbh->disconnect or warn "\n\nDisconnection error ($DBI::errstr)";

print "\n\n";

print "\n\n\nDone !\n\n";

###############################################################################################

# This subroutine checks if a message already exists in the array storage
# Returns -1 if the message doesn't exist and 1 if it does
#
# Inputs are $count $first group
sub check_exists
{
my $tcount=$_[0];
my $tgroup=$_[1];
my $c;
for ($c=0;$c<$unique_count;$c++)
 {
 if (($tcount eq $msg_counts[$c]) && ($tgroup eq $first_groups[$c])) {return 1;}
 }
return -1;	
}

