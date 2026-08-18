# Two Pointers — Complete Notes (C++)
*Concept-complete reference: types, identification, why it works, and problems*

---

## 📌 Setup (use this everywhere)

```cpp
#include <iostream>
#include <vector>
#include <string>
#include <algorithm>
#include <climits>
using namespace std;
```

---

## 📌 L1 — Introduction: What & Why

```
WHAT IS TWO POINTERS?
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Maintain two indices (pointers) into a data structure (usually
a sorted array, string, or linked list) and move them according
to some rule, instead of using nested loops to check every pair.

WHY TWO POINTERS?
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Brute force pair-checking is O(N^2) — for every i, scan all j.
Two pointers exploit a MONOTONIC PROPERTY (usually: sortedness,
or "if this pair doesn't work, no pair with this pointer
combination will either") to eliminate whole ranges of
candidates in one step. This drops most pair/triplet problems
from O(N^2)/O(N^3) to O(N)/O(N^2).

CORE REQUIREMENT — THE "MONOTONICITY" INSIGHT:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Two pointers only works when moving a pointer in one direction
predictably increases or decreases some quantity you care about.
  e.g. in a SORTED array, moving left pointer right -> sum increases
       moving right pointer left  -> sum decreases
This predictability is what lets you discard candidates without
checking them — that's the entire source of the speedup.
If there's no such monotonic relationship, two pointers doesn't
apply and you likely need hashing, sorting first, or DP.

TWO POINTERS vs SLIDING WINDOW:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Sliding window IS a two-pointer technique (both pointers move
same direction, defining a contiguous range). But "two pointers"
is the broader family — it also includes pointers that:
  - start at opposite ends and move toward each other
  - move at different speeds (fast/slow)
  - walk two different arrays/lists in parallel
Sliding window = subset of two pointers, specialized for
"contiguous subarray/substring" problems. Two pointers (opposite-
ends / fast-slow) is used for pair-finding, in-place partitioning,
merging, and cycle-detection instead.

HOW TO IDENTIFY A TWO POINTER PROBLEM:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Array/string is sorted, or can be sorted without losing what
   you need (e.g. pair sums, but NOT if original indices matter).
2. You're looking for a PAIR or TRIPLET satisfying a condition
   (sum, difference, product).
3. You need to do something IN-PLACE with O(1) extra space
   (partitioning, deduplication, reversal).
4. Two sorted sequences need to be MERGED or COMPARED.
5. A linked list problem mentions cycles, middle element, or
   "Nth from end" — classic fast/slow pointer signals.
```

---

## 📌 L2 — The Four Types of Two Pointers

```
TYPE 1 — OPPOSITE DIRECTIONAL (converging / two ends)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  left = 0, right = n - 1
  move left++ or right-- based on a condition
  pointers move TOWARD each other, stop when left >= right
  USE FOR: pair sum in sorted array, container with most water,
  trapping rain water, palindrome check, reverse in-place,
  3Sum/4Sum (fix outer index, two-pointer the rest)

TYPE 2 — SAME DIRECTIONAL, DIFFERENT SPEEDS (fast/slow)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  slow = 0, fast = 0 (or slow = write index, fast = read index)
  both move forward, fast moves faster or explores ahead
  USE FOR: remove duplicates in-place, move zeroes, partition
  (Dutch National Flag), linked list cycle detection (Floyd's),
  middle of linked list, Nth node from end

TYPE 3 — SAME DIRECTIONAL, SAME SPEED (read/write pointer)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  i = write position, j = read/scan position, j always >= i
  used for in-place compaction/filtering
  USE FOR: remove element, remove duplicates, move zeroes
  (this overlaps heavily with Type 2 — some problems are
  "same speed" scans, others need j to genuinely outrun i)

TYPE 4 — TWO POINTERS ON TWO DIFFERENT SEQUENCES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  i on array A, j on array B, both start at 0
  advance whichever pointer's element is "behind" in the merge order
  USE FOR: merge two sorted arrays, intersection/union of two
  sorted arrays, compare version strings, merge step of merge sort

MEMORY AID:
  Type 1 (⇦ ⇨ converge)   → sorted array, find a PAIR
  Type 2/3 (→ →  chase)   → in-place editing, linked list cycles
  Type 4 (→A  →B parallel)→ merging two separate sequences
```

---

## 📌 L3 — Pair Sum in Sorted Array (Two Sum II)

```cpp
// LC 167 — Type 1: opposite directional
// Array is SORTED. Move left/right based on how sum compares to target.
vector<int> pairSum(vector<int>& arr, int target) {
    int left = 0, right = arr.size() - 1;

    while (left < right) {
        int sum = arr[left] + arr[right];
        if (sum == target) return {left, right};
        else if (sum < target) left++;   // need a bigger sum -> move left up
        else right--;                     // need a smaller sum -> move right down
    }
    return {-1, -1};
}
// TC: O(N), SC: O(1)
// KEY: because array is sorted, increasing `left` only ever
// increases sum, decreasing `right` only ever decreases sum ->
// no pair is ever skipped by mistake
```

---

## 📌 L4 — Reverse Array / Palindrome Check (In-Place)

```cpp
// Type 1: opposite directional, classic in-place swap
void reverseArray(vector<int>& arr) {
    int left = 0, right = arr.size() - 1;
    while (left < right) {
        swap(arr[left], arr[right]);
        left++;
        right--;
    }
}

// LC 125 — Valid Palindrome (skip non-alphanumeric, ignore case)
bool isPalindrome(string& s) {
    int left = 0, right = s.size() - 1;
    while (left < right) {
        while (left < right && !isalnum(s[left])) left++;
        while (left < right && !isalnum(s[right])) right--;
        if (tolower(s[left]) != tolower(s[right])) return false;
        left++;
        right--;
    }
    return true;
}
// TC: O(N), SC: O(1)
```

---

## 📌 L5 — Container With Most Water

```cpp
// LC 11 — Type 1: opposite directional, GREEDY pointer movement
int maxArea(vector<int>& height) {
    int left = 0, right = height.size() - 1;
    int best = 0;

    while (left < right) {
        int width = right - left;
        int h = min(height[left], height[right]);
        best = max(best, width * h);

        // ALWAYS move the pointer at the SHORTER wall.
        // Moving the taller wall inward can only keep width smaller
        // AND height capped by the same (or smaller) short wall ->
        // strictly never improves the answer. Moving the shorter
        // wall is the only move that has a CHANCE of improving area.
        if (height[left] < height[right]) left++;
        else right--;
    }
    return best;
}
// TC: O(N), SC: O(1)
// KEY: the greedy proof ("always move the shorter side") is THE
// insight of this problem — memorize the reasoning, not just the code
```

---

## 📌 L6 — Trapping Rain Water

```cpp
// LC 42 — Type 1: opposite directional + running max from both sides
int trap(vector<int>& height) {
    int left = 0, right = height.size() - 1;
    int leftMax = 0, rightMax = 0;
    int water = 0;

    while (left < right) {
        if (height[left] < height[right]) {
            // leftMax is the binding constraint on this side
            height[left] >= leftMax ? leftMax = height[left]
                                     : water += leftMax - height[left];
            left++;
        } else {
            height[right] >= rightMax ? rightMax = height[right]
                                       : water += rightMax - height[right];
            right--;
        }
    }
    return water;
}
// TC: O(N), SC: O(1)
// KEY: water trapped at index i = min(maxLeft(i), maxRight(i)) - height[i].
// Whichever side has the SMALLER current max is the side whose water
// level is already determined (the other side is guaranteed to have
// an even taller wall somewhere), so it's safe to resolve that side.
```

---

## 📌 L7 — 3Sum (Fix One + Two Pointer the Rest)

```cpp
// LC 15 — sort first, fix arr[i], then Type 1 two-pointer on the remainder
vector<vector<int>> threeSum(vector<int>& arr) {
    sort(arr.begin(), arr.end());
    int n = arr.size();
    vector<vector<int>> result;

    for (int i = 0; i < n - 2; i++) {
        if (i > 0 && arr[i] == arr[i - 1]) continue;  // skip dup outer

        int left = i + 1, right = n - 1;
        while (left < right) {
            int sum = arr[i] + arr[left] + arr[right];
            if (sum == 0) {
                result.push_back({arr[i], arr[left], arr[right]});
                left++; right--;
                while (left < right && arr[left] == arr[left - 1]) left++;
                while (left < right && arr[right] == arr[right + 1]) right--;
            } else if (sum < 0) {
                left++;
            } else {
                right--;
            }
        }
    }
    return result;
}
// TC: O(N^2) — O(N log N) sort + O(N) outer * O(N) two-pointer inner
// SC: O(1) extra (excluding output / sort space)
// KEY: sorting first is what MAKES two pointers possible here —
// converts an O(N^3) triplet search into O(N^2)
```

---

## 📌 L8 — 4Sum (Fix Two + Two Pointer the Rest)

```cpp
// LC 18 — extends 3Sum by fixing two outer indices instead of one
vector<vector<int>> fourSum(vector<int>& arr, long long target) {
    sort(arr.begin(), arr.end());
    int n = arr.size();
    vector<vector<int>> result;

    for (int i = 0; i < n - 3; i++) {
        if (i > 0 && arr[i] == arr[i - 1]) continue;
        for (int j = i + 1; j < n - 2; j++) {
            if (j > i + 1 && arr[j] == arr[j - 1]) continue;

            int left = j + 1, right = n - 1;
            while (left < right) {
                long long sum = (long long)arr[i] + arr[j] + arr[left] + arr[right];
                if (sum == target) {
                    result.push_back({arr[i], arr[j], arr[left], arr[right]});
                    left++; right--;
                    while (left < right && arr[left] == arr[left - 1]) left++;
                    while (left < right && arr[right] == arr[right + 1]) right--;
                } else if (sum < target) left++;
                else right--;
            }
        }
    }
    return result;
}
// TC: O(N^3), SC: O(1) extra
// KEY: general pattern -> "K-Sum" fixes K-2 outer loops, then does
// one Type-1 two-pointer pass for the last 2 numbers. Always sort first.
```

---

## 📌 L9 — Remove Duplicates from Sorted Array (In-Place)

```cpp
// LC 26 — Type 2/3: slow = write pointer, fast = read/scan pointer
int removeDuplicates(vector<int>& arr) {
    if (arr.empty()) return 0;
    int slow = 0;   // last position of a confirmed-unique element

    for (int fast = 1; fast < (int)arr.size(); fast++) {
        if (arr[fast] != arr[slow]) {
            slow++;
            arr[slow] = arr[fast];
        }
    }
    return slow + 1;   // new length
}
// TC: O(N), SC: O(1)
// KEY: `slow` only advances when a genuinely new value is found ->
// fast "scouts ahead", slow marks where the next unique value belongs
```

---

## 📌 L10 — Move Zeroes (In-Place)

```cpp
// LC 283 — Type 2/3: slow = next position for a non-zero element
void moveZeroes(vector<int>& arr) {
    int slow = 0;
    for (int fast = 0; fast < (int)arr.size(); fast++) {
        if (arr[fast] != 0) {
            swap(arr[slow], arr[fast]);
            slow++;
        }
    }
}
// TC: O(N), SC: O(1)
// KEY: everything before `slow` is non-zero and in original relative
// order; swap (not just overwrite) keeps zeroes correctly pushed back
```

---

## 📌 L11 — Sort Colors / Dutch National Flag (Three Pointers)

```cpp
// LC 75 — extension of two pointers to THREE pointers
// low/mid/high partition array into [0s | 1s | unprocessed | 2s]
void sortColors(vector<int>& arr) {
    int low = 0, mid = 0, high = arr.size() - 1;

    while (mid <= high) {
        if (arr[mid] == 0) {
            swap(arr[low], arr[mid]);
            low++; mid++;
        } else if (arr[mid] == 1) {
            mid++;
        } else { // arr[mid] == 2
            swap(arr[mid], arr[high]);
            high--;
            // do NOT increment mid here — swapped-in value from
            // `high` hasn't been classified yet
        }
    }
}
// TC: O(N) single pass, SC: O(1)
// KEY: three regions maintained as invariants:
//   [0, low)      -> all 0s
//   [low, mid)    -> all 1s
//   [mid, high]   -> unprocessed
//   (high, n)     -> all 2s
```

---

## 📌 L12 — Merge Two Sorted Arrays

```cpp
// LC 88-style — Type 4: two pointers on TWO different sequences
// Merge arr2 into arr1 (arr1 has trailing space for arr2's elements)
void merge(vector<int>& arr1, int m, vector<int>& arr2, int n) {
    int i = m - 1;        // last real element of arr1
    int j = n - 1;        // last element of arr2
    int k = m + n - 1;    // last position of merged arr1

    while (j >= 0) {
        if (i >= 0 && arr1[i] > arr2[j]) {
            arr1[k--] = arr1[i--];
        } else {
            arr1[k--] = arr2[j--];
        }
    }
    // if i still >= 0 when j < 0, remaining arr1 elements are
    // already in place — nothing more to do
}
// TC: O(M + N), SC: O(1)
// KEY: filling from the BACK avoids overwriting arr1 elements
// before they've been read
```

---

## 📌 L13 — Intersection of Two Sorted Arrays

```cpp
// Type 4: two pointers on two different sorted sequences
vector<int> intersection(vector<int>& arr1, vector<int>& arr2) {
    int i = 0, j = 0;
    vector<int> result;

    while (i < (int)arr1.size() && j < (int)arr2.size()) {
        if (arr1[i] < arr2[j]) i++;
        else if (arr1[i] > arr2[j]) j++;
        else {
            result.push_back(arr1[i]);
            i++; j++;
        }
    }
    return result;
}
// TC: O(M + N), SC: O(1) extra (excluding output)
// KEY: whichever pointer is "behind" (smaller value) advances ->
// this is the merge-step logic from merge sort, reused for comparison
```

---

## 📌 L14 — Linked List Fast & Slow Pointers (Floyd's Algorithm)

```cpp
struct ListNode {
    int val;
    ListNode* next;
    ListNode(int x) : val(x), next(nullptr) {}
};

// LC 141 — Cycle Detection: fast moves 2 steps, slow moves 1 step
bool hasCycle(ListNode* head) {
    ListNode* slow = head;
    ListNode* fast = head;

    while (fast && fast->next) {
        slow = slow->next;
        fast = fast->next->next;
        if (slow == fast) return true;   // they meet -> cycle exists
    }
    return false;
}
// WHY THEY MEET: if there's a cycle, fast gains 1 step on slow every
// iteration (relative speed = 1) -> fast is guaranteed to lap slow
// within one full cycle length -> they must meet inside the cycle.

// LC 142 — Find the START of the cycle (after detecting one)
ListNode* detectCycleStart(ListNode* head) {
    ListNode* slow = head;
    ListNode* fast = head;

    while (fast && fast->next) {
        slow = slow->next;
        fast = fast->next->next;
        if (slow == fast) {
            // reset one pointer to head, move both 1 step at a time
            ListNode* ptr = head;
            while (ptr != slow) {
                ptr = ptr->next;
                slow = slow->next;
            }
            return ptr;    // meeting point = cycle start
        }
    }
    return nullptr;
}
// PROOF SKETCH: let distance head->cycleStart = a, cycleStart->meetPoint = b,
// meetPoint->cycleStart (going around) = c. Meeting gives: 2(a+b) = a+b+(b+c)
// => a = c. So moving `a` steps from head and `a` steps from meeting
// point both land exactly on cycleStart at the same time.

// LC 876 — Middle of Linked List: fast moves 2x, slow moves 1x
ListNode* middleNode(ListNode* head) {
    ListNode* slow = head;
    ListNode* fast = head;
    while (fast && fast->next) {
        slow = slow->next;
        fast = fast->next->next;
    }
    return slow;   // when fast reaches end, slow is at the middle
}

// LC 19 — Nth Node From End: two pointers, GAP of N maintained
ListNode* removeNthFromEnd(ListNode* head, int n) {
    ListNode dummy(0);
    dummy.next = head;
    ListNode* fast = &dummy;
    ListNode* slow = &dummy;

    for (int i = 0; i < n; i++) fast = fast->next;  // create gap of n

    while (fast->next) {
        fast = fast->next;
        slow = slow->next;
    }
    slow->next = slow->next->next;   // slow is now just before target
    return dummy.next;
}
// TC: O(N) single pass for all four, SC: O(1)
// KEY: a fixed GAP or fixed SPEED RATIO between two pointers is what
// converts "find something relative to the end / a cycle" into a
// single pass instead of needing to know the length upfront
```

---

## 📌 All Patterns — Quick Revision

```
TWO POINTER CHEAT SHEET:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TYPE                    → TECHNIQUE:
  Opposite directional     → left=0, right=n-1, converge inward
  Same dir, diff speed     → slow/fast, fast explores ahead
  Same dir, read/write     → i=write, j=read, compact in-place
  Two sequences            → i on A, j on B, advance the "behind" one

PROBLEM → PATTERN:
  Pair sum (sorted)         → opposite directional, move by sum comparison
  Reverse / palindrome      → opposite directional, swap & converge
  Container with most water → opposite directional, greedy: move shorter wall
  Trapping rain water       → opposite directional, track leftMax/rightMax
  3Sum / 4Sum / K-Sum       → sort + fix (K-2) indices + opposite directional
  Remove duplicates         → read/write pointer, write only on new value
  Move zeroes                → read/write pointer, swap non-zero forward
  Sort colors (DNF)         → THREE pointers, low/mid/high partition
  Merge two sorted arrays   → two sequences, fill from back (in-place variant)
  Intersection of 2 arrays  → two sequences, advance smaller-value pointer
  Linked list cycle detect  → fast/slow (2x/1x speed), Floyd's algorithm
  Cycle start                → fast/slow meet, then reset+equal-speed walk
  Middle of linked list     → fast/slow, fast reaches end when slow at middle
  Nth from end / gap probs  → fast/slow with a fixed head-start gap of N

WHEN TWO POINTERS DOES *NOT* APPLY:
  - Array isn't sorted AND sorting would destroy needed info
    (e.g. need original indices) -> use hashing instead
  - No monotonic relationship between pointer movement and the
    quantity you're tracking -> can't safely discard candidates
  - Looking for SUBSEQUENCES (non-contiguous, non-paired) with
    complex dependencies -> likely DP territory instead

DECISION FLOWCHART:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Sorted array + pair/triplet sum?      -> opposite directional
  In-place filter/partition/compact?    -> read/write (same speed)
  Linked list cycle / middle / Nth end? -> fast/slow (different speed)
  Merging or comparing 2 sequences?     -> two sequences (parallel)
  Contiguous subarray/substring?        -> that's sliding window,
                                            not classic two pointers

COMPLEXITY QUICK REF:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Opposite directional      O(N) time, O(1) space
K-Sum (fix K-2, 2-ptr)    O(N^(K-1)) time, O(1) extra space
Read/write in-place       O(N) time, O(1) space
Fast/slow (linked list)   O(N) time, O(1) space
Two sequences (merge)     O(M+N) time, O(1) extra space
```

---

## 📌 LeetCode Problem Map

```
TOPIC                              | LC #  | DIFFICULTY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Two Sum II (sorted)                | 167   | Medium
Valid Palindrome                   | 125   | Easy
Reverse String                     | 344   | Easy
Container With Most Water          | 11    | Medium
Trapping Rain Water                | 42    | Hard
3Sum                               | 15    | Medium
3Sum Closest                       | 16    | Medium
4Sum                               | 18    | Medium
Remove Duplicates from Sorted Arr  | 26    | Easy
Remove Element                     | 27    | Easy
Move Zeroes                        | 283   | Easy
Sort Colors (Dutch Flag)           | 75    | Medium
Merge Sorted Array                 | 88    | Easy
Intersection of Two Arrays II      | 350   | Easy
Squares of a Sorted Array          | 977   | Easy
Backspace String Compare           | 844   | Easy
Linked List Cycle                  | 141   | Easy
Linked List Cycle II                | 142   | Medium
Middle of the Linked List          | 876   | Easy
Remove Nth Node From End of List   | 19    | Medium
Happy Number (cycle in sequence)   | 202   | Easy
Palindrome Linked List             | 234   | Easy
Sort Array By Parity               | 905   | Easy
Boats to Save People               | 881   | Medium
```
