# Fraz Linked List Series — Complete Notes (C++)
*Based on Fraz's "Linked List Series" YouTube Playlist — 25 Videos*

---

## 📌 C++ Linked List Node Setup (use this everywhere)

```cpp
#include <iostream>
#include <vector>
#include <queue>
#include <stack>
#include <unordered_map>
#include <unordered_set>
#include <list>
#include <string>
#include <climits>
#include <algorithm>
using namespace std;

// Singly Linked List Node
struct ListNode {
    int val;
    ListNode* next;
    ListNode(int x) : val(x), next(nullptr) {}
};

// Doubly Linked List Node
struct DListNode {
    int val;
    DListNode* prev;
    DListNode* next;
    DListNode(int x) : val(x), prev(nullptr), next(nullptr) {}
};

// Build singly linked list from vector — for testing
ListNode* buildList(vector<int>& vals) {
    if (vals.empty()) return nullptr;
    ListNode* head = new ListNode(vals[0]);
    ListNode* curr = head;
    for (int i = 1; i < (int)vals.size(); i++) {
        curr->next = new ListNode(vals[i]);
        curr = curr->next;
    }
    return head;
}

// Print list — for debugging
void printList(ListNode* head) {
    while (head) {
        cout << head->val << " -> ";
        head = head->next;
    }
    cout << "NULL\n";
}
```

---

## 📌 L0 — Series Overview

```
SERIES OVERVIEW:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
25 episodes (EP 0 – EP 24), basics → advanced, C++ & Java
Covers: representation, core traversal tricks, reversal
        patterns, hashing via chaining, design problems
        (HashSet/HashMap, Browser History, LRU Cache),
        cycle detection, in-place list manipulation
Goal: single resource for linked list interview prep
```

---

## 📌 L1 — Uses of Linked List (Real Life)

```
REAL-WORLD USES:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Image viewer / gallery    → prev/next via DLL
Music player playlist     → next/previous track
Browser history           → back/forward navigation
Undo/Redo in editors      → DLL of states
Hash tables               → chaining for collision resolution
OS memory management      → free memory block lists
Polynomial representation → each term stored as a node

WHY LINKED LIST HERE (vs array):
  Frequent insert/delete without shifting elements
  Size not known upfront / grows and shrinks dynamically
```

---

## 📌 L2 — Representation of Linked List (C++ and Java)

```cpp
// Node structure (struct — members public by default)
struct ListNode {
    int val;
    ListNode* next;
    ListNode(int x) : val(x), next(nullptr) {}
};

// Build manually
ListNode* head = new ListNode(12);
head->next             = new ListNode(8);
head->next->next       = new ListNode(5);
head->next->next->next = new ListNode(9);
// head -> 12 -> 8 -> 5 -> 9 -> NULL

// ARRAY vs LINKED LIST — MEMORY LAYOUT:
// Array:  contiguous block, e.g. int arr[5] starting at address 200
//         elements sit at 200, 204, 208, 212, 216 (4 bytes each)
//         address of arr[i] = base + i * sizeof(int)   → O(1) access
// List:   nodes scattered anywhere in heap memory
//         each node explicitly stores the NEXT node's address
//         no formula for node i's address → must walk from head
```

```
JAVA EQUIVALENT:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class ListNode {
    int val;
    ListNode next;
    ListNode(int x) { val = x; }
}
// Java has no explicit pointers or delete — GC reclaims unreachable nodes
// "next" is a reference, not a raw address, but the mental model is the same
```

---

## 📌 L3 — Delete a Node (Given Only That Node)

```cpp
// LC 237 — Delete Node in a Linked List
// CONSTRAINT: no access to head; node is guaranteed NOT the tail
// TRICK: can't fix prev->next (no way to reach prev), so instead
//        copy the NEXT node's value into this node, then delete next
void deleteNode(ListNode* node) {
    ListNode* nxt = node->next;
    node->val = nxt->val;      // "become" the next node
    node->next = nxt->next;    // skip over the (now-duplicate) next node
    delete nxt;                // free the actual next node
}
// TC: O(1), SC: O(1)
// FAILS if node is the last node — there's no next node to copy from
```

---

## 📌 L4 — Arrays vs Linked List

```
ARRAY vs LINKED LIST:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Memory        → contiguous block         | scattered nodes + next pointers
Access        → O(1) random access       | O(N) sequential walk from head
Insert/Delete → O(N) shift elements      | O(1) at a known node (relink)
Size          → fixed at creation        | dynamic, grows/shrinks at runtime
Cache locality→ good (sequential reads)  | poor (pointers jump across heap)
Extra memory  → none                     | one (or two) pointers per node

WHEN TO USE WHICH:
  Need random access / binary search       → Array
  Frequent insert/delete, unknown size     → Linked List
  Need contiguous memory for cache perf    → Array
```

---

## 📌 L5 — Middle of the Linked List

```cpp
// LC 876
// ── BRUTE FORCE: count length, then walk to the middle ─────
ListNode* middleBrute(ListNode* head) {
    int len = 0;
    for (ListNode* t = head; t; t = t->next) len++;
    ListNode* curr = head;
    for (int i = 0; i < len / 2; i++) curr = curr->next;
    return curr;
}

// ── OPTIMAL: slow/fast two-pointer (tortoise-hare) ──────────
ListNode* middleOptimal(ListNode* head) {
    ListNode* slow = head;
    ListNode* fast = head;
    while (fast && fast->next) {
        slow = slow->next;         // moves 1 step
        fast = fast->next->next;   // moves 2 steps
    }
    return slow;   // when fast hits the end, slow sits at the middle
}
// TC: O(N) both — but optimal is a SINGLE pass (brute is two passes)
// SC: O(1)
// For EVEN length, this returns the SECOND middle node
```

---

## 📌 L6 — Convert Binary Number in a Linked List to Integer

```cpp
// LC 1290 — head to tail reads MSB to LSB
int getDecimalValue(ListNode* head) {
    int num = 0;
    while (head) {
        num = num * 2 + head->val;   // shift left, drop in the new bit
        head = head->next;
    }
    return num;
}
// TC: O(N), SC: O(1)
// Same trick used to build an integer from a decimal digit string:
//   num = num * 10 + digit
```

---

## 📌 L7 — Doubly Linked List and STL

```cpp
// Doubly Linked List Node
struct DListNode {
    int val;
    DListNode* prev;
    DListNode* next;
    DListNode(int x) : val(x), prev(nullptr), next(nullptr) {}
};

// Insert newNode AFTER node
void insertAfter(DListNode* node, DListNode* newNode) {
    newNode->next = node->next;
    newNode->prev = node;
    if (node->next) node->next->prev = newNode;
    node->next = newNode;
}

// Delete a node — O(1), no head search needed (unlike singly LL)
void deleteDNode(DListNode* node) {
    if (node->prev) node->prev->next = node->next;
    if (node->next) node->next->prev = node->prev;
    delete node;
}
// KEY ADVANTAGE over singly LL: O(1) backward traversal AND O(1)
//   delete of a given node, without needing its predecessor passed in
```

```cpp
// ── C++ STL list<T> (a doubly linked list under the hood) ──
#include <list>

list<int> ll = {1, 2, 3};
ll.push_back(4);              // 1,2,3,4
ll.push_front(0);             // 0,1,2,3,4
ll.insert(++ll.begin(), 99);  // insert after the 1st element
ll.pop_back();
ll.pop_front();

auto it = ll.begin();
ll.erase(it);                 // O(1) erase given a valid iterator

for (int x : ll) cout << x << " ";
// STL list: O(1) insert/erase anywhere given an iterator,
//           but NO random access (no ll[i], no operator[])
```

---

## 📌 L8 — Design HashSet

```cpp
// LC 705 — implement using chaining: an array of buckets,
// each bucket a linked list. This is exactly how real hash
// sets resolve collisions — the reason this lecture sits in
// a Linked List series.

class MyHashSet {
    static const int SIZE = 1009;      // prime → fewer collisions
    vector<list<int>> buckets;

    int hashKey(int key) { return key % SIZE; }

public:
    MyHashSet() : buckets(SIZE) {}

    void add(int key) {
        int b = hashKey(key);
        for (int x : buckets[b]) if (x == key) return;  // already present
        buckets[b].push_back(key);
    }
    void remove(int key) {
        int b = hashKey(key);
        buckets[b].remove(key);   // list::remove erases all matching values
    }
    bool contains(int key) {
        int b = hashKey(key);
        for (int x : buckets[b]) if (x == key) return true;
        return false;
    }
};
// TC: O(N/SIZE) average per op (load factor) — O(N) worst case
//     if every key collides into the same bucket
// SC: O(N + SIZE)
```

---

## 📌 L9 — Design HashMap

```cpp
// LC 706 — same chaining idea, buckets store key-value pairs

class MyHashMap {
    static const int SIZE = 1009;
    vector<list<pair<int,int>>> buckets;

    int hashKey(int key) { return key % SIZE; }

public:
    MyHashMap() : buckets(SIZE) {}

    void put(int key, int value) {
        int b = hashKey(key);
        for (auto& p : buckets[b]) {
            if (p.first == key) { p.second = value; return; }  // update
        }
        buckets[b].push_back({key, value});
    }
    int get(int key) {
        int b = hashKey(key);
        for (auto& p : buckets[b]) if (p.first == key) return p.second;
        return -1;
    }
    void remove(int key) {
        int b = hashKey(key);
        buckets[b].remove_if([key](const pair<int,int>& p) {
            return p.first == key;
        });
    }
};
// TC: O(N/SIZE) average, O(N) worst
// SC: O(N + SIZE)
// Real unordered_map/unordered_set use this same chaining design
//   (plus dynamic resizing when load factor gets too high)
```

---

## 📌 L10 — Reverse Linked List

```cpp
// LC 206
// ── ITERATIVE — 3 pointers ──────────────────────────────
ListNode* reverseIterative(ListNode* head) {
    ListNode* prev = nullptr;
    ListNode* curr = head;
    while (curr) {
        ListNode* nxt = curr->next;  // save next BEFORE overwriting it
        curr->next = prev;           // reverse the link
        prev = curr;                 // advance prev
        curr = nxt;                  // advance curr
    }
    return prev;   // prev ends up as the new head
}

// ── RECURSIVE ────────────────────────────────────────────
ListNode* reverseRecursive(ListNode* head) {
    if (!head || !head->next) return head;   // base case: 0 or 1 node
    ListNode* newHead = reverseRecursive(head->next);
    head->next->next = head;   // make the next node point back to head
    head->next = nullptr;      // break the old forward link
    return newHead;
}
// TC: O(N) both
// SC: O(1) iterative / O(N) recursive (call stack)
```

---

## 📌 L11 — Reverse Nodes in k-Group (Extra Space)

```cpp
// LC 25 — naive: collect k nodes into a vector, relink in reverse
ListNode* reverseKGroupExtraSpace(ListNode* head, int k) {
    ListNode dummy(0);
    dummy.next = head;
    ListNode* groupPrev = &dummy;

    while (true) {
        ListNode* kth = groupPrev;
        for (int i = 0; i < k && kth; i++) kth = kth->next;
        if (!kth) break;                 // fewer than k nodes left, stop

        vector<ListNode*> nodes;
        ListNode* curr = groupPrev->next;
        for (int i = 0; i < k; i++) { nodes.push_back(curr); curr = curr->next; }

        // relink the k collected nodes in reverse order
        for (int i = k - 1; i > 0; i--) nodes[i]->next = nodes[i - 1];
        nodes[0]->next = curr;           // old group head -> node after group
        groupPrev->next = nodes[k - 1];  // new head of this group

        groupPrev = nodes[0];            // old head is now this group's tail
    }
    return dummy.next;
}
// TC: O(N), SC: O(K) extra space per group (the vector)
```

---

## 📌 L12 — Reverse Nodes in k-Group (No Extra Space — Optimal)

```cpp
// LC 25 — optimal: pure pointer manipulation, O(1) extra space

// Check whether at least k nodes exist starting at node
bool hasKNodes(ListNode* node, int k) {
    while (node && k > 0) { node = node->next; k--; }
    return k == 0;
}

ListNode* reverseKGroup(ListNode* head, int k) {
    if (!hasKNodes(head, k)) return head;   // fewer than k left → leave as-is

    // reverse exactly k nodes (same 3-pointer trick as L10)
    ListNode* prev = nullptr;
    ListNode* curr = head;
    for (int i = 0; i < k; i++) {
        ListNode* nxt = curr->next;
        curr->next = prev;
        prev = curr;
        curr = nxt;
    }
    // `head` is now the TAIL of this reversed group — point it at
    // the (recursively) reversed remainder of the list
    head->next = reverseKGroup(curr, k);
    return prev;   // prev is the new head of this group
}
// TC: O(N), SC: O(N/K) recursion stack — O(1) if rewritten iteratively
//     with an explicit groupPrev pointer (same idea as L11, no vector)
```

---

## 📌 L13 — Merge Two Sorted Lists

```cpp
// LC 21
ListNode* mergeTwoLists(ListNode* l1, ListNode* l2) {
    ListNode dummy(0);
    ListNode* tail = &dummy;
    while (l1 && l2) {
        if (l1->val <= l2->val) { tail->next = l1; l1 = l1->next; }
        else                    { tail->next = l2; l2 = l2->next; }
        tail = tail->next;
    }
    tail->next = l1 ? l1 : l2;   // attach whichever list still has nodes left
    return dummy.next;
}
// TC: O(N + M), SC: O(1) — just relinking existing nodes, no new ones
// DUMMY NODE trick: avoids special-casing which list contributes the head
```

---

## 📌 L14 — Merge K Sorted Lists

```cpp
// LC 23
// ── MIN-HEAP over the current head of each list ─────────
struct Compare {
    bool operator()(ListNode* a, ListNode* b) { return a->val > b->val; }  // min-heap
};

ListNode* mergeKLists(vector<ListNode*>& lists) {
    priority_queue<ListNode*, vector<ListNode*>, Compare> pq;
    for (ListNode* node : lists) if (node) pq.push(node);

    ListNode dummy(0);
    ListNode* tail = &dummy;
    while (!pq.empty()) {
        ListNode* smallest = pq.top(); pq.pop();
        tail->next = smallest;
        tail = tail->next;
        if (smallest->next) pq.push(smallest->next);
    }
    return dummy.next;
}
// TC: O(N log K) — N total nodes, heap never exceeds size K
// SC: O(K) heap

// ── ALTERNATIVE: pairwise divide & conquer ──────────────
// Merge lists two at a time (using mergeTwoLists from L13, like
// merge sort's merge step) until only one list remains.
// Same O(N log K) time, no heap/extra data structure needed.
```

---

## 📌 L15 — Remove Duplicates from Sorted List

```cpp
// LC 83 — list is sorted, so duplicates are always adjacent
ListNode* deleteDuplicates(ListNode* head) {
    ListNode* curr = head;
    while (curr && curr->next) {
        if (curr->val == curr->next->val) {
            ListNode* dup = curr->next;
            curr->next = curr->next->next;   // skip the duplicate
            delete dup;
        } else {
            curr = curr->next;   // only advance when nothing was removed
        }
    }
    return head;
}
// TC: O(N), SC: O(1)
```

---

## 📌 L16 — Linked List Cycle (With Proof)

```cpp
// LC 141 — Floyd's Cycle Detection (Tortoise & Hare)
bool hasCycle(ListNode* head) {
    ListNode* slow = head;
    ListNode* fast = head;
    while (fast && fast->next) {
        slow = slow->next;
        fast = fast->next->next;
        if (slow == fast) return true;   // pointers collide → cycle exists
    }
    return false;   // fast reached NULL → no cycle
}
// TC: O(N), SC: O(1)

// PROOF that slow and fast MUST meet if a cycle exists:
//   Once both pointers are inside the cycle, fast gains on slow by
//   exactly 1 node every step (fast moves 2, slow moves 1 → relative
//   speed = 1). The gap between them shrinks by 1 each step. The
//   cycle has some finite length C, so within at most C steps the
//   gap hits exactly 0 — fast can't "jump over" slow, since the gap
//   only ever shrinks by 1 at a time. So they're guaranteed to land
//   on the same node.
```

---

## 📌 L17 — Linked List Cycle II (Find Start, With Proof)

```cpp
// LC 142 — return the node WHERE the cycle begins
ListNode* detectCycle(ListNode* head) {
    ListNode* slow = head;
    ListNode* fast = head;
    while (fast && fast->next) {
        slow = slow->next;
        fast = fast->next->next;
        if (slow == fast) {              // cycle found — now find its start
            ListNode* ptr = head;
            while (ptr != slow) {         // both move 1 step at a time now
                ptr = ptr->next;
                slow = slow->next;
            }
            return ptr;                   // meeting point = cycle start
        }
    }
    return nullptr;
}
// TC: O(N), SC: O(1)

// PROOF (why resetting one pointer to head works):
//   L = distance from head to the cycle's start
//   C = cycle length
//   k = distance slow travels INTO the cycle before meeting fast (0<=k<C)
//   At the meeting point: slow traveled L + k
//                         fast traveled 2*(L + k)   (fast is always 2x slow)
//   fast is also just k steps into some lap of the cycle, m laps ahead:
//                         2(L + k) = L + k + m*C     for some integer m >= 1
//   =>  L + k = m*C   =>   L = m*C - k
//   So walking L steps from HEAD lands exactly on the cycle start.
//   Walking L = (m*C - k) steps from the MEETING POINT: the first k
//   steps complete the current lap (back to cycle start), then (m-1)
//   more full laps land back on the cycle start again. Same step
//   count, same destination → the two pointers converge exactly at
//   the cycle's start.
```

---

## 📌 L18 — Intersection of Two Linked Lists

```cpp
// LC 160
// ── TWO POINTER, SWITCH-HEADS TRICK ─────────────────────
ListNode* getIntersectionNode(ListNode* headA, ListNode* headB) {
    ListNode* a = headA;
    ListNode* b = headB;
    while (a != b) {
        a = a ? a->next : headB;   // when a hits the end, restart at headB
        b = b ? b->next : headA;   // when b hits the end, restart at headA
    }
    return a;   // the intersection node, or nullptr if both hit end together
}
// TRICK: switching heads equalizes total distance walked by both
//        pointers, so the (lenA - lenB) offset cancels out on its own
// TC: O(N + M), SC: O(1)
// (No need to separately compute the length difference up front)
```

---

## 📌 L19 — Palindrome Linked List

```cpp
// LC 234
ListNode* reverseList(ListNode* head) {   // reuse the L10 pattern
    ListNode* prev = nullptr;
    while (head) {
        ListNode* nxt = head->next;
        head->next = prev;
        prev = head;
        head = nxt;
    }
    return prev;
}

bool isPalindrome(ListNode* head) {
    if (!head || !head->next) return true;

    // 1) find the middle (slow/fast, L5)
    ListNode* slow = head;
    ListNode* fast = head;
    while (fast && fast->next) { slow = slow->next; fast = fast->next->next; }

    // 2) reverse the second half
    ListNode* secondHalf = reverseList(slow);

    // 3) compare both halves
    ListNode* p1 = head;
    ListNode* p2 = secondHalf;
    bool result = true;
    while (p2) {
        if (p1->val != p2->val) { result = false; break; }
        p1 = p1->next;
        p2 = p2->next;
    }
    return result;
}
// TC: O(N), SC: O(1)
// COMBINES two earlier patterns: middle-finding (L5) + reversal (L10)
// Optional: reverse the second half back to restore the original list
```

---

## 📌 L20 — Remove Linked List Elements

```cpp
// LC 203 — remove ALL nodes whose value equals target
ListNode* removeElements(ListNode* head, int val) {
    ListNode dummy(0);
    dummy.next = head;
    ListNode* curr = &dummy;
    while (curr->next) {
        if (curr->next->val == val) {
            ListNode* toDelete = curr->next;
            curr->next = curr->next->next;
            delete toDelete;
        } else {
            curr = curr->next;
        }
    }
    return dummy.next;
}
// TC: O(N), SC: O(1)
// DUMMY NODE: handles the case where head itself (possibly several
//   leading matches in a row) must be removed, with no special-casing
```

---

## 📌 L21 — Design Browser History

```cpp
// LC 1472 — Doubly Linked List: curr = current page,
// walking prev = "back", walking next = "forward"

struct PageNode {
    string url;
    PageNode* prev;
    PageNode* next;
    PageNode(string u) : url(u), prev(nullptr), next(nullptr) {}
};

class BrowserHistory {
    PageNode* curr;
public:
    BrowserHistory(string homepage) {
        curr = new PageNode(homepage);
    }
    void visit(string url) {
        PageNode* node = new PageNode(url);
        curr->next = node;     // overwrites (drops) any old forward history
        node->prev = curr;
        curr = node;
    }
    string back(int steps) {
        while (steps-- > 0 && curr->prev) curr = curr->prev;
        return curr->url;
    }
    string forward(int steps) {
        while (steps-- > 0 && curr->next) curr = curr->next;
        return curr->url;
    }
};
// TC: O(1) visit, O(min(steps, distance to end)) back/forward
// SC: O(N) pages visited
// KEY: visit() overwrites curr->next, discarding the old forward chain —
//      exactly what "visiting a new page after going back" should do
```

---

## 📌 L22 — LRU Cache

```cpp
// LC 146 — Doubly Linked List (kept in recency order) + HashMap (O(1) lookup)
class LRUCache {
    struct Node {
        int key, val;
        Node* prev;
        Node* next;
        Node(int k, int v) : key(k), val(v), prev(nullptr), next(nullptr) {}
    };

    int capacity;
    unordered_map<int, Node*> cache;   // key -> node pointer
    Node *head, *tail;   // dummy sentinels: head <-> ... <-> tail
                          // most-recent sits right after head,
                          // least-recent sits right before tail

    void removeNode(Node* node) {
        node->prev->next = node->next;
        node->next->prev = node->prev;
    }
    void insertFront(Node* node) {   // insert right after head (most recent)
        node->next = head->next;
        node->prev = head;
        head->next->prev = node;
        head->next = node;
    }

public:
    LRUCache(int cap) : capacity(cap) {
        head = new Node(0, 0);
        tail = new Node(0, 0);
        head->next = tail;
        tail->prev = head;
    }

    int get(int key) {
        if (!cache.count(key)) return -1;
        Node* node = cache[key];
        removeNode(node);
        insertFront(node);       // just accessed → move to most-recent
        return node->val;
    }

    void put(int key, int value) {
        if (cache.count(key)) {
            removeNode(cache[key]);
            delete cache[key];
        }
        Node* node = new Node(key, value);
        cache[key] = node;
        insertFront(node);
        if ((int)cache.size() > capacity) {
            Node* lru = tail->prev;      // node right before tail = least recent
            removeNode(lru);
            cache.erase(lru->key);
            delete lru;
        }
    }
};
// TC: O(1) for both get and put
// SC: O(capacity)
// KEY: DLL alone gives O(1) move-to-front + O(1) delete-from-anywhere;
//      hashmap alone gives O(1) key -> node lookup. Need BOTH together.
// Sentinel head/tail nodes remove all the null-check edge cases
```

---

## 📌 L23 — Copy List with Random Pointer (Extra Space)

```cpp
// LC 138 — each node has an extra `random` pointer to ANY node (or null)
struct RandomNode {
    int val;
    RandomNode* next;
    RandomNode* random;
    RandomNode(int x) : val(x), next(nullptr), random(nullptr) {}
};

// ── WITH EXTRA SPACE: hashmap old node -> new node ──────
RandomNode* copyRandomListHashMap(RandomNode* head) {
    if (!head) return nullptr;
    unordered_map<RandomNode*, RandomNode*> oldToNew;

    // Pass 1: create every new node (value only), map old -> new
    for (RandomNode* curr = head; curr; curr = curr->next)
        oldToNew[curr] = new RandomNode(curr->val);

    // Pass 2: wire next and random pointers using the map
    for (RandomNode* curr = head; curr; curr = curr->next) {
        oldToNew[curr]->next   = curr->next   ? oldToNew[curr->next]   : nullptr;
        oldToNew[curr]->random = curr->random ? oldToNew[curr->random] : nullptr;
    }
    return oldToNew[head];
}
// TC: O(N), SC: O(N) for the hashmap
```

---

## 📌 L24 — Copy List with Random Pointer (No Extra Space — Optimal)

```cpp
// LC 138 — O(1) extra space: interweave copies into the original list
RandomNode* copyRandomListOptimal(RandomNode* head) {
    if (!head) return nullptr;

    // Step 1: interweave — old1 -> new1 -> old2 -> new2 -> ...
    for (RandomNode* curr = head; curr; curr = curr->next->next) {
        RandomNode* copy = new RandomNode(curr->val);
        copy->next = curr->next;
        curr->next = copy;
    }

    // Step 2: assign random pointers using the interweaved structure —
    // curr->random->next is exactly the copy of curr->random
    for (RandomNode* curr = head; curr; curr = curr->next->next) {
        curr->next->random = curr->random ? curr->random->next : nullptr;
    }

    // Step 3: detach — unweave into two separate lists, restore original
    RandomNode* newHead = head->next;
    RandomNode* curr = head;
    while (curr) {
        RandomNode* copy = curr->next;
        curr->next = copy->next;                                   // restore original
        copy->next = copy->next ? copy->next->next : nullptr;       // link the copy list
        curr = curr->next;
    }
    return newHead;
}
// TC: O(N) — three linear passes
// SC: O(1) extra (excluding the output list itself)
// KEY TRICK: placing each copy right after its original means
//   curr->random->next IS the copy of curr->random — no hashmap needed
```

---

## 📌 All Patterns — Quick Revision

```
LINKED LIST PATTERN CHEAT SHEET:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CORE TECHNIQUES:
  Reverse (whole/partial)  → 3-pointer (prev, curr, next) walk
  Find the middle          → slow/fast two-pointer
  Detect a cycle           → Floyd's slow/fast, meet = cycle exists
  Find the cycle's start   → reset 1 pointer to head, move both by 1
  Merge sorted lists       → dummy node + pick the smaller each step
  K-way merge              → min-heap of current heads, O(N log K)
  Dummy / sentinel node    → removes special-casing of the head
  Two-list meeting point   → switch-heads trick equalizes distance

PROBLEM → PATTERN:
  Middle of list               → slow/fast pointer
  Reverse list                 → 3-pointer in-place
  Reverse in groups of k       → repeat 3-pointer reversal per group
  Detect / find start of cycle → Floyd's algorithm (+ reset-to-head)
  Palindrome check             → find middle + reverse half + compare
  Merge 2 / K sorted lists     → dummy node merge / min-heap
  Remove duplicates (sorted)   → compare adjacent nodes
  Remove all nodes with value  → dummy node + skip matches
  Intersection of 2 lists      → switch-heads two pointer
  Clone list with random ptr   → hashmap OR interweave-copy trick
  LRU Cache                    → DLL (recency order) + hashmap (O(1))
  Browser history / undo-redo  → DLL, curr pointer walks prev/next

HASHING VIA CHAINING (why HashSet/HashMap sit in a LL series):
  Bucket array + one linked list per bucket resolves collisions
  hashKey(key) = key % SIZE   (SIZE ideally prime, e.g. 1009)
  Load factor = N / SIZE  → keep buckets short for near-O(1) ops

DOUBLY vs SINGLY LINKED LIST:
  Singly → less memory, no backward walk, O(N) delete (need prev)
  Doubly → O(1) delete given the node, O(1) backward walk,
           extra pointer per node — used in LRU, Browser History

C++ SPECIFIC TIPS:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Use a dummy/sentinel node to avoid special-casing head operations
list<T> in STL = doubly linked list; O(1) insert/erase by iterator
unordered_map<Node*, Node*> is the standard way to clone list/graph
priority_queue with a custom Compare struct → min-heap of pointers
Always save curr->next into a local var BEFORE rewriting curr->next
Two-pointer loop guard: check `fast && fast->next` (not just `fast`)
  so both even- and odd-length lists are handled safely

COMPLEXITY QUICK REF:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Traverse / reverse / delete (given node)   O(N) / O(N) / O(1)
Slow-fast pointer (middle, cycle)          O(N) time, O(1) space
Merge two sorted lists                     O(N+M) time, O(1) space
Merge K sorted lists (heap)                O(N log K) time, O(K) space
HashSet / HashMap (chaining, avg case)     O(1) amortized per op
LRU Cache get/put                          O(1) time, O(capacity) space
Copy list with random pointer (optimal)    O(N) time, O(1) extra space
```

---

## 📌 LeetCode Problem Map

```
TOPIC                                  | LC #  | DIFFICULTY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Delete Node in a Linked List           | 237   | Medium
Middle of the Linked List              | 876   | Easy
Convert Binary Number in a LL to Int   | 1290  | Easy
Design HashSet                         | 705   | Easy
Design HashMap                         | 706   | Easy
Reverse Linked List                    | 206   | Easy
Reverse Nodes in k-Group               | 25    | Hard
Merge Two Sorted Lists                 | 21    | Easy
Merge k Sorted Lists                   | 23    | Hard
Remove Duplicates from Sorted List     | 83    | Easy
Linked List Cycle                      | 141   | Easy
Linked List Cycle II                   | 142   | Medium
Intersection of Two Linked Lists       | 160   | Easy
Palindrome Linked List                 | 234   | Easy
Remove Linked List Elements            | 203   | Easy
Design Browser History                 | 1472  | Medium
LRU Cache                              | 146   | Medium
Copy List with Random Pointer          | 138   | Medium
```
