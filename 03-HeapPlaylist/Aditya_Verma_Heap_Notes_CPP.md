# Aditya Verma Heap Series — Complete Notes (C++)
*Based on Aditya Verma's Heap Playlist — 10 Videos (topics reconstructed from the course curriculum, not verbatim transcripts)* 

[Leetcode Playlist](https://leetcode.com/problem-list/heap-priority-queue/)

---

## 📌 C++ Heap Setup (use this everywhere)

```cpp
#include <iostream>
#include <vector>
#include <queue>          // priority_queue lives here
#include <unordered_map>
#include <tuple>
#include <climits>
#include <algorithm>
using namespace std;

// ── STL HEAPS ────────────────────────────────────────────
priority_queue<int> maxHeap;                                    // default = MAX-heap, root = largest
priority_queue<int, vector<int>, greater<int>> minHeap;         // MIN-heap, root = smallest

// Heap of pairs — compares .first, ties broken by .second
priority_queue<pair<int,int>> maxHeapPair;
priority_queue<pair<int,int>, vector<pair<int,int>>, greater<pair<int,int>>> minHeapPair;

// Custom comparator (struct) — needed for anything beyond pair/tuple (e.g. pointers)
struct Compare {
    bool operator()(pair<int,int>& a, pair<int,int>& b) {
        return a.second > b.second;      // MIN-heap ordered by .second
    }
};
priority_queue<pair<int,int>, vector<pair<int,int>>, Compare> pq;

// Core ops:  pq.push(x) O(log N)  |  pq.pop() O(log N)  |  pq.top() O(1)  |  pq.empty(), pq.size() O(1)

// ── ARRAY REPRESENTATION (0-indexed) ────────────────────
// parent(i) = (i-1)/2      left(i) = 2*i+1      right(i) = 2*i+2

// ── MANUAL MAX-HEAP (insert / extractMax / heapify) ─────
class MaxHeap {
    vector<int> arr;

    void heapifyUp(int i) {
        while (i > 0) {
            int parent = (i - 1) / 2;
            if (arr[parent] < arr[i]) { swap(arr[parent], arr[i]); i = parent; }
            else break;
        }
    }

    void heapifyDown(int i) {
        int n = arr.size();
        while (true) {
            int left = 2*i + 1, right = 2*i + 2, largest = i;
            if (left  < n && arr[left]  > arr[largest]) largest = left;
            if (right < n && arr[right] > arr[largest]) largest = right;
            if (largest == i) break;
            swap(arr[i], arr[largest]);
            i = largest;
        }
    }

public:
    void insert(int val) { arr.push_back(val); heapifyUp(arr.size() - 1); }

    int extractMax() {
        int maxVal = arr[0];
        arr[0] = arr.back();
        arr.pop_back();
        heapifyDown(0);
        return maxVal;
    }

    int getMax()  { return arr[0]; }
    bool empty()  { return arr.empty(); }
};
// TC: insert O(log N), extractMax O(log N), getMax O(1)

// ── BUILD HEAP FROM AN UNSORTED ARRAY — O(N), NOT O(N log N) ──
void heapifyDown(vector<int>& arr, int n, int i) {
    int left = 2*i + 1, right = 2*i + 2, largest = i;
    if (left  < n && arr[left]  > arr[largest]) largest = left;
    if (right < n && arr[right] > arr[largest]) largest = right;
    if (largest != i) {
        swap(arr[i], arr[largest]);
        heapifyDown(arr, n, largest);
    }
}
void buildHeap(vector<int>& arr) {
    int n = arr.size();
    for (int i = n/2 - 1; i >= 0; i--) heapifyDown(arr, n, i);   // start at last non-leaf
}
// TC: O(N) total — most nodes sit near the bottom with tiny height, so the
// heights don't all cost log N the way N inserts would (N inserts = O(N log N))
```

---

## 📌 L1 — Heap Introduction & Identification

```
WHAT IS A HEAP:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Complete Binary Tree + Heap Order Property
  Complete BT → all levels filled except last;
                last level filled strictly left to right
  Heap Order  → every parent obeys a fixed relation with
                its children (>= for max, <= for min)
                — NOT a full ordering like a BST

TYPES:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Max-Heap → parent >= children   (root = MAXIMUM)
Min-Heap → parent <= children   (root = MINIMUM)

HEAP vs BST:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Heap → weak order (parent-child only), array-backed,
       O(1) peek at min/max, O(N) search for arbitrary value
BST  → strict order (left < root < right), pointer-backed,
       O(log N) search when balanced, inorder = sorted

HOW TO IDENTIFY A HEAP PROBLEM (keywords):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
"Kth largest / Kth smallest"        → heap of size K
"K closest / K farthest"            → heap of size K on distance
"Top K frequent"                    → heap of size K on frequency
"Merge K sorted ..."                → heap of size K, one slot per list
"Continuously running median"       → two heaps
"Minimum cost to combine/connect"   → greedy + min-heap
"Schedule by priority"              → heap as a priority queue
```

```
Array:  [50, 30, 40, 10, 20, 35]
Index:    0    1   2   3   4   5

Tree view (valid max-heap):
              50
            /    \
          30      40
         /  \     /
       10   20  35
```

---

## 📌 L2 — Kth Smallest Element in an Array

```cpp
// Approach: MAX-HEAP of size K
// Keep the K smallest elements seen so far; the heap's top
// (the largest among those K) IS the Kth smallest overall.
int kthSmallest(vector<int>& arr, int k) {
    priority_queue<int> maxHeap;
    for (int num : arr) {
        maxHeap.push(num);
        if ((int)maxHeap.size() > k) maxHeap.pop();   // evict current largest
    }
    return maxHeap.top();
}
// TC: O(N log K), SC: O(K)
// WHY MAX-HEAP: we're capping the heap at the K smallest values, so
// whatever is largest inside that cap is the first one to get evicted.
```

---

## 📌 L3 — Kth Largest Element in an Array

```cpp
// LC 215 — mirror image of Kth Smallest: MIN-HEAP of size K
int kthLargest(vector<int>& arr, int k) {
    priority_queue<int, vector<int>, greater<int>> minHeap;
    for (int num : arr) {
        minHeap.push(num);
        if ((int)minHeap.size() > k) minHeap.pop();   // evict current smallest
    }
    return minHeap.top();
}
// TC: O(N log K), SC: O(K)
// ALTERNATIVES: full max-heap + pop K times → O(N + K log N)
//               QuickSelect (Hoare partition)  → O(N) average, O(N²) worst
```

---

## 📌 L4 — Sort a Nearly Sorted / K-Sorted Array

```cpp
// GFG classic — every element is at most K positions from its
// final sorted position. Approach: MIN-HEAP of size K+1.
vector<int> sortKSortedArray(vector<int>& arr, int k) {
    priority_queue<int, vector<int>, greater<int>> minHeap;
    vector<int> result;

    for (int num : arr) {
        minHeap.push(num);
        // once the heap holds K+1 elements, its min is guaranteed
        // to be in its correct final position
        if ((int)minHeap.size() > k) {
            result.push_back(minHeap.top());
            minHeap.pop();
        }
    }
    while (!minHeap.empty()) {
        result.push_back(minHeap.top());
        minHeap.pop();
    }
    return result;
}
// TC: O(N log K), SC: O(K)
// Example: arr = [6,5,3,2,8,10,9], k = 3 → [2,3,5,6,8,9,10]
```

---

## 📌 L5 — K Closest Elements to X

```cpp
// LC 658 (general form) — MAX-HEAP of size K on |arr[i] - x|.
// Heap keeps the K closest values seen so far; evict the FARTHEST
// one when it overflows (opposite heap type from what you'd guess).
vector<int> kClosestElements(vector<int>& arr, int x, int k) {
    priority_queue<pair<int,int>> maxHeap;      // {distance, value}
    for (int num : arr) {
        maxHeap.push({abs(num - x), num});
        if ((int)maxHeap.size() > k) maxHeap.pop();   // evict farthest
    }
    vector<int> result;
    while (!maxHeap.empty()) {
        result.push_back(maxHeap.top().second);
        maxHeap.pop();
    }
    return result;   // NOTE: unsorted — sort if the problem wants ascending order
}
// TC: O(N log K), SC: O(K)
// FASTER for the sorted-array LC 658 variant: binary search + window shrink → O(log N + K)
```

---

## 📌 L6 — Top K Frequent Elements

```cpp
// LC 347 — hashmap for frequency + MIN-HEAP of size K (by count)
vector<int> topKFrequent(vector<int>& nums, int k) {
    unordered_map<int,int> freq;
    for (int num : nums) freq[num]++;

    priority_queue<pair<int,int>, vector<pair<int,int>>, greater<pair<int,int>>> minHeap;
    for (auto& [val, cnt] : freq) {
        minHeap.push({cnt, val});
        if ((int)minHeap.size() > k) minHeap.pop();   // evict least frequent
    }

    vector<int> result;
    while (!minHeap.empty()) {
        result.push_back(minHeap.top().second);
        minHeap.pop();
    }
    return result;
}
// TC: O(N log K), SC: O(N) map + O(K) heap
// RELATED: "Sort Characters By Frequency" (LC 451) — same map, but a full
// heap (or bucket sort by count) since ALL elements are needed, not just K
```

---

## 📌 L7 — K Closest Points to Origin

```cpp
// LC 973 — MAX-HEAP of size K on squared distance
// (skip sqrt entirely — squared distance preserves the same ordering)
vector<vector<int>> kClosestPoints(vector<vector<int>>& points, int k) {
    priority_queue<pair<int,int>> maxHeap;      // {distSq, pointIndex}
    for (int i = 0; i < (int)points.size(); i++) {
        int distSq = points[i][0]*points[i][0] + points[i][1]*points[i][1];
        maxHeap.push({distSq, i});
        if ((int)maxHeap.size() > k) maxHeap.pop();   // evict farthest
    }
    vector<vector<int>> result;
    while (!maxHeap.empty()) {
        result.push_back(points[maxHeap.top().second]);
        maxHeap.pop();
    }
    return result;
}
// TC: O(N log K), SC: O(K)
```

---

## 📌 L8 — Connect N Ropes with Minimum Cost

```cpp
// LC 1167 (Minimum Cost to Connect Sticks) — GREEDY + MIN-HEAP.
// Always connect the two SMALLEST ropes first (Huffman-coding style).
int connectRopes(vector<int>& ropes) {
    priority_queue<int, vector<int>, greater<int>> minHeap(ropes.begin(), ropes.end());
    int totalCost = 0;
    while (minHeap.size() > 1) {
        int first = minHeap.top();  minHeap.pop();
        int second = minHeap.top(); minHeap.pop();
        int cost = first + second;
        totalCost += cost;
        minHeap.push(cost);
    }
    return totalCost;
}
// TC: O(N log N), SC: O(N)
// WHY GREEDY WORKS: merging small pieces first keeps them from being
// re-added into later sums over and over (exchange-argument proof —
// same idea as Huffman encoding)
// NOTE: the range constructor above heapifies in O(N), same idea as buildHeap in Setup
```

---

## 📌 L9 — Merge K Sorted Arrays

```cpp
// GFG classic — MIN-HEAP storing {value, arrayIndex, elementIndex}
vector<int> mergeKSortedArrays(vector<vector<int>>& arrays) {
    using T = tuple<int,int,int>;
    priority_queue<T, vector<T>, greater<T>> minHeap;

    for (int i = 0; i < (int)arrays.size(); i++)
        if (!arrays[i].empty()) minHeap.push({arrays[i][0], i, 0});

    vector<int> result;
    while (!minHeap.empty()) {
        auto [val, arrIdx, elemIdx] = minHeap.top();
        minHeap.pop();
        result.push_back(val);

        if (elemIdx + 1 < (int)arrays[arrIdx].size())
            minHeap.push({arrays[arrIdx][elemIdx + 1], arrIdx, elemIdx + 1});
    }
    return result;
}
// TC: O(N log K) — N = total elements across all arrays, K = number of arrays
// SC: O(K) for the heap (at most one entry per array at any time)
```

---

## 📌 L10 — Merge K Sorted Lists

```cpp
// LC 23 — same pattern as L9, but over linked lists instead of arrays
struct ListNode {
    int val;
    ListNode* next;
    ListNode(int x) : val(x), next(nullptr) {}
};

struct ListCompare {
    bool operator()(ListNode* a, ListNode* b) { return a->val > b->val; }  // min-heap on val
};

ListNode* mergeKLists(vector<ListNode*>& lists) {
    priority_queue<ListNode*, vector<ListNode*>, ListCompare> minHeap;
    for (ListNode* head : lists) if (head) minHeap.push(head);

    ListNode dummy(0);
    ListNode* tail = &dummy;
    while (!minHeap.empty()) {
        ListNode* node = minHeap.top(); minHeap.pop();
        tail->next = node;
        tail = tail->next;
        if (node->next) minHeap.push(node->next);
    }
    return dummy.next;
}
// TC: O(N log K), SC: O(K)
// ALTERNATIVE: pairwise merge (merge lists 2 at a time, like merge sort) — same O(N log K)
```

---

## 📌 All Patterns — Quick Revision

```
HEAP PATTERN CHEAT SHEET:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
THE SIZE-K TRICK (core idea behind most problems):
  Want the K "best" elements → cap a heap at size K
  Want K LARGEST / closest   → use a MIN-heap, evict the smallest
  Want K SMALLEST / lowest   → use a MAX-heap, evict the largest
  (the heap type is the OPPOSITE of what you're hunting for —
   you always evict the "worst of the best K so far")

PROBLEM → PATTERN:
  Kth smallest              → max-heap size K, answer = top
  Kth largest               → min-heap size K, answer = top
  Sort K-sorted array       → min-heap size K+1, pop as you push
  K closest to X            → max-heap size K on |val - X|
  Top K frequent            → hashmap + min-heap size K on count
  K closest points          → max-heap size K on squared distance
  Connect ropes / min cost  → min-heap, always merge 2 smallest (greedy)
  Merge K sorted arrays/lists → min-heap size K, one slot per source
  Running median             → two heaps (max-heap left half, min-heap right half)
  Task/priority scheduling   → max-heap on frequency or priority value

C++ SPECIFIC TIPS:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
priority_queue<int> pq;                             // max-heap (default)
priority_queue<int, vector<int>, greater<int>> pq;  // min-heap
Constructing from a range (begin,end) heapifies in O(N), not O(N log N)
Use pair<int,int> or tuple<int,int,int> to carry extra info through the heap
Write a struct comparator for anything beyond pair/tuple (e.g. ListNode*)
Copy pq.top() out to a variable BEFORE calling pq.pop()
Cast .size() to (int) before comparing with a signed k to avoid sign warnings

COMPLEXITY QUICK REF:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
push / pop                 O(log N)
top / peek                 O(1)
build heap from N items    O(N)          — NOT O(N log N)
"heap capped at size K"    O(N log K) time, O(K) space
merge K sources pattern    O(N log K) time, O(K) space
```

---

## 📌 LeetCode / GFG Problem Map

```
TOPIC                            | REF #  | DIFFICULTY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Kth Largest Element in an Array  | LC 215 | Medium
Kth Smallest (215, inverted)     | LC 215*| Medium
Sort a Nearly/K-Sorted Array     | GFG    | Medium
Find K Closest Elements          | LC 658 | Medium
Top K Frequent Elements          | LC 347 | Medium
Sort Characters By Frequency     | LC 451 | Medium
K Closest Points to Origin       | LC 973 | Medium
Minimum Cost to Connect Sticks   | LC 1167| Medium
Merge K Sorted Arrays            | GFG    | Medium
Merge K Sorted Lists             | LC 23  | Hard
```



# Heap Interview Questions Roadmap

## Must Do (Core Heap Questions)

-   703. Kth Largest Element in a Stream *(Easy)*
-   215. Kth Largest Element in an Array *(Medium)*
-   347. Top K Frequent Elements *(Medium)*
-   973. K Closest Points to Origin *(Medium)*
-   692. Top K Frequent Words *(Medium)*
-   378. Kth Smallest Element in a Sorted Matrix *(Medium)*
-   373. Find K Pairs with Smallest Sums *(Medium)*
-   621. Task Scheduler *(Medium)*
-   1167. Minimum Cost to Connect Sticks *(Medium)*
-   1834. Single-Threaded CPU *(Medium)*
-   23. Merge K Sorted Lists *(Hard)*
-   295. Find Median from Data Stream *(Hard)*
-   502. IPO *(Hard)*
-   857. Minimum Cost to Hire K Workers *(Hard)*
-   871. Minimum Number of Refueling Stops *(Hard)*

------------------------------------------------------------------------

## Highly Recommended

-   253. Meeting Rooms II
-   632. Smallest Range Covering Elements from K Lists
-   767. Reorganize String
-   1353. Maximum Number of Events That Can Be Attended
-   1642. Furthest Building You Can Reach
-   1705. Maximum Number of Eaten Apples
-   1792. Maximum Average Pass Ratio
-   1851. Minimum Interval to Include Each Query
-   1962. Remove Stones to Minimize the Total
-   2208. Minimum Operations to Halve Array Sum
-   2336. Smallest Number in Infinite Set
-   2353. Design a Food Rating System
-   2402. Meeting Rooms III
-   2462. Total Cost to Hire K Workers
-   2530. Maximal Score After Applying K Operations
-   2542. Maximum Subsequence Score

------------------------------------------------------------------------

## Advanced / Google-Level Heap Problems

-   239. Sliding Window Maximum
-   480. Sliding Window Median
-   630. Course Schedule III
-   778. Swim in Rising Water
-   1383. Maximum Performance of a Team
-   1499. Max Value of Equation
-   1606. Find Servers That Handled Most Number of Requests
-   1675. Minimize Deviation in Array
-   1825. Finding MK Average
-   1912. Design Movie Rental System
