# Namespaces, cgroups and Containers

Containers are OS-level isolation mechanisms rather than miniature virtual machines.

### Namespaces
Isolate views of resources such as process IDs, network interfaces, mounts and users.

### cgroups
Control/account for resource usage such as CPU and memory.

### Container image
Usually contains a user-space filesystem/runtime dependencies; it shares the host kernel in ordinary containers.

## Container vs VM

VM: virtualizes hardware and normally runs a guest kernel.

Container: isolates processes while using the host kernel.

This distinction is a common backend/SRE interview question.
