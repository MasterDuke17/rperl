# [[[ HEADER ]]]
package RPerl::Algorithm::Sort::Merge;
use strict;
use warnings;
use RPerl::AfterSubclass;
our $VERSION = 0.001_000;

# [[[ OO INHERITANCE ]]]
use parent qw(RPerl::Algorithm::Sort);
use RPerl::Algorithm::Sort;

# [[[ OO PROPERTIES ]]]
our hashref $properties =
{
	variant => my string $TYPED_mode = 'topdown',  # default to top-down variant
	data => my unknown $TYPED_data  # TODO: create nonscalarref data type?
};

# [[[ OO METHODS & SUBROUTINES ]]]

# call out to sort data, return nothing
our void::method $sort = sub {(my object $self) = @_;
	if ((ref($self->{data}) eq 'ARRAY') or ($self->{data}->isa('arrayref')))
	{
		if ($self->{variant} eq 'topdown') { $self->{data} = mergesort_array_topdown($self->{data}); }
		elsif ($self->{variant} eq 'bottomup') { $self->{data} = mergesort_array_bottomup($self->{data}); }
		else { die("Unsupported variant '" . $self->{variant} . "' detected for arrayref data type (topdown or bottomup supported), dying"); }
	}
	elsif ($self->{data}->isa('scalar_linkedlistref'))
	{
		if ($self->{variant} eq 'topdown') { $self->{data}->{head} = mergesort_linkedlist_topdown($self->{data}->{head}); }
		else { die("Unsupported variant '" . $self->{variant} . "' detected for linkedlistref data type (only topdown supported), dying"); }
	}
	else { die("Unsupported data structure '" . ref($self->{data}) . "' detected (arrayref or linkedlistref supported), dying"); }
};

# top-down variant: comparison-based and stable and online [O(n log n) average total time, O(n) worst-case total extra space]
# sort data, return sorted data
our scalartype_arrayref $mergesort_array_topdown = sub {(my scalartype_arrayref $data) = @_;
	my integer $data_length = scalar(@{$data});  # CONSTANT
	
#	RPerl::diag("in mergesort_array_topdown(), have \$data = \n" . RPerl::DUMPER($data) . "\n");
#	RPerl::diag("in mergesort_array_topdown(), have \$data_length = $data_length\n");

	# singleton or empty sublists are sorted
	return $data if ($data_length <= 1);
	
	# split data in half at midpoint
	my integer $i_middle = int($data_length / 2);  # CONSTANT
	my scalartype_arrayref $left = [@$data[0 .. ($i_middle - 1)]];
	my scalartype_arrayref $right = [@$data[$i_middle .. ($data_length - 1)]];
	
	# recursively call this function on the sublists [O(log n) time], then merge the lengths-add-to-n sublists [O(n) time]
	$left = mergesort_array_topdown($left);
	$right = mergesort_array_topdown($right);
	$data = merge_array_topdown($left, $right);

	# data is now sorted [O(n log n) total time, O(n) total extra space] 
	# via iteration during merging [O(n) time, O(n) extra space] and recursion [O(log n) time, O(1) extra space? why not O(log n) extra space for call stack like in-place quicksort?]
	return $data;
};

# top-down variant; merge sublists data, return merged data [O(n) time, O(n) total extra space]
our scalartype_arrayref $merge_array_topdown = sub {(my scalartype_arrayref $left, my scalartype_arrayref $right) = @_;
	my integer $left_length = scalar(@{$left});
	my integer $right_length = scalar(@{$right});
	
	# merged sublists [O(n) total extra space]
	my @merged_scalar__array = ();
	
	# iteratively merge elements of lengths-add-to-n sublists [O(n) time, O(n) total extra space for merged sublists]
	while (($left_length > 0) || ($right_length > 0))
	{
		if (($left_length > 0) && ($right_length > 0))
		{
			# compare elements and merge in smaller element, this is the core sort comparison
			if ($left->[0] <= $right->[0]) { push(@merged_scalar__array, shift(@{$left}));  $left_length--; }
			else { push(@merged_scalar__array, shift(@{$right}));  $right_length--; }
		}
		elsif ($left_length > 0) { @merged_scalar__array = (@merged_scalar__array, @{$left});  $left_length = 0; }
		elsif ($right_length > 0) { @merged_scalar__array = (@merged_scalar__array, @{$right});  $right_length = 0; }
	}
	
	return \@merged_scalar__array;
};

# bottom-up variant: comparison-based and stable and online [O(n log n) average total time, O(n) worst-case total extra space]
# sort data, return sorted data
our scalartype_arrayref $mergesort_array_bottomup = sub {(my scalartype_arrayref $data) = @_;
	my integer $data_length = scalar(@{$data});  # CONSTANT
	my integer $width;	
	my integer $i;
	
	# temporary storage for partially sorted data [O(n) total extra space; counted for this function, not the merge_array_bottomup() function]
	my scalartype_arrayref $tmp_data = [];
	
#	RPerl::diag("in mergesort_array_bottomup(), have \$data = \n" . RPerl::DUMPER($data) . "\n");
#	RPerl::diag("in mergesort_array_bottomup(), have \$data_length = $data_length\n");
	
	# iterate through the length-n list with logarithmic iterator growth [O(log n) time]
	for ($width = 1; $width < $data_length; $width = $width * 2)
	{
#		RPerl::diag("in mergesort_array_bottomup(), top of outer for() loop, have \$width = $width\n");
		for ($i = 0; $i < $data_length; $i = $i + ($width * 2))
		{
#			RPerl::diag("in mergesort_array_bottomup(), top of inner for() loop, have \$i = $i\n");
			merge_array_bottomup($data, $tmp_data, $i, min(($i + $width), $data_length), min(($i + ($width * 2)), $data_length));
		}
		$data = [@$tmp_data];
	}
	
	# data is now sorted [O(n log n) total time, O(n) total extra space] 
	# via iteration during merging [O(n) time, O(1) extra space] and top-level nested iteration [O(log n) time, O(n) extra space]
	return $data;
};

# bottom-up variant; merge sublists, return nothing [O(n) time, O(1) extra space]
our void $merge_array_bottomup = sub {(my scalartype_arrayref $data, my scalartype_arrayref $tmp_data, my integer $i_left, my integer $i_right, my integer $i_end) = @_;  # CONSTANTS $i_left, $i_right, $i_end
	my integer $i0 = $i_left;
	my integer $i1 = $i_right;
	my integer $j;
	
#	RPerl::diag("in merge_array_bottomup(), have \$data = \n" . RPerl::DUMPER($data) . "\n");
#	RPerl::diag("in merge_array_bottomup(), have \$tmp_data = \n" . RPerl::DUMPER($tmp_data) . "\n");
#	RPerl::diag("in merge_array_bottomup(), have \$i_left = $i_left\n");
#	RPerl::diag("in merge_array_bottomup(), have \$i_right = $i_right\n");
#	RPerl::diag("in merge_array_bottomup(), have \$i_end = $i_end\n");
		
	# iteratively merge elements of lengths-add-to-n sublists [O(n) time, O(1) extra space]
	for ($j = $i_left; $j < $i_end; $j++)
	{
#		RPerl::diag("in merge_array_bottomup(), top of for() loop, have \$j = $j\n");

		# compare elements and merge in smaller element, this is the core sort comparison
		if (($i0 < $i_right) && (($i1 >= $i_end) || ($data->[$i0] <= $data->[$i1])))
		{
#			RPerl::diag("in merge_array_bottomup(), setting \$tmp_data->[$j] = \$data->[\$i0] = \$data->[$i0] = " . $data->[$i0] . "\n");
			$tmp_data->[$j] = $data->[$i0];
			$i0++;
		}
		else
		{
#			RPerl::diag("in merge_array_bottomup(), setting \$tmp_data->[$j] = \$data->[\$i1] = \$data->[$i1] = " . $data->[$i1] . "\n");
			$tmp_data->[$j] = $data->[$i1];
			$i1++;
		}
	}
};

# bottom-up variant; return smaller of 2 scalars [O(1) time, O(1) extra space]
our scalartype $min = sub {(my scalartype $a, my scalartype $b) = @_; if ($a < $b) {return $a;} else {return $b;}};  # CONSTANTS $a, $b

# linked list, top-down variant: comparison-based and stable and online [O(n log n) average total time, O(1) worst-case total extra space]
# sort data starting at head node, return new head node of sorted data
our linkedlistnoderef $mergesort_linkedlist_topdown = sub {(my linkedlistnoderef $head) = @_;
#	RPerl::diag("in mergesort_linkedlist_topdown(), received \$head = " . RPerl::DUMPER($head) . "\n");

	my linkedlistnoderef $left;
	my linkedlistnoderef $right;
	
	# singleton or empty sublists are sorted
	return $head if (not(defined($head)) or not(defined($head->{next})));
	
	($left, $right) = @{split_linkedlist($head)};
#	RPerl::diag("in mergesort_linkedlist_topdown(), after split_linkedlist() have \$left = " . RPerl::DUMPER($left) . "\n");
#	RPerl::diag("in mergesort_linkedlist_topdown(), after split_linkedlist() have \$right = " . RPerl::DUMPER($right) . "\n");

	$left = mergesort_linkedlist_topdown($left);
	$right = mergesort_linkedlist_topdown($right);
#	RPerl::diag("in mergesort_linkedlist_topdown(), after recursion to mergesort_linkedlist_topdown() have \$left = " . RPerl::DUMPER($left) . "\n");
#	RPerl::diag("in mergesort_linkedlist_topdown(), after recursion to mergesort_linkedlist_topdown() have \$right = " . RPerl::DUMPER($right) . "\n");
	
	$head = merge_linkedlist_topdown($left, $right);
#	RPerl::diag("in mergesort_linkedlist_topdown(), after merge_linkedlist_topdown(), about to return \$head = " . RPerl::DUMPER($head) . "\n");
	
	return $head;
};

# linked list, top-down variant; split into sublists, return sublists [O(n) time, O(1) extra space]
our arrayref $split_linkedlist = sub {(my scalartype_linkedlistref $head) = @_;
#	RPerl::diag("in split_linkedlist(), received \$head->{data} = " . $head->{data} . "\n");
	
	my linkedlistnoderef $left;
	my linkedlistnoderef $right;
	my linkedlistnoderef $slow;
	my linkedlistnoderef $fast;
	
	# singleton or empty sublists
	if (not(defined($head)) or not(defined($head->{next})))
	{
		$left = $head;
		$right = undef;	
	}
	else
	{
		$slow = $head;
		$fast = $head->{next};
		
		# advance fast twice and slow once
		while (defined($fast))
		{
			$fast = $fast->{next};
			if (defined($fast))
			{
				$slow = $slow->{next};
				$fast = $fast->{next};
			}
		}
		
		# split data in half at midpoint
		$left = $head;
		$right = $slow->{next};
		$slow->{next} = undef;
	}
	
#	RPerl::diag("in split_linkedlist(), have final \$left = " . RPerl::DUMPER($left) . "\n");
#	RPerl::diag("in split_linkedlist(), have final \$right = " . RPerl::DUMPER($right) . "\n");
	return [$left, $right];
};

# linked list, top-down variant; merge sublists, return sublists [O(n) time, O(1) extra space]
our linkedlistnoderef $merge_linkedlist_topdown = sub {(my linkedlistnoderef $left, my linkedlistnoderef $right) = @_;
#	RPerl::diag("in merge_linkedlist_topdown(), received \$left = " . RPerl::DUMPER($left) . "\n");
#	RPerl::diag("in merge_linkedlist_topdown(), received \$right = " . RPerl::DUMPER($right) . "\n");

	my linkedlistnoderef $merged;
	
	if (not(defined($left)))
	{
#		RPerl::diag("in merge_linkedlist_topdown(), have undefined \$left, returning only \$right\n");
		return $right;
	}
	elsif (not(defined($right)))
	{
#		RPerl::diag("in merge_linkedlist_topdown(), have undefined \$right, returning only \$left\n");
		return $left;
	}
	
	if ($left->{data} <= $right->{data})
	{
#		RPerl::diag("in merge_linkedlist_topdown(), have \$left->{data} <= \$right->{data} === " . $left->{data} . " <= " . $right->{data} . "\n");
		$merged = $left;
		$merged->{next} = merge_linkedlist_topdown($left->{next}, $right);
	}
	else
	{
#		RPerl::diag("in merge_linkedlist_topdown(), have \$left->{data} > \$right->{data} === " . $left->{data} . " > " . $right->{data} . "\n");
		$merged = $right;
		$merged->{next} = merge_linkedlist_topdown($left, $right->{next});
	}
	
#	RPerl::diag("in merge_linkedlist_topdown(), returning \$merged = " . RPerl::DUMPER($merged) . "\n");
	return $merged;
};

1;  # end of class