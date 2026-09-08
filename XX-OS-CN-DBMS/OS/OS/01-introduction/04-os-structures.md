# OS Structures

## Why structure matters

The kernel contains many components. Its architecture determines isolation, performance, maintainability and failure behavior.

### Monolithic kernel

Most core services execute in one privileged address space. Internal calls are fast, but a kernel bug can have a large blast radius.

### Microkernel

Keeps a small privileged core and moves services into user space. This improves isolation but can add communication/context-switch overhead.

### Layered design

Organizes functionality into layers with controlled dependencies.

### Modular kernel

Core kernel plus dynamically loadable modules. Linux uses a largely monolithic design with strong modularity.

### Hybrid

Combines ideas from monolithic and microkernel designs.

## Interview comparison

```text
Monolithic: more kernel work in one privileged domain -> fast internal paths, larger trusted core
Microkernel: smaller trusted core -> stronger isolation, more IPC boundaries
```
