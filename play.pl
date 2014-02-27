use strict;
use warnings;
use JSON::Any;
use File::Slurp;
use Tk;
use FindBin '$Bin';
use File::Spec::Functions;

my $data = JSON::Any->jsonToObj(read_file(catdir($Bin, 'pieces.json')));
my $found = $data->{found};

my @prizes;
my %prize;
while (<DATA>) {
	chomp;
	my ($name, $from, $to) = split /\t/;
	for my $i ($from .. $to) {
		$prizes[$i] = $name;
		push @{$prize{$name}}, $i;
	}
}
my $codeText = "";
my $mw = MainWindow->new;
$mw->title("Monopoly");
my $frame1 = $mw->Frame(-borderwidth => 2,
		     -relief => 'ridge');
$frame1->pack(-side => 'top',
	      -expand => 'n',
	      -fill => "x");

      use Data::Dumper;
$frame1->Label(-text => "Piece: ")->pack(-side => "left", -anchor => "w");
my $entry;
$entry = $frame1->Entry(
	-validate => 'key',
	-validatecommand => sub {
		return 0 unless defined $_[1] && $_[1] =~ /[0-9]/;
		return 0 if length($_[0]) > 2;
		$codeText = $prizes[$_[0]] if $_[0];
		return 1;
	},
	-width => 30);
$entry->bind('<Return>' => sub {
	my $ind = $entry->get();
	return unless $ind;
	$found->[$ind]++;
	$entry->delete(0, 'end');
	$codeText = '';
});
		
$entry->pack(-side => "left",
	     -anchor => "w",
	     -fill => "x",
	     -expand => "y");
$entry->focus;
my $codeLabel = $mw->Label(
	-textvariable => \$codeText,
)->pack(-side => "left", -anchor => "w", -expand => 'w');

$mw->Button(-text => "Exit", -command => sub {
	write_file(catdir($Bin, 'pieces.json'), JSON::Any->objToJson({prizes => \%prize, found => $found}));
		exit;
	})->pack(-side => "bottom");
MainLoop;


__DATA__
$1,000,000	1	6
$500,000 Dream Home	7	11
$100,000 Cash	12	16
$40,000 Vehicle	17	21
$40,000 Motorcycle or Boat	22	26
$25,000 Backyard Makeover	27	31
$10,000 Family Vacation	32	36
$5,000 ATV or Camping Package	37	40
$2,500 Free Groceries	41	44
$1,000 Free Groceries	45	48
$500 Apple iPad Air	49	52
$500 Xbox One	53	56
$250 Grocery Gift Card	57	60
$250 Cash	61	64
$100 Grocery Gift Card	65	68
$50 Grocery Gift Card	69	72
$25 Grocery Gift Card	73	76
$25 Cash	77	80
$15 Monopoly Board Game	81	84
$10 Grocery Gift Card	85	88
$5 Grocery Gift Card	89	92
