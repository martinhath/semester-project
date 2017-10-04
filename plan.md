# Project Plan, Fall '17

This is my project plan of the semester project in the fall of '17.
The plan consists of three lists:
one list of memory reclamation schemes,
one list of data structures using these schemes, and
one list of misc. stuff.

Tasks which are in *bold* are required for the MVP.

## Memory Reclamation Schemes

We list all reclamation schemes we might want to implement.
Due to time restrictions there is no way we will implement all.
Note that we can use eg. `crossbeam-epoch` "for free", for the data structures
that is implemented when comparing approaches.

 - [ ] *No memory reclamation (NMR)*
 - [ ] *EBR*
 - [ ] *Hazard Pointers*
 - [ ] Some thing based on RC
 - [ ] Optimistic Access (Cohen&Petrank)
 - [ ] DEBRA (Brown)
 - [ ] Forkscan (Alistarh et.al)

## Data Structures

We list all data strucutes we might want to test the reclamation schemes on.
This is primarily

 - [ ] *Queue*
 - [ ] *List*
 - [ ] SkipList
 - [ ] HashMap (?)
 - [ ] Some set structure (?)

## Misc

We need to build some testing suite, to ensure the correctness of the implementations.
We also need to set up some benchmarking suite for a fair comparison,
which needs to handle different workloads (eg. `read:write` ratio).

 - [ ] *Testing suite*
 - [ ] *Benchmarking suite*
