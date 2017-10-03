#!/usr/bin/perl -w

use Image::Magick;
use URI::Encode qw(uri_encode uri_decode);
$image = Image::Magick->new;
$image->Set(size=>'300x300');
$image->ReadImage('xc:white');

my $text = $ENV{'QUERY_STRING'};
my $decoded = uri_decode($text);

my $filename = '/tmp/ao.png';
#$text = "This is a test";
#$image->Annotate(pointsize=>40, fill=>'blue', text=>$text);
my $wrapped = Wrap($decoded, $image, '205');
$image->Annotate(font=>'kai.ttf', pointsize=>14, fill=>'blue', gravity=>'NorthWest', geometry=>'+20+10', text=>$wrapped);
$image->Annotate(font=>'kai.ttf', pointsize=>14, fill=>'black', gravity=>'SouthEast', geometry=>'+20+15', text=>'by @cmercu');
$image->Write(filename=>$filename, compression=>'None');

open IMAGE, $filename;
#assume is a jpeg...
my ($image, $buff);
while(read IMAGE, $buff, 1024) {
    $image .= $buff;
}
close IMAGE;
print "Content-type: image/png\n\n";
print $image;
unlink $filename;

sub Wrap
{
   my ($text, $img, $maxwidth) = @_;

   my %widths = map(($_ => ($img->QueryFontMetrics(text=>$_))[4]),
      keys %{{map(($_ => 1), split //, $text)}});

   my (@newtext, $pos);
   for (split //, $text) {
      if ($widths{$_} + $pos > $maxwidth) {
         $pos = 0;
         my @word;
         if ( $newtext[-1] ne " "
              && $newtext[-1] ne "-"
              && $newtext[-1] ne "\n") {
            unshift @word, pop @newtext
               while ( @newtext && $newtext[-1] ne " "
                       && $newtext[-1] ne "-"
                       && $newtext[-1] ne "\n")
         }
         if ($newtext[-1] eq "\n" || @newtext == 0) {
            push @newtext, @word, "\n";
         } else {
            push @newtext, "\n", @word;
            $pos += $widths{$_} for (@word);
         }
      }
      push @newtext, $_;
      $pos += $widths{$_};
      $pos = 0 if $newtext[-1] eq "\n";
   }
   return join "", @newtext;
}
