# Kadane's Algorithm — Study Guide

## 1. What it is

Kadane's algorithm finds the **maximum sum of a contiguous subarray** within a 1D array of numbers (which may be positive, negative, or zero) in **O(n) time and O(1) space** — a single pass, no extra memory.

The problem it solves is called the **maximum subarray problem**: given `arr`, find the contiguous slice `arr[i..j]` whose sum is the largest possible. "Contiguous" is the key word — elements must be adjacent, unlike a subsequence.

It's technically a tiny piece of **dynamic programming**: the answer for "best subarray ending at index `j`" is built directly from "best subarray ending at index `j-1`", so you never recompute overlapping work.

---

## 2. The core intuition

Walk left to right. At each element ask one question:

> **Should I extend the subarray I've been building, or throw it away and start fresh from here?**

The rule: if the running sum you've accumulated so far is **negative**, it can only drag down whatever comes next — so discard it and start over at the current element. A negative prefix never helps a future sum.

Two variables carry all the state you need:

- `current` — the best subarray sum *ending exactly at the current index*
- `best` — the best sum *seen anywhere so far*

### The recurrence

```
current = max(arr[i], current + arr[i])
best    = max(best, current)
```

`max(arr[i], current + arr[i])` is literally the "start fresh vs. extend" decision. Initialize **both** to `arr[0]` (not to 0 — that breaks all-negative arrays, see pitfalls).

---

## 3. Worked example

Array: `[-2, 1, -3, 4, -1, 2, 1, -5, 4]`

| i | arr[i] | current = max(arr[i], current+arr[i]) | best |
|---|--------|----------------------------------------|------|
| 0 | -2 | -2 (init) | -2 |
| 1 | 1  | max(1, -2+1=-1) = **1** | 1 |
| 2 | -3 | max(-3, 1-3=-2) = **-2** | 1 |
| 3 | 4  | max(4, -2+4=2) = **4** | 4 |
| 4 | -1 | max(-1, 4-1=3) = **3** | 4 |
| 5 | 2  | max(2, 3+2=5) = **5** | 5 |
| 6 | 1  | max(1, 5+1=6) = **6** | **6** |
| 7 | -5 | max(-5, 6-5=1) = **1** | 6 |
| 8 | 4  | max(4, 1+4=5) = **5** | 6 |

Answer: **6**, from subarray `[4, -1, 2, 1]`.

Notice at i=2 the running sum dipped to -2 but `best` held onto 1; and at i=3, since -2+4=2 < 4, the algorithm effectively restarted at 4.

---

## 4. Implementations

**Python**
```python
def max_subarray(nums):
    current = best = nums[0]
    for x in nums[1:]:
        current = max(x, current + x)
        best = max(best, current)
    return best
```

**Go** (fast I/O matters for large N — relevant to your WarriorDivineEnergy problem)
```go
func maxSubArray(nums []int) int {
    current, best := nums[0], nums[0]
    for i := 1; i < len(nums); i++ {
        if current < 0 {
            current = nums[i]
        } else {
            current += nums[i]
        }
        if current > best {
            best = current
        }
    }
    return best
}
```

**Java**
```java
int maxSubArray(int[] nums) {
    int current = nums[0], best = nums[0];
    for (int i = 1; i < nums.length; i++) {
        current = Math.max(nums[i], current + nums[i]);
        best = Math.max(best, current);
    }
    return best;
}
```

### To recover the actual subarray (indices)
Track a tentative start; commit it when you start fresh, and record both ends when you beat `best`:
```python
def max_subarray_indices(nums):
    current = best = nums[0]
    start = best_l = best_r = 0
    for i in range(1, len(nums)):
        if nums[i] > current + nums[i]:
            current, start = nums[i], i
        else:
            current += nums[i]
        if current > best:
            best, best_l, best_r = current, start, i
    return best, best_l, best_r
```

---

## 5. Common pitfalls

- **All-negative arrays.** If you initialize to 0 and reset `current` to 0, you'll wrongly return 0 for `[-3, -1, -2]`. Initializing both vars to `arr[0]` (and using `max(x, current+x)` rather than clamping at 0) handles it — the answer is the least-negative element, `-1`.
- **Empty subarray allowed?** Some variants let you pick an empty subarray (sum 0). Clarify this with your interviewer — it changes initialization.
- **Overflow.** With N up to 10^6 and values up to 10^5, sums can reach ~10^11 — use 64-bit (`int64`/`long`), not 32-bit.
- **Off-by-one on the loop** when you start iterating from index 1 after seeding with index 0.
- **Confusing subarray with subsequence** — Kadane is contiguous only.

---

## 6. Good articles & resources

- **NeetCode — Kadane's Algorithm** (clean intuition, part of the advanced course): https://neetcode.io/courses/advanced-algorithms/0
- **GeeksforGeeks — Maximum Subarray Sum** (naive → optimal, multiple languages): https://www.geeksforgeeks.org/dsa/largest-sum-contiguous-subarray/
- **takeUforward — Kadane's Algorithm** (interview-focused, includes index recovery): https://takeuforward.org/data-structure/kadanes-algorithm-maximum-subarray-sum-in-an-array
- **algo.monster — LeetCode 53 in-depth**: https://algo.monster/liteproblems/53
- **Codecademy — Kadane's Algorithm**: https://www.codecademy.com/article/kadanes-algorithm-find-maximum-subarray-sum-in-an-array
- **Techie Delight** (C++/Java/Python, notes the all-negative edge case): https://www.techiedelight.com/maximum-subarray-problem-kadanes-algorithm/
- **Sassafras13 blog** (dynamic-programming framing, proof intuition): https://sassafras13.github.io/KadanesAlgo/

---

## 7. LeetCode problems (easy → hard)

These are the problems where Kadane's algorithm — or a direct extension of it (max-ending-here running state, sometimes tracked in two directions or as a max/min pair) — is the intended or a standard solution.

### Easy
| # | Problem | Kadane connection |
|---|---------|-------------------|
| 53 | Maximum Subarray | The canonical Kadane problem. |
| 121 | Best Time to Buy and Sell Stock | Kadane on the array of consecutive price *differences* → max subarray of gains. |
| 1005 | Maximize Sum Of Array After K Negations | Greedy, but pairs naturally with running-sum reasoning. |

### Medium
| # | Problem | Kadane connection |
|---|---------|-------------------|
| 152 | Maximum Product Subarray | Kadane variant tracking **both** max and min ending here (a negative can flip to the max). |
| 918 | Maximum Sum Circular Subarray | Kadane twice: normal max, plus `total − min-subarray` for the wrapping case. |
| 1191 | K-Concatenation Maximum Sum | Kadane on one/two copies plus prefix/suffix and total-sum analysis. |
| 1749 | Maximum Absolute Sum of Any Subarray | Run Kadane for both max-subarray and min-subarray; answer is `max(maxSum, -minSum)`. |
| 978 | Longest Turbulent Subarray | Running-state DP in the Kadane spirit (extend vs. restart on alternation). |
| 1567 | Maximum Length of Subarray With Positive Product | Kadane-style running lengths (track positive/negative streak lengths). |
| 2606 | Find the Substring With Maximum Cost | Kadane on character-value array. |
| 1013 | Partition Array Into Three Parts With Equal Sum | Running-sum partitioning (same accumulation idea). |
| 363 | Max Sum of Rectangle No Larger Than K | 2D: fix column pair, run a constrained Kadane on compressed rows. |

### Hard
| # | Problem | Kadane connection |
|---|---------|-------------------|
| 1746 | Maximum Subarray Sum After One Operation | **Directly your WarriorDivineEnergy pattern** — two DP states: best with the special operation unused vs. already used. |
| 2321 | Maximum Score Of Spliced Array | Kadane on the element-wise difference array (max subarray = best swap gain), run in both directions. |
| 689 | Maximum Sum of 3 Non-Overlapping Subarrays | Extends fixed-window max-sum reasoning to three windows. |
| 644 | Maximum Average Subarray II | Binary-search + Kadane-style feasibility check. |

---

## 8. The variant most relevant to your assessment

Your prep guide's **Problem 1 (WarriorDivineEnergy)** is Kadane with one optional operation. The trick is carrying **two rolling states**:

- `no_op` — best subarray sum ending here with the special operation *not yet used*
- `used`  — best subarray sum ending here with it *already used*

```
no_op = max(arr[i], no_op + arr[i])
used  = max(no_op_prev + operation(arr[i]),   # use op now
            used_prev + arr[i])               # already used it earlier
answer = max(answer, no_op, used)
```

This is exactly **LeetCode 1746** in structure. Master 53 first, then 1746 — that pair covers the base algorithm and the "extra DP state" twist your assessment is testing. Keep everything O(1) rolling state, use fast input, and use 64-bit sums for the N ≤ 10^6 constraint.
