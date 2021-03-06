package MaxMind::DB::Reader::Role::NodeReader;

use strict;
use warnings;
use namespace::autoclean;
use autodie;

use Moose::Role;

with 'MaxMind::DB::Reader::Role::HasMetadata';

has _node_byte_size => (
    is       => 'ro',
    isa      => 'Int',
    init_arg => undef,
    lazy     => 1,
    builder  => '_build_node_byte_size',
);

has _search_tree_size => (
    is       => 'ro',
    isa      => 'Int',
    init_arg => undef,
    lazy     => 1,
    builder  => '_build_search_tree_size',
);

sub _read_node {
    my $self     = shift;
    my $node_num = shift;

    my $node = q{};
    $self->_read(
        \$node,
        $node_num * $self->_node_byte_size(),
        $self->_node_byte_size(),
    );

    return $self->_split_node_into_records($node);
}

sub _split_node_into_records {
    my $self = shift;
    my $node = shift;

    if ( $self->record_size() == 24 ) {
        return unpack( NN => pack( 'xa*xa*' => unpack( a3a3 => $node ) ) );
    }
    elsif ( $self->record_size() == 28 ) {
        my ( $left, $middle, $right ) = unpack( a3Ca3 => $node );

        return (
            unpack( N => pack( 'Ca*', ( $middle & 0xf0 ) >> 4, $left ) ),
            unpack( N => pack( 'Ca*', ( $middle & 0x0f ),      $right ) )
        );
    }
    elsif ( $self->record_size() == 32 ) {
        return unpack( NN => $node );
    }
}

sub _build_node_byte_size {
    my $self = shift;

    return $self->record_size() * 2 / 8;
}

sub _build_search_tree_size {
    my $self = shift;

    return $self->node_count() * $self->_node_byte_size();
}

1;
