#!/usr/bin/perl
#
#  Slightly adapted from https://sourceforge.net/p/skychart/code/HEAD/tree/trunk/skychart/sample_client/perl/tcpclient2.pl
#
use warnings;
use strict;

use IO::Socket;
use Cwd;

my $handle;

#
# example program to send sequential command to the program
#

my $host = "127.0.0.1";
my $port = "3292";
my $eol = "\x0D\x0A";
my $path = cwd;

  connectCDC();

  sendcmd("newchart test");
  sendcmd("selectchart test");

  sendcmd("setproj equat");
  sendcmd("redraw");
  sendcmd("search M37");
  sleep(2);
  sendcmd("setfov 3d0m0s");
  sendcmd("redraw");

#  sendcmd("saveimg PNG \"$path/test.png\" ");
  sendcmd("saveimg JPEG \"$path/test.jpg\" 50");

  sleep(5);
  sendcmd("closechart test");
  sendcmd("quit");


sub sendcmd {
  my $cmd = shift;
  print STDOUT " Send CMD : $cmd \n";
  print $handle $cmd.$eol;                       # send command

  my $line = <$handle>;
  while (($line =~/^\.\r\n$/) or ($line =~ /^>/)) # keepalive and click on the chart
    {
     $line = <$handle>;
    }
  # we go here after receiving response from our command
  print STDOUT $line;
  if (($line =~ /^OK!/) or ($line =~ /^Bye!/) )
     {
     print STDOUT "Command success\n";
     }
  else {
     print STDOUT "Command failed: +$line+ \n";
	 exit;
     }
}

sub connectCDC {

# do the connection
$handle = IO::Socket::INET->new(Proto     => "tcp",
                                PeerAddr  => $host,
                                PeerPort  => $port)
          or die "cannot connect to Cartes du Ciel at $host port $port : $!";

$handle->autoflush(1);

print STDOUT "[Connected to $host:$port]\n";

# wait connection and get client chart name
  my $line = <$handle>;
  print STDOUT $line;
  $line =~ /OK! id=(.*) chart=(.*)$/;
  my $client = $1;
  my $chart = $2;
  chop $chart;
  if ($client)
    {
     print STDOUT " We are connected as client $client , the active chart is $chart\n";
    }
    else { die " We are not connected \n"};
}
