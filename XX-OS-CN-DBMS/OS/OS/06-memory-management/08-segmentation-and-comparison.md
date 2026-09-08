# Segmentation vs Paging

**Segmentation** divides memory into variable-sized logical regions such as code, data and stack. A logical address identifies a segment plus an offset.

**Paging** divides memory into fixed-size pages/frames.

| Paging | Segmentation |
|---|---|
| Fixed-size units | Variable-size logical units |
| Avoids external fragmentation in physical allocation | Can suffer external fragmentation |
| Transparent to programmer in many modern systems | Maps naturally to logical regions |
| Easy frame allocation | Natural protection/sharing by segment |

Modern general-purpose systems primarily rely on paging; segmentation concepts remain important historically and for interviews.
## Small example

Segmentation might describe a program as:

```text
Code segment  → executable instructions
Data segment  → globals
Stack segment → call frames
```

Paging instead treats memory as equal-sized pages regardless of logical meaning.
