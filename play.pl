#! /usr/bin/perl

use strict;
use warnings;
use JSON::Any;
use File::Slurp;
use Tk;
use Tk::Table;
use FindBin '$Bin';
use File::Spec::Functions;

my $file = catdir( $Bin, 'pieces.json' );
my $data = -r $file ? JSON::Any->jsonToObj( read_file( $file ) ) : {};
my $found = $data->{found};

my @order;
my @prizes;
my %prize;
while (<DATA>) {
    chomp;
    my ( $name, $from, $to ) = split /\t/;
    for my $i ( $from .. $to ) {
		push @order, $name unless exists $prize{$name};
        $prizes[$i] = $name;
        push @{ $prize{$name} }, $i;
    }
}
my $codeText = "";
my $mw       = MainWindow->new;
$mw->title("Monopoly");
my $frame1 = $mw->Frame(
    -borderwidth => 2,
    -relief      => 'ridge'
);
$frame1->pack(
    -side   => 'top',
    -expand => 'n',
    -fill   => "x"
);

$frame1->Label( -text => "Piece: " )->pack( -side => "left", -anchor => "w" );
my $entry;
$entry = $frame1->Entry(
    -validate        => 'key',
    -validatecommand => sub {
        return 0 unless defined $_[1] && $_[1] =~ /[0-9]/;
        return 0 if length( $_[0] ) > 2;
        $codeText = $prizes[ $_[0] ] if $_[0];
        return 1;
    },
    -width => 30
);
$entry->bind(
    '<Return>' => sub {
        my $ind = $entry->get();
        return unless $ind;
        $found->[$ind]++;
        $entry->delete( 0, 'end' );
        $codeText = '';
    } );

$entry->pack(
    -side   => "left",
    -anchor => "w",
    -fill   => "x",
    -expand => "y"
);
$entry->focus;

my $frame2 = $mw->Frame(
    -borderwidth => 2,
    -relief      => 'ridge'
);
$frame2->pack(
    -side   => 'top',
    -expand => 'y',
    -fill   => "x"
);

my $codeLabel = $frame2->Label( -textvariable => \$codeText, )->pack( -side => "left", -anchor => "w", -expand => 'yes', -fill=>'x' );
my $tableFrame = $mw->Frame(-borderwidth=>2, -relief=>'raised')->pack( -expand=>'yes', -fill=>'both');
my $cols = 0;
for (values %prize) {
	$cols = @$_ if @$_ > $cols;
}
my $table = $tableFrame->Table(-columns=>$cols, -rows=>scalar(%prize), -relief=>'raised', -scrollbars=>'e');
for my $r (0 .. @order) {
	my $tmp = $table->Label(-text=>$order[$r], -padx=>2, -anchor=>'w', -background=>'white', -relief=>'groove');
	$table->put($r, 0, $tmp);
}
$table->pack(-expand=>'yes', -fill=>'both');

$mw->Button(
    -text    => "Exit",
    -command => sub {
        write_file( catdir( $Bin, 'pieces.json' ), JSON::Any->objToJson( { found => $found } ) );
        exit;
    } )->pack( -side => "bottom" );
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
