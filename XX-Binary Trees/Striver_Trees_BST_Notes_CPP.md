# Striver Tree Series — Complete Notes (C++)
*Based on TakeUForward Tree Playlist — 54 Videos*

---

## 📌 C++ Tree Node Setup (use this everywhere)

```cpp
#include <iostream>
#include <vector>
#include <queue>
#include <stack>
#include <unordered_map>
#include <map>
#include <climits>
#include <algorithm>
using namespace std;

struct TreeNode {
    int val;
    TreeNode* left;
    TreeNode* right;
    TreeNode(int x) : val(x), left(nullptr), right(nullptr) {}
};

// Build tree from level-order vector (nullptr = null node) — for testing
TreeNode* buildTree(vector<int*> vals) {
    if (vals.empty() || !vals[0]) return nullptr;
    TreeNode* root = new TreeNode(*vals[0]);
    queue<TreeNode*> q;
    q.push(root);
    int i = 1;
    while (!q.empty() && i < vals.size()) {
        TreeNode* node = q.front(); q.pop();
        if (i < vals.size() && vals[i]) {
            node->left = new TreeNode(*vals[i]);
            q.push(node->left);
        }
        i++;
        if (i < vals.size() && vals[i]) {
            node->right = new TreeNode(*vals[i]);
            q.push(node->right);
        }
        i++;
    }
    return root;
}
```

---

## 📌 L1 — Introduction to Trees

```
KEY TERMINOLOGY:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Root       → topmost node (no parent)
Leaf       → node with no children
Height     → longest path from node to leaf
Depth      → distance from root to node
Degree     → number of children of a node

TYPES OF BINARY TREES:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Full BT     → every node has 0 or 2 children
Complete BT → all levels filled except last; last filled left to right
Perfect BT  → all leaves at same level, all internal nodes have 2 children
Balanced BT → |height(left) - height(right)| <= 1 for every node
Degenerate  → every node has only 1 child (like a linked list)

TREE vs LINEAR DS:
  Arrays, Stacks, Queues, LL → Linear (sequential)
  Trees                      → Hierarchical (non-linear)
```

---

## 📌 L2 — Binary Tree Representation in C++

```cpp
// Node structure (struct used instead of class — members public by default)
struct TreeNode {
    int val;
    TreeNode* left;
    TreeNode* right;
    TreeNode(int x) : val(x), left(nullptr), right(nullptr) {}
};

// Build manually
TreeNode* root = new TreeNode(1);
root->left      = new TreeNode(2);
root->right     = new TreeNode(3);
root->left->left  = new TreeNode(4);
root->left->right = new TreeNode(5);
//        1
//       / \
//      2   3
//     / \
//    4   5
```

---

## 📌 L4 — Traversal Overview

```
DFS TRAVERSALS (use recursion / explicit stack):
  Preorder   →  Root  → Left  → Right
  Inorder    →  Left  → Root  → Right
  Postorder  →  Left  → Right → Root

BFS TRAVERSAL (use queue):
  Level Order → level by level, left to right

MEMORY AID:
  Pre  = ROOT first  (Root Left Right)
  In   = ROOT middle (Left Root Right)
  Post = ROOT last   (Left Right Root)
```

---

## 📌 L5 — Preorder Traversal (Root → Left → Right)

```cpp
// ── RECURSIVE ──────────────────────────────────────────
void preorderHelper(TreeNode* node, vector<int>& result) {
    if (!node) return;
    result.push_back(node->val);   // ROOT first
    preorderHelper(node->left, result);
    preorderHelper(node->right, result);
}
vector<int> preorderRecursive(TreeNode* root) {
    vector<int> result;
    preorderHelper(root, result);
    return result;
}

// ── ITERATIVE (stack) ───────────────────────────────────
vector<int> preorderIterative(TreeNode* root) {
    if (!root) return {};
    vector<int> result;
    stack<TreeNode*> st;
    st.push(root);
    while (!st.empty()) {
        TreeNode* node = st.top(); st.pop();
        result.push_back(node->val);
        // Push RIGHT first so LEFT is processed first (LIFO)
        if (node->right) st.push(node->right);
        if (node->left)  st.push(node->left);
    }
    return result;
}
// Tree: 1->2->4,5 and 3
// Preorder: [1, 2, 4, 5, 3]
```

---

## 📌 L6 — Inorder Traversal (Left → Root → Right)

```cpp
// ── RECURSIVE ──────────────────────────────────────────
void inorderHelper(TreeNode* node, vector<int>& result) {
    if (!node) return;
    inorderHelper(node->left, result);
    result.push_back(node->val);   // ROOT middle
    inorderHelper(node->right, result);
}
vector<int> inorderRecursive(TreeNode* root) {
    vector<int> result;
    inorderHelper(root, result);
    return result;
}

// ── ITERATIVE (stack) ───────────────────────────────────
vector<int> inorderIterative(TreeNode* root) {
    vector<int> result;
    stack<TreeNode*> st;
    TreeNode* curr = root;
    while (curr || !st.empty()) {
        // Go as far left as possible
        while (curr) {
            st.push(curr);
            curr = curr->left;
        }
        curr = st.top(); st.pop();
        result.push_back(curr->val);
        curr = curr->right;        // move to right subtree
    }
    return result;
}
// KEY: Inorder of BST gives sorted array!
```

---

## 📌 L7 — Postorder Traversal (Left → Right → Root)

```cpp
// ── RECURSIVE ──────────────────────────────────────────
void postorderHelper(TreeNode* node, vector<int>& result) {
    if (!node) return;
    postorderHelper(node->left, result);
    postorderHelper(node->right, result);
    result.push_back(node->val);   // ROOT last
}

// ── ITERATIVE — 2 STACKS ────────────────────────────────
vector<int> postorderTwoStacks(TreeNode* root) {
    if (!root) return {};
    stack<TreeNode*> st1, st2;
    st1.push(root);
    while (!st1.empty()) {
        TreeNode* node = st1.top(); st1.pop();
        st2.push(node);
        if (node->left)  st1.push(node->left);
        if (node->right) st1.push(node->right);
    }
    vector<int> result;
    while (!st2.empty()) {
        result.push_back(st2.top()->val);
        st2.pop();
    }
    return result;
}

// ── ITERATIVE — 1 STACK ─────────────────────────────────
vector<int> postorderOneStack(TreeNode* root) {
    vector<int> result;
    stack<TreeNode*> st;
    TreeNode* curr = root;
    TreeNode* lastVisited = nullptr;
    while (curr || !st.empty()) {
        while (curr) { st.push(curr); curr = curr->left; }
        curr = st.top();
        if (curr->right && lastVisited != curr->right) {
            curr = curr->right;
        } else {
            result.push_back(curr->val);
            lastVisited = curr;
            st.pop();
            curr = nullptr;
        }
    }
    return result;
}
```

---

## 📌 L8 — Level Order Traversal (BFS)

```cpp
// LC 102 — returns each level as a separate vector
vector<vector<int>> levelOrder(TreeNode* root) {
    if (!root) return {};
    vector<vector<int>> result;
    queue<TreeNode*> q;
    q.push(root);
    while (!q.empty()) {
        int levelSize = q.size();
        vector<int> level;
        for (int i = 0; i < levelSize; i++) {
            TreeNode* node = q.front(); q.pop();
            level.push_back(node->val);
            if (node->left)  q.push(node->left);
            if (node->right) q.push(node->right);
        }
        result.push_back(level);
    }
    return result;
}
// Tree:    1
//         / \
//        2   3
//       / \   \
//      4   5   6
// Output: [[1],[2,3],[4,5,6]]
```

---

## 📌 L9–L12 — Iterative Traversals Summary

```
Preorder iterative  → Push root → pop → push right then left
Inorder iterative   → Go left as far as possible, pop, go right
Postorder 2-stack   → Like reverse preorder → reverse result
Postorder 1-stack   → Track lastVisited pointer

INTERVIEW TIP:
  "Without recursion"      → use explicit stack
  "O(1) space traversal"   → Morris Traversal (L37)
```

---

## 📌 L14 — Maximum Depth / Height of Binary Tree

```cpp
// LC 104
// ── RECURSIVE (Post-order) ──────────────────────────────
int maxDepth(TreeNode* root) {
    if (!root) return 0;
    int left  = maxDepth(root->left);
    int right = maxDepth(root->right);
    return 1 + max(left, right);
}

// ── BFS (Level Order) ───────────────────────────────────
int maxDepthBFS(TreeNode* root) {
    if (!root) return 0;
    int depth = 0;
    queue<TreeNode*> q;
    q.push(root);
    while (!q.empty()) {
        depth++;
        int sz = q.size();
        for (int i = 0; i < sz; i++) {
            TreeNode* node = q.front(); q.pop();
            if (node->left)  q.push(node->left);
            if (node->right) q.push(node->right);
        }
    }
    return depth;
}
// TC: O(N), SC: O(H) recursive / O(N) BFS
```

---

## 📌 L15 — Check Balanced Binary Tree

```cpp
// LC 110
// NAIVE O(N^2): compute height at every node separately
// OPTIMAL O(N): compute height bottom-up, return -1 if unbalanced

int checkHeight(TreeNode* node) {
    if (!node) return 0;
    int left = checkHeight(node->left);
    if (left == -1) return -1;           // already unbalanced
    int right = checkHeight(node->right);
    if (right == -1) return -1;
    if (abs(left - right) > 1) return -1; // unbalanced here
    return 1 + max(left, right);
}

bool isBalanced(TreeNode* root) {
    return checkHeight(root) != -1;
}
// KEY: Return -1 as sentinel to propagate unbalance upward
// TC: O(N), SC: O(H)
```

---

## 📌 L16 — Diameter of Binary Tree

```cpp
// LC 543
// Diameter = longest path between any two nodes
// At each node: diameter through it = leftHeight + rightHeight

int diameterHelper(TreeNode* node, int& maxDia) {
    if (!node) return 0;
    int left  = diameterHelper(node->left, maxDia);
    int right = diameterHelper(node->right, maxDia);
    maxDia = max(maxDia, left + right);  // update global max
    return 1 + max(left, right);         // return height
}

int diameterOfBinaryTree(TreeNode* root) {
    int maxDia = 0;
    diameterHelper(root, maxDia);
    return maxDia;
}
// TRICK: Calculate height AND diameter in same DFS pass
// TC: O(N), SC: O(H)
```

---

## 📌 L17 — Maximum Path Sum in Binary Tree

```cpp
// LC 124 — path can start and end at any node

int maxPathHelper(TreeNode* node, int& maxSum) {
    if (!node) return 0;
    // Take only positive contributions from children
    int left  = max(maxPathHelper(node->left, maxSum),  0);
    int right = max(maxPathHelper(node->right, maxSum), 0);
    // Path through this node (turning point)
    maxSum = max(maxSum, node->val + left + right);
    // Return max gain continuing upward (can only pick one branch)
    return node->val + max(left, right);
}

int maxPathSum(TreeNode* root) {
    int maxSum = INT_MIN;
    maxPathHelper(root, maxSum);
    return maxSum;
}
// KEY INSIGHT:
// - max(child, 0) ignores negative subtrees
// - Can't take both left+right AND continue upward
// TC: O(N), SC: O(H)
```

---

## 📌 L18 — Check if Two Trees are Identical

```cpp
// LC 100 — Same Tree
bool isSameTree(TreeNode* p, TreeNode* q) {
    if (!p && !q) return true;   // both null
    if (!p || !q) return false;  // one null
    if (p->val != q->val) return false;
    return isSameTree(p->left, q->left) &&
           isSameTree(p->right, q->right);
}
// TC: O(N), SC: O(H)
```

---

## 📌 L19 — Zigzag / Spiral Level Order Traversal

```cpp
// LC 103
vector<vector<int>> zigzagLevelOrder(TreeNode* root) {
    if (!root) return {};
    vector<vector<int>> result;
    queue<TreeNode*> q;
    q.push(root);
    bool leftToRight = true;
    while (!q.empty()) {
        int sz = q.size();
        vector<int> level(sz);
        for (int i = 0; i < sz; i++) {
            TreeNode* node = q.front(); q.pop();
            // Fill index depends on direction
            int idx = leftToRight ? i : (sz - 1 - i);
            level[idx] = node->val;
            if (node->left)  q.push(node->left);
            if (node->right) q.push(node->right);
        }
        result.push_back(level);
        leftToRight = !leftToRight;   // toggle direction
    }
    return result;
}
```

---

## 📌 L20 — Boundary Traversal of Binary Tree

```cpp
bool isLeaf(TreeNode* node) {
    return !node->left && !node->right;
}

void addLeftBoundary(TreeNode* node, vector<int>& res) {
    TreeNode* curr = node->left;
    while (curr) {
        if (!isLeaf(curr)) res.push_back(curr->val);
        curr = curr->left ? curr->left : curr->right;
    }
}

void addLeaves(TreeNode* node, vector<int>& res) {
    if (!node) return;
    if (isLeaf(node)) { res.push_back(node->val); return; }
    addLeaves(node->left, res);
    addLeaves(node->right, res);
}

void addRightBoundary(TreeNode* node, vector<int>& res) {
    TreeNode* curr = node->right;
    vector<int> temp;
    while (curr) {
        if (!isLeaf(curr)) temp.push_back(curr->val);
        curr = curr->right ? curr->right : curr->left;
    }
    // Add in reverse (bottom-up)
    for (int i = temp.size() - 1; i >= 0; i--)
        res.push_back(temp[i]);
}

vector<int> boundaryOfBinaryTree(TreeNode* root) {
    if (!root) return {};
    vector<int> res;
    if (!isLeaf(root)) res.push_back(root->val);
    addLeftBoundary(root, res);
    addLeaves(root, res);
    addRightBoundary(root, res);
    return res;
}
```

---

## 📌 L21 — Vertical Order Traversal

```cpp
// LC 987 — assign (col, row) to each node
// group by col, sort within col by (row, val)

vector<vector<int>> verticalTraversal(TreeNode* root) {
    // {col → {row → sorted vals}}
    map<int, map<int, multiset<int>>> nodes;

    queue<pair<TreeNode*, pair<int,int>>> q;  // {node, {col, row}}
    q.push({root, {0, 0}});

    while (!q.empty()) {
        auto [node, pos] = q.front(); q.pop();
        auto [col, row] = pos;
        nodes[col][row].insert(node->val);
        if (node->left)  q.push({node->left,  {col-1, row+1}});
        if (node->right) q.push({node->right, {col+1, row+1}});
    }

    vector<vector<int>> result;
    for (auto& [col, rowMap] : nodes) {
        vector<int> colVals;
        for (auto& [row, vals] : rowMap)
            colVals.insert(colVals.end(), vals.begin(), vals.end());
        result.push_back(colVals);
    }
    return result;
}
// map keeps col sorted, multiset handles same-position ties
```

---

## 📌 L22 — Top View of Binary Tree

```cpp
// First node seen at each horizontal column (BFS order)
vector<int> topView(TreeNode* root) {
    if (!root) return {};
    map<int, int> colMap;   // col → first node val
    queue<pair<TreeNode*, int>> q;  // {node, col}
    q.push({root, 0});
    while (!q.empty()) {
        auto [node, col] = q.front(); q.pop();
        if (colMap.find(col) == colMap.end())
            colMap[col] = node->val;   // first seen = top
        if (node->left)  q.push({node->left,  col-1});
        if (node->right) q.push({node->right, col+1});
    }
    vector<int> result;
    for (auto& [col, val] : colMap)
        result.push_back(val);
    return result;
}
```

---

## 📌 L23 — Bottom View of Binary Tree

```cpp
// Last node at each column (deepest level wins → keep overwriting)
vector<int> bottomView(TreeNode* root) {
    if (!root) return {};
    map<int, int> colMap;
    queue<pair<TreeNode*, int>> q;
    q.push({root, 0});
    while (!q.empty()) {
        auto [node, col] = q.front(); q.pop();
        colMap[col] = node->val;    // overwrite = bottom wins
        if (node->left)  q.push({node->left,  col-1});
        if (node->right) q.push({node->right, col+1});
    }
    vector<int> result;
    for (auto& [col, val] : colMap)
        result.push_back(val);
    return result;
}
// TOP vs BOTTOM:
// Top    → first seen at each col (don't overwrite)
// Bottom → last seen at each col (keep overwriting)
```

---

## 📌 L24 — Right View / Left View

```cpp
// LC 199 — Right Side View

// ── BFS: take last element of each level ────────────────
vector<int> rightSideViewBFS(TreeNode* root) {
    if (!root) return {};
    vector<int> result;
    queue<TreeNode*> q;
    q.push(root);
    while (!q.empty()) {
        int sz = q.size();
        for (int i = 0; i < sz; i++) {
            TreeNode* node = q.front(); q.pop();
            if (i == sz - 1) result.push_back(node->val);  // last in level
            if (node->left)  q.push(node->left);
            if (node->right) q.push(node->right);
        }
    }
    return result;
}

// ── DFS: visit right first, first node at each depth ────
void rightDFS(TreeNode* node, int depth, vector<int>& res) {
    if (!node) return;
    if (depth == (int)res.size())
        res.push_back(node->val);  // first node at this depth
    rightDFS(node->right, depth+1, res);  // RIGHT first
    rightDFS(node->left,  depth+1, res);
}
vector<int> rightSideView(TreeNode* root) {
    vector<int> result;
    rightDFS(root, 0, result);
    return result;
}

// Left View: same but visit LEFT first in DFS
void leftDFS(TreeNode* node, int depth, vector<int>& res) {
    if (!node) return;
    if (depth == (int)res.size())
        res.push_back(node->val);
    leftDFS(node->left,  depth+1, res);   // LEFT first
    leftDFS(node->right, depth+1, res);
}
```

---

## 📌 L26 — Print Root to Node Path

```cpp
bool rootToNodePath(TreeNode* node, int target, vector<int>& path) {
    if (!node) return false;
    path.push_back(node->val);
    if (node->val == target) return true;
    if (rootToNodePath(node->left,  target, path) ||
        rootToNodePath(node->right, target, path))
        return true;
    path.pop_back();   // backtrack
    return false;
}

vector<int> getPath(TreeNode* root, int target) {
    vector<int> path;
    rootToNodePath(root, target, path);
    return path;
}
// Used as building block for: LCA, distance between nodes, path sum
```

---

## 📌 L28 — Maximum Width of Binary Tree

```cpp
// LC 662 — index left child = 2*i, right child = 2*i+1
// NORMALIZE by subtracting min index at each level to prevent overflow

int widthOfBinaryTree(TreeNode* root) {
    if (!root) return 0;
    int maxWidth = 0;
    queue<pair<TreeNode*, long long>> q;  // {node, index}
    q.push({root, 0});
    while (!q.empty()) {
        int sz = q.size();
        long long minIdx = q.front().second;  // normalize
        long long first, last;
        for (int i = 0; i < sz; i++) {
            auto [node, idx] = q.front(); q.pop();
            idx -= minIdx;           // normalize
            if (i == 0)   first = idx;
            if (i == sz-1) last = idx;
            if (node->left)  q.push({node->left,  2*idx});
            if (node->right) q.push({node->right, 2*idx+1});
        }
        maxWidth = max(maxWidth, (int)(last - first + 1));
    }
    return maxWidth;
}
// Use long long for indices to avoid overflow before normalization
```

---

## 📌 L30 — All Nodes at Distance K from Target

```cpp
// LC 863 — Convert tree to undirected graph using parent map, then BFS

void buildParent(TreeNode* node, TreeNode* par,
                 unordered_map<TreeNode*, TreeNode*>& parent) {
    if (!node) return;
    parent[node] = par;
    buildParent(node->left,  node, parent);
    buildParent(node->right, node, parent);
}

vector<int> distanceK(TreeNode* root, TreeNode* target, int k) {
    unordered_map<TreeNode*, TreeNode*> parent;
    buildParent(root, nullptr, parent);

    unordered_set<TreeNode*> visited;
    queue<TreeNode*> q;
    q.push(target);
    visited.insert(target);
    int dist = 0;

    while (!q.empty()) {
        if (dist == k) {
            vector<int> result;
            while (!q.empty()) {
                result.push_back(q.front()->val);
                q.pop();
            }
            return result;
        }
        int sz = q.size();
        for (int i = 0; i < sz; i++) {
            TreeNode* node = q.front(); q.pop();
            for (TreeNode* neighbor : {node->left, node->right, parent[node]}) {
                if (neighbor && !visited.count(neighbor)) {
                    visited.insert(neighbor);
                    q.push(neighbor);
                }
            }
        }
        dist++;
    }
    return {};
}
```

---

## 📌 L31 — Minimum Time to Burn Binary Tree

```cpp
// Same parent-map + BFS pattern as distance K
// Answer = max distance from target to any leaf

TreeNode* findTarget(TreeNode* root, int target,
                     unordered_map<TreeNode*, TreeNode*>& parent) {
    if (!root) return nullptr;
    parent[root] = nullptr;
    queue<TreeNode*> q;
    q.push(root);
    TreeNode* targetNode = nullptr;
    while (!q.empty()) {
        TreeNode* node = q.front(); q.pop();
        if (node->val == target) targetNode = node;
        if (node->left)  { parent[node->left]  = node; q.push(node->left); }
        if (node->right) { parent[node->right] = node; q.push(node->right); }
    }
    return targetNode;
}

int minTimeToBurn(TreeNode* root, int target) {
    unordered_map<TreeNode*, TreeNode*> parent;
    TreeNode* targetNode = findTarget(root, target, parent);

    unordered_set<TreeNode*> visited;
    queue<TreeNode*> q;
    q.push(targetNode);
    visited.insert(targetNode);
    int time = 0;

    while (!q.empty()) {
        int sz = q.size();
        bool spread = false;
        for (int i = 0; i < sz; i++) {
            TreeNode* node = q.front(); q.pop();
            for (TreeNode* nb : {node->left, node->right, parent[node]}) {
                if (nb && !visited.count(nb)) {
                    visited.insert(nb);
                    q.push(nb);
                    spread = true;
                }
            }
        }
        if (spread) time++;
    }
    return time;
}
```

---

## 📌 L32 — Count Nodes in Complete Binary Tree (O(log²N))

```cpp
// LC 222
// KEY: In complete BT, either left or right subtree is perfect

int leftHeight(TreeNode* node) {
    int h = 0;
    while (node) { h++; node = node->left; }
    return h;
}
int rightHeight(TreeNode* node) {
    int h = 0;
    while (node) { h++; node = node->right; }
    return h;
}

int countNodes(TreeNode* root) {
    if (!root) return 0;
    int lh = leftHeight(root);
    int rh = rightHeight(root);
    if (lh == rh)
        return (1 << lh) - 1;    // perfect binary tree: 2^h - 1
    return 1 + countNodes(root->left) + countNodes(root->right);
}
// TC: O(log²N), SC: O(log N)
```

---

## 📌 L34 — Construct BT from Preorder + Inorder

```cpp
// LC 105
// KEY: preorder[0] = root; find root in inorder → split left/right

TreeNode* buildHelper(vector<int>& preorder, int& preIdx,
                      unordered_map<int,int>& inMap,
                      int inStart, int inEnd) {
    if (inStart > inEnd) return nullptr;
    int rootVal = preorder[preIdx++];
    TreeNode* root = new TreeNode(rootVal);
    int mid = inMap[rootVal];
    root->left  = buildHelper(preorder, preIdx, inMap, inStart, mid-1);
    root->right = buildHelper(preorder, preIdx, inMap, mid+1, inEnd);
    return root;
}

TreeNode* buildTree(vector<int>& preorder, vector<int>& inorder) {
    unordered_map<int,int> inMap;
    for (int i = 0; i < inorder.size(); i++)
        inMap[inorder[i]] = i;
    int preIdx = 0;
    return buildHelper(preorder, preIdx, inMap, 0, inorder.size()-1);
}
// TC: O(N), SC: O(N) for hashmap
```

---

## 📌 L35 — Construct BT from Postorder + Inorder

```cpp
// LC 106
// KEY: postorder.back() = root; build RIGHT subtree first

TreeNode* buildHelperPost(vector<int>& postorder, int& postIdx,
                          unordered_map<int,int>& inMap,
                          int inStart, int inEnd) {
    if (inStart > inEnd) return nullptr;
    int rootVal = postorder[postIdx--];
    TreeNode* root = new TreeNode(rootVal);
    int mid = inMap[rootVal];
    // Build RIGHT first (reading postorder from back)
    root->right = buildHelperPost(postorder, postIdx, inMap, mid+1, inEnd);
    root->left  = buildHelperPost(postorder, postIdx, inMap, inStart, mid-1);
    return root;
}

TreeNode* buildTreePost(vector<int>& inorder, vector<int>& postorder) {
    unordered_map<int,int> inMap;
    for (int i = 0; i < inorder.size(); i++)
        inMap[inorder[i]] = i;
    int postIdx = postorder.size() - 1;
    return buildHelperPost(postorder, postIdx, inMap, 0, inorder.size()-1);
}
```

---

## 📌 L36 — Serialize and Deserialize Binary Tree

```cpp
// LC 297 — BFS with "null" markers

string serialize(TreeNode* root) {
    if (!root) return "null";
    string res = "";
    queue<TreeNode*> q;
    q.push(root);
    while (!q.empty()) {
        TreeNode* node = q.front(); q.pop();
        if (node) {
            res += to_string(node->val) + ",";
            q.push(node->left);
            q.push(node->right);
        } else {
            res += "null,";
        }
    }
    return res;
}

TreeNode* deserialize(string data) {
    if (data == "null") return nullptr;
    stringstream ss(data);
    string token;
    getline(ss, token, ',');
    TreeNode* root = new TreeNode(stoi(token));
    queue<TreeNode*> q;
    q.push(root);
    while (!q.empty()) {
        TreeNode* node = q.front(); q.pop();
        if (getline(ss, token, ',') && token != "null") {
            node->left = new TreeNode(stoi(token));
            q.push(node->left);
        }
        if (getline(ss, token, ',') && token != "null") {
            node->right = new TreeNode(stoi(token));
            q.push(node->right);
        }
    }
    return root;
}
```

---

## 📌 L37 — Morris Traversal (O(1) Space!)

```cpp
// No stack, no recursion — uses temporary threads (right pointers)

// ── MORRIS INORDER ──────────────────────────────────────
vector<int> morrisInorder(TreeNode* root) {
    vector<int> result;
    TreeNode* curr = root;
    while (curr) {
        if (!curr->left) {
            result.push_back(curr->val);
            curr = curr->right;
        } else {
            // Find inorder predecessor
            TreeNode* pred = curr->left;
            while (pred->right && pred->right != curr)
                pred = pred->right;
            if (!pred->right) {
                pred->right = curr;     // create thread
                curr = curr->left;
            } else {
                pred->right = nullptr;  // remove thread
                result.push_back(curr->val);
                curr = curr->right;
            }
        }
    }
    return result;
}

// ── MORRIS PREORDER ─────────────────────────────────────
vector<int> morrisPreorder(TreeNode* root) {
    vector<int> result;
    TreeNode* curr = root;
    while (curr) {
        if (!curr->left) {
            result.push_back(curr->val);
            curr = curr->right;
        } else {
            TreeNode* pred = curr->left;
            while (pred->right && pred->right != curr)
                pred = pred->right;
            if (!pred->right) {
                result.push_back(curr->val);  // print BEFORE creating thread
                pred->right = curr;
                curr = curr->left;
            } else {
                pred->right = nullptr;
                curr = curr->right;
            }
        }
    }
    return result;
}
// TC: O(N), SC: O(1)
// USE WHEN: interviewer says O(1) space traversal
```

---

## 📌 L38 — Flatten Binary Tree to Linked List

```cpp
// LC 114 — in-place, right pointer = next, left = null, preorder order

// ── APPROACH 1: O(N) space — store preorder, reconnect ──
void flattenV1(TreeNode* root) {
    vector<TreeNode*> nodes;
    function<void(TreeNode*)> preorder = [&](TreeNode* node) {
        if (!node) return;
        nodes.push_back(node);
        preorder(node->left);
        preorder(node->right);
    };
    preorder(root);
    for (int i = 1; i < nodes.size(); i++) {
        nodes[i-1]->left  = nullptr;
        nodes[i-1]->right = nodes[i];
    }
}

// ── APPROACH 2: O(1) space — Morris-like (Striver's optimal) ──
void flattenV2(TreeNode* root) {
    TreeNode* curr = root;
    while (curr) {
        if (curr->left) {
            // Find rightmost of left subtree
            TreeNode* rightmost = curr->left;
            while (rightmost->right)
                rightmost = rightmost->right;
            // Attach current right to rightmost
            rightmost->right = curr->right;
            // Move left subtree to right
            curr->right = curr->left;
            curr->left  = nullptr;
        }
        curr = curr->right;
    }
}

// ── APPROACH 3: Reverse postorder (right→left→root) ────
TreeNode* prev = nullptr;
void flattenV3(TreeNode* root) {
    if (!root) return;
    flattenV3(root->right);
    flattenV3(root->left);
    root->right = prev;
    root->left  = nullptr;
    prev = root;
}
```

---

## 📌 L39 — Introduction to BST

```
BINARY SEARCH TREE PROPERTIES:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
- For every node:
    * Everything in LEFT subtree  < node->val
    * Everything in RIGHT subtree > node->val
- No duplicates in standard BST
- Inorder traversal of BST → SORTED array ← KEY FACT
- Search/Insert/Delete: O(H)
    * Balanced BST: O(log N)
    * Skewed BST:   O(N)

              8
            /   \
           3     10
         /   \     \
        1     6     14
             / \    /
            4   7  13

Inorder: [1,3,4,6,7,8,10,13,14]  ← sorted!
```

---

## 📌 L40 — Search in BST

```cpp
// LC 700
TreeNode* searchBST(TreeNode* root, int val) {
    while (root) {
        if (root->val == val)   return root;
        else if (val < root->val) root = root->left;
        else                      root = root->right;
    }
    return nullptr;
}
// TC: O(H) = O(log N) balanced, O(N) worst
```

---

## 📌 L42 — Floor and Ceiling in BST

```cpp
// Floor = largest value <= key
int floorBST(TreeNode* root, int key) {
    int floor = -1;
    while (root) {
        if (root->val == key) return root->val;
        else if (root->val < key) {
            floor = root->val;    // potential floor
            root = root->right;   // go right for better candidate
        } else {
            root = root->left;    // too big, go left
        }
    }
    return floor;
}

// Ceiling = smallest value >= key
int ceilBST(TreeNode* root, int key) {
    int ceil = -1;
    while (root) {
        if (root->val == key) return root->val;
        else if (root->val > key) {
            ceil = root->val;     // potential ceil
            root = root->left;    // go left for better candidate
        } else {
            root = root->right;   // too small, go right
        }
    }
    return ceil;
}
// MEMORY AID:
// Floor: go right when node < key (record as candidate)
// Ceil:  go left  when node > key (record as candidate)
```

---

## 📌 L43 — Insert in BST

```cpp
// LC 701 — always insert as a LEAF node
TreeNode* insertIntoBST(TreeNode* root, int val) {
    if (!root) return new TreeNode(val);
    TreeNode* curr = root;
    while (true) {
        if (val < curr->val) {
            if (!curr->left) { curr->left = new TreeNode(val); break; }
            curr = curr->left;
        } else {
            if (!curr->right) { curr->right = new TreeNode(val); break; }
            curr = curr->right;
        }
    }
    return root;
}
// TC: O(H), SC: O(1) iterative
```

---

## 📌 L44 — Delete in BST

```cpp
// LC 450
// Case 1: leaf → just delete
// Case 2: one child → replace with child
// Case 3: two children → replace with inorder successor (leftmost of right subtree)

TreeNode* deleteNode(TreeNode* root, int key) {
    if (!root) return nullptr;
    if (key < root->val) {
        root->left  = deleteNode(root->left, key);
    } else if (key > root->val) {
        root->right = deleteNode(root->right, key);
    } else {
        // Found node to delete
        if (!root->left)  return root->right;  // Case 1 & 2
        if (!root->right) return root->left;   // Case 2
        // Case 3: find inorder successor
        TreeNode* successor = root->right;
        while (successor->left)
            successor = successor->left;
        root->val   = successor->val;
        root->right = deleteNode(root->right, successor->val);
    }
    return root;
}
// TC: O(H), SC: O(H) recursive stack
```

---

## 📌 L45 — Kth Smallest / Largest Element in BST

```cpp
// LC 230 — Kth Smallest
// KEY: inorder of BST = sorted → kth in inorder = kth smallest

int kthSmallest(TreeNode* root, int k) {
    int count = 0, result = -1;
    function<void(TreeNode*)> inorder = [&](TreeNode* node) {
        if (!node || count >= k) return;
        inorder(node->left);
        if (++count == k) { result = node->val; return; }
        inorder(node->right);
    };
    inorder(root);
    return result;
}

// Kth Largest: reverse inorder (Right → Root → Left)
int kthLargest(TreeNode* root, int k) {
    int count = 0, result = -1;
    function<void(TreeNode*)> reverseInorder = [&](TreeNode* node) {
        if (!node || count >= k) return;
        reverseInorder(node->right);   // RIGHT first
        if (++count == k) { result = node->val; return; }
        reverseInorder(node->left);
    };
    reverseInorder(root);
    return result;
}
// TC: O(H + K), SC: O(H)
```

---

## 📌 L46 — Validate BST

```cpp
// LC 98
// WRONG: just checking left < root < right per node (misses subtree violations)
// RIGHT: pass valid [minVal, maxVal] range down the tree

bool validateHelper(TreeNode* node, long long minVal, long long maxVal) {
    if (!node) return true;
    if (node->val <= minVal || node->val >= maxVal) return false;
    return validateHelper(node->left,  minVal,      node->val) &&
           validateHelper(node->right, node->val,   maxVal);
}
bool isValidBST(TreeNode* root) {
    return validateHelper(root, LLONG_MIN, LLONG_MAX);
}

// ALTERNATIVE: inorder traversal → check if strictly increasing
bool isValidBSTV2(TreeNode* root) {
    long long prev = LLONG_MIN;
    function<bool(TreeNode*)> inorder = [&](TreeNode* node) -> bool {
        if (!node) return true;
        if (!inorder(node->left))       return false;
        if (node->val <= prev)          return false;
        prev = node->val;
        return inorder(node->right);
    };
    return inorder(root);
}
```

---

## 📌 L47 — LCA in BST

```cpp
// LC 235 — uses BST property, O(H) vs O(N) for general tree

TreeNode* lowestCommonAncestorBST(TreeNode* root,
                                   TreeNode* p, TreeNode* q) {
    while (root) {
        if (p->val < root->val && q->val < root->val)
            root = root->left;           // both in left
        else if (p->val > root->val && q->val > root->val)
            root = root->right;          // both in right
        else
            return root;                 // split point = LCA
    }
    return nullptr;
}

// LCA of GENERAL Binary Tree (LC 236) — different!
TreeNode* lowestCommonAncestor(TreeNode* root,
                                TreeNode* p, TreeNode* q) {
    if (!root || root == p || root == q) return root;
    TreeNode* left  = lowestCommonAncestor(root->left,  p, q);
    TreeNode* right = lowestCommonAncestor(root->right, p, q);
    if (left && right) return root;    // p in left, q in right
    return left ? left : right;
}
```

---

## 📌 L48 — Construct BST from Preorder Traversal

```cpp
// LC 1008
// APPROACH: Use valid range bound — O(N)

TreeNode* bstFromPreorderHelper(vector<int>& pre, int& idx,
                                 int minVal, int maxVal) {
    if (idx >= (int)pre.size()) return nullptr;
    int val = pre[idx];
    if (val < minVal || val > maxVal) return nullptr;
    TreeNode* node = new TreeNode(val);
    idx++;
    node->left  = bstFromPreorderHelper(pre, idx, minVal,   val-1);
    node->right = bstFromPreorderHelper(pre, idx, val+1, maxVal);
    return node;
}

TreeNode* bstFromPreorder(vector<int>& preorder) {
    int idx = 0;
    return bstFromPreorderHelper(preorder, idx, INT_MIN, INT_MAX);
}
// TC: O(N), SC: O(H)
```

---

## 📌 L49 — Inorder Successor and Predecessor in BST

```cpp
// Successor: smallest value GREATER than p->val
TreeNode* inorderSuccessor(TreeNode* root, TreeNode* p) {
    TreeNode* successor = nullptr;
    while (root) {
        if (p->val < root->val) {
            successor = root;         // potential successor
            root = root->left;        // go left for smaller candidate
        } else {
            root = root->right;       // need larger
        }
    }
    return successor;
}

// Predecessor: largest value SMALLER than p->val
TreeNode* inorderPredecessor(TreeNode* root, TreeNode* p) {
    TreeNode* predecessor = nullptr;
    while (root) {
        if (p->val > root->val) {
            predecessor = root;       // potential predecessor
            root = root->right;       // go right for larger candidate
        } else {
            root = root->left;        // need smaller
        }
    }
    return predecessor;
}
// TC: O(H), SC: O(1)
```

---

## 📌 L50 — BST Iterator

```cpp
// LC 173 — next() in O(1) amortized, O(H) space

class BSTIterator {
    stack<TreeNode*> st;

    void pushLeft(TreeNode* node) {
        while (node) { st.push(node); node = node->left; }
    }

public:
    BSTIterator(TreeNode* root) { pushLeft(root); }

    int next() {
        TreeNode* node = st.top(); st.pop();
        pushLeft(node->right);    // prepare right subtree
        return node->val;
    }

    bool hasNext() { return !st.empty(); }
};
// TRICK: Only push left path, lazily push right's left path when needed
// SC: O(H) stack space at any time
```

---

## 📌 L51 — Two Sum in BST

```cpp
// LC 653
// APPROACH: Inorder → sorted vector → two pointer

void inorderCollect(TreeNode* node, vector<int>& nums) {
    if (!node) return;
    inorderCollect(node->left, nums);
    nums.push_back(node->val);
    inorderCollect(node->right, nums);
}

bool findTarget(TreeNode* root, int k) {
    vector<int> nums;
    inorderCollect(root, nums);
    int left = 0, right = nums.size() - 1;
    while (left < right) {
        int sum = nums[left] + nums[right];
        if (sum == k)      return true;
        else if (sum < k)  left++;
        else               right--;
    }
    return false;
}
// TC: O(N), SC: O(N)
```

---

## 📌 L52 — Recover BST (Two Nodes Swapped)

```cpp
// LC 99
// Inorder of valid BST = sorted → swapped nodes create inversions

class Solution {
    TreeNode *first, *second, *prev;
public:
    void inorder(TreeNode* node) {
        if (!node) return;
        inorder(node->left);
        if (prev && prev->val > node->val) {
            if (!first) first = prev;    // first inversion: prev is wrong
            second = node;               // keep updating second
        }
        prev = node;
        inorder(node->right);
    }
    void recoverTree(TreeNode* root) {
        first = second = prev = nullptr;
        inorder(root);
        swap(first->val, second->val);
    }
};
// TC: O(N), SC: O(H)
// Can do O(1) space with Morris Traversal
```

---

## 📌 L53 — Largest BST in Binary Tree

```cpp
// LC 333 — at each node, know: (isBST, size, minVal, maxVal)

struct Info { bool isBST; int size, minVal, maxVal; };

int maxBST = 0;

Info largestBSTHelper(TreeNode* node) {
    if (!node) return {true, 0, INT_MAX, INT_MIN};

    Info left  = largestBSTHelper(node->left);
    Info right = largestBSTHelper(node->right);

    if (left.isBST && right.isBST &&
        left.maxVal < node->val && node->val < right.minVal) {
        int size = left.size + right.size + 1;
        maxBST = max(maxBST, size);
        return {true, size,
                min(left.minVal,  node->val),
                max(right.maxVal, node->val)};
    }
    return {false, 0, INT_MIN, INT_MAX};
}

int largestBSTSubtree(TreeNode* root) {
    maxBST = 0;
    largestBSTHelper(root);
    return maxBST;
}
// TC: O(N), SC: O(H)
// KEY: Pass up (isBST, size, min, max) from children
```

---

## 📌 All Patterns — Quick Revision

```
TREE PATTERN CHEAT SHEET:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TRAVERSAL TYPE  → TECHNIQUE:
  Recursive DFS   → simple recursion
  Iterative DFS   → explicit stack<TreeNode*>
  Morris          → O(1) space, thread pointers
  BFS/Level Order → queue<TreeNode*>

PROBLEM → PATTERN:
  Height/Depth         → post-order DFS (bottom-up)
  Balanced tree        → return -1 as sentinel from helper
  Diameter             → post-order, track maxDia globally
  Max path sum         → same as diameter but with node values
  Top/Bottom view      → BFS + map<int,int> by column
  Vertical order       → BFS + map<int, map<int, multiset<int>>>
  Right/Left view      → DFS, depth == result.size()
  Boundary traversal   → 3 parts: left + leaves + right(reversed)
  LCA                  → post-order, return p/q when found
  LCA in BST           → walk using values, no recursion needed
  Path to node         → DFS + backtracking
  K-distance nodes     → parent map + BFS
  Burn tree            → parent map + BFS
  Width of tree        → BFS with long long index, normalize

BST SPECIFIC:
  Search/Insert/Delete → walk using BST property O(H)
  Validate BST         → pass (minVal, maxVal) range down
  Kth smallest         → inorder (kth element)
  Kth largest          → reverse inorder
  Floor                → walk, record when node->val <= key
  Ceil                 → walk, record when node->val >= key
  Successor            → walk, record last left turn node
  Predecessor          → walk, record last right turn node
  Two sum in BST       → inorder → sorted vector → two pointer
  Recover BST          → inorder, find 2 inversion points, swap

CONSTRUCTION:
  Pre + Inorder  → pre[0] = root, locate in inorder to split
  Post + Inorder → post.back() = root, build RIGHT first
  BST from pre   → use valid range [minVal, maxVal]
  Serialize      → BFS with "null" markers
  Deserialize    → BFS reconstruction with stringstream

C++ SPECIFIC TIPS:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Use long long for BFS indices (max width) to avoid overflow
Use LLONG_MIN/LLONG_MAX for validate BST to handle INT_MIN nodes
Use multiset for vertical traversal (handles duplicate vals + sorted)
Use function<void(TreeNode*)> for inline lambdas with capture
Pass result by reference (&) into helpers instead of returning
Use structured bindings (auto [node, col] = ...) for pair/tuple

COMPLEXITY QUICK REF:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
All traversals      O(N) time, O(H) space
BST operations      O(H) = O(log N) balanced, O(N) worst
Count complete BT   O(log²N) — special complete BT property
Morris traversal    O(N) time, O(1) space — best space
```

---

## 📌 LeetCode Problem Map

```
TOPIC                     | LC #  | DIFFICULTY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Preorder Traversal        | 144   | Easy
Inorder Traversal         | 94    | Easy
Postorder Traversal       | 145   | Easy
Level Order               | 102   | Medium
Zigzag Level Order        | 103   | Medium
Max Depth                 | 104   | Easy
Balanced Tree             | 110   | Easy
Diameter                  | 543   | Easy
Max Path Sum              | 124   | Hard
Same Tree                 | 100   | Easy
Right Side View           | 199   | Medium
Vertical Traversal        | 987   | Hard
Max Width                 | 662   | Medium
All Nodes at Distance K   | 863   | Medium
Count Complete Nodes      | 222   | Medium
Build from Pre + In       | 105   | Medium
Build from Post + In      | 106   | Medium
Serialize / Deserialize   | 297   | Hard
Flatten to Linked List    | 114   | Medium
BST Search                | 700   | Easy
BST Insert                | 701   | Medium
BST Delete                | 450   | Medium
Validate BST              | 98    | Medium
Kth Smallest in BST       | 230   | Medium
LCA of BST                | 235   | Medium
LCA of Binary Tree        | 236   | Medium
BST from Preorder         | 1008  | Medium
BST Iterator              | 173   | Medium
Two Sum in BST            | 653   | Easy
Recover BST               | 99    | Medium
Largest BST Subtree       | 333   | Medium
```

