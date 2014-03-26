#!/usr/bin/perl

use strict;
use v5.10;
use GridBox;
use Term::ReadKey;
use Time::HiRes;

my $instructions = "Use the arrow keys to pack all the numbers
in the grid in a specific direction. Try to combine 
increasing sequencial fibonacci numbers together.";

my %fib_next = (1 => 2,
                2 => 3,
                3 => 5,
                5 => 8,
                8 => 13,
               13 => 21,
               21 => 34,
               34 => 55,
               55 => 89,
               89 => 144,
              144 => 233,
              233 => 377,
              377 => 610,
              610 => 987,
              987 => 1597,
             1597 => 2584,
             2584 => 4181,
             );

my %opts;

&Main();

sub Main{
   $SIG{'INT'} = sub { exit(0) };      # force performing of END block on control c.
   print "\033[2J";    #clear the screen
   print "\033[0;0H"; #jump to 0,0
   my $grid = GridBox->new();
   # Initialize grid with two 2s.
   my ($birth_row,$birth_col) = @{$grid->get_random_free_cell_from_grid()};
   $grid->set_row_col($birth_row,$birth_col,1);
   my ($birth_row,$birth_col) = @{$grid->get_random_free_cell_from_grid()};
   $grid->set_row_col($birth_row,$birth_col,1);
   $grid->print_grid();
   print "Type 'x' to exit. Otherwise use arrow keys to control game.\n";
   print "$instructions\n";
   my $char;
   my $state = 'waiting_for_start_char';
   my $cnt = 0;
#   ReadMode 3; 
   ReadMode 4; # Turn off controls keys
   my $routine = \&add_if_fibonacci_sequence;
   while (1) {
      while (not defined ($char = ReadKey(-1))) {
         Time::HiRes::usleep(10000);
      }
      my $ord = ord($char);
      if ($state eq 'waiting_for_start_char') {
         if ($ord == 27) {
            $state = 'waiting_for_left_square_bracked';
         }
      }
      elsif ($state eq 'waiting_for_left_square_bracked') {
         if ($char eq '[') {
            $state = 'waiting_for_arrow_direction';
         }
      }
      elsif ($state eq 'waiting_for_arrow_direction') {
         $state = 'waiting_for_start_char';
         print "\033[2J";    #clear the screen
         print "\033[0;0H"; #jump to 0,0
         if ($char eq 'A') {
            # Up Arrow
            my $grid_change = $grid->process_routine_north($routine);
            if ($grid_change) {
               # Only add birth number is packing or routine changes grid
               my ($birth_row,$birth_col) = @{$grid->get_random_free_cell_from_grid()};
               $grid->set_row_col($birth_row,$birth_col,1);
            }
            $grid->print_grid();
         }
         elsif ($char eq 'B') {
            # Down Arrow
            my $grid_change = $grid->process_routine_south($routine);
            if ($grid_change) {
               # Only add birth number is packing or routine changes grid
               my ($birth_row,$birth_col) = @{$grid->get_random_free_cell_from_grid()};
               $grid->set_row_col($birth_row,$birth_col,1);
            }
            $grid->print_grid();
         }
         elsif ($char eq 'C') {
            # Right Arrow
            my $grid_change = $grid->process_routine_east($routine);
            if ($grid_change) {
               # Only add birth number is packing or routine changes grid
               my ($birth_row,$birth_col) = @{$grid->get_random_free_cell_from_grid()};
               $grid->set_row_col($birth_row,$birth_col,1);
            }
            $grid->print_grid();
         }
         elsif ($char eq 'D') {
            # Left Arrow
            my $grid_change = $grid->process_routine_west($routine);
            if ($grid_change) {
               # Only add birth number is packing or routine changes grid
               my ($birth_row,$birth_col) = @{$grid->get_random_free_cell_from_grid()};
               $grid->set_row_col($birth_row,$birth_col,1);
            }
            $grid->print_grid();
         }
         print "Type 'x' to exit. Otherwise use arrow keys to control game.\n";
         print "$instructions\n";
         print "0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987, 1597, 2584, 4181, ...\n";
      }
      if ($char eq 'x') {
         ReadMode 0;
         exit();
      }
   }
   sleep 0;                            # Put here, so when debugging we can see results of previous lines.
}

sub add_if_equal {
   my $arg1 = shift;
   my $arg2 = shift;

   my $return;
   if ($arg1 == $arg2) {
      $return = $arg1 + $arg2;
   }
   return $return;
}

sub add_if_fibonacci_sequence {
   my $arg1 = shift;
   my $arg2 = shift;

   my $return;
   if (($arg1 == 1) && ($arg2 == 1)) {
      $return = 2;
   }
   elsif ($arg2 == $fib_next{$arg1}) {
      $return = $fib_next{$arg2};
   }
#   elsif ($arg1 == $fib_next{$arg2}) {
#      $return = $fib_next{$arg1};
#   }
     
   return $return;
}


sub Log{
   my $msg = shift;
   if ($msg !~ m/\n$/) {
      $msg .= "\n";
   }
   my $log_file = $0 . '.log';
   if (open my $LF, ">>$log_file") {
      print $LF scalar localtime, "\n ";
      print $LF $msg;
      close $LF;
   }
}

sub BEGIN{
   # Uncomment the following in order to get the debugger to debug the this routine
   # $DB::single = 1;, 
   
}

sub END{

}

__END__

Put notes here

=head1 USAGE



