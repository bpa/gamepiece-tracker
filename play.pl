#! /usr/bin/perl

use strict;
use warnings;
use JSON::Any;
use File::Slurp;
use Tk;
use Tk::Table;
use FindBin '$Bin';
use File::Spec::Functions;
use Data::Dumper;

my $file = catdir( $Bin, 'pieces.json' );
my $data = -r $file ? JSON::Any->jsonToObj( read_file($file) ) : {};
my $found = $data->{found};

my @order;
my @prizes;
my %prize;
my @prize_map;
while (<DATA>) {
    chomp;
    my ( $name, $from, $to ) = split /\t/;
    next unless $name;
    for my $i ( $from .. $to ) {
        push @order, $name unless exists $prize{$name};
        $prizes[$i] = $name;
        push @{ $prize{$name} }, $i;
        $prize_map[$i] = [ $#order, $#{ $prize{$name} } ];
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
my ( $entry, $table );
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
        if ( defined $prize_map[$ind] ) {
            my ( $r, $c ) = @{ $prize_map[$ind] };
            $table->get( $r, $c + 1 )->configure( -text => $found->[$ind] );
        }
        write_file( catdir( $Bin, 'pieces.json' ),
            JSON::Any->objToJson( { found => $found } ) );
    } );

$entry->pack(
    -side   => "left",
    -anchor => "w",
    -fill   => "x",
    -expand => "y"
);
$entry->focus;

my $codeLabel = $mw->Label( -textvariable => \$codeText, )
  ->pack( -side => "top", -anchor => "w", -expand => 'no', -fill => 'x' );
my $tableFrame = $mw->Frame( -borderwidth => 2, -relief => 'raised' )
  ->pack( -expand => 'yes', -fill => 'both', -side => 'bottom' );
my $cols = 0;
for ( values %prize ) {
    $cols = @$_ if @$_ > $cols;
}
$table = $tableFrame->Table(
    -columns    => $cols,
    -rows       => scalar(%prize),
    -relief     => 'raised',
    -scrollbars => 'e'
);
for my $r ( 0 .. $#order ) {
    my $tmp = $table->Label(
        -text       => $order[$r],
        -anchor     => 'w',
        -background => 'white',
        -relief     => 'groove'
    );
    $table->put( $r, 0, $tmp );
    my $pieces = $prize{ $order[$r] };
    for my $c ( 0 .. $#$pieces ) {
        $table->put(
            $r,
            $c + 1,
            $table->Label(
                -text       => $found->[ $pieces->[$c] ],
                -anchor     => 'e',
                -background => $found->[ $pieces->[$c] ] ? 'white' : 'red',
                -relief     => 'groove',
            ) );
    }
}
$table->pack( -expand => 'yes', -fill => 'both' );

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
