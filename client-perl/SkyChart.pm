package SkyChart;

use IO::Socket;

sub new { # {{{

  my $classname = shift;
  my %opts      = @_;
  my $self = {};

  bless $self, $classname;

  $host = $opts->{host} || '127.0.0.1';
  $port = $opts->{port} ||  3292;


  $self->{tcp_ip} = IO::Socket::INET->new(
    Proto     => "tcp",
    PeerAddr  => $host,
    PeerPort  => $port
  ) or die "cannot connect to Cartes du Ciel at $host port $por";

  $self->{tcp_ip} -> autoflush(1);
  
# wait connection and get client chart name
  my $line = readline($self->{tcp_ip});
# print STDOUT $line;
  $line =~ /OK! id=(.*) chart=(.*)$/;
  $self->{client_nr} = $1;
  my $chart = $2;
  chop $chart;
  if (! $self->{client_nr}) {
    die "Connection to Cartes du Ciel failed.";
  }
  else {
     print STDOUT " We are connected as client $client , the active chart is $chart\n";
  }

  return $self;

} # }}}

sub sendcmd {
  my $self = shift;
  my $cmd  = shift;

  print STDOUT " Send CMD : $cmd \n";
#
  print { $self->{tcp_ip} } "$cmd\x0d\x0a";

  my $line = <$handle>;

  if ($line =~ /$client_nr/) {
     print "client_nr: $line\n";
  }

  while (($line =~/^\.\r\n$/) or ($line =~ /^>/)) { # keepalive and click on the chart
    $line = <$handle>;
  }

  if ($line =~ /^OK!/ or $line =~ /^Bye!/ ) {
    print STDOUT "Command success\n";
    return 0;
  }
  else {
    return $line;
#   print STDOUT "Command failed: +$line+ \n";
#   exit;
  }

#   # we go here after receiving response from our command
#   print STDOUT $line;
#   if (($line =~ /^OK!/) or ($line =~ /^Bye!/) )
#      {
#      print STDOUT "Command success\n";
#      }
#   else {
#      print STDOUT "Command failed: +$line+ \n";
# 	 exit;
#      }

}


1;
