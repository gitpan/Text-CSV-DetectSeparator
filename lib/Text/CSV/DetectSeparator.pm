package Text::CSV::DetectSeparator;

use 5.006001;
use strict;
use warnings;
use Tie::File;
use Text::CSV_XS;
use File::Type;

our $VERSION   = '0.03';
our $MAX_LINES = 10;
our @possible_sepchars = (',',';',':','.','#');

sub new{
  my ($class,$filename) = @_;
  my $self = {Counter => 0};
  
  bless $self,$class;
  
  if($filename && -e $filename){
    my $filetype = $self->_check_mimetype($filename);
    if($filetype eq 'application/octet-stream'){
      $self->_localize_newlines($filename);
      $self->{Separator} = $self->_find_separator($filename);
    }
    else{
      print STDERR "No valid MIME-Type\n";
    }
  }
  
  if($filename && not -e $filename){
    print STDERR "File $filename does not exist\n";
  }
  
  return $self;
}# new

sub file{  
  my ($self,$filename) = @_;
  
  $self->{Counter} = 0;
  
  if($filename && -e $filename){
    my $filetype = $self->_check_mimetype($filename);
    if($filetype eq 'application/octet-stream'){
      $self->_localize_newlines($filename);
      $self->{Separator} = $self->_find_separator($filename);
    }
    else{
      print STDERR "No valid MIME-Type\n";
    }
  }
  
  if($filename && not -e $filename){
    print STDERR "File $filename does not exist\n";
  }
}# file

sub separator{
  my ($self) = @_;
  return $self->{Separator};
}# separator

sub _localize_newlines{
  my ($self,$file) = @_;

  $self->{Error} = undef;
  tie my @array,'Tie::File',$file or $self->{Error} = $!;
    unless($self->{Error}){
    for(@array){
      my $newline = $/;
      s/\015{1,2}\012|\015|\012/$newline/g;
    }
    untie @array;
  }
}# _localize_newlines

sub _check_mimetype{
  my ($self,$file) = @_;
  my $filetype     = '';

  my $ft = File::Type->new();
  $filetype = $ft->mime_type($file);
    
  return $filetype;
}# _check_mimetype

sub _find_separator{
  my ($self,$file) = @_;
  my $separator;
  my @extracted;
  
  $self->{Error} = undef;
  tie my @lines,'Tie::File',$file or $self->{Error} = $!;
  die $self->{Error},"\n" if($self->{Error});
  unless($self->{Error}){
    my %lineindexes;
    while(keys(%lineindexes) < $MAX_LINES && keys(%lineindexes) < scalar(@lines)){
      my $index = int rand(scalar(@lines));
      next if($lines[$index] =~ /^\s*$/);
      $lineindexes{$index} = 1;
    }
    push(@extracted,$lines[$_]) for(keys(%lineindexes));
    untie @lines;
    $separator = $self->_parse($file,@extracted);
  }
  
  return $separator;
}# _find_separator

sub _parse{
  my ($self,$file,@lines) = @_;
  my @sepchars;
  my $sepchar;
  $self->{Counter}++;
  for my $char(@possible_sepchars){
    my $parser = Text::CSV_XS->new({sep_char => $char});
    my $number_cols = 0;
    my $counter     = 0;
    for my $line(@lines){
      if($parser->parse($line)){
        my @fields = $parser->fields();
        next if(scalar(@fields) == 1);
        $counter++;
        $number_cols = scalar(@fields) if($counter == 1);
        unless($number_cols == scalar(@fields)){
          last;
        }
        if($counter == scalar(@lines)){
          push(@sepchars,$char);
        }
      }
    }
  }
  
  #print STDERR Dumper(\@sepchars);
  
  if(scalar(@sepchars) == 1){
    #print STDERR "just one\n";
    $sepchar = $sepchars[0];
  }
  elsif($self->{Counter} == 10){
    $sepchar = undef;
  }
  else{
    $MAX_LINES *= 2;
    $sepchar = $self->_find_separator($file);
  }
  
  return $sepchar;
}


# Preloaded methods go here.

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Text::CSV::DetectSeparator - Helps to find the fieldseparator in a csv-file

=head1 SYNOPSIS

  use Text::CSV::DetectSeparator;
  
  my $file = 'test.csv';
  my $detector = Text::CSV::DetectSeparator->new($file);
  
  print $detector->separator();

=head1 DESCRIPTION

C<Text::CSV::DetectSeparator> is written to automate the detection of the
fieldseparators in CSV-files. It just test, whether one of these characters is
the seperator:
  ,
  ;
  .
  :
  #

=head1 METHODS

=head2 new([$file])

  my $obj = Text::CSV::DetectSeparator->new()

creates a new C<Text::CSV::DetectSeparator> object and searchs for the separator
if a filename is given.

=head2 file($filename)

Searchs for the separator if a filename is given 

=head2 separator ()

Returns the separator or undef if the search fails (e.g. two or more possible
separators).

=head1 PREREQUESITS

  Text::CSV_XS
  Tie::File
  File::Type

=head1 AUTHOR

Renee Baecker, E<lt>module@renee-baecker.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by Renee Baecker

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.6.1 or,
at your option, any later version of Perl 5 you may have available.


=cut
