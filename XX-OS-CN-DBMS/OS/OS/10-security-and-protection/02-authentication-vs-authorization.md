# Authentication vs Authorization

- **Authentication (AuthN):** Who are you?
- **Authorization (AuthZ):** What are you allowed to do?

Example: logging in with a password authenticates identity; checking whether that identity may read `/reports` is authorization.

## Interview trap

Encryption is not authentication. A system can encrypt data while still needing credentials/identity checks to decide who may access it.
