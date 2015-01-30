#!/usr/local/bin/perl -w

use warnings;
use strict;
use LWP::Simple;
use Data::Dumper;

use constant PHP_FPM_STATUS_PAGE => 'http://10.0.13.11:82/php-fpm-status';

use constant XYMON_WWW_ROOT => '';
sub get_graph_html {
        my ($host, $service) = @_;
        '<table summary="'.$service.' Graph"><tr><td><A HREF="'.XYMON_WWW_ROOT.'/xymon-cgi/showgraph.sh?host='.$host.'&amp;service='.$service.'&amp;graph_width=576&amp;graph_height=120&amp;first=1&amp;count=1&amp;disp='.$host.'&amp;action=menu"><IMG BORDER=0 SRC="'.XYMON_WWW_ROOT.'/xymon-cgi/showgraph.sh?host='.$host.'&amp;service='.$service.'&amp;graph_width=576&amp;graph_height=120&amp;first=1&amp;count=1&amp;disp='.$host.'&amp;graph=hourly&amp;action=view" ALT="xymongraph '.$service.'"></A></td><td align="left" valign="top"><a href="'.XYMON_WWW_ROOT.'/xymon-cgi/showgraph.sh?host='.$host.'&amp;service='.$service.'&amp;graph_width=576&amp;graph_height=120&amp;first=1&amp;count=1&amp;disp='.$host.'&amp;graph_start=1350474056&amp;graph_end=1350646856&amp;graph=custom&amp;action=selzoom"><img src="'.XYMON_WWW_ROOT.'/xymon/gifs/zoom.gif" border=0 alt="Zoom graph" style=\'padding: 3px\'></a></td></tr></table>';
}

sub do_the_work {
  my $content = get(PHP_FPM_STATUS_PAGE);
  return undef unless defined $content;

  my @lines = split /\n/, $content;
  my @keys = map {$_ =~ /^(.+?):/ && $1} @lines;
  my @values = map {$_ =~ /^.+?:\s+(.+)$/ && $1} @lines;

  my %res;
  @res{@keys} = @values;

  return (\%res, $content);
}

my ($values, $status_page) = do_the_work();

my $host = $ENV{MACHINEDOTS};
my $report_date = `/bin/date`;
my $color = 'red';
my $service = 'phpfpm';


my $data;
my $trends;
if ($values) {
  $color = 'clear';

  $trends = "
[phpfpm_connections.rrd]
DS:acceptedconn:DERIVE:600:0:U ".$values->{'accepted conn'}."
[phpfpm_processes.rrd]
DS:idle:GAUGE:600:0:U ".$values->{'idle processes'}."
DS:active:GAUGE:600:0:U ".$values->{'active processes'}."
DS:total:GAUGE:600:0:U ".$values->{'total processes'}."
";

  $data = "
<h2>Status</h2>
".$status_page."

<h2>Counters</h2>
".get_graph_html($host, 'phpfpm_connections')."
".get_graph_html($host, 'phpfpm_processes')."
";
}
else {
  $data = 'Error!';
  $trends = '';
}

system( ("$ENV{BB}", "$ENV{BBDISP}", "status $host.$service $color $report_date$data\n") );
if ($trends) {
  system( "$ENV{BB} $ENV{BBDISP} 'data $host.trends $trends'\n");
}
