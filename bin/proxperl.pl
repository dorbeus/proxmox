#!/usr/bin/perl -w
#
# Viewed best with tabsize 3
#
# Modified/Adapted into perl by Phil Kauffman 
#
# Remy van Elst created the original version in bash
# https://raymii.org/cms/p_Proxbash_-_Bash_script_to_manage_Proxmox_VE
#
# OSX install macports
# port install p5.8-math-*
# port install p5.8-crypt-*
#
# Linux
# apt-get install build-essential
# apt-get install libmath-gmp-perl
# cpan install Net::SSH::Perl
# cpan install Math::Pari
# cpan install YAML
# cpan install Math::BigInt::Calc

use strict();
use warnings;
use Switch;
use Net::SSH::Perl;

my $host = "chelsea.cs.uchicago.edu";
my $port = 22;
my $user = "root";
my $pass = "teiG7acu";

my %sshargs = (
	protocol		=> 2,
	port			=> $port,
	debug			=> 0,
	interactive	=> 0,
	options		=> [ "BatchMode yes" ]
);

# create new host to ssh into
$ssh = Net::SSH::Perl->new($host, %sshargs);
# now open a connection
$ssh->login($user, $pass, %sshargs) || die("SSH: Could not login");
# to send a command
# my($stdout, $stderr, $exit) = $ssh->cmd($cmd);

#sub createct(){}
#sub startct(){}
#sub stopct(){}
#sub deletect(){}
#sub shelldrop(){}
#sub listcts(){}
#sub listvms(){}
#sub ctinfo(){}
#sub ctexec(){}
#sub get_storage_device_list(){}
#sub get_cttemplate_list(){}
#sub get_iso_list(){}
#sub get_vm_list(){}

sub get_cluster_nextid {
# usage: my $x = get_cluster_nextid();
# get next id from server, if exit code is 0 return the ID, otherwise return 0/false
	my($stdout, $stderr, $exit) = $ssh->cmd("pvesh get /cluster/nextid");
	if ($exit == 0) {
		# filter out the quotes from the ID
		$stdout =~ m/"(\d{3,})"/;
		my $nextid = $1;
		return $nextid;
	} else {
		return 0;
	}
}

sub get_ct_list(){
# Returns an array of all CTs on the connected node.
	my @ctlist;
	my $count = 0;	
	# get list of cts
	my($stdout, $stderr, $exit) = $ssh->cmd("vzlist -j -o ctid");
	# if the command exited cleanly
	if($exit == 0) {
		@lines = split("\n", $stdout);
		for (my $i = 0; $i <= $#lines; $i++) {
			if ($lines[$i] =~  m/"ctid": (\d{3,})/){
				$ctlist[$count] = $1;
				$count++;				
			}
		}
	}
	if ( $exit == 0 && @ctlist ){ return @ctlist; } else { return 0; }
}

# print_array(get_cluster_nodes());
sub get_cluster_nodes(){
# Returns an array of all nodes in the cluster
   my @nodes;
   my $count = 0;
   # get list of cts
   my($stdout, $stderr, $exit) = $ssh->cmd("pvesh get nodes");
   # if the command exited cleanly
   if($exit == 0) {
      @lines = split("\n", $stdout);
      for (my $i = 0; $i <= $#lines; $i++) {
         if ($lines[$i] =~  m/"node" : "(\D{1,})",/){
            $nodes[$count] = $1;
				$count++;
         }
      }
   }
	if ( $exit == 0 && @nodes ){ return @nodes; } else { return 0; }
}

sub send_command(){
	my $command = @_;
	my @nodes = get_cluster_nodes();	

	for (my $i = 0; $i <= $#nodes; $i++){
		my($stdout, $stderr, $exit) = $ssh->cmd("$command");
	}
	return($stdout, $stderr, $exit);
}

sub print_array(){
# used for debug only: Will print out the entire contents of a 1D array.
	@array = @_;
	for (my $i = 0; $i <= $#array; $i++){
		print "$array[$i]\n";
	}
}

sub usage() {
	printf("Create oVZ VM:\n");
	printf("$0 createct node-hostname node-password node-template node-ram node-disk node-ip\n");
	printf("Example: $0 createct prod001 supersecret1 ubuntu12 1024 15  172.20.5.48\n");
	printf("\n");
	printf("Start vm:\n");
	printf("$0 startct\n");
	printf("\n");
	printf("Stop vm:\n");
	printf("$0 stopct\n");
	printf("\n");
	printf("Remove vm:\n");
	printf("$0 deletect\n");
	printf("\n");
	printf("List all containers (OpenVZ):\n");
	printf("$0 listcts\n");
	printf("\n");
	printf("Get CT info:\n");
	printf("$0 ctinfo\n");
	printf("\n");
	printf("List all virtual machines (KVM)\n");
	printf("$0 listvms\n");
	printf("\n");
	printf("Execute command in ct:\n");
	printf("$0 execinct ID COMMAND\n");
	printf("Example: $0 execinct 103 \"apt-get update; apt-get -y upgrade\" \n");
	printf("\n");
	printf("Shell dropper\n");
	printf("$0 shelldrop CTID");
	printf("$0 shelldrop 101\n");
}

=begin comment

my $action = defined $ARGV[0];

switch ($action) {
	case "createct"	{ createct($ARGV[1], $ARGV[2], $ARGV[3], $ARGV[4], $ARGV[5], $ARGV[6], $ARGV[7], $ARGV[8]) }
	case "startct"		{ startct($ARGV[1], $ARGV[2]) }
	case "stopct"		{ stopct($ARGV[1], $ARGV[2]) }
	case "deletect"	{ deletect($ARGV[1], $ARGV[2]) }
	case "shelldrop"	{ shelldrop($ARGV[1], $ARGV[2]) }
	case "listcts"		{ listcts() }
	case "listvms"		{ listvms() }
	case "ctinfo"		{ get_ct_info($ARGV[1], $ARGV[2]) }
	case "ctexec"		{ ctexec($ARGV[1], $ARGV[2]) }
	case "usage"		{ usage() }
	else					{ usage() }
}

=cut
