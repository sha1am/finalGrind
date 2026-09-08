# Protection and Access Control

**Protection** controls how processes/users access system resources. **Security** is broader: protection, authentication, cryptography, isolation, secure configuration, auditing and threat resistance.

A useful model is:

```text
subject (process/user)
        |
   access check
        |
resource/object
```

Unix permissions use owner/group/other plus read/write/execute bits; ACLs can express more detailed rules.

## Principle of least privilege

Give a process only the permissions it needs, reducing the blast radius of bugs and compromise.
