# Resiable Lists

Pascal's array type is very basic. The `Lists` unit implements two more complex list types: `TArrayList` and `TLinkedList`.

## TArrayList

`TArrayList` is an resizable list backed by a single block of memory. It has constant time access and linear time iteration. Insertion is linear time and addition is constant time in the best case and linear time in the worst case.

## TLinkedList

`TLinkedList` is a resizable list back by a series of linked nodes. It has linear time access and iteration but provides constant time inserts and additions.


