# Striver Graph Series — Complete Notes (C++)

*Based on TakeUForward Graph Playlist — 56 Videos (G-1 to G-56)*

---

## 📌 C++ Graph Representation Setup (use this everywhere)

```cpp
#include <bits/stdc++.h>
using namespace std;

// ── INPUT FORMAT (standard across almost every question) ──
// Line 1: n m           → n = nodes, m = edges
// Next m lines: u v     → undirected edge between u and v
//   (add a 3rd value "w" on each line if the graph is weighted)

// ── ADJACENCY LIST (default choice — use this unless told otherwise) ──
int n, m;
cin >> n >> m;
vector<int> adj[n + 1];              // 1-indexed by convention
for (int i = 0; i < m; i++) {
    int u, v;
    cin >> u >> v;
    adj[u].push_back(v);
    adj[v].push_back(u);             // omit this line for a DIRECTED graph
}
// Space: O(2E) undirected, O(E) directed | Build: O(E)

// ── ADJACENCY LIST, WEIGHTED (store {neighbor, weight} pairs) ──
vector<pair<int,int>> adjW[n + 1];
// adjW[u].push_back({v, w});
// adjW[v].push_back({u, w});        // omit for directed

// ── ADJACENCY MATRIX (only when N is small / need O(1) edge lookup) ──
int adjMat[n + 1][n + 1] = {0};
// adjMat[u][v] = 1; adjMat[v][u] = 1;     // unweighted undirected
// adjMat[u][v] = w;                       // weighted, directed
// Space: O(N²) — expensive, avoid unless the problem forces it

// ── VISITED ARRAY (every single traversal needs this) ──
vector<int> vis(n + 1, 0);
```

```
GRID / MATRIX PROBLEMS (Number of Islands, Flood Fill, Rotten Oranges...):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Treat every cell (i, j) as a graph "node". Neighbors = adjacent cells.
delRow[] = {-1, 0, 1, 0}     // 4-directional
delCol[] = { 0, 1, 0,-1}
delRow8[] = {-1,-1,-1, 0, 0, 1, 1, 1}   // 8-directional (diagonals too)
delCol8[] = {-1, 0, 1,-1, 1,-1, 0, 1}

for (int k = 0; k < 4; k++) {
    int nrow = row + delRow[k], ncol = col + delCol[k];
    if (nrow >= 0 && nrow < n && ncol >= 0 && ncol < m &&
        !visited[nrow][ncol] && grid[nrow][ncol] == targetVal) {
        // valid neighbor
    }
}
```

---

## 📌 L1 — Introduction to Graphs, Types & Conventions (G-1)

```
KEY TERMINOLOGY:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Node / Vertex   → the circles. Numbered in ANY order (no fixed rule).
Edge            → connection between two nodes.
Undirected edge → edge(u,v) means u→v AND v→u both exist.
Directed edge   → edge(u,v) means ONLY u→v exists (arrow shows direction).
Path            → sequence of nodes where consecutive nodes have an edge,
                   and NO NODE REPEATS in the path.
Cycle           → start at a node, travel via edges, return to the SAME node.

GRAPH TYPES:
  Undirected cyclic graph   → undirected + has ≥1 cycle
  Directed acyclic graph    → directed + NO cycle → called a DAG
  (DAG is critical — topological sort ONLY exists on a DAG)

DEGREE:
  Undirected: degree(node) = number of edges attached to it
    PROPERTY: sum of all degrees = 2 × (number of edges)
              (every edge touches exactly 2 nodes)
  Directed:   in-degree(node)  = number of incoming edges
              out-degree(node) = number of outgoing edges

EDGE WEIGHT:
  If not specified in the problem → assume UNIT weight (= 1) for every edge.
```

**MEMORY AID:** A tree is just a special graph — connected, no cycle, N nodes & N−1 edges. Every tree is a graph; not every graph is a tree.

---

## 📌 L2 — Graph Representation in C++ (G-2, G-3)

```
INPUT: first line "n m" (nodes, edges), then m lines of "u v" (an edge).
No fixed relationship between n and m — m can be anything.

TWO WAYS TO STORE:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Adjacency Matrix  → O(N²) space. adj[u][v] = 1 (and adj[v][u] = 1
                        if undirected). Simple, but wasteful for sparse
                        graphs and the space cost doesn't depend on m.
2. Adjacency List    → O(2E) space undirected, O(E) directed. Store only
                        what matters — the actual neighbors. THIS IS THE
                        DEFAULT choice for almost every problem going
                        forward in this playlist.
```

```cpp
// Reading input + building adjacency list (undirected, unweighted)
int n, m; cin >> n >> m;
vector<int> adj[n + 1];
for (int i = 0; i < m; i++) {
    int u, v; cin >> u >> v;
    adj[u].push_back(v);
    adj[v].push_back(u);
}

// DIRECTED version — only one push_back (u → v, not the reverse)
adj[u].push_back(v);

// WEIGHTED version — store pairs {neighbor, weight}
vector<pair<int,int>> adj[n + 1];
adj[u].push_back({v, w});
adj[v].push_back({u, w});   // omit if directed
```

**Java equivalent:** no pointers, so use `ArrayList<List<Integer>>` — conceptually identical, same push/iterate pattern.

---

## 📌 L3 — Connected Components & the Visited-Array Pattern (G-4)

```
A graph doesn't have to be one single connected blob. If a graph has 10
nodes but only 8 edges connecting them in separate clusters, each cluster
is a COMPONENT. "This is also a graph" applies even to disconnected pieces
— they're just multiple components of ONE graph as defined by the input.

WHY THIS MATTERS: any traversal (BFS/DFS) starting from a single node
ONLY visits that node's component. It will NEVER reach other components.
```

```cpp
// THE UNIVERSAL WRAPPER — every traversal-based problem uses this shape
vector<int> vis(n + 1, 0);
for (int i = 1; i <= n; i++) {
    if (!vis[i]) {
        // bfs(i, adj, vis);   or   dfs(i, adj, vis);
        // this call touches every node in i's component
    }
}
// Number of times this if-condition triggers = number of components
```

**KEY:** This loop-over-all-nodes-and-traverse-if-unvisited pattern is the backbone of Number of Provinces, Number of Islands, and virtually every "count the components" question.

---

## 📌 L4 — Breadth-First Search / BFS Traversal (G-5)

```
BFS = LEVEL-WISE traversal ("breadth" = go wide before going deep).
Given a starting node, level 0 = start node, level 1 = its direct
neighbors, level 2 = their neighbors, and so on. Nodes within the SAME
level can be visited in any order relative to each other, but every
node of level k must come before any node of level k+1.
```

```cpp
vector<int> bfs(int src, vector<int> adj[], int n) {
    vector<int> vis(n + 1, 0), result;
    queue<int> q;
    q.push(src);
    vis[src] = 1;
    while (!q.empty()) {
        int node = q.front(); q.pop();
        result.push_back(node);
        for (auto neighbor : adj[node]) {
            if (!vis[neighbor]) {
                vis[neighbor] = 1;
                q.push(neighbor);          // mark visited AT INSERTION time,
            }                              // not at pop time — avoids dupes
        }
    }
    return result;
}
// TC: O(N + 2E) — visit every node once, scan every edge twice (both ends)
// SC: O(N) for visited + queue
```

**TRICK:** Always mark `vis[]=1` the moment you *push* a node into the queue, never wait until you pop it — otherwise the same node can be queued multiple times by different neighbors before it's processed.

---

## 📌 L5 — Depth-First Search / DFS Traversal (G-6)

```
DFS = go as DEEP as possible down one path before backtracking.
Given a starting node, pick any unvisited neighbor, dive into it fully
(recursively repeating the same rule), and only backtrack when a node
has no unvisited neighbors left. Different neighbor-order choices give
different (but all valid) DFS traversals of the same graph.
```

```cpp
void dfs(int node, vector<int> adj[], vector<int>& vis, vector<int>& result) {
    vis[node] = 1;
    result.push_back(node);
    for (auto neighbor : adj[node]) {
        if (!vis[neighbor]) {
            dfs(neighbor, adj, vis, result);
        }
    }
}
// TC: O(N + 2E), SC: O(N) visited + O(N) recursion stack (worst case skewed graph)
```

**MEMORY AID:** BFS ~ ripples spreading outward on water (queue = FIFO). DFS ~ a maze-runner committing fully to one corridor before backing up (recursion = implicit stack).


---

## 📌 L6 — Number of Provinces (G-7)

```cpp
// A "province" = a connected component. Count them.
// Input here is commonly an ADJACENCY MATRIX.
void dfs(int node, vector<vector<int>>& isConnected, vector<int>& vis) {
    vis[node] = 1;
    for (int j = 0; j < isConnected.size(); j++) {
        if (isConnected[node][j] == 1 && !vis[j]) dfs(j, isConnected, vis);
    }
}
int findCircleNum(vector<vector<int>>& isConnected) {
    int n = isConnected.size();
    vector<int> vis(n, 0);
    int provinces = 0;
    for (int i = 0; i < n; i++) {
        if (!vis[i]) { provinces++; dfs(i, isConnected, vis); }
    }
    return provinces;
}
// TC: O(N^2) for matrix scan + O(N) traversal, SC: O(N)
```
**KEY:** This is the L3 visited-array wrapper pattern applied directly — every fresh `if (!vis[i])` trigger is one new province.

---

## 📌 L7 — Number of Islands (G-8)

```
Grid of 0 (water) / 1 (land). Count connected land groups.
NOTE: this variant of the problem allows all 8 DIRECTIONS (incl.
diagonals) — different from LeetCode 200, which is 4-directional only.
Read the problem statement carefully before picking delRow/delCol.
```

```cpp
void bfs(int row, int col, vector<vector<int>>& vis, vector<vector<char>>& grid) {
    vis[row][col] = 1;
    queue<pair<int,int>> q;
    q.push({row, col});
    int n = grid.size(), m = grid[0].size();
    while (!q.empty()) {
        auto [r, c] = q.front(); q.pop();
        for (int dr = -1; dr <= 1; dr++) {
            for (int dc = -1; dc <= 1; dc++) {
                int nr = r + dr, nc = c + dc;
                if (nr >= 0 && nr < n && nc >= 0 && nc < m &&
                    grid[nr][nc] == '1' && !vis[nr][nc]) {
                    vis[nr][nc] = 1;
                    q.push({nr, nc});
                }
            }
        }
    }
}
int numIslands(vector<vector<char>>& grid) {
    int n = grid.size(), m = grid[0].size(), count = 0;
    vector<vector<int>> vis(n, vector<int>(m, 0));
    for (int i = 0; i < n; i++)
        for (int j = 0; j < m; j++)
            if (grid[i][j] == '1' && !vis[i][j]) { count++; bfs(i, j, vis, grid); }
    return count;
}
// TC: O(N*M) traversal * O(9) per cell ~ O(N*M), SC: O(N*M)
```

---

## 📌 L8 — Flood Fill Algorithm (G-9)

```
Start at pixel (sr, sc). Recolor it AND every 4-directionally connected
pixel of the SAME original color, using BFS or DFS.
GOTCHA: if newColor == the original color, do nothing — otherwise the
"already visited" check breaks (you'd be comparing against the color
you just painted) and you can infinite-loop.
```

```cpp
void dfs(int row, int col, vector<vector<int>>& image, vector<vector<int>>& ans,
          int delRow[], int delCol[], int iniColor, int newColor) {
    ans[row][col] = newColor;
    int n = image.size(), m = image[0].size();
    for (int i = 0; i < 4; i++) {
        int nrow = row + delRow[i], ncol = col + delCol[i];
        if (nrow >= 0 && nrow < n && ncol >= 0 && ncol < m &&
            image[nrow][ncol] == iniColor && ans[nrow][ncol] != newColor) {
            dfs(nrow, ncol, image, ans, delRow, delCol, iniColor, newColor);
        }
    }
}
vector<vector<int>> floodFill(vector<vector<int>>& image, int sr, int sc, int newColor) {
    int iniColor = image[sr][sc];
    vector<vector<int>> ans = image;
    int delRow[] = {-1, 0, 1, 0}, delCol[] = {0, 1, 0, -1};
    dfs(sr, sc, image, ans, delRow, delCol, iniColor, newColor);
    return ans;
}
// TC: O(N*M), SC: O(N*M) recursion stack worst case
```

---

## 📌 L9 — Rotten Oranges (Multi-Source BFS) (G-10)

```
Grid: 0 = empty, 1 = fresh orange, 2 = rotten orange. Every unit of time,
a rotten orange rots ALL its 4-directional fresh neighbors SIMULTANEOUSLY.
Find minimum time to rot every orange (-1 if impossible).

KEY IDEA — MULTI-SOURCE BFS: don't start BFS from one cell. Push
*every* initially-rotten orange into the queue FIRST, all tagged with
time 0. Then run one combined BFS — because they were all queued
together, the level-by-level nature of BFS naturally simulates
"everything rots in parallel each second."
```

```cpp
int orangesRotting(vector<vector<int>>& grid) {
    int n = grid.size(), m = grid[0].size();
    queue<pair<pair<int,int>, int>> q;   // {{row,col}, time}
    vector<vector<int>> vis = grid;
    int freshCount = 0;
    for (int i = 0; i < n; i++)
        for (int j = 0; j < m; j++) {
            if (grid[i][j] == 2) q.push({{i, j}, 0});
            if (grid[i][j] == 1) freshCount++;
        }
    int delRow[] = {-1, 0, 1, 0}, delCol[] = {0, 1, 0, -1};
    int tm = 0, rottenCount = 0;
    while (!q.empty()) {
        auto [cell, t] = q.front(); q.pop();
        auto [r, c] = cell;
        tm = max(tm, t);
        for (int i = 0; i < 4; i++) {
            int nr = r + delRow[i], nc = c + delCol[i];
            if (nr >= 0 && nr < n && nc >= 0 && nc < m &&
                vis[nr][nc] == 1) {
                vis[nr][nc] = 2;
                q.push({{nr, nc}, t + 1});
                rottenCount++;
            }
        }
    }
    return rottenCount == freshCount ? tm : -1;
}
// TC: O(N*M), SC: O(N*M)
```
**MEMORY AID:** Any "spreads simultaneously from multiple starting points" problem (rotten oranges, number of enclaves' complement, walls & gates) = multi-source BFS: seed the queue with ALL sources before the loop starts.


---

## 📌 L10 — Detect Cycle in Undirected Graph — BFS (G-11)

```
IDEA: If BFS ever reaches a node that is ALREADY VISITED and that node
is NOT the immediate parent you just came from, you've found two
different paths converging on the same node → a cycle exists.
Carry {node, parent} pairs in the queue instead of bare nodes.
```

```cpp
bool detectCycleBFS(int src, vector<int> adj[], vector<int>& vis) {
    vis[src] = 1;
    queue<pair<int,int>> q;             // {node, parent}
    q.push({src, -1});
    while (!q.empty()) {
        auto [node, parent] = q.front(); q.pop();
        for (auto neighbor : adj[node]) {
            if (!vis[neighbor]) {
                vis[neighbor] = 1;
                q.push({neighbor, node});
            } else if (neighbor != parent) {
                return true;             // visited AND not where we came from
            }
        }
    }
    return false;
}
bool isCycle(int n, vector<int> adj[]) {
    vector<int> vis(n + 1, 0);
    for (int i = 1; i <= n; i++)
        if (!vis[i] && detectCycleBFS(i, adj, vis)) return true;
    return false;
}
// TC: O(N + 2E), SC: O(N)
```

---

## 📌 L11 — Detect Cycle in Undirected Graph — DFS (G-12)

```cpp
bool dfs(int node, int parent, vector<int> adj[], vector<int>& vis) {
    vis[node] = 1;
    for (auto neighbor : adj[node]) {
        if (!vis[neighbor]) {
            if (dfs(neighbor, node, adj, vis)) return true;
        } else if (neighbor != parent) {
            return true;                 // back-edge to a non-parent = cycle
        }
    }
    return false;
}
bool isCycle(int n, vector<int> adj[]) {
    vector<int> vis(n + 1, 0);
    for (int i = 1; i <= n; i++)
        if (!vis[i] && dfs(i, -1, adj, vis)) return true;
    return false;
}
// TC: O(N + 2E), SC: O(N) + O(N) recursion stack
```
**KEY:** Same "carry the parent" trick in both BFS and DFS. Passing `parent = node` (not `-1`) into the recursive call is what lets you tell "I've legitimately come back the way I came" apart from "I've hit a genuinely different path" — the latter is the cycle.


---

## 📌 L12 — 0/1 Matrix: Distance of Nearest Cell Having 1 (G-13)

```
Given a binary grid, for EVERY cell return the distance to the nearest
'1' cell (distance = |row1-row2| + |col1-col2|, i.e. steps, not
diagonal). A '1' cell's distance to itself is 0.

SAME multi-source BFS idea as Rotten Oranges: seed the queue with every
'1' cell at distance 0 simultaneously, then BFS outward.
```

```cpp
vector<vector<int>> nearest(vector<vector<int>>& grid) {
    int n = grid.size(), m = grid[0].size();
    vector<vector<int>> vis(n, vector<int>(m, 0)), dist(n, vector<int>(m, 0));
    queue<pair<pair<int,int>, int>> q;
    for (int i = 0; i < n; i++)
        for (int j = 0; j < m; j++)
            if (grid[i][j] == 1) { q.push({{i, j}, 0}); vis[i][j] = 1; }

    int delRow[] = {-1, 0, 1, 0}, delCol[] = {0, 1, 0, -1};
    while (!q.empty()) {
        auto [cell, d] = q.front(); q.pop();
        auto [r, c] = cell;
        dist[r][c] = d;
        for (int i = 0; i < 4; i++) {
            int nr = r + delRow[i], nc = c + delCol[i];
            if (nr >= 0 && nr < n && nc >= 0 && nc < m && !vis[nr][nc]) {
                vis[nr][nc] = 1;
                q.push({{nr, nc}, d + 1});
            }
        }
    }
    return dist;
}
// TC: O(N*M), SC: O(N*M)
```

---

## 📌 L13 — Surrounded Regions: Replace O's with X's (G-14)

```
An 'O' (or connected group of O's) gets flipped to 'X' UNLESS it's
connected to a boundary O — diagonals don't count, only 4-directional.

OBSERVATION: any 'O' touching the border can NEVER be surrounded — trace
its component and mark those safe FIRST, then flip every remaining
untouched 'O' to 'X'.
```

```cpp
void dfs(int row, int col, vector<vector<int>>& vis, vector<vector<char>>& mat,
          int delRow[], int delCol[]) {
    vis[row][col] = 1;
    int n = mat.size(), m = mat[0].size();
    for (int i = 0; i < 4; i++) {
        int nrow = row + delRow[i], ncol = col + delCol[i];
        if (nrow >= 0 && nrow < n && ncol >= 0 && ncol < m &&
            !vis[nrow][ncol] && mat[nrow][ncol] == 'O')
            dfs(nrow, ncol, vis, mat, delRow, delCol);
    }
}
vector<vector<char>> fill(vector<vector<char>>& mat) {
    int n = mat.size(), m = mat[0].size();
    vector<vector<int>> vis(n, vector<int>(m, 0));
    int delRow[] = {-1, 0, 1, 0}, delCol[] = {0, 1, 0, -1};
    // Step 1: DFS from every boundary 'O' — mark its whole component safe
    for (int j = 0; j < m; j++) {
        if (mat[0][j] == 'O' && !vis[0][j]) dfs(0, j, vis, mat, delRow, delCol);
        if (mat[n-1][j] == 'O' && !vis[n-1][j]) dfs(n-1, j, vis, mat, delRow, delCol);
    }
    for (int i = 0; i < n; i++) {
        if (mat[i][0] == 'O' && !vis[i][0]) dfs(i, 0, vis, mat, delRow, delCol);
        if (mat[i][m-1] == 'O' && !vis[i][m-1]) dfs(i, m-1, vis, mat, delRow, delCol);
    }
    // Step 2: any 'O' left unvisited was never boundary-connected → flip it
    for (int i = 0; i < n; i++)
        for (int j = 0; j < m; j++)
            if (!vis[i][j] && mat[i][j] == 'O') mat[i][j] = 'X';
    return mat;
}
// TC: O(N*M), SC: O(N*M)
```
**TRICK:** "Start from the boundary and mark what's safe" beats "start from every O and check if it reaches the boundary" — same pattern reused in L14.

---

## 📌 L14 — Number of Enclaves (G-15)

```
Binary grid; you may move 4-directionally between land cells. Count land
cells from which you CANNOT walk off the grid boundary in any number
of moves.

Exact mirror of L13's trick: any land cell connected to the boundary is
NOT an enclave. DFS/BFS from every boundary land cell, mark reachable;
answer = count of land cells that stayed unmarked.
```

```cpp
int numberOfEnclaves(vector<vector<int>>& grid) {
    int n = grid.size(), m = grid[0].size();
    vector<vector<int>> vis(n, vector<int>(m, 0));
    int delRow[] = {-1, 0, 1, 0}, delCol[] = {0, 1, 0, -1};
    queue<pair<int,int>> q;
    for (int i = 0; i < n; i++)
        for (int j = 0; j < m; j++)
            if ((i == 0 || i == n-1 || j == 0 || j == m-1) && grid[i][j] == 1) {
                q.push({i, j});
                vis[i][j] = 1;
            }
    while (!q.empty()) {
        auto [r, c] = q.front(); q.pop();
        for (int k = 0; k < 4; k++) {
            int nr = r + delRow[k], nc = c + delCol[k];
            if (nr >= 0 && nr < n && nc >= 0 && nc < m &&
                !vis[nr][nc] && grid[nr][nc] == 1) {
                vis[nr][nc] = 1;
                q.push({nr, nc});
            }
        }
    }
    int count = 0;
    for (int i = 0; i < n; i++)
        for (int j = 0; j < m; j++)
            if (grid[i][j] == 1 && !vis[i][j]) count++;
    return count;
}
// TC: O(N*M), SC: O(N*M)
```

---

## 📌 L15 — Number of Distinct Islands (G-16)

```
Count islands by SHAPE, not just by count — two islands with the same
shape (same relative layout, NOT rotated/reflected) count as ONE
distinct shape.

KEY IDEA — CANONICAL SHAPE ENCODING: DFS/BFS the island as usual, but
for every cell visited record its position RELATIVE to the island's
starting cell: (row - baseRow, col - baseCol). This makes the shape
translation-invariant. Store each island's list of relative coordinates
in a set<vector<pair<int,int>>> — the set's size is the answer.
```

```cpp
void dfs(int row, int col, vector<vector<int>>& vis, vector<vector<int>>& grid,
          vector<pair<int,int>>& shape, int baseRow, int baseCol,
          int delRow[], int delCol[]) {
    vis[row][col] = 1;
    shape.push_back({row - baseRow, col - baseCol});
    int n = grid.size(), m = grid[0].size();
    for (int i = 0; i < 4; i++) {
        int nrow = row + delRow[i], ncol = col + delCol[i];
        if (nrow >= 0 && nrow < n && ncol >= 0 && ncol < m &&
            !vis[nrow][ncol] && grid[nrow][ncol] == 1)
            dfs(nrow, ncol, vis, grid, shape, baseRow, baseCol, delRow, delCol);
    }
}
int countDistinctIslands(vector<vector<int>>& grid) {
    int n = grid.size(), m = grid[0].size();
    vector<vector<int>> vis(n, vector<int>(m, 0));
    int delRow[] = {-1, 0, 1, 0}, delCol[] = {0, 1, 0, -1};
    set<vector<pair<int,int>>> islands;
    for (int i = 0; i < n; i++)
        for (int j = 0; j < m; j++)
            if (grid[i][j] == 1 && !vis[i][j]) {
                vector<pair<int,int>> shape;
                dfs(i, j, vis, grid, shape, i, j, delRow, delCol);
                islands.insert(shape);
            }
    return islands.size();
}
// TC: O(N*M log(N*M)) (set insertion), SC: O(N*M)
```


---

## 📌 L16 — Bipartite Graph Check — BFS (G-17)

```
A graph is BIPARTITE if you can color every node with just 2 colors
such that no two adjacent nodes share a color.

RULE OF THUMB: any graph with NO odd-length cycle is bipartite. A single
odd cycle anywhere makes the whole graph non-bipartite. Linear chains
and even cycles are always bipartite.
```

```cpp
bool bfsCheck(int src, vector<int> adj[], vector<int>& color) {
    queue<int> q;
    q.push(src);
    color[src] = 0;                     // start with color 0
    while (!q.empty()) {
        int node = q.front(); q.pop();
        for (auto neighbor : adj[node]) {
            if (color[neighbor] == -1) {
                color[neighbor] = !color[node];   // opposite color
                q.push(neighbor);
            } else if (color[neighbor] == color[node]) {
                return false;            // same color on adjacent nodes → fail
            }
        }
    }
    return true;
}
bool isBipartite(int n, vector<int> adj[]) {
    vector<int> color(n, -1);
    for (int i = 0; i < n; i++)
        if (color[i] == -1)
            if (!bfsCheck(i, adj, color)) return false;
    return true;
}
// TC: O(N + 2E), SC: O(N)
```

---

## 📌 L17 — Bipartite Graph Check — DFS (G-18)

```cpp
bool dfsCheck(int node, int col, vector<int> adj[], vector<int>& color) {
    color[node] = col;
    for (auto neighbor : adj[node]) {
        if (color[neighbor] == -1) {
            if (!dfsCheck(neighbor, !col, adj, color)) return false;
        } else if (color[neighbor] == col) {
            return false;
        }
    }
    return true;
}
bool isBipartite(int n, vector<int> adj[]) {
    vector<int> color(n, -1);
    for (int i = 0; i < n; i++)
        if (color[i] == -1)
            if (!dfsCheck(i, 0, adj, color)) return false;
    return true;
}
// TC: O(N + 2E), SC: O(N) + O(N) recursion stack
```
**MEMORY AID:** Bipartite ⇔ 2-colorable ⇔ no odd cycle. All three are the same fact — pick whichever framing clicks in an interview.


---

## 📌 L18 — Detect Cycle in a Directed Graph — DFS (G-19)

```
The undirected trick ("visited neighbor that isn't my parent = cycle")
FAILS on directed graphs — a node can be visited via a completely
different branch that has nothing to do with the current DFS path, and
that's NOT a cycle.

FIX: track TWO arrays — `vis[]` (visited ever) AND `pathVis[]` (visited
in the CURRENT recursion stack / current path). A cycle exists only if
you reach a node that is pathVis == 1 right now. On backtracking from a
node, reset its pathVis back to 0 — it's leaving the current path.
```

```cpp
bool dfs(int node, vector<int> adj[], vector<int>& vis, vector<int>& pathVis) {
    vis[node] = 1;
    pathVis[node] = 1;
    for (auto neighbor : adj[node]) {
        if (!vis[neighbor]) {
            if (dfs(neighbor, adj, vis, pathVis)) return true;
        } else if (pathVis[neighbor]) {
            return true;                 // back-edge within the CURRENT path
        }
    }
    pathVis[node] = 0;                   // backtrack: leaving this path
    return false;
}
bool isCyclic(int n, vector<int> adj[]) {
    vector<int> vis(n, 0), pathVis(n, 0);
    for (int i = 0; i < n; i++)
        if (!vis[i] && dfs(i, adj, vis, pathVis)) return true;
    return false;
}
// TC: O(N + E), SC: O(N) + O(N) recursion stack
```
**KEY:** `pathVis` is what separates "already explored elsewhere" (fine) from "currently an ancestor of me on this exact path" (cycle). This vis + pathVis pair is the backbone of L18, L19, and directed-cycle problems generally.

---

## 📌 L19 — Find Eventual Safe States — DFS (G-20)

```
Terminal node = no outgoing edges. Safe node = EVERY path starting from
it eventually reaches a terminal node (i.e. it's never part of, or
leading into, a cycle). Return all safe nodes, sorted ascending.

APPROACH: reuse the vis + pathVis cycle-detection machinery from L18.
Use a 3rd state array to memoize each node as SAFE(2) / UNSAFE(1) so you
never recompute. A node is unsafe iff it lies on a cycle OR leads into
one; everything else is safe.
```

```cpp
bool dfs(int node, vector<int> adj[], vector<int>& vis, vector<int>& pathVis,
          vector<int>& check) {
    vis[node] = 1;
    pathVis[node] = 1;
    check[node] = 0;                     // assume unsafe until proven otherwise
    for (auto neighbor : adj[node]) {
        if (!vis[neighbor]) {
            if (dfs(neighbor, adj, vis, pathVis, check)) return true;
        } else if (pathVis[neighbor]) {
            return true;                 // cycle found
        }
    }
    pathVis[node] = 0;
    check[node] = 1;                     // survived — genuinely safe
    return false;
}
vector<int> eventualSafeNodes(int n, vector<int> adj[]) {
    vector<int> vis(n, 0), pathVis(n, 0), check(n, 0), result;
    for (int i = 0; i < n; i++)
        if (!vis[i]) dfs(i, adj, vis, pathVis, check);
    for (int i = 0; i < n; i++)
        if (check[i] == 1) result.push_back(i);
    return result;                       // already sorted since i goes 0..n-1
}
// TC: O(N + E), SC: O(N)
```

---

## 📌 L20 — Topological Sort — DFS (G-21)

```
Topo sort = a linear ordering of nodes such that for every directed edge
u → v, u appears BEFORE v in the ordering. ONLY exists on a DAG — an
undirected edge can never be satisfied (u before v AND v before u is
impossible), and a cycle can never be satisfied either.

KEY IDEA: do a normal DFS. The moment a node has explored ALL its
neighbors (i.e. right as it finishes / is about to return), PUSH it onto
a stack. Once all DFS calls finish, POP the stack — that's the topo
order. ("Finish last, appear first.")
```

```cpp
void dfs(int node, vector<int> adj[], vector<int>& vis, stack<int>& st) {
    vis[node] = 1;
    for (auto neighbor : adj[node])
        if (!vis[neighbor]) dfs(neighbor, adj, vis, st);
    st.push(node);                       // push AFTER all neighbors are done
}
vector<int> topoSort(int n, vector<int> adj[]) {
    vector<int> vis(n, 0), result;
    stack<int> st;
    for (int i = 0; i < n; i++)
        if (!vis[i]) dfs(i, adj, vis, st);
    while (!st.empty()) { result.push_back(st.top()); st.pop(); }
    return result;
}
// TC: O(N + E), SC: O(N)
```

---

## 📌 L21 — Topological Sort — Kahn's Algorithm / BFS (G-22)

```
BFS-flavored topo sort using IN-DEGREES instead of a finish-time stack.

ALGORITHM:
1. Compute in-degree of every node.
2. Push all nodes with in-degree 0 into a queue (they have no
   prerequisite — safe to place first).
3. Pop a node, add to result, and for each of its neighbors decrement
   their in-degree by 1. If a neighbor's in-degree hits 0, push it.
4. Repeat until the queue is empty.
```

```cpp
vector<int> topoSortBFS(int n, vector<int> adj[]) {
    vector<int> inDegree(n, 0);
    for (int i = 0; i < n; i++)
        for (auto neighbor : adj[i]) inDegree[neighbor]++;

    queue<int> q;
    for (int i = 0; i < n; i++)
        if (inDegree[i] == 0) q.push(i);

    vector<int> result;
    while (!q.empty()) {
        int node = q.front(); q.pop();
        result.push_back(node);
        for (auto neighbor : adj[node])
            if (--inDegree[neighbor] == 0) q.push(neighbor);
    }
    return result;
}
// TC: O(N + E), SC: O(N)
```

---

## 📌 L22 — Detect Cycle in Directed Graph — Kahn's Algorithm (G-23)

```
Topo sort ONLY exists for a DAG. So: run Kahn's algorithm as-is even on
a graph you suspect has a cycle. If the graph has NO cycle, every node
eventually reaches in-degree 0 and gets pushed — result.size() == n.
If a cycle exists, the nodes locked inside it never reach in-degree 0,
so they're never pushed → result.size() < n. That gap IS the cycle
detector — no extra bookkeeping needed.
```

```cpp
bool isCyclicKahns(int n, vector<int> adj[]) {
    vector<int> inDegree(n, 0);
    for (int i = 0; i < n; i++)
        for (auto neighbor : adj[i]) inDegree[neighbor]++;
    queue<int> q;
    for (int i = 0; i < n; i++)
        if (inDegree[i] == 0) q.push(i);
    int count = 0;
    while (!q.empty()) {
        int node = q.front(); q.pop();
        count++;
        for (auto neighbor : adj[node])
            if (--inDegree[neighbor] == 0) q.push(neighbor);
    }
    return count != n;                   // fewer than n processed → cycle
}
// TC: O(N + E), SC: O(N)
```

---

## 📌 L23 — Course Schedule I & II (G-24)

```
Prerequisite pair [a, b] means "must finish b before a" → edge b → a.
  Course Schedule I:  can all courses be finished?  → is a valid topo
                       order possible? → run Kahn's, check count == n.
  Course Schedule II: RETURN one valid order (or {} if impossible)
                       → the topo order Kahn's produces IS the answer.
Both problems are the exact same Kahn's-algorithm code — I just choose
whether to return a bool or the `result` vector itself.
```

```cpp
vector<int> findOrder(int numCourses, vector<vector<int>>& prerequisites) {
    vector<int> adj[numCourses], inDegree(numCourses, 0);
    for (auto& p : prerequisites) {
        adj[p[1]].push_back(p[0]);       // b -> a  (b before a)
        inDegree[p[0]]++;
    }
    queue<int> q;
    for (int i = 0; i < numCourses; i++)
        if (inDegree[i] == 0) q.push(i);
    vector<int> result;
    while (!q.empty()) {
        int node = q.front(); q.pop();
        result.push_back(node);
        for (auto nb : adj[node])
            if (--inDegree[nb] == 0) q.push(nb);
    }
    return result.size() == numCourses ? result : vector<int>{};
}
// TC: O(N + E), SC: O(N)
```

---

## 📌 L24 — Find Eventual Safe States — BFS / Topo Sort (G-25)

```
Same problem as L19, solved the Kahn's way this time.

KEY IDEA: REVERSE every edge in the graph first. A node that only leads
to terminal nodes in the original graph becomes reachable FROM terminal
nodes in the reversed graph. Terminal nodes (out-degree 0 originally)
become in-degree-0 nodes in the reversed graph — perfect Kahn's seeds.
Run Kahn's on the reversed graph; every node that gets processed is
SAFE. Sort the result at the end.
```

```cpp
vector<int> eventualSafeNodes(int n, vector<vector<int>>& graph) {
    vector<int> adjRev[n], inDegree(n, 0);
    for (int u = 0; u < n; u++)
        for (auto v : graph[u]) {
            adjRev[v].push_back(u);      // reverse the edge
            inDegree[u]++;               // in-degree in the REVERSED graph
        }
    queue<int> q;
    for (int i = 0; i < n; i++)
        if (inDegree[i] == 0) q.push(i);
    vector<int> safe(n, 0);
    while (!q.empty()) {
        int node = q.front(); q.pop();
        safe[node] = 1;
        for (auto nb : adjRev[node])
            if (--inDegree[nb] == 0) q.push(nb);
    }
    vector<int> result;
    for (int i = 0; i < n; i++) if (safe[i]) result.push_back(i);
    return result;                       // sorted since i goes 0..n-1
}
// TC: O(N + E), SC: O(N)
```

---

## 📌 L25 — Alien Dictionary (G-26)

```
Given N words from an alien language using the first K letters of the
alphabet, sorted according to the ALIEN order, figure out that order.

KEY IDEA: compare each pair of ADJACENT words in the list. The first
position where their characters differ tells you one ordering
constraint: that char in word[i] comes before that char in word[i+1] →
add a directed edge. Once all K characters and their constraint edges
are built, topologically sort the K-node graph (Kahn's or DFS) — that
ordering IS the alien alphabet.
```

```cpp
string findOrder(vector<string>& words, int k) {
    vector<int> adj[k];
    for (int i = 0; i < words.size() - 1; i++) {
        string w1 = words[i], w2 = words[i + 1];
        int len = min(w1.size(), w2.size());
        for (int j = 0; j < len; j++) {
            if (w1[j] != w2[j]) {
                adj[w1[j] - 'a'].push_back(w2[j] - 'a');
                break;                    // only the FIRST differing char matters
            }
        }
    }
    // Standard Kahn's topo sort on these k nodes
    vector<int> inDegree(k, 0);
    for (int i = 0; i < k; i++)
        for (auto nb : adj[i]) inDegree[nb]++;
    queue<int> q;
    for (int i = 0; i < k; i++) if (inDegree[i] == 0) q.push(i);
    string result;
    while (!q.empty()) {
        int node = q.front(); q.pop();
        result += char(node + 'a');
        for (auto nb : adj[node])
            if (--inDegree[nb] == 0) q.push(nb);
    }
    return result;
}
// TC: O(N * len + K), SC: O(K)
```
**GOTCHA:** if `w1` is longer than `w2` AND `w1` is a prefix of `w2` reversed (e.g. `["abc", "ab"]` — a longer word appearing BEFORE its own prefix), the dictionary is invalid — no valid ordering exists. Worth a special check in a full solution.


---

## 📌 L26 — Shortest Path in a Directed Acyclic Graph (G-27)

```
Weighted DAG, source is always node 0. Find shortest distance from
source to every node.

KEY IDEA: combine topo sort with EDGE RELAXATION. Because it's a DAG,
a topo order guarantees that by the time you process node u, every
possible predecessor of u has ALREADY been finalized — so you can
process nodes in topo order and "relax" each outgoing edge exactly
once, and every distance is correct by the time you reach that node.
(Relaxing an edge u→v with weight w means: if dist[u] + w < dist[v],
update dist[v].)
```

```cpp
void topoDFS(int node, vector<int>& vis, stack<int>& st, vector<pair<int,int>> adj[]) {
    vis[node] = 1;
    for (auto [neighbor, wt] : adj[node])
        if (!vis[neighbor]) topoDFS(neighbor, vis, st, adj);
    st.push(node);
}
vector<int> shortestPath(int n, vector<pair<int,int>> adj[]) {
    vector<int> vis(n, 0);
    stack<int> st;
    for (int i = 0; i < n; i++) if (!vis[i]) topoDFS(i, vis, st, adj);

    vector<int> dist(n, INT_MAX);
    dist[0] = 0;
    while (!st.empty()) {
        int node = st.top(); st.pop();
        if (dist[node] != INT_MAX) {
            for (auto [neighbor, wt] : adj[node])
                if (dist[node] + wt < dist[neighbor])
                    dist[neighbor] = dist[node] + wt;
        }
    }
    for (int i = 0; i < n; i++) if (dist[i] == INT_MAX) dist[i] = -1;
    return dist;
}
// TC: O(N + E) — no PQ needed, topo order alone guarantees correctness!
// SC: O(N)
```

---

## 📌 L27 — Shortest Path in Undirected Graph, Unit Weights (G-28)

```
All edges weigh exactly 1. Plain BFS already finds shortest paths
correctly in this case — level number IS the distance — no Dijkstra
needed. Only reach for Dijkstra/PQ when weights are non-uniform.
```

```cpp
vector<int> shortestPath(vector<vector<int>>& edges, int n, int m, int src) {
    vector<int> adj[n];
    for (auto& e : edges) { adj[e[0]].push_back(e[1]); adj[e[1]].push_back(e[0]); }

    vector<int> dist(n, INT_MAX);
    dist[src] = 0;
    queue<int> q;
    q.push(src);
    while (!q.empty()) {
        int node = q.front(); q.pop();
        for (auto neighbor : adj[node])
            if (dist[node] + 1 < dist[neighbor]) {
                dist[neighbor] = dist[node] + 1;
                q.push(neighbor);
            }
    }
    for (auto& d : dist) if (d == INT_MAX) d = -1;
    return dist;
}
// TC: O(N + 2E), SC: O(N)
```

---

## 📌 L28 — Word Ladder I (G-29)

```
Transform beginWord → endWord, changing exactly one letter per step,
every intermediate word must exist in wordList. Find the SHORTEST
transformation length (LC 127).

KEY IDEA: this is BFS on an IMPLICIT graph — each "node" is a word, and
an edge exists between two words that differ by exactly one letter. You
don't build this graph explicitly (too expensive); instead, from the
current word, try changing EVERY position to EVERY letter a-z and check
if the result is in the (hash-setted) word list.
```

```cpp
int ladderLength(string beginWord, string endWord, vector<string>& wordList) {
    unordered_set<string> words(wordList.begin(), wordList.end());
    queue<pair<string,int>> q;
    q.push({beginWord, 1});
    words.erase(beginWord);
    while (!q.empty()) {
        auto [word, steps] = q.front(); q.pop();
        if (word == endWord) return steps;
        for (int i = 0; i < word.size(); i++) {
            char original = word[i];
            for (char c = 'a'; c <= 'z'; c++) {
                word[i] = c;
                if (words.count(word)) {
                    words.erase(word);   // consume it — never revisit
                    q.push({word, steps + 1});
                }
            }
            word[i] = original;
        }
    }
    return 0;                            // target unreachable
}
// TC: O(N * L * 26) where N = wordList size, L = word length. SC: O(N)
```
**KEY:** Erasing a word from the set the moment it's queued acts as the "visited" check — a word can only ever contribute one edge into the BFS.

---

## 📌 L29 — Word Ladder II (G-30, G-31)

```
Same setup as Word Ladder I, but return EVERY shortest transformation
sequence, not just the length (LC 126) — one of the hardest BFS problems
in the playlist.

INTERVIEW-SAFE APPROACH (level-by-level BFS storing full paths):
  - BFS queue holds entire PATHS (vector<string>), not just words.
  - Process one whole LEVEL at a time. Within a level, collect every
    word used by ANY path completed at that level into a temporary
    "used this level" set, and erase all of them from the master word
    set only AFTER the whole level finishes.
      (Erasing mid-level would wrongly block a sibling path in the SAME
       level from reusing that word — sibling paths must be allowed to
       share intermediate words as long as they're still same-distance.)
  - Stop as soon as any path reaches endWord — every path of that exact
    length is a valid shortest sequence.

LEETCODE-SAFE OPTIMIZATION (2-step, for passing strict TLE limits —
NOT how you'd explain it in an interview): 
  Step 1 — run Word-Ladder-I-style BFS once, but instead of stopping at
  the first hit, record each word's BFS LEVEL and, for every word,
  which earlier words could have produced it (its "predecessors").
  Step 2 — DFS/backtrack from endWord to beginWord following only
  predecessor links whose level is exactly one less — this reconstructs
  every shortest path without the memory overhead of storing full paths
  in the BFS queue itself.
```

```cpp
vector<vector<string>> findLadders(string beginWord, string endWord,
                                    vector<string>& wordList) {
    unordered_set<string> words(wordList.begin(), wordList.end());
    if (!words.count(endWord)) return {};
    words.erase(beginWord);              // block immediate self-revisit, same as Word Ladder I

    queue<vector<string>> q;
    q.push({beginWord});
    vector<vector<string>> ans;

    while (!q.empty() && ans.empty()) {
        int sz = q.size();
        vector<string> newlyUsed;                       // gather this whole level
        for (int i = 0; i < sz; i++) {
            vector<string> path = q.front(); q.pop();
            string word = path.back();
            if (word == endWord) { ans.push_back(path); continue; }  // done — don't expand past it
            for (int j = 0; j < word.size(); j++) {
                char original = word[j];
                for (char c = 'a'; c <= 'z'; c++) {
                    word[j] = c;
                    if (words.count(word)) {
                        path.push_back(word);
                        q.push(path);
                        newlyUsed.push_back(word);
                        path.pop_back();
                    }
                }
                word[j] = original;
            }
        }
        for (auto& w : newlyUsed) words.erase(w);       // erase AFTER full level
    }
    return ans;
}
// TC: exponential in the worst case (many equal-length paths) — expected/accepted
//     for interviews; see G-31 note above for the LeetCode-passing variant.
```


---

## 📌 L30 — Dijkstra's Algorithm — Priority Queue (G-32)

```
THE single-source shortest path algorithm for graphs with NON-NEGATIVE
edge weights. Given a source, find the shortest distance to every node.

ALGORITHM: greedy + relaxation. Keep a min-priority-queue of
{distance, node}, always pull out the CURRENT smallest known distance
first, and relax all its outgoing edges. Because you always expand the
globally-closest unfinalized node next, once a node is popped its
distance is guaranteed final (this greedy property is WHY Dijkstra
requires non-negative weights — a negative edge could still improve an
already-popped/finalized node later, breaking the guarantee).
```

```cpp
vector<int> dijkstra(int n, vector<pair<int,int>> adj[], int src) {
    priority_queue<pair<int,int>, vector<pair<int,int>>, greater<>> pq;  // min-heap
    vector<int> dist(n, INT_MAX);
    dist[src] = 0;
    pq.push({0, src});                   // {distance, node}
    while (!pq.empty()) {
        auto [d, node] = pq.top(); pq.pop();
        if (d > dist[node]) continue;    // stale entry — a better one was already processed
        for (auto [neighbor, wt] : adj[node]) {
            if (d + wt < dist[neighbor]) {
                dist[neighbor] = d + wt;
                pq.push({dist[neighbor], neighbor});
            }
        }
    }
    return dist;
}
// TC: O(E log V), SC: O(N)
```

---

## 📌 L31 — Dijkstra's Algorithm — Set (G-33)

```
Same algorithm, using set<pair<int,int>> instead of a priority_queue.
ADVANTAGE OVER PQ: a set lets you ERASE the stale (old-distance, node)
entry the moment you find a better distance for that node — a PQ can't
remove arbitrary elements, so it silently accumulates stale entries
that just get skipped later. The set keeps its size tighter, which
matters on dense graphs with many relaxations.
```

```cpp
vector<int> dijkstraSet(int n, vector<pair<int,int>> adj[], int src) {
    set<pair<int,int>> st;               // {distance, node}, auto-sorted ascending
    vector<int> dist(n, INT_MAX);
    dist[src] = 0;
    st.insert({0, src});
    while (!st.empty()) {
        auto [d, node] = *st.begin();
        st.erase(st.begin());            // smallest distance, like PQ's top()
        for (auto [neighbor, wt] : adj[node]) {
            if (d + wt < dist[neighbor]) {
                if (dist[neighbor] != INT_MAX)
                    st.erase({dist[neighbor], neighbor});  // remove the STALE entry
                dist[neighbor] = d + wt;
                st.insert({dist[neighbor], neighbor});
            }
        }
    }
    return dist;
}
// TC: O(E log V), SC: O(N)
```

---

## 📌 L32 — Dijkstra: Why PQ/Set (Not Plain Queue) + Complexity (G-34)

```
Q: A plain queue also reaches every node — why isn't that good enough?
A: A plain queue processes nodes in INSERTION order, not distance order.
   A node can get pushed multiple times via different-length paths
   before its truly shortest path arrives, and each push does wasted
   relaxation work down the line. PQ/set always expand the GLOBALLY
   nearest unfinalized node next, which is what guarantees each node is
   relaxed via its optimal predecessor and avoids that wasted re-work.

TIME COMPLEXITY DERIVATION — O(E log V):
  Every edge can trigger at most one push into the PQ/set → up to E
  pushes/pops total. Each push/pop on a PQ/set of up to V elements costs
  O(log V). Total: O(E log V).

INTUITION FOR THE ALGORITHM: it's a controlled BFS where "level" is
replaced by "running distance" — instead of expanding strictly ring by
ring, you always expand whichever frontier node currently has the
smallest tentative distance, which is exactly what a min-heap gives you
for free.
```

---

## 📌 L33 — Print Shortest Path Using Dijkstra's Algorithm (G-35)

```
Same as Dijkstra, but return the actual PATH, not just the distance.
KEY IDEA: maintain a parent[] array. Every time you relax an edge
(update dist[neighbor]), also set parent[neighbor] = node. At the end,
backtrack from destination to source via parent[], then reverse.
```

```cpp
vector<int> shortestPath(int n, int m, vector<vector<int>>& edges) {
    vector<pair<int,int>> adj[n + 1];
    for (auto& e : edges) {
        adj[e[0]].push_back({e[1], e[2]});
        adj[e[1]].push_back({e[0], e[2]});
    }
    vector<int> dist(n + 1, INT_MAX), parent(n + 1);
    for (int i = 1; i <= n; i++) parent[i] = i;    // self = "no parent yet"
    dist[1] = 0;
    priority_queue<pair<int,int>, vector<pair<int,int>>, greater<>> pq;
    pq.push({0, 1});
    while (!pq.empty()) {
        auto [d, node] = pq.top(); pq.pop();
        for (auto [neighbor, wt] : adj[node]) {
            if (d + wt < dist[neighbor]) {
                dist[neighbor] = d + wt;
                parent[neighbor] = node;
                pq.push({dist[neighbor], neighbor});
            }
        }
    }
    if (dist[n] == INT_MAX) return {-1};
    vector<int> path;
    int node = n;
    while (parent[node] != node) { path.push_back(node); node = parent[node]; }
    path.push_back(1);
    reverse(path.begin(), path.end());
    return path;
}
// TC: O(E log V), SC: O(N)
```


---

## 📌 L34 — Shortest Distance in a Binary Maze (G-36)

```
Grid of 0/1, move 4-directionally only through 1-cells, every step costs
1. Find shortest distance from source to destination.
Since every move costs exactly 1, this is really L27's "unit weight"
case again — plain BFS suffices, no PQ required.
```

```cpp
int shortestPathBinaryMatrix(vector<vector<int>>& grid, pair<int,int> src, pair<int,int> dest) {
    int n = grid.size(), m = grid[0].size();
    vector<vector<int>> dist(n, vector<int>(m, INT_MAX));
    dist[src.first][src.second] = 0;
    queue<pair<int, pair<int,int>>> q;   // {distance, {row, col}}
    q.push({0, src});
    int delRow[] = {-1, 0, 1, 0}, delCol[] = {0, 1, 0, -1};
    while (!q.empty()) {
        auto [d, cell] = q.front(); q.pop();
        auto [r, c] = cell;
        for (int i = 0; i < 4; i++) {
            int nr = r + delRow[i], nc = c + delCol[i];
            if (nr >= 0 && nr < n && nc >= 0 && nc < m &&
                grid[nr][nc] == 1 && d + 1 < dist[nr][nc]) {
                dist[nr][nc] = d + 1;
                q.push({d + 1, {nr, nc}});
            }
        }
    }
    int ans = dist[dest.first][dest.second];
    return ans == INT_MAX ? -1 : ans;
}
// TC: O(N*M), SC: O(N*M)
```

---

## 📌 L35 — Path With Minimum Effort (G-37)

```
Grid of heights, 4-directional moves. A route's "effort" = the MAXIMUM
absolute height difference between any two consecutive cells along it
(not the sum). Minimize that maximum over all routes to the destination.

KEY IDEA — DIJKSTRA WITH A DIFFERENT "DISTANCE": instead of
dist[neighbor] = dist[node] + weight, define effort[neighbor] =
max(effort[node], |height[node] - height[neighbor]|), and relax exactly
like Dijkstra using a min-PQ ordered by that effort value. This "minimax
path" pattern shows up any time the cost of a path is defined by its
worst single edge instead of a running sum.
```

```cpp
int minimumEffortPath(vector<vector<int>>& heights) {
    int n = heights.size(), m = heights[0].size();
    vector<vector<int>> effort(n, vector<int>(m, INT_MAX));
    priority_queue<vector<int>, vector<vector<int>>, greater<>> pq;  // {effort, row, col}
    effort[0][0] = 0;
    pq.push({0, 0, 0});
    int delRow[] = {-1, 0, 1, 0}, delCol[] = {0, 1, 0, -1};
    while (!pq.empty()) {
        auto top = pq.top(); pq.pop();
        int e = top[0], r = top[1], c = top[2];
        if (r == n - 1 && c == m - 1) return e;
        for (int i = 0; i < 4; i++) {
            int nr = r + delRow[i], nc = c + delCol[i];
            if (nr >= 0 && nr < n && nc >= 0 && nc < m) {
                int newEffort = max(e, abs(heights[nr][nc] - heights[r][c]));
                if (newEffort < effort[nr][nc]) {
                    effort[nr][nc] = newEffort;
                    pq.push({newEffort, nr, nc});
                }
            }
        }
    }
    return 0;
}
// TC: O(N*M*log(N*M)), SC: O(N*M)
```

---

## 📌 L36 — Cheapest Flights Within K Stops (G-38)

```
Find cheapest price from src to dst using AT MOST K stops (K+1 edges).
Plain Dijkstra doesn't directly work here: the globally cheapest route
might use MORE than K stops, and Dijkstra's greedy "finalize on pop"
behavior would incorrectly lock in a cheap-but-too-many-stops path,
blocking a valid (slightly pricier but within-K) alternative.

FIX: carry the STOP COUNT as part of the state you push, and do NOT
prune based on a per-node `dist[]` "already finalized" check the way
normal Dijkstra does — a node reached with a higher cost but MORE
remaining stop budget can still lead to a valid within-K-stops answer
that a cheaper-but-over-budget path can't. The only cutoff is the stop
budget itself (`stops > k`); the min-PQ ordering by cost still
guarantees the FIRST time `dst` is popped, that's the true answer.
```

```cpp
int findCheapestPrice(int n, vector<vector<int>>& flights, int src, int dst, int k) {
    vector<pair<int,int>> adj[n];   // {to, price}
    for (auto& f : flights) adj[f[0]].push_back({f[1], f[2]});

    // PQ holds {cost, node, stopsUsed} — ordered by cost
    priority_queue<vector<int>, vector<vector<int>>, greater<>> pq;
    pq.push({0, src, 0});

    while (!pq.empty()) {
        auto top = pq.top(); pq.pop();
        int cost = top[0], node = top[1], stops = top[2];
        if (node == dst) return cost;      // first pop of dst = cheapest valid answer
        if (stops > k) continue;           // out of stop budget — dead end
        for (auto [neighbor, price] : adj[node])
            pq.push({cost + price, neighbor, stops + 1});
    }
    return -1;
}
// TC: O(E * K) in the worst case (each edge can be relaxed once per stop layer)
// SC: O(N * K) for the PQ in the worst case
```
**KEY:** Any shortest-path variant with an EXTRA constraint (max stops, max fuel, must-visit-node) usually needs the constraint folded into the "state" (node, extraDimension), not just the node — the state space grows, but each state is still processed via Dijkstra/BFS-style relaxation.

---

## 📌 L37 — Minimum Multiplications to Reach End (G-39)

```
Given `start`, target `end`, and an array of multipliers, repeatedly
pick any multiplier, multiply the current value, then take mod 1e5.
Find the MINIMUM number of multiplications to go from start to end.

KEY IDEA: this is BFS on an IMPLICIT graph where "nodes" are the
100,000 possible values (0 to 99999, since everything is mod 1e5), and
an edge exists from value v to (v * arr[i]) % 100000 for every
multiplier arr[i]. Since every transition costs exactly 1 step, plain
BFS finds the minimum step count.
```

```cpp
int minimumMultiplications(vector<int>& arr, int start, int end) {
    const int MOD = 100000;
    vector<int> dist(MOD, INT_MAX);
    dist[start] = 0;
    queue<pair<int,int>> q;              // {value, steps}
    q.push({start, 0});
    while (!q.empty()) {
        auto [val, steps] = q.front(); q.pop();
        if (val == end) return steps;
        for (int x : arr) {
            int newVal = (int)((1LL * val * x) % MOD);
            if (steps + 1 < dist[newVal]) {
                dist[newVal] = steps + 1;
                q.push({newVal, steps + 1});
            }
        }
    }
    return -1;
}
// TC: O(MOD * |arr|), SC: O(MOD)
```

---

## 📌 L38 — Number of Ways to Arrive at Destination (G-40)

```
Weighted undirected graph. Count the number of DISTINCT paths from node
0 to node n-1 that all achieve the SHORTEST possible travel time.

KEY IDEA: run Dijkstra as normal, but maintain a parallel `ways[]`
array. When relaxing an edge to `neighbor`:
  - if a STRICTLY SHORTER distance is found  → ways[neighbor] = ways[node]
                                                (start counting fresh)
  - if an EQUALLY SHORT distance is found    → ways[neighbor] += ways[node]
                                                (another equally-good route found)
```

```cpp
int countPaths(int n, vector<vector<int>>& roads) {
    const int MOD = 1e9 + 7;
    vector<pair<int,long long>> adj[n];
    for (auto& r : roads) {
        adj[r[0]].push_back({r[1], r[2]});
        adj[r[1]].push_back({r[0], r[2]});
    }
    vector<long long> dist(n, LLONG_MAX), ways(n, 0);
    dist[0] = 0; ways[0] = 1;
    priority_queue<pair<long long,int>, vector<pair<long long,int>>, greater<>> pq;
    pq.push({0, 0});
    while (!pq.empty()) {
        auto [d, node] = pq.top(); pq.pop();
        if (d > dist[node]) continue;
        for (auto [neighbor, wt] : adj[node]) {
            if (d + wt < dist[neighbor]) {
                dist[neighbor] = d + wt;
                ways[neighbor] = ways[node] % MOD;
                pq.push({dist[neighbor], neighbor});
            } else if (d + wt == dist[neighbor]) {
                ways[neighbor] = (ways[neighbor] + ways[node]) % MOD;
            }
        }
    }
    return ways[n - 1];
}
// TC: O(E log V), SC: O(N)
```


---

## 📌 L39 — Bellman-Ford Algorithm (G-41)

```
Also a single-source shortest path algorithm, but unlike Dijkstra it
WORKS WITH NEGATIVE EDGE WEIGHTS, and can DETECT negative weight cycles
(Dijkstra can't do either — negative edges break its greedy guarantee,
and a negative cycle would make Dijkstra loop trying to minimize
forever).

CONSTRAINT: only works on a DIRECTED graph. For an undirected graph,
convert each edge into two directed edges (u→v and v→u, same weight)
first.

ALGORITHM:
1. Relax ALL E edges, in any order, N−1 times total.
   (Why N−1? The longest possible SIMPLE path in an N-node graph has
   at most N−1 edges — that many full passes guarantee every shortest
   path has been fully propagated.)
2. Do ONE more pass (the Nth). If ANY edge can still be relaxed
   (distance still improves), a negative weight cycle exists.
```

```cpp
vector<int> bellmanFord(int n, vector<vector<int>>& edges, int src) {
    vector<long long> dist(n, LLONG_MAX);
    dist[src] = 0;
    for (int i = 0; i < n - 1; i++) {
        for (auto& e : edges) {
            int u = e[0], v = e[1], wt = e[2];
            if (dist[u] != LLONG_MAX && dist[u] + wt < dist[v])
                dist[v] = dist[u] + wt;
        }
    }
    // Nth pass — if anything still relaxes, negative cycle exists
    for (auto& e : edges) {
        int u = e[0], v = e[1], wt = e[2];
        if (dist[u] != LLONG_MAX && dist[u] + wt < dist[v])
            return {-1};                 // negative cycle detected
    }
    vector<int> result(dist.begin(), dist.end());
    return result;
}
// TC: O(V * E) — much slower than Dijkstra's O(E log V), but handles
//     negative weights, which Dijkstra fundamentally cannot.
// SC: O(N)
```

---

## 📌 L40 — Floyd-Warshall Algorithm (G-42)

```
MULTI-source shortest path — finds shortest distance between EVERY pair
of nodes, not just from one source. Works on directed or undirected
(convert undirected to 2 directed edges first), and can also detect
negative cycles (a node whose distance-to-itself becomes negative after
running the algorithm sits on one).

CORE IDEA: "go via every possible intermediate vertex." For every
candidate intermediate node `via`, check if routing through it improves
the direct dist[i][j] for every pair (i, j). Do this for all `via` in
sequence — by the time all N vertices have been tried as an
intermediate, every pair holds its true shortest distance.

CRITICAL ORDER: the `via` loop MUST be the OUTERMOST loop, not i or j —
this is what makes the DP correctness argument hold (each layer only
depends on results already finalized by the previous layer).
```

```cpp
void floydWarshall(vector<vector<int>>& dist) {   // dist[i][j] pre-filled, INF where no edge
    int n = dist.size();
    for (int via = 0; via < n; via++) {
        for (int i = 0; i < n; i++) {
            for (int j = 0; j < n; j++) {
                if (dist[i][via] < INT_MAX && dist[via][j] < INT_MAX)
                    dist[i][j] = min(dist[i][j], dist[i][via] + dist[via][j]);
            }
        }
    }
    // Negative cycle check: any dist[i][i] that became negative
    for (int i = 0; i < n; i++)
        if (dist[i][i] < 0) { /* negative cycle exists */ }
}
// TC: O(N^3), SC: O(N^2) — the N x N distance matrix itself
```

---

## 📌 L41 — City With the Smallest Number of Neighbours at a Threshold Distance (G-43)

```
Weighted undirected graph. For every city, count how many other cities
are reachable within `distanceThreshold`. Return the city with the
FEWEST such neighbors — ties broken by picking the LARGER city number.

Straightforward APPLICATION of Floyd-Warshall: since you need
all-pairs shortest distances anyway (every city as a potential source),
run Floyd-Warshall once, then for each city count how many entries in
its row are ≤ threshold (excluding itself), and scan for the minimum
count / largest tie-breaking index.
```

```cpp
int findTheCity(int n, vector<vector<int>>& edges, int distanceThreshold) {
    vector<vector<int>> dist(n, vector<int>(n, INT_MAX / 2));
    for (int i = 0; i < n; i++) dist[i][i] = 0;
    for (auto& e : edges) {
        dist[e[0]][e[1]] = e[2];
        dist[e[1]][e[0]] = e[2];
    }
    for (int via = 0; via < n; via++)
        for (int i = 0; i < n; i++)
            for (int j = 0; j < n; j++)
                dist[i][j] = min(dist[i][j], dist[i][via] + dist[via][j]);

    int bestCity = -1, minCount = INT_MAX;
    for (int city = 0; city < n; city++) {
        int count = 0;
        for (int other = 0; other < n; other++)
            if (other != city && dist[city][other] <= distanceThreshold) count++;
        if (count <= minCount) { minCount = count; bestCity = city; }  // "<=" keeps LARGER index on ties
    }
    return bestCity;
}
// TC: O(N^3), SC: O(N^2)
```


---

## 📌 L42 — Minimum Spanning Tree — Theory (G-44)

```
SPANNING TREE: given a connected undirected graph of N nodes, a spanning
tree is a SUBSET of edges such that:
  - exactly N nodes and N−1 edges remain,
  - every node is still reachable from every other node.
A single graph can have MULTIPLE valid spanning trees.

MINIMUM SPANNING TREE (MST): the spanning tree whose edge weights sum
to the smallest possible total, among all spanning trees of the graph.

Two classic MST algorithms, both GREEDY: Prim's (grow one tree outward,
node by node) and Kruskal's (sort all edges, add greedily via
Disjoint Set — see L44-L45).
```

---

## 📌 L43 — Prim's Algorithm (G-45)

```
Grow the MST as a single connected tree, one edge at a time, always
picking the SMALLEST-weight edge that connects the CURRENT tree to a
new (not-yet-included) node.

STATE NEEDED:
  - a min-priority-queue of {weight, node, parent}
  - a visited[] array (node included in MST yet?)
  - running sum + an edge list if you need to print the MST itself
```

```cpp
int spanningTree(int n, vector<pair<int,int>> adj[]) {
    priority_queue<pair<int,int>, vector<pair<int,int>>, greater<>> pq;  // {wt, node}
    vector<int> vis(n, 0);
    pq.push({0, 0});                     // start arbitrarily from node 0
    int sum = 0;
    while (!pq.empty()) {
        auto [wt, node] = pq.top(); pq.pop();
        if (vis[node]) continue;         // already part of MST — skip
        vis[node] = 1;
        sum += wt;
        for (auto [neighbor, edgeWt] : adj[node])
            if (!vis[neighbor]) pq.push({edgeWt, neighbor});
    }
    return sum;
}
// TC: O(E log E) for the heap operations, SC: O(N + E)
```
**KEY:** Prim's pushes a neighbor into the PQ every time it's reachable from the growing tree — possibly multiple times at different weights. The `if (vis[node]) continue;` guard at pop-time is what discards the stale, heavier duplicates cheaply instead of trying to prevent them at push-time.

---

## 📌 L44 — Disjoint Set: Union by Rank / Size + Path Compression (G-46)

```
PROBLEM DSU SOLVES: "do nodes u and v belong to the same component?" —
answerable via a DFS/BFS in O(N), but Disjoint Set answers it in
NEAR-O(1) amortized. Especially suited to DYNAMIC graphs where edges
keep getting ADDED over time and you need fast repeated queries
in between (a plain traversal would have to rerun from scratch).

TWO CORE OPERATIONS:
  findUltimateParent(node) → the representative/"boss" of node's component
  union(u, v)              → merge u's component and v's component

PATH COMPRESSION: while finding the ultimate parent, rewire every node
visited along the way to point DIRECTLY at the ultimate parent. Future
lookups for those nodes become O(1).

UNION BY RANK: track an approximate tree-height ("rank") per component.
When merging two components, attach the SHORTER tree under the TALLER
tree's root — keeps the overall structure flat.

UNION BY SIZE: alternative to rank — track component SIZE instead, and
attach the SMALLER component under the LARGER one's root. Equally valid;
pick one, don't mix rank and size logic together.
```

```cpp
class DisjointSet {
    vector<int> rank_, parent, size_;
public:
    DisjointSet(int n) {
        rank_.resize(n + 1, 0);
        size_.resize(n + 1, 1);
        parent.resize(n + 1);
        for (int i = 0; i <= n; i++) parent[i] = i;
    }
    int findUPar(int node) {
        if (node == parent[node]) return node;
        return parent[node] = findUPar(parent[node]);   // PATH COMPRESSION
    }
    int size(int node) { return size_[findUPar(node)]; }  // component size, given ANY member node
    void unionByRank(int u, int v) {
        int ulp_u = findUPar(u), ulp_v = findUPar(v);
        if (ulp_u == ulp_v) return;
        if (rank_[ulp_u] < rank_[ulp_v]) parent[ulp_u] = ulp_v;
        else if (rank_[ulp_v] < rank_[ulp_u]) parent[ulp_v] = ulp_u;
        else { parent[ulp_v] = ulp_u; rank_[ulp_u]++; }
    }
    void unionBySize(int u, int v) {
        int ulp_u = findUPar(u), ulp_v = findUPar(v);
        if (ulp_u == ulp_v) return;
        if (size_[ulp_u] < size_[ulp_v]) { parent[ulp_u] = ulp_v; size_[ulp_v] += size_[ulp_u]; }
        else { parent[ulp_v] = ulp_u; size_[ulp_u] += size_[ulp_v]; }
    }
};
// TC: O(4α) ≈ O(1) amortized per operation (α = inverse Ackermann, grows
//     so slowly it's a constant for all practical N). SC: O(N)
```
**MEMORY AID:** DFS/BFS answers "are u, v connected?" by re-walking the whole component every time — O(N) per query. DSU answers the same question by comparing two O(1) parent-lookups — the entire point of the data structure is trading a one-time union cost for near-instant future queries.

---

## 📌 L45 — Kruskal's Algorithm (G-47)

```
Alternative MST algorithm — EDGE-CENTRIC instead of Prim's node-centric
growth.

ALGORITHM:
1. Sort ALL edges by weight, ascending.
2. Walk the sorted edges one by one. For edge (u, v, wt): if u and v are
   ALREADY in the same DSU component, adding this edge would create a
   cycle — skip it. Otherwise, union them and add wt to the MST sum.
3. Stop once N−1 edges have been added (or just finish the list).
```

```cpp
int kruskalsMST(int n, vector<vector<int>>& edges) {   // edges[i] = {wt, u, v}
    sort(edges.begin(), edges.end());
    DisjointSet ds(n);
    int mstWt = 0;
    for (auto& e : edges) {
        int wt = e[0], u = e[1], v = e[2];
        if (ds.findUPar(u) != ds.findUPar(v)) {
            mstWt += wt;
            ds.unionBySize(u, v);
        }
    }
    return mstWt;
}
// TC: O(E log E) for the sort + O(E * 4α) for DSU ops, SC: O(N + E)
```
**KEY:** Prim's vs Kruskal's — Prim's grows ONE tree outward and needs adjacency lists + a PQ; Kruskal's works directly off a flat EDGE LIST + DSU and doesn't care about connectivity structure while sorting. Prefer Kruskal's when the input is naturally an edge list (or you also need DSU for a follow-up query); Prim's is more natural when you already have an adjacency list.


---

## 📌 L46 — Number of Provinces — Disjoint Set (G-48)

```
Same problem as L6, solved with DSU instead of BFS/DFS — good drill for
recognizing "count components" as a DSU-shaped problem, not just a
traversal-shaped one.
```

```cpp
int numProvinces(vector<vector<int>> adjMat, int n) {
    DisjointSet ds(n);
    for (int i = 0; i < n; i++)
        for (int j = 0; j < n; j++)
            if (adjMat[i][j] == 1) ds.unionBySize(i, j);
    int count = 0;
    for (int i = 0; i < n; i++)
        if (ds.findUPar(i) == i) count++;   // node IS its own ultimate parent → new component
    return count;
}
// TC: ~O(N^2 * 4α), SC: O(N)
```

---

## 📌 L47 — Number of Operations to Make Network Connected (G-49)

```
Given a graph with `n` computers and a list of existing cables, you may
UNPLUG any one cable and use it to connect any two computers instead.
Find the minimum operations to make the whole network connected (-1 if
impossible).

KEY IDEA: 
  - If total edges < n − 1, it's IMPOSSIBLE (not enough cable to even
    theoretically span n nodes) — return -1.
  - Otherwise: union everything with DSU. Redundant edges (both
    endpoints already in the same component when you try to union them)
    are exactly the "spare cables" you're free to relocate. Count of
    components after all unions = c. You need exactly (c − 1) extra
    cables to connect c components into 1 — and you're guaranteed to
    have at least that many spares whenever edges ≥ n − 1.
```

```cpp
int makeConnected(int n, vector<vector<int>>& connections) {
    if (connections.size() < n - 1) return -1;
    DisjointSet ds(n);
    for (auto& c : connections) ds.unionBySize(c[0], c[1]);
    int components = 0;
    for (int i = 0; i < n; i++)
        if (ds.findUPar(i) == i) components++;
    return components - 1;
}
// TC: O(E * 4α + N), SC: O(N)
```

---

## 📌 L48 — Accounts Merge (G-50)

```
Each account = [name, email1, email2, ...]. Two accounts belong to the
SAME person if they share ANY email. Merge all accounts per person,
emails sorted, name first.

KEY IDEA: DSU over ACCOUNT INDICES (not emails directly). For each
account, union its index with the index of any other account that
already "owns" one of its emails (track via a hash map: email → first
account index seen). After all unions, group emails by
findUPar(accountIndex), sort each group, and prepend the name.
```

```cpp
vector<vector<string>> accountsMerge(vector<vector<string>>& accounts) {
    int n = accounts.size();
    DisjointSet ds(n);
    unordered_map<string, int> emailToAccount;
    for (int i = 0; i < n; i++) {
        for (int j = 1; j < accounts[i].size(); j++) {
            string email = accounts[i][j];
            if (emailToAccount.count(email))
                ds.unionBySize(i, emailToAccount[email]);
            else
                emailToAccount[email] = i;
        }
    }
    vector<set<string>> mergedEmails(n);
    for (auto& [email, idx] : emailToAccount)
        mergedEmails[ds.findUPar(idx)].insert(email);

    vector<vector<string>> result;
    for (int i = 0; i < n; i++) {
        if (mergedEmails[i].empty()) continue;
        vector<string> temp = {accounts[i][0]};
        temp.insert(temp.end(), mergedEmails[i].begin(), mergedEmails[i].end());
        result.push_back(temp);
    }
    return result;
}
// TC: ~O(N log N) dominated by sorting emails via the set, SC: O(N)
```

---

## 📌 L49 — Number of Islands II — Online Queries (G-51)

```
Grid starts entirely water. Queries arrive ONE AT A TIME, each turning
one cell into land; after EVERY query, report the CURRENT total island
count. ("Online" = must answer incrementally, can't see future queries.)

KEY IDEA: DSU built for a DYNAMIC graph — this is the textbook use case
mentioned back in L44. On each query: mark the cell as land, then union
it with any of its already-land 4-directional neighbors. Track a running
`count` of components: it starts at (previous count + 1) for the new
land cell, then decreases by 1 for every successful (non-redundant)
union performed against a neighbor.
```

```cpp
vector<int> numOfIslands(int n, int m, vector<vector<int>>& operators) {
    DisjointSet ds(n * m);
    vector<vector<int>> vis(n, vector<int>(m, 0));
    int delRow[] = {-1, 0, 1, 0}, delCol[] = {0, 1, 0, -1};
    int count = 0;
    vector<int> result;
    for (auto& op : operators) {
        int row = op[0], col = op[1];
        if (vis[row][col]) { result.push_back(count); continue; }  // duplicate query
        vis[row][col] = 1;
        count++;
        for (int i = 0; i < 4; i++) {
            int nr = row + delRow[i], nc = col + delCol[i];
            if (nr >= 0 && nr < n && nc >= 0 && nc < m && vis[nr][nc]) {
                int node = row * m + col, adjNode = nr * m + nc;
                if (ds.findUPar(node) != ds.findUPar(adjNode)) {
                    count--;
                    ds.unionBySize(node, adjNode);
                }
            }
        }
        result.push_back(count);
    }
    return result;
}
// TC: O(Q * 4 * 4α) for Q queries, SC: O(N*M)
```
**KEY:** Flattening a 2D cell (row, col) into a 1D DSU index via `row * m + col` is the standard trick whenever DSU needs to operate over a grid.

---

## 📌 L50 — Making a Large Island (G-52)

```
N×N binary grid. You may flip AT MOST ONE 0 to a 1. Find the size of the
LARGEST possible connected group of 1's afterward.

KEY IDEA — two-pass:
  1. DSU/BFS every EXISTING island first, tagging each land cell with a
     component id and tracking each component's SIZE.
  2. For every 0-cell, look at its (up to 4) distinct neighboring
     component ids, sum their sizes + 1 (for the flipped cell itself)
     — using a SET of neighbor ids first avoids double-counting when
     two neighbor cells belong to the same island. Track the max over
     all 0-cells. If the grid is all 1's, the answer is simply N*N.
```

```cpp
int largestIsland(vector<vector<int>>& grid) {
    int n = grid.size();
    DisjointSet ds(n * n);
    int delRow[] = {-1, 0, 1, 0}, delCol[] = {0, 1, 0, -1};
    // Pass 1: union existing land
    for (int row = 0; row < n; row++)
        for (int col = 0; col < n; col++) {
            if (grid[row][col] == 0) continue;
            for (int i = 0; i < 4; i++) {
                int nr = row + delRow[i], nc = col + delCol[i];
                if (nr >= 0 && nr < n && nc >= 0 && nc < n && grid[nr][nc] == 1)
                    ds.unionBySize(row * n + col, nr * n + nc);
            }
        }
    // Pass 2: try flipping every 0
    int mx = 0;
    for (int row = 0; row < n; row++)
        for (int col = 0; col < n; col++) {
            if (grid[row][col] == 1) continue;
            set<int> uniqueComponents;
            for (int i = 0; i < 4; i++) {
                int nr = row + delRow[i], nc = col + delCol[i];
                if (nr >= 0 && nr < n && nc >= 0 && nc < n && grid[nr][nc] == 1)
                    uniqueComponents.insert(ds.findUPar(nr * n + nc));
            }
            int sizeTotal = 1;
            for (auto id : uniqueComponents) sizeTotal += ds.size(id);  // exposes size_[] via a getter
            mx = max(mx, sizeTotal);
        }
    // If the whole grid was already land, mx never got set — cover that case
    for (int cell = 0; cell < n * n; cell++) mx = max(mx, ds.size(ds.findUPar(cell)));
    return mx;
}
// TC: O(N^2 * 4α), SC: O(N^2)
```

---

## 📌 L51 — Most Stones Removed With Same Row or Column (G-53)

```
Given stones at (row, col) coordinates. A stone can be removed if it
shares a row OR column with some OTHER stone that is still standing.
Maximize the number of stones removed.

KEY INSIGHT: within any single connected group of stones (connected =
chained by shared rows/columns, transitively), you can ALWAYS remove
every stone except one — repeatedly remove leaf-like stones until a
single stone remains per component. So the answer is simply:
    (total stones) − (number of connected components)

KEY IDEA — DSU over ROW/COLUMN space, not stone-pair adjacency: union
each stone's row with its column directly (offset columns by +N to
keep them distinct from row indices in the same DSU array). Two stones
end up in the same DSU component automatically iff they're connected
through any chain of shared rows/columns — no need to explicitly find
or union stone-pairs.
```

```cpp
int removeStones(vector<vector<int>>& stones) {
    int n = stones.size();
    int maxRow = 0, maxCol = 0;
    for (auto& s : stones) { maxRow = max(maxRow, s[0]); maxCol = max(maxCol, s[1]); }
    DisjointSet ds(maxRow + maxCol + 1);
    for (auto& s : stones)
        ds.unionBySize(s[0], maxRow + 1 + s[1]);   // offset columns to avoid row/col index clashes

    set<int> uniqueComponents;
    for (auto& s : stones) uniqueComponents.insert(ds.findUPar(s[0]));
    return n - uniqueComponents.size();
}
// TC: O(N * 4α), SC: O(maxRow + maxCol)
```


---

## 📌 L52 — Strongly Connected Components — Kosaraju's Algorithm (G-54)

```
SCCs are only meaningful on DIRECTED graphs. A strongly connected
component = a maximal group of nodes where EVERY node can reach EVERY
other node in the group (both directions, possibly via a longer path).

KOSARAJU'S ALGORITHM — 3 steps:
1. Do a normal DFS over the whole graph, pushing each node onto a stack
   by FINISH TIME — exactly like Topological Sort's DFS (L20), even
   though this graph may have cycles (the ordering is still well
   defined by finish time).
2. TRANSPOSE the graph — reverse every edge.
3. Pop nodes off the stack one at a time. For each still-unvisited node,
   DFS on the TRANSPOSED graph — every node reached in that single DFS
   call is exactly one SCC.

WHY IT WORKS (intuition): reversing all edges preserves "mutually
reachable" pairs but destroys reachability that only went ONE way
between different SCCs. Popping in finish-time order guarantees you
always start a new DFS from a node that can't accidentally leak into
an SCC that should have already been fully explored.
```

```cpp
void dfs1(int node, vector<int>& vis, vector<int> adj[], stack<int>& st) {
    vis[node] = 1;
    for (auto neighbor : adj[node]) if (!vis[neighbor]) dfs1(neighbor, vis, adj, st);
    st.push(node);
}
void dfs2(int node, vector<int>& vis, vector<int> adjT[]) {
    vis[node] = 1;
    for (auto neighbor : adjT[node]) if (!vis[neighbor]) dfs2(neighbor, vis, adjT);
}
int kosaraju(int n, vector<int> adj[]) {
    vector<int> vis(n, 0);
    stack<int> st;
    for (int i = 0; i < n; i++) if (!vis[i]) dfs1(i, vis, adj, st);

    vector<int> adjT[n];
    for (int i = 0; i < n; i++) {
        vis[i] = 0;
        for (auto neighbor : adj[i]) adjT[neighbor].push_back(i);   // reverse the edge
    }

    int sccCount = 0;
    while (!st.empty()) {
        int node = st.top(); st.pop();
        if (!vis[node]) { sccCount++; dfs2(node, vis, adjT); }
    }
    return sccCount;
}
// TC: O(N + E) for each of the 3 passes → O(N + E) overall, SC: O(N + E)
```

---

## 📌 L53 — Bridges in a Graph — Tarjan's Algorithm (G-55)

```
A BRIDGE is an edge whose removal INCREASES the number of connected
components (i.e. it's the sole connection between two otherwise-
separate parts of the graph).

ALGORITHM — DFS with two timestamp arrays:
  tin[node]  = the STEP at which this node was first discovered by DFS
  low[node]  = the LOWEST tin reachable from this node's subtree,
               INCLUDING via one back-edge to an ancestor (but not
               back through the direct parent edge you just came from)

BRIDGE CONDITION: edge (node → child) in the DFS tree is a bridge iff
    low[child] > tin[node]
i.e. the child's subtree has NO way back to `node` or anything above it
except through this exact edge — sever it and the subtree disconnects.
```

```cpp
int timer = 1;
void dfs(int node, int parent, vector<int>& vis, vector<int>& tin, vector<int>& low,
          vector<int> adj[], vector<vector<int>>& bridges) {
    vis[node] = 1;
    tin[node] = low[node] = timer++;
    for (auto neighbor : adj[node]) {
        if (neighbor == parent) continue;    // skip the exact edge we arrived through
        if (!vis[neighbor]) {
            dfs(neighbor, node, vis, tin, low, adj, bridges);
            low[node] = min(low[node], low[neighbor]);
            if (low[neighbor] > tin[node])
                bridges.push_back({node, neighbor});   // BRIDGE found
        } else {
            low[node] = min(low[node], tin[neighbor]);  // back-edge to an ancestor
        }
    }
}
vector<vector<int>> criticalConnections(int n, vector<int> adj[]) {
    vector<int> vis(n, 0), tin(n, -1), low(n, -1);
    vector<vector<int>> bridges;
    dfs(0, -1, vis, tin, low, adj, bridges);
    return bridges;
}
// TC: O(N + E), SC: O(N)
```
**GOTCHA:** skip the neighbor only when it's the PARENT NODE, not merely "already visited" — an already-visited neighbor that ISN'T the direct parent is exactly the back-edge that makes `low[]` meaningful.

---

## 📌 L54 — Articulation Points in a Graph (G-56)

```
An ARTICULATION POINT (cut vertex) is a NODE whose removal increases
the number of connected components — the vertex analog of a bridge.

Reuses the exact same tin[]/low[] machinery as L53, with two changes:
  - When computing low[node] from a neighbor, exclude BOTH the parent
    AND any already-VISITED node reached via a back-edge in the usual
    way (same as bridges).
  - CONDITION differs from bridges: node is an articulation point if
      (a) it is NOT the DFS root, and has some child with
          low[child] >= tin[node]   (note: >= here, not strictly > like
          bridges — because removing the NODE itself, not just one
          edge, is enough to cut off that child's subtree even if the
          child could otherwise reach back exactly to this node), OR
      (b) it IS the DFS root, and has MORE THAN ONE child in the DFS
          tree (a root with 2+ independent subtrees is only holding
          them together because it's the shared root — remove it and
          they fall apart into separate components).
```

```cpp
int timer = 1;
void dfs(int node, int parent, vector<int>& vis, vector<int>& tin, vector<int>& low,
          vector<int>& isArticulation, vector<int> adj[]) {
    vis[node] = 1;
    tin[node] = low[node] = timer++;
    int childCount = 0;
    for (auto neighbor : adj[node]) {
        if (neighbor == parent) continue;
        if (!vis[neighbor]) {
            dfs(neighbor, node, vis, tin, low, isArticulation, adj);
            low[node] = min(low[node], low[neighbor]);
            if (low[neighbor] >= tin[node] && parent != -1)
                isArticulation[node] = 1;
            childCount++;
        } else {
            low[node] = min(low[node], tin[neighbor]);
        }
    }
    if (parent == -1 && childCount > 1) isArticulation[node] = 1;  // root special case
}
vector<int> articulationPoints(int n, vector<int> adj[]) {
    vector<int> vis(n, 0), tin(n, -1), low(n, -1), isArticulation(n, 0);
    for (int i = 0; i < n; i++)
        if (!vis[i]) dfs(i, -1, vis, tin, low, isArticulation, adj);
    vector<int> result;
    for (int i = 0; i < n; i++) if (isArticulation[i]) result.push_back(i);
    return result;
}
// TC: O(N + E), SC: O(N)
```


---

## 📌 All Patterns — Quick Revision

```
GRAPH PATTERN CHEAT SHEET:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TRAVERSAL TYPE  → TECHNIQUE:
  BFS             → queue<int>, level-wise, mark visited AT PUSH time
  DFS             → recursion (implicit stack), goes deep before wide
  Multi-source BFS→ seed the queue with ALL sources before the loop starts
  Grid as graph   → each cell is a node, 4 or 8-directional delRow/delCol

PROBLEM → PATTERN:
  Connected components    → visited-array wrapper: loop 1..n, traverse if unvisited
  Number of provinces/    → same wrapper applied to grid or adjacency matrix
    islands
  Flood fill               → DFS/BFS from one cell, same-color 4-directional
  Rotten oranges / 0-1     → multi-source BFS, queue seeded with all sources
    matrix nearest cell
  Surrounded regions /     → DFS/BFS from the BOUNDARY first, mark safe,
    number of enclaves       flip/count everything left untouched
  Distinct islands         → DFS/BFS + store shape as coordinates RELATIVE
                              to the island's start cell, dedupe via a set
  Bipartite check           → 2-color via BFS/DFS; odd cycle ⇒ not bipartite
  Cycle, undirected         → BFS/DFS carrying {node, parent}; visited
                              neighbor ≠ parent ⇒ cycle
  Cycle, directed            → DFS with vis[] AND pathVis[] (recursion-stack
                              tracker); hit a pathVis node ⇒ cycle
  Cycle, directed (Kahn's)   → run Kahn's topo sort; result.size() < n ⇒ cycle
  Topological sort (DFS)     → DFS, push node to stack AFTER exploring
                              neighbors, then pop = topo order
  Topological sort (Kahn's)  → BFS by in-degree; push in-degree-0 nodes,
                              decrement neighbors as you pop
  Eventual safe states       → cycle-detection DFS w/ memo, OR reverse
                              graph + Kahn's from terminal (out-degree 0) nodes
  Course schedule I/II       → Kahn's topo sort on the prerequisite graph
  Alien dictionary            → build edges from first-differing chars of
                              adjacent words, then topo sort the K letters
  Shortest path, DAG          → topo sort + relax edges IN topo order
  Shortest path, unit weight  → plain BFS (level number = distance)
  Word ladder I/II             → BFS on an IMPLICIT graph (word ↔ word
                              differing by 1 letter); II needs level-batched
                              erase + path storage (or 2-pass CP trick)
  Dijkstra                     → PQ or set of {dist, node}, greedy relax;
                              FAILS on negative weights
  Print shortest path          → Dijkstra + parent[] array, backtrack & reverse
  Minimax path (min effort)    → Dijkstra where "distance" = max edge on path
  Path with extra constraint   → fold constraint into the STATE you push
    (K stops, etc.)              (node, stopsUsed) instead of just node
  Bellman-Ford                 → relax ALL edges N−1 times; Nth pass
                              detects negative cycles; handles negative weights
  Floyd-Warshall                → all-pairs; `via` loop OUTERMOST;
                              dist[i][i] < 0 ⇒ negative cycle
  MST                           → Prim's (grow tree, PQ) or Kruskal's
                              (sort edges, DSU, skip same-component)
  Disjoint Set / DSU            → findUPar + path compression + union by
                              rank/size; near-O(1) "same component?" queries;
                              ideal for DYNAMIC / online-query graphs
  DSU on a grid                  → flatten (row, col) → row*m + col
  DSU on constraint pairs         → union the CONSTRAINT dimensions
    (rows/cols, not stones)        directly (e.g. row i ↔ col j+offset),
                                    not the objects themselves
  Strongly connected components   → Kosaraju's: DFS finish-order stack →
                                    transpose graph → DFS again in that order
  Bridges                          → tin[]/low[]; bridge iff low[child] > tin[node]
  Articulation points              → same tin[]/low[], but low[child] >=
                                    tin[node] (non-root), or root with 2+
                                    DFS-tree children

ALGORITHM SELECTION GUIDE (shortest path):
  Unweighted / unit weights            → plain BFS
  DAG (weighted, no cycle)             → topo sort + relaxation
  Non-negative weights, general graph  → Dijkstra (PQ or set)
  Negative weights allowed              → Bellman-Ford
  Need negative-cycle DETECTION         → Bellman-Ford (single source) or
                                          Floyd-Warshall (all pairs)
  All-pairs shortest path               → Floyd-Warshall
  Extra constraint (stops/fuel/etc.)     → Dijkstra/BFS with constraint folded
                                          into the state, not just the node

C++ SPECIFIC TIPS:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Default to adjacency LIST (vector<int> adj[n+1]) — matrix is O(N^2), rarely worth it
Use vector<pair<int,int>> for weighted adjacency: {neighbor, weight}
priority_queue<pair<int,int>, vector<pair<int,int>>, greater<>> = MIN-heap
set<pair<int,int>> as a Dijkstra alternative — supports erasing stale entries
Carry {node, parent} through BFS/DFS for undirected cycle detection
Carry vis[] AND pathVis[] through DFS for directed cycle detection
delRow[]/delCol[] arrays are the cleanest way to express 4- or 8-directional moves
Flatten grid coordinates to 1D (row*m + col) whenever DSU is used on a grid
Use long long for distance sums when weights or N are large (avoid overflow)
DSU: always path-compress in findUPar; always union by rank OR size, never both

COMPLEXITY QUICK REF:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
BFS / DFS                    O(N + 2E) time, O(N) space
Grid BFS/DFS                 O(N*M) time, O(N*M) space
Dijkstra (PQ or set)         O(E log V) time, O(N) space
Bellman-Ford                 O(V * E) time, O(N) space
Floyd-Warshall               O(N^3) time, O(N^2) space
Prim's (PQ)                  O(E log E) time, O(N + E) space
Kruskal's                    O(E log E) time (sort-dominated), O(N + E) space
Disjoint Set (per op)        O(4α) ≈ O(1) amortized, O(N) space
Kosaraju's SCC                O(N + E) time, O(N + E) space
Bridges / Articulation Points O(N + E) time, O(N) space
```

---

## 📌 LeetCode / GFG Problem Map

```
TOPIC                                    | LC / SOURCE  | DIFFICULTY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Number of Provinces                      | LC 547        | Medium
Number of Islands                        | LC 200 (GFG*) | Medium
Flood Fill                               | LC 733        | Easy
Rotten Oranges                           | LC 994        | Medium
Detect Cycle — Undirected (BFS/DFS)      | GFG           | Medium
0/1 Matrix — Nearest Cell Having 1       | LC 542 (GFG*) | Medium
Surrounded Regions                       | LC 130        | Medium
Number of Enclaves                       | LC 1020       | Medium
Number of Distinct Islands               | LC 694†       | Medium
Bipartite Graph Check                    | LC 785        | Medium
Detect Cycle — Directed (DFS)            | GFG           | Medium
Eventual Safe States                     | LC 802        | Medium
Topological Sort (DFS / Kahn's BFS)      | GFG           | Medium
Detect Cycle — Directed (Kahn's)         | GFG           | Medium
Course Schedule                          | LC 207        | Medium
Course Schedule II                       | LC 210        | Medium
Alien Dictionary                         | LC 269†       | Hard
Shortest Path in DAG                     | GFG           | Medium
Shortest Path — Unit Weights             | GFG           | Medium
Word Ladder I                            | LC 127        | Hard
Word Ladder II                           | LC 126        | Hard
Dijkstra's Algorithm                     | GFG           | Medium
Print Shortest Path (Dijkstra)           | GFG           | Hard
Shortest Distance in Binary Maze         | LC 1091 (var) | Medium
Path With Minimum Effort                 | LC 1631       | Medium
Cheapest Flights Within K Stops          | LC 787        | Medium
Minimum Multiplications to Reach End     | GFG           | Medium
Number of Ways to Arrive at Destination  | LC 1976       | Medium
Bellman-Ford Algorithm                   | GFG           | Medium
Floyd-Warshall Algorithm                 | GFG           | Medium
Smallest Number of Neighbours (Threshold)| LC 1334       | Medium
Minimum Spanning Tree — Theory           | GFG           | —
Prim's Algorithm                         | GFG           | Medium
Disjoint Set (Union by Rank/Size)        | GFG           | —
Kruskal's Algorithm                      | GFG           | Medium
Number of Provinces — DSU                | LC 547        | Medium
Operations to Make Network Connected     | LC 1319       | Medium
Accounts Merge                           | LC 721        | Medium
Number of Islands II — Online Queries    | LC 305†       | Hard
Making a Large Island                    | LC 827        | Hard
Most Stones Removed (Same Row/Column)    | LC 947        | Medium
Strongly Connected Components (Kosaraju) | GFG           | Hard
Bridges in Graph (Critical Connections)  | LC 1192       | Hard
Articulation Point in Graph              | GFG           | Hard

* The taught version differs from the exact LC constraints (e.g. 8-directional
  islands, or "nearest 1" instead of LC's "nearest 0") — good for the
  underlying pattern, double check exact constraints before submitting on LC.
† LeetCode Premium — practice on GFG or a mirror if you don't have Premium.
```
