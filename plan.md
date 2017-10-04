# Project Plan, Fall '17

This is my project plan of the semester project in the fall of '17.
The plan consists of three lists:
one list of memory reclamation schemes,
one list of data structures using these schemes, and
one list of misc. stuff.

The checkboxes are checked off when they are considered done.
Eg, `No memory reclamation` will be checked off when there
is a correct implementation of all data structures we want to use,
without any memory reclamation.

## Memory Reclamation Schemes

We list all reclamation schemes we might want to implement.
Due to time restrictions there is no way we will implement all.
Note that we can use eg. `crossbeam-epoch` "for free", for the data structures
that is implemented when comparing approaches.

 - [ ] No memory reclamation
 - [ ] EBR
 - [ ] Hazard Pointers
 - [ ] Some thing based on RC
 - [ ] Optimistic Access (Cohen&Petrank)
 - [ ] DEBRA (Brown)
 - [ ] Forkscan (Alistarh et.al)

## Data Structures

We list all data strucutes we might want to test the reclamation schemes on.
This is primarily

 - [ ] Queue
 - [ ] List
 - [ ] SkipList
 - [ ] HashMap (?)
 - [ ] Some set structure (?)

## Misc

We need to build some testing suite, to ensure the correctness of the implementations.
We also need to set up some benchmarking suite for a fair comparison,
which needs to handle different workloads (eg. `read:write` ratio).

 - [ ] Testing suite
 - [ ] Benchmarking suite

# Progress

How far have are we?

Tasks which are in **bold** are required for the MVP.


| Reclamation Scheme | Queue | List | SkipList | HashMap (?) |
| --- | --- | --- | --- | --- |
|*No memory reclamation (NMR)* | **yes** | **no** | no | no |
|*EBR* |  **no** | **no** | no | no |
|*Hazard Pointers* |  **no** | **no** | no | no |
| `crossbeam-epoch` | **yes** | **yes** | no | no |
|Some thing based on RC |  no | no | no | no |
|Optimistic Access (Cohen&Petrank) |  no | no | no | no |
|DEBRA (Brown) |  no | no | no | no |
|Forkscan (Alistarh et.al) |  no | no | no | no |
