# Curriculum Map and Source Alignment

## Primary-source coverage

### TUF categories

TUF's current interview sheet groups its 28 tracked items under:

- Introduction to OS — 7
- Process Management — 5
- Memory Management — 8
- File Systems — 4
- I/O Systems — 3
- Storage management and data protection — 1

The repository preserves those broad buckets while expanding concepts that are commonly asked as follow-ups rather than creating a one-file-per-question structure.

### YouTube depth/order

The supplied playlist is titled **Complete OS Course | Placements | Semester Exams | Jobs** and its introduction describes the series as a foundation for placements, exams and jobs. The repository therefore follows the conventional learning progression of introduction → processes → scheduling/synchronization → memory → files → I/O/storage, while adding backend/Linux extensions near the end.

## Added SDE-focused gaps

- IPC and file descriptors
- signals/process lifecycle
- mmap and copy-on-write
- blocking/non-blocking/asynchronous I/O
- I/O multiplexing
- containers: namespaces/cgroups
- memory pressure/OOM
- journaling/durability

These are included because they connect OS theory to backend production systems.
