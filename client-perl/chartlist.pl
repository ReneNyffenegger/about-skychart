#!/usr/bin/perl
#
#  Slightly adapted from https://sourceforge.net/p/skychart/code/HEAD/tree/trunk/skychart/sample_client/perl/chartlist.pl
#
use warnings;
use strict;
use IO::Socket;
use Cwd;

#
# Produce a list of jpeg chart from the list in chartlist.txt
#

my $host = "127.0.0.1";
my $port = "3292";
my $path = cwd;

# my $handle;
my $client_nr;

my $tcp_ip = connectSkyChart();

# initialization
  sendcmd("settz Etc/GMT");
  sendcmd("setproj equat");
  sendcmd("setfov 10");
  sendcmd("redraw");

# read target file
open (my $chartlist, '<', 'chartlist.txt');
while (my $rec = <$chartlist>) {
#   print $rec;
    $rec =~ /^(.*)\t(.*)$/;
    next if $rec =~ /^#/;
    my $dte = $1;
    my $obj = $2;
    sendcmd("setdate \"$dte\"");
    sendcmd("search \"$obj\"");
    sendcmd("redraw");
   (my $dte_ = $dte) =~ tr/ :/_-/;
    sendcmd("saveimg JPEG \"$path/$dte_.jpg\" 50");
} 
close ($chartlist);

sendcmd("quit");

# end


sub sendcmd {
  my $cmd = shift;
  print STDOUT " Send CMD : $cmd \n";

  print $tcp_ip "$cmd\x0d\x0a";

  my $line = <$tcp_ip>;

  if ($line =~ /$client_nr/) {       # click form our client
     print STDOUT $line;
  }
  while (($line =~/^\.\r\n$/) or ($line =~ /^>/)) { # keepalive and click on the chart
     $line = <$tcp_ip>;
     if ($line =~ /$client_nr/) {       # click form our client
        print STDOUT $line;
     }
  }
  # we go here after receiving response from our command
  if ($line =~ /^OK!/ or $line =~ /^Bye!/ ) {
#   print STDOUT "Command success\n";
  }
  else {
    print STDOUT "$line\n";
    exit;
  }
}

sub connectSkyChart {

# do the connection
  my $tcp_ip = IO::Socket::INET->new(Proto     => "tcp",
                                  PeerAddr  => $host,
                                  PeerPort  => $port)
            or die "cannot connect to Cartes du Ciel at $host port $port : $!";
  
  $tcp_ip->autoflush(1);
  
  print STDOUT "[Connected to $host:$port]\n";

# wait connection and get client chart name
  my $line = <$tcp_ip>;
  print STDOUT $line;
  $line =~ /OK! id=(.*) chart=(.*)$/;
  $client_nr = $1;
  my $chart = $2;
  chop $chart;
  if ($client_nr) {
     print STDOUT " We are connected as client $client_nr , the active chart is $chart\n";
  }
  else {
    die " We are not connected \n"
  };

  return $tcp_ip;
}
