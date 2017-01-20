#!/usr/bin/perl
use warnings;
use strict;

use IO::Socket;

#
# example program that receive all messages from the program
# and process the information from each click on the chart.
#

my $host = "127.0.0.1";
my $port = "3292";
my $handle;

connectCDC();

while (defined (my $line = <$handle>)) {
  if (!($line =~/^\.\r\n$/)) { #skip keepalive data
    my ($h1,$chart,$h2,$ra,$dec,$type,$desc) = split(/\s+/,$line,7);
    if ($ra and ($h1 eq ">")) {
      print "From $chart  RA: $ra DEC: $dec Type: $type \n";
      print "$desc\n";
    }
    else {
      print $line
    };
  }
  else {
     print $line;
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
  if ($client) {
     print STDOUT " We are connected as client $client , the active chart is $chart\n";
     print STDOUT " Close CDC or hit Ctrl+C to quit.\n";
  }
  else { die " We are not connected \n"};
}
