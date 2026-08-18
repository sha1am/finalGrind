# Sliding Window Series — Complete Notes (C++)
*Based on Sliding Window Playlist — 13 Videos*

---

# 📌 Setup (use this everywhere)

```cpp
#include <iostream>
#include <vector>
#include <string>
#include <unordered_map>
#include <deque>
#include <climits>
#include <algorithm>
using namespace std;
```

---

## 📌 L1 — Introduction, Identification & Types

```
WHAT IS A WINDOW?
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
A window = a contiguous subarray/substring [start...end].
"Sliding" = the window moves forward over the array/string,
expanding or shrinking, instead of recomputing from scratch
for every possible subarray.

WHY SLIDING WINDOW?
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Brute force checks all O(N^2) or O(N^3) subarrays and
recomputes the answer for each one → wasteful, because
consecutive windows share most of their elements.
Sliding window reuses the previous window's computed state
(sum / freq map / count) and just adjusts for the element
entering and the element leaving → O(N) or O(N log N).

HOW TO IDENTIFY A SLIDING WINDOW PROBLEM:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. The problem talks about a contiguous subarray / substring
   (not subsequence — order & contiguity matter).
2. There's a notion of "window size k" OR a condition that
   defines whether a window is "valid" (e.g., sum <= target,
   at most k distinct chars, contains all chars of pattern).
3. Brute force naturally involves two nested loops (i, j)
   where the inner loop re-scans overlapping ranges.

TWO TYPES OF SLIDING WINDOW:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Fixed Size Window   → k is given and constant.
                       Slide by exactly 1 each step:
                       add arr[right], remove arr[left], right++, left++.

Variable Size Window → size grows/shrinks based on a condition.
                        Expand `right` greedily; shrink from `left`
                        while the window becomes invalid (or while
                        it's "more valid than needed", depending
                        on the problem).

TEMPLATE SKELETON:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
int left = 0;
for (int right = 0; right < n; right++) {
    // 1. include arr[right] into window state

    while (/* window invalid */) {
        // 2. exclude arr[left] from window state
        left++;
    }
    // 3. window [left, right] is valid here -> update answer
}
```

---

## 📌 L2 — Sliding Window Problems (Overview / Roadmap)

```
PROBLEM CATEGORIES COVERED IN THIS SERIES:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FIXED SIZE WINDOW:
  - Maximum Sum Subarray of size K
  - First Negative Number in every Window of size K
  - Count Occurrences of Anagrams
  - Maximum of all Subarrays of size K

VARIABLE SIZE WINDOW:
  - Largest Subarray with Sum K (positives, then +negatives)
  - Longest Substring with K Unique Characters
  - Longest Substring Without Repeating Characters
  - Pick Toys (Longest Subarray with at most 2 distinct)
  - Minimum Window Substring
  - Subarray Product Less Than K

GENERAL PROBLEM-SOLVING FLOW (taught across the series):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Brute Force        → generate all subarrays/substrings O(N^2)/O(N^3)
2. Better (two pointer)→ remove redundant recomputation
3. Optimal (sliding window) → O(N) using window state + add/remove ops
```

---

## 📌 L3 — Maximum Sum Subarray of Size K

```cpp
// Fixed size window. Maintain running sum; slide by one each step.
int maxSumSubarraySizeK(vector<int>& arr, int k) {
    int n = arr.size();
    int windowSum = 0, maxSum = INT_MIN;

    // Build first window
    for (int i = 0; i < k; i++) windowSum += arr[i];
    maxSum = windowSum;

    // Slide: add arr[right], remove arr[right-k]
    for (int right = k; right < n; right++) {
        windowSum += arr[right] - arr[right - k];
        maxSum = max(maxSum, windowSum);
    }
    return maxSum;
}
// TC: O(N), SC: O(1)
// KEY: windowSum_new = windowSum_old + incoming - outgoing
```

---

## 📌 L4 — First Negative Number in Every Window of Size K

```cpp
// Use a deque to store INDICES of negative numbers in current window,
// in order of appearance (front = oldest negative still in window).
vector<int> firstNegativeInWindow(vector<int>& arr, int k) {
    int n = arr.size();
    vector<int> result;
    deque<int> dq;   // stores indices of negative elements

    for (int right = 0; right < n; right++) {
        if (arr[right] < 0) dq.push_back(right);

        // window not yet full
        if (right >= k - 1) {
            // remove indices that fell out of window from the front
            while (!dq.empty() && dq.front() <= right - k) {
                dq.pop_front();
            }
            result.push_back(dq.empty() ? 0 : arr[dq.front()]);
            // NOTE: window start for this iteration = right - k + 1
        }
    }
    return result;
}
// TC: O(N), SC: O(K) worst case
// KEY: deque holds only negative indices -> front is always the
// first negative of the current window
```

---

## 📌 L5 — Count Occurrences of Anagrams

```cpp
// LC 438 family — count windows of size |pattern| in text that
// are anagrams of pattern.
int countAnagramOccurrences(string& text, string& pattern) {
    int k = pattern.size();
    unordered_map<char,int> need;
    for (char c : pattern) need[c]++;

    unordered_map<char,int> window;
    int matched = 0;              // count of chars with correct freq
    int count = 0;

    for (int right = 0; right < (int)text.size(); right++) {
        char inChar = text[right];
        if (need.count(inChar)) {
            window[inChar]++;
            if (window[inChar] == need[inChar]) matched++;
            else if (window[inChar] == need[inChar] + 1) matched--; // overshoot
        }

        if (right >= k) {
            char outChar = text[right - k];
            if (need.count(outChar)) {
                if (window[outChar] == need[outChar]) matched--;
                window[outChar]--;
                if (window[outChar] == need[outChar]) matched++;
            }
        }

        if (right >= k - 1 && matched == (int)need.size()) count++;
    }
    return count;
}
// TC: O(N), SC: O(26) ~ O(1)
// KEY: track how many distinct chars currently match required freq
// exactly, instead of comparing whole maps every window
```

---

## 📌 L6 — Maximum of All Subarrays of Size K

```cpp
// LC 239 — Monotonic deque storing INDICES, values decreasing
// front to back. Front is always the max of current window.
vector<int> maxSlidingWindow(vector<int>& arr, int k) {
    deque<int> dq;      // decreasing order of arr[index]
    vector<int> result;

    for (int right = 0; right < (int)arr.size(); right++) {
        // pop smaller elements from back — they can never be
        // the max while arr[right] is still in the window
        while (!dq.empty() && arr[dq.back()] < arr[right]) {
            dq.pop_back();
        }
        dq.push_back(right);

        // remove front if it's out of window
        if (dq.front() <= right - k) dq.pop_front();

        if (right >= k - 1) result.push_back(arr[dq.front()]);
    }
    return result;
}
// TC: O(N) — each index pushed & popped at most once
// SC: O(K)
// KEY: monotonic decreasing deque = classic "max in sliding window"
```

---

## 📌 L7 — Variable Size Window: Largest Subarray with Sum K (Part 1)

```cpp
// PART 1: assumes all POSITIVE numbers (sum only increases as
// window grows, so shrink-while-too-big logic is safe/valid).

// ── BRUTE FORCE O(N^2) ──────────────────────────────────
int longestSubarrayBrute(vector<int>& arr, long long k) {
    int n = arr.size(), maxLen = 0;
    for (int i = 0; i < n; i++) {
        long long sum = 0;
        for (int j = i; j < n; j++) {
            sum += arr[j];
            if (sum == k) maxLen = max(maxLen, j - i + 1);
        }
    }
    return maxLen;
}

// ── OPTIMAL: TWO POINTER / SLIDING WINDOW O(N) ──────────
int longestSubarrayOptimal(vector<int>& arr, long long k) {
    int n = arr.size(), left = 0, maxLen = 0;
    long long sum = 0;

    for (int right = 0; right < n; right++) {
        sum += arr[right];

        // shrink while sum exceeds k (only valid because arr[i] >= 0)
        while (sum > k && left <= right) {
            sum -= arr[left];
            left++;
        }

        if (sum == k) maxLen = max(maxLen, right - left + 1);
    }
    return maxLen;
}
// TC: O(N) — left and right each move forward at most N times
// SC: O(1)
```

---

## 📌 L8 — Largest Subarray with Sum K (Part 2 — handles negatives)

```cpp
// PART 2: array can contain NEGATIVE numbers too.
// Two-pointer shrink logic breaks (sum isn't monotonic), so use
// prefix sum + hashmap of {prefixSum -> earliest index} instead.

int longestSubarrayWithNegatives(vector<int>& arr, long long k) {
    unordered_map<long long, int> firstIndex; // prefixSum -> earliest idx
    long long sum = 0;
    int maxLen = 0;

    for (int i = 0; i < (int)arr.size(); i++) {
        sum += arr[i];

        if (sum == k) maxLen = max(maxLen, i + 1);

        // if (sum - k) occurred before at index j, then
        // subarray (j+1 ... i) sums to exactly k
        if (firstIndex.count(sum - k)) {
            maxLen = max(maxLen, i - firstIndex[sum - k]);
        }

        // store only the FIRST occurrence -> keeps subarray longest
        if (!firstIndex.count(sum)) firstIndex[sum] = i;
    }
    return maxLen;
}
// TC: O(N), SC: O(N)
// KEY: this is prefix-sum + hashmap, NOT sliding window — used
// specifically because negatives break window monotonicity
```

---

## 📌 L9 — Variable Size Sliding Window: General Format

The variable-size pattern we will use in these notes is:

```cpp
int left = 0;

for (int right = 0; right < n; right++) {

    // 1. ADD right element
    add(arr[right]);

    // 2. SHRINK while window is INVALID
    while (windowIsInvalid()) {
        remove(arr[left]);
        left++;
    }

    // 3. PROCESS the valid window
    process();
}
```

```
MENTAL MODEL:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
right -> GROWS the window
left  -> SHRINKS the window

1. Add right.
2. If the window becomes invalid, move left until valid again.
3. Once valid, process the answer.

IMPORTANT:
For LONGEST valid window:
    shrink WHILE INVALID
    then:
    ans = max(ans, right - left + 1);

For COUNTING all valid subarrays ending at right:
    shrink WHILE INVALID
    then:
    count += right - left + 1;

For SHORTEST / MINIMUM valid window:
    once the window becomes valid, keep shrinking WHILE VALID
    and record the answer before removing left.
```

### Pattern A — Longest valid window

```cpp
int left = 0;

for (int right = 0; right < n; right++) {

    add(arr[right]);

    while (windowIsInvalid()) {
        remove(arr[left]);
        left++;
    }

    ans = max(ans, right - left + 1);
}
```

Use when we want the largest window that obeys a constraint.

Examples:
- Longest Substring Without Repeating Characters
- Fruit Into Baskets / Pick Toys
- Longest Substring with At Most K Distinct Characters

### Pattern B — Count valid subarrays

```cpp
int left = 0;

for (int right = 0; right < n; right++) {

    add(arr[right]);

    while (windowIsInvalid()) {
        remove(arr[left]);
        left++;
    }

    count += right - left + 1;
}
```

Why `right - left + 1`?

We are NOT saying that the total number of subarrays inside the
window equals the window size.

We are counting the number of valid subarrays that END at the
current `right`.

If the valid window is:

```
[5, 2, 6]
 ↑     ↑
left  right
```

the valid subarrays ending at `right` are:

```
[6]
[2, 6]
[5, 2, 6]
```

There are exactly:

```cpp
right - left + 1
```

possible starting positions.

Every valid subarray is counted exactly once — when `right`
reaches its last element.

Use this in:
- Subarray Product Less Than K

### Pattern C — Shortest valid window

```cpp
int left = 0;

for (int right = 0; right < n; right++) {

    add(arr[right]);

    while (windowIsValid()) {

        ans = min(ans, right - left + 1);

        remove(arr[left]);
        left++;
    }
}
```

Here we shrink WHILE VALID because after finding a valid window,
we want to see how small we can make it while keeping it valid.

Examples:
- Minimum Size Subarray Sum
- Minimum Window Substring

### Variable-window decision rule

```
Want LONGEST valid window?
    -> shrink while INVALID
    -> update MAX after shrinking

Want COUNT of valid subarrays?
    -> shrink while INVALID
    -> count += right - left + 1

Want SHORTEST valid window?
    -> shrink while VALID
    -> update MIN inside the while loop
```

### Complexity

Even though there is a `while` loop inside a `for` loop, this is
usually O(N), not O(N^2).

`right` moves from 0 -> n-1 once.
`left` also only moves forward and can move at most n times.

So total pointer movement is O(2N) = O(N).

---

## 📌 L10 — Longest Substring with K Unique Characters

```cpp
// Variable window, Pattern A: shrink while distinct count > k
int longestKUniqueSubstring(string& s, int k) {
    unordered_map<char,int> freq;
    int left = 0, maxLen = 0;

    for (int right = 0; right < (int)s.size(); right++) {
        freq[s[right]]++;

        while ((int)freq.size() > k) {
            freq[s[left]]--;
            if (freq[s[left]] == 0) freq.erase(s[left]);
            left++;
        }

        if ((int)freq.size() == k) {
            maxLen = max(maxLen, right - left + 1);
        }
    }
    return maxLen;
}
// TC: O(N), SC: O(K)
```

---

## 📌 L11 — Longest Substring Without Repeating Characters

Use the SAME generic variable-window Pattern A:
add right -> shrink while invalid -> process valid window.

```cpp
int lengthOfLongestSubstring(string s) {

    unordered_map<char, int> freq;

    int left = 0;
    int maxLen = 0;

    for (int right = 0; right < (int)s.size(); right++) {

        // ADD
        freq[s[right]]++;

        // INVALID when the incoming character is repeated
        while (freq[s[right]] > 1) {

            // REMOVE
            freq[s[left]]--;
            left++;
        }

        // Window is valid here
        maxLen = max(maxLen, right - left + 1);
    }

    return maxLen;
}
```

Example:

```
s = "abca"

[a]       valid
[ab]      valid
[abc]     valid
[abca]    INVALID because 'a' occurs twice

remove left 'a'

[bca]     valid again
```

KEY:
Do not use a separate `lastSeen` jump optimization in these notes.
Solve it using the generic frequency-map + shrink-while-invalid
pattern so the same variable-window template stays consistent.

TC: O(N)
SC: O(character set)

---

## 📌 L12 — Pick Toys (Longest Subarray with At Most 2 Distinct)

```cpp
// Generalizes to LC 904 "Fruit Into Baskets".
// Variable window, Pattern A: shrink while distinct types > 2
int pickToys(vector<int>& toys) {
    unordered_map<int,int> freq;
    int left = 0, maxLen = 0;

    for (int right = 0; right < (int)toys.size(); right++) {
        freq[toys[right]]++;

        while ((int)freq.size() > 2) {
            freq[toys[left]]--;
            if (freq[toys[left]] == 0) freq.erase(toys[left]);
            left++;
        }

        maxLen = max(maxLen, right - left + 1);
    }
    return maxLen;
}
// TC: O(N), SC: O(1) (at most 3 keys in map at any time)
// KEY: same skeleton as "K unique characters" with K fixed at 2
```

---

## 📌 L13 — Minimum Window Substring

```cpp
// LC 76 — Variable window, Pattern B: shrink WHILE STILL VALID
// to find the smallest valid window, not the largest.
string minWindow(string& s, string& t) {
    if (t.empty() || s.size() < t.size()) return "";

    unordered_map<char,int> need;
    for (char c : t) need[c]++;

    unordered_map<char,int> window;
    int required = need.size();   // distinct chars still needed
    int formed = 0;                // distinct chars currently satisfied
    int left = 0, bestLen = INT_MAX, bestStart = 0;

    for (int right = 0; right < (int)s.size(); right++) {
        char c = s[right];
        window[c]++;
        if (need.count(c) && window[c] == need[c]) formed++;

        // window fully satisfies t -> try to shrink from left
        while (formed == required) {
            if (right - left + 1 < bestLen) {
                bestLen = right - left + 1;
                bestStart = left;
            }
            char leftChar = s[left];
            window[leftChar]--;
            if (need.count(leftChar) && window[leftChar] < need[leftChar]) {
                formed--;
            }
            left++;
        }
    }
    return bestLen == INT_MAX ? "" : s.substr(bestStart, bestLen);
}
// TC: O(|S| + |T|), SC: O(|S| + |T|)
// KEY: formed == required means window is currently VALID ->
// this is the "shrink while valid, expand while invalid" pattern,
// opposite of longest-substring problems
```

---

## 📌 L14 — Subarray Product Less Than K

```cpp
// LC 713
// nums contains positive integers.
// Count contiguous subarrays whose product is < k.

int numSubarrayProductLessThanK(vector<int>& nums, int k) {

    if (k <= 1)
        return 0;

    int left = 0;
    long long product = 1;
    int count = 0;

    for (int right = 0; right < (int)nums.size(); right++) {

        // 1. ADD right
        product *= nums[right];

        // 2. SHRINK while INVALID
        while (product >= k) {
            product /= nums[left];
            left++;
        }

        // 3. COUNT all valid subarrays ending at right
        count += right - left + 1;
    }

    return count;
}
```

Why do we shrink while INVALID rather than while valid?

Our valid condition is:

```
product < k
```

We want to KEEP a valid window. We only need to shrink when:

```
product >= k
```

because the window has become invalid.

After shrinking, `[left...right]` is valid again.

Why:

```cpp
count += right - left + 1;
```

Suppose the current valid window is:

```
[5, 2, 6]
 ↑     ↑
left  right
```

The valid subarrays ending at the current `right` are:

```
[6]
[2, 6]
[5, 2, 6]
```

There are 3, exactly the current window size.

We are NOT saying:

```
number of ALL subarrays inside window = window size
```

We are saying:

```
number of valid subarrays ENDING AT right
= number of possible starting positions
= right - left + 1
```

Every subarray gets counted exactly once, when `right` reaches
the final element of that subarray.

IMPORTANT:
This reasoning works because the problem has POSITIVE numbers.
If the full window product is < k, removing positive factors
from the left cannot make the product larger.

TC: O(N)
SC: O(1)

KEY PATTERN:

```cpp
for (int right = 0; right < n; right++) {

    add(right);

    while (invalid) {
        remove(left);
        left++;
    }

    count += right - left + 1;
}
```

---

## 📌 All Patterns — Quick Revision

```
SLIDING WINDOW CHEAT SHEET:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WINDOW TYPE     → TECHNIQUE:
  Fixed size K       → add arr[right], remove arr[right-k], slide by 1
  Variable, maximize → expand right, shrink left WHILE INVALID
  Variable, minimize → expand right, shrink left WHILE STILL VALID
  Variable, count    → expand right, shrink WHILE INVALID,
                        add (right-left+1) valid subarrays ending at right

PROBLEM → PATTERN:
  Max sum subarray size K         → fixed window, running sum
  First negative in window K      → fixed window + deque of indices
  Count anagram occurrences       → fixed window + freq map + matched-count trick
  Max of all subarrays size K     → fixed window + monotonic decreasing deque
  Longest subarray sum K (pos.)   → variable window, shrink while sum > k
  Longest subarray sum K (+/-)    → NOT sliding window; prefix sum + hashmap
  Longest substring K distinct    → variable window, shrink while distinct > k
  Longest substring no repeats    → variable window, jump left via lastSeen map
  Longest subarray ≤2 distinct    → variable window, special case of K-distinct (K=2)
  Minimum window substring        → variable window, shrink WHILE valid
  Subarray product < K              → variable window, shrink WHILE invalid,
                                      count += right-left+1

WHEN SLIDING WINDOW DOES *NOT* APPLY:
  - Negative numbers + "sum equals target" -> window sum isn't
    monotonic as it grows/shrinks -> use prefix sum + hashmap instead
  - Subsequence problems (non-contiguous) -> sliding window needs
    contiguity; use DP/other techniques instead

MONOTONIC DEQUE QUICK REF:
  Max in window -> pop smaller from back before pushing (decreasing deque)
  Min in window -> pop larger from back before pushing (increasing deque)
  Always pop from front when front index falls outside window

COMPLEXITY QUICK REF:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Fixed size window       O(N) time, O(1) or O(K) space
Variable size window    O(N) time (left, right each move ≤ N times)
Monotonic deque window  O(N) time (amortized, each index pushed/popped once)
Prefix sum + hashmap    O(N) time, O(N) space
```

---

## 📌 LeetCode Problem Map

```
TOPIC                                   | LC #  | DIFFICULTY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Maximum Sum Subarray of Size K          | -     | Easy (GFG)
First Negative in Window of Size K      | -     | Medium (GFG)
Count Occurrences of Anagrams           | 438*  | Medium
Maximum of All Subarrays of Size K      | 239   | Hard
Largest Subarray with Sum K (positives) | -     | Medium (GFG)
Largest Subarray with Sum K (+/-)       | 325*  | Medium
Longest Substring with K Unique Chars   | -     | Medium (GFG)
Longest Substring Without Repeating     | 3     | Medium
Fruit Into Baskets (Pick Toys)          | 904   | Medium
Minimum Window Substring                | 76    | Hard
Subarray Product Less Than K              | 713   | Medium

(* closely related LeetCode variant, not an exact match)
```













# Sliding Window: 3 Mental Models

Use these patterns to recognize the approach instead of memorizing individual problems.

---

# 1. Fixed-Size Window — Maintain Exactly K

### Recognition

The problem gives you the exact window size, such as a subarray or substring of size **K**.

### Mental Model

```
EXPAND → SIZE K → ANSWER → REMOVE LEFT → REPEAT
```

### Template

```cpp
int left = 0;

for (int right = 0; right < n; right++) {

    // Add nums[right]

    if (right - left + 1 == k) {

        // Calculate answer

        // Remove nums[left]

        left++;
    }
}
```

### Think

> The window size is fixed. I just slide it.

---

# 2. Variable Window — Longest / Maximum

### Recognition

Find the **longest substring/subarray** while a condition remains true.

### Mental Model

```
EXPAND → INVALID? → SHRINK UNTIL VALID → UPDATE MAX
```

### Template

```cpp
int left = 0;

for (int right = 0; right < n; right++) {

    // Add nums[right]

    while (invalid()) {

        // Remove nums[left]

        left++;
    }

    ans = max(ans, right - left + 1);
}
```

### Think

> Grow greedily. If I break the rule, shrink just enough to fix it.

---

# 3. Variable Window — Minimum

### Recognition

Find the **smallest/minimum window** satisfying a condition.

### Mental Model

```
EXPAND → VALID? → RECORD MIN → SHRINK WHILE STILL VALID
```

### Template

```cpp
int left = 0;

for (int right = 0; right < n; right++) {

    // Add nums[right]

    while (valid()) {

        ans = min(ans, right - left + 1);

        // Remove nums[left]

        left++;
    }
}
```

### Think

> As soon as the window becomes valid, squeeze it as much as possible.

---

# One-Page Cheat Sheet

| Pattern            | Recognition                   | Core Loop                       |
| ------------------ | ----------------------------- | ------------------------------- |
| Fixed Window       | Window size `K` is given      | Reach `K` → Answer → Slide      |
| Variable — Longest | Longest while condition holds | Expand → Invalid → Shrink → Max |
| Variable — Minimum | Smallest satisfying condition | Expand → Valid → Min → Shrink   |

---

# The Distinction to Burn Into Memory

## Longest Window

```
while (INVALID) {
    shrink();
}

updateMaximum();
```

---

## Minimum Window

```
while (VALID) {
    updateMinimum();
    shrink();
}
```
