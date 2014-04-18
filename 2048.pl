#!/usr/bin/perl

use strict;
use v5.10;
use GridBox;

my %opts;

&Main();

sub Main{
   $SIG{'INT'} = sub { exit(0) };      # force performing of END block on control c.
   # open STDERR, '>', "error.log"
   print "\033[2J";    #clear the screen
   print "\033[0;0H"; #jump to 0,0
   my $grid = GridBox->new();
   # Initialize grid with two 2s.
   my ($birth_row,$birth_col) = @{$grid->get_random_free_cell_from_grid()};
   $grid->set_row_col($birth_row,$birth_col,2);
   my ($birth_row,$birth_col) = @{$grid->get_random_free_cell_from_grid()};
   $grid->set_row_col($birth_row,$birth_col,2);
   $grid->print_grid();
   print "\nUse arrow keys to pack the grid. Type 'x' to exit.\n";
   my $char;
   my $state = 'waiting_for_start_char';
   my $cnt = 0;
   my $routine = \&add_if_equal;
   
   my $BSD = -f '/vmunix';
   if ($BSD) {
       system "stty cbreak /dev/tty 2>&1";
   }
   else {
       system "stty", '-icanon',
       system "stty", 'eol', "\001"; 
   }

   while (1) {
      $char = getc(STDIN);
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
               $grid->set_row_col($birth_row,$birth_col,2);
            }
            $grid->print_grid();
         }
         elsif ($char eq 'B') {
            # Down Arrow
            my $grid_change = $grid->process_routine_south($routine);
            if ($grid_change) {
               # Only add birth number is packing or routine changes grid
               my ($birth_row,$birth_col) = @{$grid->get_random_free_cell_from_grid()};
               $grid->set_row_col($birth_row,$birth_col,2);
            }
            $grid->print_grid();
         }
         elsif ($char eq 'C') {
            # Right Arrow
            my $grid_change = $grid->process_routine_east($routine);
            if ($grid_change) {
               # Only add birth number is packing or routine changes grid
               my ($birth_row,$birth_col) = @{$grid->get_random_free_cell_from_grid()};
               $grid->set_row_col($birth_row,$birth_col,2);
            }
            $grid->print_grid();
         }
         elsif ($char eq 'D') {
            # Left Arrow
            my $grid_change = $grid->process_routine_west($routine);
            if ($grid_change) {
               # Only add birth number is packing or routine changes grid
               my ($birth_row,$birth_col) = @{$grid->get_random_free_cell_from_grid()};
               $grid->set_row_col($birth_row,$birth_col,2);
            }
            $grid->print_grid();
         }
         print "\nUse arrow keys to pack the grid. Type 'x' to exit.\n";
      }
      if ($char eq 'x') {
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
   
   # Log Program Start
   my $args = join ' ', @ARGV;
   # &Log("Starting $$ $0 " . join ' ', @ARGV);

}

sub END{
   # &Log('End');

}

__END__

Put notes here

=head1 USAGE



