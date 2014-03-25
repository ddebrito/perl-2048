#!/usr/bin/perl

package GridBox;
@ISA = ();
our $AUTOLOAD;

use strict;
use Carp qw(cluck);

#        Col_num   0     1      2       3
# Row_num    
#   0             0,0   0,1    0,2     0,3
#   1             1,0   1,1    1,2     1,3           
#   2             2,0   2,1    2,2     2,3
#   3             3,0   3,1    3,2     3,3



sub new{
   my ($class, %args) = @_;

   my %hash;

   # Populate the arguments into the hash.
   foreach my $arg (keys %args) {
      $hash{$arg} = $args{$arg};
   }

   # DO NOT DO WORK IN THE CONSTRUCTOR!
   #   Do work in methods/subroutines so they can be tested.

   # build class data structure
   my $self = \%hash;

   bless $self, $class;
   # Default is 4 x 4 grid;
   $self->{grid} = [ 
                    [ undef, undef, undef, undef ],
                    [ undef, undef, undef, undef ],
                    [ undef, undef, undef, undef ],
                    [ undef, undef, undef, undef ],
                   ];
   return $self;
}

sub get_free_cell_cnt {
   my $self = shift;

   my $free_cell_cnt = 0;
   foreach my $row (@{$self->{grid}}) {
      foreach my $cell (@$row) {
         if ((!defined $cell) || ($cell eq '')) {
            $free_cell_cnt++;
         }
      }
   }
   return $free_cell_cnt;
}

sub get_free_cell_cnt_for_col_num {
   my $self = shift;
   my $col_num = shift;

   my $free_cell_cnt = 0;
   for (my $row_num=0; $row_num<=3; $row_num++) {
      if (!defined $self->{grid}[$row_num][$col_num]) {
         $free_cell_cnt++;
      }
   }
   return $free_cell_cnt;
}

sub get_free_cell_cnt_for_row_num {
   my $self = shift;
   my $row_num = shift;

   my $row = $self->{grid}[$row_num];
   my $free_cell_cnt = 0;
   foreach my $cell (@$row) {
      if ((!defined $cell) || ($cell eq '')) {
         $free_cell_cnt++;
      }
   }
   return $free_cell_cnt;
}

sub get_random_free_cell_from_grid {
   my $self = shift;

   my $return = [undef,undef];
   my $free_cell_cnt = 0;
   my %free_cells = ();
   for (my $row_num=0; $row_num<=3; $row_num++) {
      for (my $col_num=0; $col_num<=3; $col_num++) {
         if (!defined $self->{grid}[$row_num][$col_num]) {
            $free_cells{$free_cell_cnt} = [$row_num,$col_num];
            $free_cell_cnt++;
         }
      }
   }
   if ($free_cell_cnt) {
      my $rand = int(rand($free_cell_cnt));
      $return = $free_cells{$rand};
   }
   return $return;
}

sub get_random_free_cell_from_east {
   my $self = shift;

   my $return = [undef,undef];
   COL:
   for (my $col_num=3; $col_num>=0; $col_num--) {
      my $num_free_row_cells = $self->get_free_cell_cnt_for_col_num($col_num);
      if ($num_free_row_cells) {
         while (1) {
            my $rand = int(rand(4));
            if (!defined $self->{grid}[$rand][$col_num]) {
               $return = [$rand,$col_num];
               last COL;
            }
         }
      }
   }
   return $return;
}


sub get_random_free_cell_from_north {
   my $self = shift;

   my $return = [undef,undef];
   ROW:
   for (my $row_num=0; $row_num<=3; $row_num++) {
      my $num_free_row_cells = $self->get_free_cell_cnt_for_row_num($row_num);
      if ($num_free_row_cells) {
         while (1) {
            my $rand = int(rand(4));
            if (!defined $self->{grid}[$row_num][$rand]) {
               $return = [$row_num,$rand];
               last ROW;
            }
         }
      }
   }
   return $return;
}

sub get_random_free_cell_from_south {
   my $self = shift;

   my $return = [undef,undef];
   ROW:
   for (my $row_num=3; $row_num>=0; $row_num--) {
      my $num_free_row_cells = $self->get_free_cell_cnt_for_row_num($row_num);
      if ($num_free_row_cells) {
         while (1) {
            my $rand = int(rand(4));
            if (!defined $self->{grid}[$row_num][$rand]) {
               $return = [$row_num,$rand];
               last ROW;
            }
         }
      }
   }
   return $return;
}

sub get_random_free_cell_from_west {
   my $self = shift;

   my $return = [undef,undef];
   COL:
   for (my $col_num=0; $col_num<3; $col_num++) {
      my $num_free_row_cells = $self->get_free_cell_cnt_for_col_num($col_num);
      if ($num_free_row_cells) {
         while (1) {
            my $rand = int(rand(4));
            if (!defined $self->{grid}[$rand][$col_num]) {
               $return = [$rand,$col_num];
               last COL;
            }
         }
      }
   }
   return $return;
}

sub pack_east { 
   my $self = shift;

   my $packing_occured = 0;
   for (my $i=1; $i<=3; $i++) {
      for (my $row_num=0; $row_num<=3; $row_num++) {
         my $row = $self->{grid}[$row_num];
         for (my $col_num=2; $col_num>=0; $col_num--) {
            my $col_right = $col_num + 1;
            if ((!defined $row->[$col_right]) || ($row->[$col_right] eq '')) {
               $row->[$col_right] = $row->[$col_num];
               if (defined $row->[$col_num]) {
                  $packing_occured++;
               }
               undef $row->[$col_num];
            }
         }
      }
   }
   return $packing_occured;
}

sub pack_north {
   my $self = shift;

   my $packing_occured = 0;
   for (my $i=1; $i<=3; $i++) {
      for (my $row_num=1; $row_num<=3; $row_num++) {
         my $row = $self->{grid}[$row_num];
         my $row_above = $self->{grid}[$row_num-1];
         for (my $col_num=0; $col_num<=3; $col_num++) {
            if ((!defined $row_above->[$col_num]) || ($row_above->[$col_num] eq '')) {
               $row_above->[$col_num] = $row->[$col_num];
               if (defined $row->[$col_num]) {
                  $packing_occured++;
               }
               undef $row->[$col_num];
            }
         }
      }
   }
   return $packing_occured;
}

sub pack_south {
   my $self = shift;

   my $packing_occured = 0;
   for (my $i=1; $i<=3; $i++) {
      for (my $row_num=2; $row_num>=0; $row_num--) {
         my $row = $self->{grid}[$row_num];
         my $row_below = $self->{grid}[$row_num+1];
         for (my $col_num=0; $col_num<=3; $col_num++) {
            if ((!defined $row_below->[$col_num]) || ($row_below->[$col_num] eq '')) {
               $row_below->[$col_num] = $row->[$col_num];
               if (defined $row->[$col_num]) {
                  $packing_occured++;
               }
               undef $row->[$col_num];
            }
         }
      }
   }
   return $packing_occured;
}

sub pack_west { 
   my $self = shift;

   my $packing_occured = 0;
   for (my $i=1; $i<=3; $i++) {
      for (my $row_num=0; $row_num<=3; $row_num++) {
         my $row = $self->{grid}[$row_num];
         for (my $col_num=1; $col_num<=3; $col_num++) {
            my $col_left = $col_num - 1;
            if ((!defined $row->[$col_left]) || ($row->[$col_left] eq '')) {
               $row->[$col_left] = $row->[$col_num];
               if (defined $row->[$col_num]) {
                  $packing_occured++;
               }
               undef $row->[$col_num];
            }
         }
      }
   }
   return $packing_occured;
}

sub print_grid {
   my $self = shift;

   foreach my $row (@{$self->{grid}}) {
      foreach my $cell (@$row) {
         if ($cell eq '') {
            printf("%5s", '__');
         }
         else {
            printf("%5s",$cell);
         }
      }
      print "\n";
   }
   print "\n";
}

sub process_routine_east { 
   my $self = shift;
   my $routine = shift;

   my $grid_change = $self->pack_east();
   for (my $row_num=0; $row_num<=3; $row_num++) {
      my $row = $self->{grid}[$row_num];
      for (my $col_num=2; $col_num>=0; $col_num--) {
         my $col_right = $col_num + 1;
         if ((defined $row->[$col_num]) && (defined $row->[$col_right])) {
            my $arg_1 = $row->[$col_num];
            my $arg_2 = $row->[$col_right];
            my $result = &$routine($arg_1,$arg_2);
            if (defined $result) {
               $row->[$col_right] = $result;
               undef $row->[$col_num];
               $grid_change++;
            }
         }
      }
   }
   $grid_change += $self->pack_east();
}

sub process_routine_north {
   my $self = shift;
   my $routine = shift;

   my $grid_change = $self->pack_north();
   for (my $row_num=1; $row_num<=3; $row_num++) {
      my $row = $self->{grid}[$row_num];
      my $row_above = $self->{grid}[$row_num-1];
      for (my $col_num=0; $col_num<=3; $col_num++) {
         if ((defined $row_above->[$col_num]) && (defined $row->[$col_num])) {
            my $arg_1 = $row->[$col_num];
            my $arg_2 = $row_above->[$col_num];
            my $result = &$routine($arg_1,$arg_2);
            if (defined $result) {
               $row_above->[$col_num] = $result;
               undef $row->[$col_num];
               $grid_change++;
            }
         }
      }
   }
   $grid_change += $self->pack_north();
   return $grid_change;
}

sub process_routine_south {
   my $self = shift;
   my $routine = shift;

   my $grid_change = $self->pack_south();
   for (my $row_num=2; $row_num>=0; $row_num--) {
      my $row = $self->{grid}[$row_num];
      my $row_below = $self->{grid}[$row_num+1];
      for (my $col_num=0; $col_num<=3; $col_num++) {
         if ((defined $row->[$col_num]) && (defined $row_below->[$col_num])) {
            my $arg_1 = $row->[$col_num];
            my $arg_2 = $row_below->[$col_num];
            my $result = &$routine($arg_1,$arg_2);
            if (defined $result) {
               $row_below->[$col_num] = $result;
               undef $row->[$col_num];
               $grid_change++;
            }
         }
      }
   }
   $grid_change += $self->pack_south();
   return $grid_change;
}

sub process_routine_west { 
   my $self = shift;
   my $routine = shift;

   my $grid_change = $self->pack_west();
   for (my $row_num=0; $row_num<=3; $row_num++) {
      my $row = $self->{grid}[$row_num];
      for (my $col_num=1; $col_num<=3; $col_num++) {
         my $col_left = $col_num - 1;
         if ((defined $row->[$col_num]) && (defined $row->[$col_left])) {
            my $arg_1 = $row->[$col_num];
            my $arg_2 = $row->[$col_left];
            my $result = &$routine($arg_1,$arg_2);
            if (defined $result) {
               $row->[$col_left] = $result;
               undef $row->[$col_num];
               $grid_change++;
            }
         }
      }
   }
   $grid_change += $self->pack_west();
   return $grid_change;
}

sub set_row_col{
   my $self = shift;
   my $row = shift;
   my $col = shift;
   my $value = shift;

   $self->{grid}[$row][$col] = $value;
}

sub Log{
   my $self = shift;
   my $msg = shift;

   my $program_name = $0;
   if (exists $self->{log_routine}) {
      my $log_routine = $self->{log_routine};
      no strict;
      &log_routine($msg);
   }
   elsif (open my $F, ">>$program_name.log") {
      print $F scalar localtime;
      print $F " $msg";
      if ($msg =! m/\n$/) {
         print $F "\n";
      }
      close $F;
   }
}

sub AUTOLOAD{
   my $self = shift;    
   my $value = shift;

   # This a autoload method catches any called method
   # that is not defined. By default the set values

   
   # Set values in this hash that you want get-able
   my %valid_autoload_get_parameters = (
      # 'xlabel', 1,      # key is 'xlabel', value is just a place holder (eg 1)
      # elevation => \&get_parameter_of_station,   # This useful getting values in a hash of hashes db.
   );

   # Set values in this hash that you want set-able
   my %valid_autoload_set_parameters = (
      # 'xlabel', 1,      # key is 'xlabel', value is just a place holder (eg 1)
   );

   my $method = $AUTOLOAD;
   my $return;
   if ($method =~ m/^.*?::set_(\w.+)$/) {
      my $parameter = $1;
      if (exists $valid_autoload_set_parameters{$parameter}) {
         if ((ref $valid_autoload_set_parameters{$parameter}) eq 'CODE') {
            my $sub = $valid_autoload_set_parameters{$parameter};
            no strict;  # Allow following sub call
            $return = &$sub($self, $parameter, $value);
            *{$AUTOLOAD} = sub{ &$sub($self, $parameter, $_[1]) };   # This reduces cost of AUTOLOADIND by installing an anonymous subroutine in the packages symbol table
         }
         else{
            $self->{$parameter} = $value;
         }
      }
   }
   if ($method =~ m/^.*?::get_(\w.+)$/) {
      my $parameter = $1;
      if (exists $valid_autoload_get_parameters{$parameter}) {
         if ((ref $valid_autoload_get_parameters{$parameter}) eq 'CODE') {
            my $sub = $valid_autoload_get_parameters{$parameter};
            no strict;  # Allow following sub call
            $return = &$sub($self, $parameter, $value);
            *{$AUTOLOAD} = sub{ &$sub($self, $parameter, $_[1]) };   # This reduces cost of AUTOLOADIND by installing an anonymous subroutine in the packages symbol table
         }
         else {
            $return = $self->{$parameter};
         }
      }
   }
   return $return; 
}

sub Error{
   my $msg = shift;

   if ($msg !~ m/\n$/) {
      $msg .= "\n";
   }
   # print STDERR $msg;
   cluck $msg;
}


sub DESTROY{

   my $self = shift;

   # Do some clean just before this object is destroyed


}

return 1;

__END__

=head1 NAME

Module::Name - One-line description of module's purpose

=head1 VERSION

This documentation refers to Module::Name version 0.0.1.

=head1 SYNOPSIS

   use Module::Name;
   
   my $obj = Module::Name->new(
      arg_1 => 'value 1';
      arg_2 => 'value 2';
      arg_3 => 'value whatever',
   );


=head1 DESCRIPTION 

=head1 SUBROUTINES/METHODS

=head1 DEPENDENCIES

   None

=head1 AUTHOR

<Dan DeBrito> (<ddebrito@gmail.com>)
   
=head1 LICENCE AND COPYRIGHT

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. See L<perlartistic>.  This program is
distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.
   
=head1 USAGE

use

