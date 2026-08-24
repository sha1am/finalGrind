# Striver DP Series — Complete Notes (C++)

*Based on TakeUForward Dynamic Programming Playlist — 56 Videos (DP 1 to DP 56)*

*Every problem below follows the same three-stage progression: **Memoization** (top-down) → **Tabulation** (bottom-up) → **Space Optimization** (further improvements). Skipped only where a stage genuinely doesn't apply (e.g. print/path-reconstruction problems need the full table; DP 43's binary-search LIS is a different algorithm entirely).*

---

## 📌 L1 — Introduction to DP: The Conversion Methodology (DP 1)

```
Memoization = TOP-DOWN. Start from the answer you need, recurse toward
the base case, cache results along the way.
Tabulation  = BOTTOM-UP. Start from the base case, iterate toward the
answer you need, filling a table.
Both give the same answer; Tabulation avoids recursion-stack overhead,
and Space Optimization then shrinks the table itself.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
THE 3-STEP RECURSION → MEMOIZATION CONVERSION (do this in EVERY problem):
  Step 0: Declare a dp[] array/table sized to the sub-problem space,
          initialized to -1 (a value the real answer can never be).
  Step 1: Right before returning a computed value, STORE it:
              dp[state] = answer;  return dp[state];
  Step 2: Right at the top of the function, CHECK before computing:
              if (dp[state] != -1) return dp[state];

MEMOIZATION → TABULATION CONVERSION:
  1. Declare the identical dp[] table.
  2. Write the BASE CASES directly into the table (no recursion needed —
     just assign the values the base-case `if` used to return).
  3. Take the recurrence relation and loop over it in the direction
     that respects dependencies (usually the reverse of how recursion
     unwound) — replace every recursive call with a table lookup.

TABULATION → SPACE OPTIMIZATION:
  Look at the recurrence: how many previous rows/states does dp[i]
  actually depend on? Almost always just 1 or 2. Replace the full
  table with that many rolling variables (commonly named `prev`,
  `prev2` for 1D; `prevRow`, `currRow` for 2D), and update them in
  place each iteration instead of keeping the whole array/matrix.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Running example — Nth Fibonacci Number:** recurrence `f(n) = f(n-1) + f(n-2)`, base case `f(0)=0, f(1)=1`.

```cpp
// ── MEMOIZATION ─────────────────────────────────────────
int f(int n, vector<int>& dp) {
    if (n <= 1) return n;
    if (dp[n] != -1) return dp[n];               // Step 2: check
    return dp[n] = f(n - 1, dp) + f(n - 2, dp);   // Step 1: store
}
// TC: O(N), SC: O(N) array + O(N) recursion stack

// ── TABULATION ──────────────────────────────────────────
int fibTab(int n) {
    vector<int> dp(n + 1);
    dp[0] = 0; dp[1] = 1;                         // base cases, hardcoded
    for (int i = 2; i <= n; i++)
        dp[i] = dp[i - 1] + dp[i - 2];            // recurrence, forward loop
    return dp[n];
}
// TC: O(N), SC: O(N) array, NO recursion stack

// ── SPACE OPTIMIZATION ───────────────────────────────────
int fibSpaceOpt(int n) {
    int prev2 = 0, prev = 1;
    for (int i = 2; i <= n; i++) {
        int curr = prev + prev2;
        prev2 = prev;
        prev = curr;
    }
    return n <= 1 ? n : prev;
}
// TC: O(N), SC: O(1)
```
**MEMORY AID:** dp[i] only ever needs dp[i-1] and dp[i-2] → that's the whole justification for collapsing an O(N) array into two variables. This "how far back does the recurrence reach?" question is what you ask in every single space-optimization step from here on.


---

## 📌 L2 — Climbing Stairs (DP 2)

```
Count distinct ways to reach stair N from stair 0, moving 1 or 2 steps
at a time. Recurrence: ways(n) = ways(n-1) + ways(n-2), base: ways(0)=1
(or handle n<=1 directly). Identical shape to Fibonacci — this lecture
exists specifically to teach you HOW TO SPOT that a counting problem is
"secretly Fibonacci."
```

```cpp
// ── MEMOIZATION ─────────────────────────────────────────
int solve(int n, vector<int>& dp) {
    if (n <= 1) return 1;
    if (dp[n] != -1) return dp[n];
    return dp[n] = solve(n - 1, dp) + solve(n - 2, dp);
}
// TC: O(N), SC: O(N) + O(N) stack

// ── TABULATION ──────────────────────────────────────────
int climbStairsTab(int n) {
    vector<int> dp(n + 1);
    dp[0] = 1;
    if (n >= 1) dp[1] = 1;
    for (int i = 2; i <= n; i++) dp[i] = dp[i - 1] + dp[i - 2];
    return dp[n];
}
// TC: O(N), SC: O(N)

// ── SPACE OPTIMIZATION ───────────────────────────────────
int climbStairsOpt(int n) {
    int prev2 = 1, prev = 1;
    for (int i = 2; i <= n; i++) {
        int curr = prev + prev2;
        prev2 = prev; prev = curr;
    }
    return prev;
}
// TC: O(N), SC: O(1)
```

---

## 📌 L3 — Frog Jump (DP 3)

```
Frog on stair 0 of an n-stair staircase, jumps to i+1 or i+2, cost of a
jump = |height[i] - height[j]|. Minimize total cost to reach stair n-1.
RECURRENCE: f(i) = min( f(i-1) + |h[i]-h[i-1]|, f(i-2) + |h[i]-h[i-2]| )
BASE CASE: f(0) = 0.
```

```cpp
// ── MEMOIZATION ─────────────────────────────────────────
int f(int i, vector<int>& height, vector<int>& dp) {
    if (i == 0) return 0;
    if (dp[i] != -1) return dp[i];
    int jumpTwo = INT_MAX;
    int jumpOne = f(i - 1, height, dp) + abs(height[i] - height[i - 1]);
    if (i > 1) jumpTwo = f(i - 2, height, dp) + abs(height[i] - height[i - 2]);
    return dp[i] = min(jumpOne, jumpTwo);
}
// TC: O(N), SC: O(N) + O(N) stack

// ── TABULATION ──────────────────────────────────────────
int frogJumpTab(int n, vector<int>& height) {
    vector<int> dp(n);
    dp[0] = 0;
    for (int i = 1; i < n; i++) {
        int jumpTwo = INT_MAX;
        int jumpOne = dp[i - 1] + abs(height[i] - height[i - 1]);
        if (i > 1) jumpTwo = dp[i - 2] + abs(height[i] - height[i - 2]);
        dp[i] = min(jumpOne, jumpTwo);
    }
    return dp[n - 1];
}
// TC: O(N), SC: O(N)

// ── SPACE OPTIMIZATION ───────────────────────────────────
int frogJumpOpt(int n, vector<int>& height) {
    int prev = 0, prev2 = 0;
    for (int i = 1; i < n; i++) {
        int jumpTwo = INT_MAX;
        int jumpOne = prev + abs(height[i] - height[i - 1]);
        if (i > 1) jumpTwo = prev2 + abs(height[i] - height[i - 2]);
        int curr = min(jumpOne, jumpTwo);
        prev2 = prev; prev = curr;
    }
    return prev;
}
// TC: O(N), SC: O(1)
```
**KEY:** "1D DP on an array" almost always has this shape: `f(i)` depends on `f(i-1)` and maybe `f(i-2)`, computed left to right. Once you can write the recurrence in words, all three code stages are mechanical.

---

## 📌 L4 — Frog Jump with K Distances (DP 4)

```
Same as L3, but the frog can jump up to K steps ahead, not just 1 or 2.
RECURRENCE generalizes to a loop over all j from 1 to K:
  f(i) = min over j in [1, K] of ( f(i-j) + |h[i]-h[i-j]| ), for i-j >= 0
```

```cpp
// ── MEMOIZATION ─────────────────────────────────────────
int f(int i, int k, vector<int>& height, vector<int>& dp) {
    if (i == 0) return 0;
    if (dp[i] != -1) return dp[i];
    int minSteps = INT_MAX;
    for (int j = 1; j <= k; j++) {
        if (i - j >= 0) {
            int jump = f(i - j, k, height, dp) + abs(height[i] - height[i - j]);
            minSteps = min(minSteps, jump);
        }
    }
    return dp[i] = minSteps;
}
// TC: O(N*K), SC: O(N) + O(N) stack

// ── TABULATION ──────────────────────────────────────────
int frogJumpKTab(int n, int k, vector<int>& height) {
    vector<int> dp(n, 0);
    for (int i = 1; i < n; i++) {
        int minSteps = INT_MAX;
        for (int j = 1; j <= k; j++) {
            if (i - j >= 0) {
                int jump = dp[i - j] + abs(height[i] - height[i - j]);
                minSteps = min(minSteps, jump);
            }
        }
        dp[i] = minSteps;
    }
    return dp[n - 1];
}
// TC: O(N*K), SC: O(N)
```
**KEY:** No further space optimization here — dp[i] can depend on up to K previous states, so you genuinely need all of the last K values, not just 1 or 2. Space optimization only collapses the array when the dependency window is small and fixed (1 or 2); here it scales with K, so the full array (or a size-K sliding window) is the practical floor.

---

## 📌 L5 — Maximum Sum of Non-Adjacent Elements / House Robber (DP 5)

```
Pick a subsequence from an array maximizing sum, with NO two picked
elements adjacent. At every index: either PICK it (and jump 2 back,
since the previous index is now forbidden) or DON'T PICK it (move 1
back, keeping full freedom for that index).

RECURRENCE: f(i) = max( arr[i] + f(i-2),  f(i-1) )
                        \_____pick_____/  \__not pick__/
```

```cpp
// ── MEMOIZATION ─────────────────────────────────────────
int f(int ind, vector<int>& arr, vector<int>& dp) {
    if (ind == 0) return arr[0];
    if (ind < 0) return 0;
    if (dp[ind] != -1) return dp[ind];
    int pick = arr[ind] + (ind > 1 ? f(ind - 2, arr, dp) : 0);
    int notPick = 0 + f(ind - 1, arr, dp);
    return dp[ind] = max(pick, notPick);
}
// TC: O(N), SC: O(N) + O(N) stack

// ── TABULATION ──────────────────────────────────────────
int robTab(vector<int>& arr) {
    int n = arr.size();
    vector<int> dp(n);
    dp[0] = arr[0];
    for (int i = 1; i < n; i++) {
        int pick = arr[i] + (i > 1 ? dp[i - 2] : 0);
        int notPick = dp[i - 1];
        dp[i] = max(pick, notPick);
    }
    return dp[n - 1];
}
// TC: O(N), SC: O(N)

// ── SPACE OPTIMIZATION ───────────────────────────────────
int robOpt(vector<int>& arr) {
    int prev = arr[0], prev2 = 0;
    for (int i = 1; i < arr.size(); i++) {
        int pick = arr[i] + (i > 1 ? prev2 : 0);
        int notPick = prev;
        int curr = max(pick, notPick);
        prev2 = prev; prev = curr;
    }
    return prev;
}
// TC: O(N), SC: O(1)
```
**MEMORY AID:** "pick / not-pick" is THE fundamental recurrence shape for almost every DP on subsequences from here on (this exact framing reappears in Knapsack, Subset Sum, Target Sum, etc.) — internalize it here.

---

## 📌 L6 — House Robber II (DP 6)

```
Same as L5, but houses are arranged in a CIRCLE — house 0 and house
n-1 are now adjacent too, so you can't pick both.

KEY IDEA: you can never pick BOTH index 0 and index n-1 in a valid
answer — so just run L5's space-optimized solution TWICE: once on the
array EXCLUDING index 0 (range [1, n-1]), once EXCLUDING index n-1
(range [0, n-2]), and take the max of the two results. Whichever
exclusion actually mattered is automatically handled correctly.
```

```cpp
int robLinear(vector<int>& arr) {           // exactly L5's space-optimized solution
    int prev = 0, prev2 = 0;
    for (int i = 0; i < arr.size(); i++) {
        int pick = arr[i] + (i > 0 ? 0 : 0) + prev2;  // prev2 covers "i-2" naturally since arr is a sub-range
        int notPick = prev;
        int curr = max(pick, notPick);
        prev2 = prev; prev = curr;
    }
    return prev;
}
int robCircular(vector<int>& arr) {
    int n = arr.size();
    if (n == 1) return arr[0];
    vector<int> excludeLast(arr.begin(), arr.end() - 1);
    vector<int> excludeFirst(arr.begin() + 1, arr.end());
    return max(robLinear(excludeLast), robLinear(excludeFirst));
}
// TC: O(N), SC: O(N) for the two sub-arrays (O(1) extra if you index-offset instead of copying)
```
**TRICK:** "Circular array constraint" in DP almost always reduces to "solve the linear version twice, once per way of breaking the circle" — same idea reappears any time a problem says "arranged in a circle."


---

## 📌 L7 — Ninja's Training (DP 7)

```
N days, 3 activities per day (0/1/2), each with merit points. Cannot
perform the SAME activity on two consecutive days. Maximize total
points. First "2D DP" of the series — state now needs (day, lastActivity).

RECURRENCE: f(day, last) = max over task != last of
                              points[day][task] + f(day-1, task)
BASE CASE: f(0, last) = max over task != last of points[0][task]
```

```cpp
// ── MEMOIZATION ─────────────────────────────────────────
int f(int day, int last, vector<vector<int>>& points, vector<vector<int>>& dp) {
    if (dp[day][last] != -1) return dp[day][last];
    if (day == 0) {
        int mx = 0;
        for (int task = 0; task < 3; task++)
            if (task != last) mx = max(mx, points[0][task]);
        return dp[day][last] = mx;
    }
    int mx = 0;
    for (int task = 0; task < 3; task++) {
        if (task != last) {
            int activity = points[day][task] + f(day - 1, task, points, dp);
            mx = max(mx, activity);
        }
    }
    return dp[day][last] = mx;
}
// call as f(n-1, 3, points, dp) — "3" means "no activity done yet"
// TC: O(N * 4 * 3), SC: O(N*4) + O(N) stack

// ── TABULATION ──────────────────────────────────────────
int ninjaTrainingTab(int n, vector<vector<int>>& points) {
    vector<vector<int>> dp(n, vector<int>(4, 0));
    dp[0][0] = max(points[0][1], points[0][2]);
    dp[0][1] = max(points[0][0], points[0][2]);
    dp[0][2] = max(points[0][0], points[0][1]);
    dp[0][3] = max({points[0][0], points[0][1], points[0][2]});
    for (int day = 1; day < n; day++) {
        for (int last = 0; last < 4; last++) {
            dp[day][last] = 0;
            for (int task = 0; task < 3; task++) {
                if (task != last) {
                    int activity = points[day][task] + dp[day - 1][task];
                    dp[day][last] = max(dp[day][last], activity);
                }
            }
        }
    }
    return dp[n - 1][3];
}
// TC: O(N * 4 * 3), SC: O(N*4)

// ── SPACE OPTIMIZATION ───────────────────────────────────
int ninjaTrainingOpt(int n, vector<vector<int>>& points) {
    vector<int> prev(4, 0);
    prev[0] = max(points[0][1], points[0][2]);
    prev[1] = max(points[0][0], points[0][2]);
    prev[2] = max(points[0][0], points[0][1]);
    prev[3] = max({points[0][0], points[0][1], points[0][2]});
    for (int day = 1; day < n; day++) {
        vector<int> curr(4, 0);
        for (int last = 0; last < 4; last++) {
            for (int task = 0; task < 3; task++)
                if (task != last)
                    curr[last] = max(curr[last], points[day][task] + prev[task]);
        }
        prev = curr;
    }
    return prev[3];
}
// TC: O(N * 4 * 3), SC: O(1) — just two length-4 arrays
```
**KEY:** A 2D DP table only needs 1D of "rolling" storage once you notice dp[day] depends ONLY on dp[day-1] — the SECOND dimension (the `last` state, size 4 here) is small and fixed, so it just travels along inside each rolling row.

---

## 📌 L8 — Grid Unique Paths (DP 8)

```
Count paths from (0,0) to (n-1,m-1) in a grid, moving only right or
down. RECURRENCE: f(i,j) = f(i-1,j) + f(i,j-1). BASE CASE: f(0,0)=1;
out-of-bounds = 0.
```

```cpp
// ── MEMOIZATION ─────────────────────────────────────────
int f(int i, int j, vector<vector<int>>& dp) {
    if (i == 0 && j == 0) return 1;
    if (i < 0 || j < 0) return 0;
    if (dp[i][j] != -1) return dp[i][j];
    int up = f(i - 1, j, dp);
    int left = f(i, j - 1, dp);
    return dp[i][j] = up + left;
}
// TC: O(N*M), SC: O(N*M) + O(N+M) stack

// ── TABULATION ──────────────────────────────────────────
int uniquePathsTab(int n, int m) {
    vector<vector<int>> dp(n, vector<int>(m, 0));
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < m; j++) {
            if (i == 0 && j == 0) { dp[i][j] = 1; continue; }
            int up = (i > 0) ? dp[i - 1][j] : 0;
            int left = (j > 0) ? dp[i][j - 1] : 0;
            dp[i][j] = up + left;
        }
    }
    return dp[n - 1][m - 1];
}
// TC: O(N*M), SC: O(N*M)

// ── SPACE OPTIMIZATION ───────────────────────────────────
int uniquePathsOpt(int n, int m) {
    vector<int> prev(m, 0);
    for (int i = 0; i < n; i++) {
        vector<int> curr(m, 0);
        for (int j = 0; j < m; j++) {
            if (i == 0 && j == 0) { curr[j] = 1; continue; }
            int up = prev[j];
            int left = (j > 0) ? curr[j - 1] : 0;
            curr[j] = up + left;
        }
        prev = curr;
    }
    return prev[m - 1];
}
// TC: O(N*M), SC: O(M) — only ONE row needs to be kept
```
**KEY:** For grid DP, dp[i][j] depends on dp[i-1][j] (the row above) and dp[i][j-1] (same row, just computed) — so space optimization drops from O(N*M) to O(M): a single rolling row, updated left to right.

---

## 📌 L9 — Unique Paths II — With Obstacles (DP 9)

```
Same as L8, but a cell can be -1 (blocked). RECURRENCE identical to L8,
with one extra guard: if the current cell is blocked, contribute 0
paths regardless of what's above/left.
```

```cpp
// ── MEMOIZATION ─────────────────────────────────────────
int f(int i, int j, vector<vector<int>>& maze, vector<vector<int>>& dp) {
    if (i >= 0 && j >= 0 && maze[i][j] == -1) return 0;   // blocked
    if (i == 0 && j == 0) return 1;
    if (i < 0 || j < 0) return 0;
    if (dp[i][j] != -1) return dp[i][j];
    int up = f(i - 1, j, maze, dp);
    int left = f(i, j - 1, maze, dp);
    return dp[i][j] = up + left;
}
// TC: O(N*M), SC: O(N*M) + O(N+M) stack

// ── TABULATION + SPACE OPTIMIZATION (combined, same pattern as L8) ──
int mazeObstaclesOpt(vector<vector<int>>& maze) {
    int n = maze.size(), m = maze[0].size();
    vector<int> prev(m, 0);
    for (int i = 0; i < n; i++) {
        vector<int> curr(m, 0);
        for (int j = 0; j < m; j++) {
            if (maze[i][j] == -1) { curr[j] = 0; continue; }
            if (i == 0 && j == 0) { curr[j] = 1; continue; }
            int up = (i > 0) ? prev[j] : 0;
            int left = (j > 0) ? curr[j - 1] : 0;
            curr[j] = up + left;
        }
        prev = curr;
    }
    return prev[m - 1];
}
// TC: O(N*M), SC: O(M)
```

---

## 📌 L10 — Minimum Path Sum in Grid (DP 10)

```
Same movement rules as L8 (right/down only), but minimize the SUM of
cell values along the path instead of counting paths.
RECURRENCE: f(i,j) = grid[i][j] + min( f(i-1,j), f(i,j-1) )
```

```cpp
// ── MEMOIZATION ─────────────────────────────────────────
int f(int i, int j, vector<vector<int>>& grid, vector<vector<int>>& dp) {
    if (i == 0 && j == 0) return grid[0][0];
    if (i < 0 || j < 0) return 1e9;
    if (dp[i][j] != -1) return dp[i][j];
    int up = grid[i][j] + f(i - 1, j, grid, dp);
    int left = grid[i][j] + f(i, j - 1, grid, dp);
    return dp[i][j] = min(up, left);
}
// TC: O(N*M), SC: O(N*M) + O(N+M) stack

// ── TABULATION ──────────────────────────────────────────
int minPathSumTab(vector<vector<int>>& grid) {
    int n = grid.size(), m = grid[0].size();
    vector<vector<int>> dp(n, vector<int>(m, 0));
    for (int i = 0; i < n; i++)
        for (int j = 0; j < m; j++) {
            if (i == 0 && j == 0) { dp[i][j] = grid[i][j]; continue; }
            int up = grid[i][j] + (i > 0 ? dp[i - 1][j] : (int)1e9);
            int left = grid[i][j] + (j > 0 ? dp[i][j - 1] : (int)1e9);
            dp[i][j] = min(up, left);
        }
    return dp[n - 1][m - 1];
}
// TC: O(N*M), SC: O(N*M)

// ── SPACE OPTIMIZATION ───────────────────────────────────
int minPathSumOpt(vector<vector<int>>& grid) {
    int n = grid.size(), m = grid[0].size();
    vector<int> prev(m, 0);
    for (int i = 0; i < n; i++) {
        vector<int> curr(m, 0);
        for (int j = 0; j < m; j++) {
            if (i == 0 && j == 0) { curr[j] = grid[i][j]; continue; }
            int up = grid[i][j] + (i > 0 ? prev[j] : (int)1e9);
            int left = grid[i][j] + (j > 0 ? curr[j - 1] : (int)1e9);
            curr[j] = min(up, left);
        }
        prev = curr;
    }
    return prev[m - 1];
}
// TC: O(N*M), SC: O(M)
```


---

## 📌 L11 — Triangle: Fixed Start, Variable End (DP 11)

```
Triangular array, n rows, row i has i+1 elements. Start at the top,
each step move to (i+1, j) or (i+1, j+1). Minimize path sum to reach
ANY cell in the last row.
RECURRENCE: f(i,j) = triangle[i][j] + min( f(i+1,j), f(i+1,j+1) )
This time it's cleaner to recurse TOP-DOWN in problem terms but code it
DOWNWARD from row 0 — or equivalently think of it bottom-up directly:
starting the DP from the LAST row upward is the natural base case here.
```

```cpp
// ── MEMOIZATION (top row to bottom row, base case = last row) ──
int f(int i, int j, int n, vector<vector<int>>& triangle, vector<vector<int>>& dp) {
    if (i == n - 1) return triangle[n - 1][j];
    if (dp[i][j] != -1) return dp[i][j];
    int down = triangle[i][j] + f(i + 1, j, n, triangle, dp);
    int diagonal = triangle[i][j] + f(i + 1, j + 1, n, triangle, dp);
    return dp[i][j] = min(down, diagonal);
}
// call as f(0, 0, n, triangle, dp)
// TC: O(N^2), SC: O(N^2) + O(N) stack

// ── TABULATION (fill from the LAST row upward — base case first) ──
int triangleTab(vector<vector<int>>& triangle) {
    int n = triangle.size();
    vector<vector<int>> dp(n, vector<int>(n, 0));
    for (int j = 0; j < n; j++) dp[n - 1][j] = triangle[n - 1][j];   // base case
    for (int i = n - 2; i >= 0; i--) {
        for (int j = i; j >= 0; j--) {
            int down = triangle[i][j] + dp[i + 1][j];
            int diagonal = triangle[i][j] + dp[i + 1][j + 1];
            dp[i][j] = min(down, diagonal);
        }
    }
    return dp[0][0];
}
// TC: O(N^2), SC: O(N^2)

// ── SPACE OPTIMIZATION ───────────────────────────────────
int triangleOpt(vector<vector<int>>& triangle) {
    int n = triangle.size();
    vector<int> front(n, 0), curr(n, 0);
    for (int j = 0; j < n; j++) front[j] = triangle[n - 1][j];
    for (int i = n - 2; i >= 0; i--) {
        for (int j = i; j >= 0; j--) {
            int down = triangle[i][j] + front[j];
            int diagonal = triangle[i][j] + front[j + 1];
            curr[j] = min(down, diagonal);
        }
        front = curr;
    }
    return front[0];
}
// TC: O(N^2), SC: O(N)
```
**KEY:** Whenever the natural base case sits at the LAST row/index rather than the first, tabulate by looping BACKWARD (n-2 down to 0) instead of forward — the loop direction always just follows "which state has to be known before this one can be computed."

---

## 📌 L12 — Minimum/Maximum Falling Path Sum: Variable Start AND End (DP 12)

```
N x M matrix. Start from ANY cell in row 0, move to row i+1 via
straight-down, diagonal-left, or diagonal-right. Maximize (or minimize)
the path sum reaching row n-1 — start AND end are both variable this
time, so try every possible starting column and take the best.
RECURRENCE: f(i,j) = matrix[i][j] + max( f(i-1,j), f(i-1,j-1), f(i-1,j+1) )
```

```cpp
// ── MEMOIZATION ──────────────────────────────────────────
int f(int i, int j, int m, vector<vector<int>>& matrix, vector<vector<int>>& dp) {
    if (j < 0 || j >= m) return -1e9;
    if (i == 0) return matrix[0][j];
    if (dp[i][j] != -1) return dp[i][j];
    int up = matrix[i][j] + f(i - 1, j, m, matrix, dp);
    int diagLeft = matrix[i][j] + f(i - 1, j - 1, m, matrix, dp);
    int diagRight = matrix[i][j] + f(i - 1, j + 1, m, matrix, dp);
    return dp[i][j] = max({up, diagLeft, diagRight});
}
int getMaxPathSum(vector<vector<int>>& matrix) {
    int n = matrix.size(), m = matrix[0].size();
    vector<vector<int>> dp(n, vector<int>(m, -1));
    int mx = INT_MIN;
    for (int j = 0; j < m; j++) mx = max(mx, f(n - 1, j, m, matrix, dp));
    return mx;
}
// TC: O(N*M*3), SC: O(N*M) + O(N) stack

// ── TABULATION ───────────────────────────────────────────
int fallingPathTab(vector<vector<int>>& matrix) {
    int n = matrix.size(), m = matrix[0].size();
    vector<vector<int>> dp(n, vector<int>(m, 0));
    for (int j = 0; j < m; j++) dp[0][j] = matrix[0][j];
    for (int i = 1; i < n; i++) {
        for (int j = 0; j < m; j++) {
            int up = matrix[i][j] + dp[i - 1][j];
            int diagLeft = matrix[i][j] + (j > 0 ? dp[i - 1][j - 1] : (int)-1e9);
            int diagRight = matrix[i][j] + (j < m - 1 ? dp[i - 1][j + 1] : (int)-1e9);
            dp[i][j] = max({up, diagLeft, diagRight});
        }
    }
    int mx = INT_MIN;
    for (int j = 0; j < m; j++) mx = max(mx, dp[n - 1][j]);
    return mx;
}
// TC: O(N*M), SC: O(N*M)

// ── SPACE OPTIMIZATION ────────────────────────────────────
int fallingPathOpt(vector<vector<int>>& matrix) {
    int n = matrix.size(), m = matrix[0].size();
    vector<int> prev(matrix[0]), curr(m, 0);
    for (int i = 1; i < n; i++) {
        for (int j = 0; j < m; j++) {
            int up = matrix[i][j] + prev[j];
            int diagLeft = matrix[i][j] + (j > 0 ? prev[j - 1] : (int)-1e9);
            int diagRight = matrix[i][j] + (j < m - 1 ? prev[j + 1] : (int)-1e9);
            curr[j] = max({up, diagLeft, diagRight});
        }
        prev = curr;
    }
    return *max_element(prev.begin(), prev.end());
}
// TC: O(N*M), SC: O(M)
```
**KEY:** "Variable start, variable end" just means: run the SAME DP as usual, and take a min/max over the entire first-or-last row at the end instead of reading one fixed corner cell.

---

## 📌 L13 — Cherry Pickup II: 3D DP (DP 13)

```
R x C grid of chocolates. Alice starts top-left (0,0), Bob starts
top-right (0, C-1). BOTH move down one row per step, each choosing to
go straight, diagonal-left, or diagonal-right independently (9 combined
options per row). If both land on the same cell, only ONE collects that
cell's chocolates. Maximize total collected by the time both reach the
last row.

STATE has 3 dimensions: (row, aliceCol, bobCol) — hence "3D DP."
RECURRENCE: f(i,j1,j2) = value(i,j1,j2) +
    max over all 9 (dj1, dj2) combos of f(i+1, j1+dj1, j2+dj2)
where value = grid[i][j1] + (j1==j2 ? 0 : grid[i][j2])
```

```cpp
// ── MEMOIZATION ─────────────────────────────────────────
int f(int i, int j1, int j2, int r, int c, vector<vector<int>>& grid,
       vector<vector<vector<int>>>& dp) {
    if (j1 < 0 || j1 >= c || j2 < 0 || j2 >= c) return -1e8;
    if (dp[i][j1][j2] != -1) return dp[i][j1][j2];
    if (i == r - 1) {
        if (j1 == j2) return dp[i][j1][j2] = grid[i][j1];
        return dp[i][j1][j2] = grid[i][j1] + grid[i][j2];
    }
    int maxi = INT_MIN;
    for (int dj1 = -1; dj1 <= 1; dj1++) {
        for (int dj2 = -1; dj2 <= 1; dj2++) {
            int value = (j1 == j2) ? grid[i][j1] : grid[i][j1] + grid[i][j2];
            value += f(i + 1, j1 + dj1, j2 + dj2, r, c, grid, dp);
            maxi = max(maxi, value);
        }
    }
    return dp[i][j1][j2] = maxi;
}
// call as f(0, 0, c-1, r, c, grid, dp)
// TC: O(R * C * C * 9), SC: O(R*C*C) + O(R) stack

// ── TABULATION ──────────────────────────────────────────
int cherryPickupTab(int r, int c, vector<vector<int>>& grid) {
    vector<vector<vector<int>>> dp(r, vector<vector<int>>(c, vector<int>(c, 0)));
    for (int j1 = 0; j1 < c; j1++)
        for (int j2 = 0; j2 < c; j2++)
            dp[r - 1][j1][j2] = (j1 == j2) ? grid[r-1][j1] : grid[r-1][j1] + grid[r-1][j2];

    for (int i = r - 2; i >= 0; i--) {
        for (int j1 = 0; j1 < c; j1++) {
            for (int j2 = 0; j2 < c; j2++) {
                int maxi = INT_MIN;
                for (int dj1 = -1; dj1 <= 1; dj1++) {
                    for (int dj2 = -1; dj2 <= 1; dj2++) {
                        int value = (j1 == j2) ? grid[i][j1] : grid[i][j1] + grid[i][j2];
                        int nj1 = j1 + dj1, nj2 = j2 + dj2;
                        if (nj1 >= 0 && nj1 < c && nj2 >= 0 && nj2 < c)
                            value += dp[i + 1][nj1][nj2];
                        else
                            value += -1e8;
                        maxi = max(maxi, value);
                    }
                }
                dp[i][j1][j2] = maxi;
            }
        }
    }
    return dp[0][0][c - 1];
}
// TC: O(R * C * C * 9), SC: O(R*C*C)

// ── SPACE OPTIMIZATION ───────────────────────────────────
int cherryPickupOpt(int r, int c, vector<vector<int>>& grid) {
    vector<vector<int>> front(c, vector<int>(c, 0)), curr(c, vector<int>(c, 0));
    for (int j1 = 0; j1 < c; j1++)
        for (int j2 = 0; j2 < c; j2++)
            front[j1][j2] = (j1 == j2) ? grid[r-1][j1] : grid[r-1][j1] + grid[r-1][j2];

    for (int i = r - 2; i >= 0; i--) {
        for (int j1 = 0; j1 < c; j1++) {
            for (int j2 = 0; j2 < c; j2++) {
                int maxi = INT_MIN;
                for (int dj1 = -1; dj1 <= 1; dj1++) {
                    for (int dj2 = -1; dj2 <= 1; dj2++) {
                        int value = (j1 == j2) ? grid[i][j1] : grid[i][j1] + grid[i][j2];
                        int nj1 = j1 + dj1, nj2 = j2 + dj2;
                        value += (nj1 >= 0 && nj1 < c && nj2 >= 0 && nj2 < c) ? front[nj1][nj2] : (int)-1e8;
                        maxi = max(maxi, value);
                    }
                }
                curr[j1][j2] = maxi;
            }
        }
        front = curr;
    }
    return front[0][c - 1];
}
// TC: O(R * C * C * 9), SC: O(C*C) — drop the row dimension only, the two
//     column dimensions stay (they're the "current state", not history)
```
**KEY:** 3D DP is just 2D DP with an extra "which of two agents" dimension bolted on — the conversion mechanics (base case at the last row, 2 rolling 2D layers instead of a full 3D cube) are identical to everything before it, just one dimension deeper.


---

## 📌 L14 — Subset Sum Equal to Target (DP 14)

```
Given an array and a target, return true/false: does SOME subset sum
exactly to target? This is the FOUNDATIONAL problem for the entire
"DP on Subsequences" cluster (11 problems, DP 14–24) — every later
lecture in this section reduces to this one.

RECURRENCE (classic "pick / not-pick" on index + remaining target):
  f(ind, target) = f(ind-1, target - arr[ind])   [PICK, only if arr[ind] <= target]
                 OR f(ind-1, target)               [NOT PICK]
BASE CASES: f(0, 0) = true (empty subset sums to 0);
            f(0, target) = (arr[0] == target)
```

```cpp
// ── MEMOIZATION ─────────────────────────────────────────
bool f(int ind, int target, vector<int>& arr, vector<vector<int>>& dp) {
    if (target == 0) return true;
    if (ind == 0) return arr[0] == target;
    if (dp[ind][target] != -1) return dp[ind][target];
    bool notTaken = f(ind - 1, target, arr, dp);
    bool taken = false;
    if (arr[ind] <= target) taken = f(ind - 1, target - arr[ind], arr, dp);
    return dp[ind][target] = taken || notTaken;
}
// TC: O(N * Target), SC: O(N * Target) + O(N) stack

// ── TABULATION ──────────────────────────────────────────
bool subsetSumTab(int n, vector<int>& arr, int target) {
    vector<vector<bool>> dp(n, vector<bool>(target + 1, false));
    for (int i = 0; i < n; i++) dp[i][0] = true;
    if (arr[0] <= target) dp[0][arr[0]] = true;
    for (int ind = 1; ind < n; ind++) {
        for (int t = 1; t <= target; t++) {
            bool notTaken = dp[ind - 1][t];
            bool taken = (arr[ind] <= t) ? dp[ind - 1][t - arr[ind]] : false;
            dp[ind][t] = taken || notTaken;
        }
    }
    return dp[n - 1][target];
}
// TC: O(N * Target), SC: O(N * Target)

// ── SPACE OPTIMIZATION ───────────────────────────────────
bool subsetSumOpt(int n, vector<int>& arr, int target) {
    vector<bool> prev(target + 1, false);
    prev[0] = true;
    if (arr[0] <= target) prev[arr[0]] = true;
    for (int ind = 1; ind < n; ind++) {
        vector<bool> curr(target + 1, false);
        curr[0] = true;
        for (int t = 1; t <= target; t++) {
            bool notTaken = prev[t];
            bool taken = (arr[ind] <= t) ? prev[t - arr[ind]] : false;
            curr[t] = taken || notTaken;
        }
        prev = curr;
    }
    return prev[target];
}
// TC: O(N * Target), SC: O(Target)
```
**MEMORY AID:** "Subset with a target sum" is a 2D DP — (index, remaining target) — with the same pick/not-pick shape as House Robber, just with an extra dimension for the running total. This exact table is the engine behind DP 14 through DP 21.

---

## 📌 L15 — Partition Equal Subset Sum (DP 15)

```
Can the array be split into two subsets with EQUAL sum? Only possible
if totalSum is even — then this is EXACTLY L14's Subset Sum with
target = totalSum / 2 (if such a subset exists, the remaining elements
automatically form the other equal-sum half).
```

```cpp
bool canPartition(vector<int>& arr, int n) {
    int totalSum = 0;
    for (int x : arr) totalSum += x;
    if (totalSum % 2 != 0) return false;
    return subsetSumOpt(n, arr, totalSum / 2);   // reuse L14 directly
}
// TC: O(N * totalSum/2), SC: O(totalSum/2) using L14's space-optimized version
```

---

## 📌 L16 — Partition Array With Minimum Absolute Sum Difference (DP 16)

```
Split into two subsets S1, S2 minimizing |sum(S1) - sum(S2)|.

KEY IDEA: run L14's Subset Sum DP fully (don't stop at one target — keep
the WHOLE last row of the tabulation table). Every index t in that last
row where dp[n-1][t] == true is an ACHIEVABLE subset sum s1. For each
achievable s1, the other subset is totalSum - s1, and the difference is
|totalSum - 2*s1|. Minimize that over every achievable s1 in [0, totalSum/2].
```

```cpp
int minSubsetSumDifference(vector<int>& arr, int n) {
    int totalSum = 0;
    for (int x : arr) totalSum += x;
    vector<vector<bool>> dp(n, vector<bool>(totalSum + 1, false));
    for (int i = 0; i < n; i++) dp[i][0] = true;
    if (arr[0] <= totalSum) dp[0][arr[0]] = true;
    for (int ind = 1; ind < n; ind++)
        for (int t = 1; t <= totalSum; t++) {
            bool notTaken = dp[ind - 1][t];
            bool taken = (arr[ind] <= t) ? dp[ind - 1][t - arr[ind]] : false;
            dp[ind][t] = taken || notTaken;
        }
    int mini = INT_MAX;
    for (int s1 = 0; s1 <= totalSum / 2; s1++) {
        if (dp[n - 1][s1]) {
            int s2 = totalSum - s1;
            mini = min(mini, abs(s2 - s1));
        }
    }
    return mini;
}
// TC: O(N * totalSum), SC: O(N * totalSum) — the FULL last row is needed here,
//     so this one can't be space-optimized down past one row (a 1-row rolling
//     version works, but you must keep that entire row, not a single cell)
```

---

## 📌 L17 — Count Subsets With Sum K (DP 17)

```
Same setup as L14, but COUNT how many subsets sum to K, not just
true/false. Same pick/not-pick shape, sum instead of OR.
GOTCHA: if the array can contain 0s, a base-case tweak is needed — a 0
can be "picked" without changing the sum, so f(0, 0) should count BOTH
choices (include the 0 or not) → base case becomes 2 ways, not 1, when
arr[0] == 0.
```

```cpp
// ── MEMOIZATION ─────────────────────────────────────────
int f(int ind, int target, vector<int>& arr, vector<vector<int>>& dp) {
    if (ind == 0) {
        if (target == 0 && arr[0] == 0) return 2;   // include the 0 or not
        if (target == 0 || target == arr[0]) return 1;
        return 0;
    }
    if (dp[ind][target] != -1) return dp[ind][target];
    int notTaken = f(ind - 1, target, arr, dp);
    int taken = 0;
    if (arr[ind] <= target) taken = f(ind - 1, target - arr[ind], arr, dp);
    return dp[ind][target] = taken + notTaken;
}
// TC: O(N * Target), SC: O(N * Target) + O(N) stack

// ── TABULATION ──────────────────────────────────────────
int countSubsetsTab(vector<int>& arr, int target, int n) {
    vector<vector<int>> dp(n, vector<int>(target + 1, 0));
    if (arr[0] == 0) { dp[0][0] = 2; } else { dp[0][0] = 1; }
    if (arr[0] != 0 && arr[0] <= target) dp[0][arr[0]] = 1;
    for (int ind = 1; ind < n; ind++)
        for (int t = 0; t <= target; t++) {
            int notTaken = dp[ind - 1][t];
            int taken = (arr[ind] <= t) ? dp[ind - 1][t - arr[ind]] : 0;
            dp[ind][t] = taken + notTaken;
        }
    return dp[n - 1][target];
}
// TC: O(N * Target), SC: O(N * Target)

// ── SPACE OPTIMIZATION ───────────────────────────────────
int countSubsetsOpt(vector<int>& arr, int target, int n) {
    vector<int> prev(target + 1, 0);
    prev[0] = (arr[0] == 0) ? 2 : 1;
    if (arr[0] != 0 && arr[0] <= target) prev[arr[0]] = 1;
    for (int ind = 1; ind < n; ind++) {
        vector<int> curr(target + 1, 0);
        curr[0] = 1;                    // empty subset always sums to 0
        for (int t = 1; t <= target; t++) {
            int notTaken = prev[t];
            int taken = (arr[ind] <= t) ? prev[t - arr[ind]] : 0;
            curr[t] = taken + notTaken;
        }
        prev = curr;
    }
    return prev[target];
}
// TC: O(N * Target), SC: O(Target)
```

---

## 📌 L18 — Count Partitions With Given Difference (DP 18)

```
Split array into S1, S2 with sum(S1) - sum(S2) = diff. Count the ways.

KEY IDEA — reduce to L17: from  s1 - s2 = diff  and  s1 + s2 = totalSum,
solving gives  s1 = (totalSum + diff) / 2. So: count subsets with sum
equal to that s1, using L17's exact code. Two edge cases before calling
it: (totalSum + diff) must be even, and s1 must be non-negative — if
either fails, the answer is 0 (no valid partition exists).
```

```cpp
int countPartitions(int n, int diff, vector<int>& arr) {
    int totalSum = 0;
    for (int x : arr) totalSum += x;
    if (totalSum - diff < 0 || (totalSum - diff) % 2) return 0;
    int s1 = (totalSum - diff) / 2;
    return countSubsetsOpt(arr, s1, n);   // reuse L17 directly
}
// TC: O(N * totalSum), SC: O(totalSum)
```


---

## 📌 L19 — 0/1 Knapsack (DP 19)

```
N items, each with a weight and a value, knapsack capacity W. Each item
used AT MOST ONCE. Maximize total value without exceeding W.
RECURRENCE: f(ind, W) = max( value[ind] + f(ind-1, W - weight[ind]),   [PICK, if weight[ind] <= W]
                              f(ind-1, W) )                             [NOT PICK]
This is THE most-asked DP problem in interviews — first lecture in the
series to teach the SINGLE-ARRAY (not just single-row) space optimization.
```

```cpp
// ── MEMOIZATION ─────────────────────────────────────────
int f(int ind, int W, vector<int>& wt, vector<int>& val, vector<vector<int>>& dp) {
    if (ind == 0) return (wt[0] <= W) ? val[0] : 0;
    if (dp[ind][W] != -1) return dp[ind][W];
    int notTaken = f(ind - 1, W, wt, val, dp);
    int taken = INT_MIN;
    if (wt[ind] <= W) taken = val[ind] + f(ind - 1, W - wt[ind], wt, val, dp);
    return dp[ind][W] = max(taken, notTaken);
}
// TC: O(N * W), SC: O(N * W) + O(N) stack

// ── TABULATION ──────────────────────────────────────────
int knapsackTab(vector<int>& wt, vector<int>& val, int n, int W) {
    vector<vector<int>> dp(n, vector<int>(W + 1, 0));
    for (int w = wt[0]; w <= W; w++) dp[0][w] = val[0];
    for (int ind = 1; ind < n; ind++) {
        for (int w = 0; w <= W; w++) {
            int notTaken = dp[ind - 1][w];
            int taken = INT_MIN;
            if (wt[ind] <= w) taken = val[ind] + dp[ind - 1][w - wt[ind]];
            dp[ind][w] = max(taken, notTaken);
        }
    }
    return dp[n - 1][W];
}
// TC: O(N * W), SC: O(N * W)

// ── SPACE OPTIMIZATION — SINGLE 1D ARRAY ─────────────────
int knapsackOpt(vector<int>& wt, vector<int>& val, int n, int W) {
    vector<int> prev(W + 1, 0);
    for (int w = wt[0]; w <= W; w++) prev[w] = val[0];
    for (int ind = 1; ind < n; ind++) {
        for (int w = W; w >= 0; w--) {          // MUST go right-to-left!
            int notTaken = prev[w];
            int taken = INT_MIN;
            if (wt[ind] <= w) taken = val[ind] + prev[w - wt[ind]];
            prev[w] = max(taken, notTaken);
        }
    }
    return prev[W];
}
// TC: O(N * W), SC: O(W) — ONE array, not two rolling rows
```
**KEY — why right-to-left matters:** with only ONE array (`prev` doubling as `curr`), `prev[w - wt[ind]]` must still hold the PREVIOUS row's value when you read it. Looping `w` downward guarantees you read cells you haven't overwritten yet this row. Loop left-to-right instead and you'd be reading values ALREADY updated for the current item — silently turning 0/1 Knapsack into Unbounded Knapsack (L23). This single-array-with-reverse-loop trick only works because each dp[ind][w] depends on dp[ind-1][SMALLER w] — it doesn't generalize to every 2D DP, just this "capacity shrinks" family.

---

## 📌 L20 — Minimum Coins (DP 20)

```
Coin denominations array (unlimited supply of each), target amount.
Minimize the NUMBER of coins used to reach target (-1 if impossible).
Same "pick / not-pick" shape as Knapsack, but since supply is infinite,
a PICK stays on the SAME index (not ind-1) — that's what "unbounded" means.
RECURRENCE: f(ind, T) = min( 1 + f(ind, T - coins[ind]),   [PICK, stay at ind]
                              f(ind-1, T) )                 [NOT PICK]
```

```cpp
// ── MEMOIZATION ─────────────────────────────────────────
int f(int ind, int T, vector<int>& coins, vector<vector<int>>& dp) {
    if (ind == 0) return (T % coins[0] == 0) ? T / coins[0] : 1e9;
    if (dp[ind][T] != -1) return dp[ind][T];
    int notTaken = f(ind - 1, T, coins, dp);
    int taken = 1e9;
    if (coins[ind] <= T) taken = 1 + f(ind, T - coins[ind], coins, dp);
    return dp[ind][T] = min(taken, notTaken);
}
// TC: O(N * T), SC: O(N * T) + O(N) stack

// ── TABULATION ──────────────────────────────────────────
int minCoinsTab(vector<int>& coins, int n, int T) {
    vector<vector<int>> dp(n, vector<int>(T + 1, 0));
    for (int t = 0; t <= T; t++) dp[0][t] = (t % coins[0] == 0) ? t / coins[0] : 1e9;
    for (int ind = 1; ind < n; ind++)
        for (int t = 0; t <= T; t++) {
            int notTaken = dp[ind - 1][t];
            int taken = 1e9;
            if (coins[ind] <= t) taken = 1 + dp[ind][t - coins[ind]];   // SAME row (ind, not ind-1)
            dp[ind][t] = min(taken, notTaken);
        }
    int ans = dp[n - 1][T];
    return ans >= (int)1e9 ? -1 : ans;
}
// TC: O(N * T), SC: O(N * T)

// ── SPACE OPTIMIZATION ───────────────────────────────────
int minCoinsOpt(vector<int>& coins, int n, int T) {
    vector<int> prev(T + 1, 0), curr(T + 1, 0);
    for (int t = 0; t <= T; t++) prev[t] = (t % coins[0] == 0) ? t / coins[0] : 1e9;
    for (int ind = 1; ind < n; ind++) {
        for (int t = 0; t <= T; t++) {
            int notTaken = prev[t];
            int taken = 1e9;
            if (coins[ind] <= t) taken = 1 + curr[t - coins[ind]];   // reads CURRENT row — unbounded
            curr[t] = min(taken, notTaken);
        }
        prev = curr;
    }
    int ans = prev[T];
    return ans >= (int)1e9 ? -1 : ans;
}
// TC: O(N * T), SC: O(T)
```
**KEY — bounded vs unbounded:** 0/1 Knapsack's PICK branch recurses into `ind-1` (previous row — each item used once). Every "infinite supply" problem's PICK branch recurses into `ind` itself (current row — reuse allowed). That one index difference is the entire distinction between L19's family and L20/L23/L24's family.

---

## 📌 L21 — Target Sum (DP 21)

```
Assign +/- signs to each array element so the total equals `target`.
Count the number of ways.
KEY IDEA — reduces directly to L18 (Count Partitions With Given
Difference): let S1 = sum of elements assigned '+', S2 = sum assigned
'-'. Then S1 - S2 = target, exactly L18's setup.
```

```cpp
int targetSum(vector<int>& arr, int target, int n) {
    return countPartitions(n, target, arr);   // reuse L18 directly
}
// TC: O(N * totalSum), SC: O(totalSum)
```

---

## 📌 L22 — Coin Change 2 (DP 22)

```
Coins with UNLIMITED supply, count the number of ways to make `target`
(order doesn't matter — {1,2} and {2,1} are the same way). Same
unbounded "stay at ind on pick" shape as L20, sum instead of min.
```

```cpp
// ── MEMOIZATION ─────────────────────────────────────────
int f(int ind, int T, vector<int>& coins, vector<vector<int>>& dp) {
    if (ind == 0) return (T % coins[0] == 0) ? 1 : 0;
    if (dp[ind][T] != -1) return dp[ind][T];
    int notTaken = f(ind - 1, T, coins, dp);
    int taken = 0;
    if (coins[ind] <= T) taken = f(ind, T - coins[ind], coins, dp);
    return dp[ind][T] = taken + notTaken;
}
// TC: O(N * T), SC: O(N * T) + O(N) stack

// ── TABULATION ──────────────────────────────────────────
int change(int T, vector<int>& coins) {
    int n = coins.size();
    vector<vector<long long>> dp(n, vector<long long>(T + 1, 0));
    for (int t = 0; t <= T; t++) dp[0][t] = (t % coins[0] == 0) ? 1 : 0;
    for (int ind = 1; ind < n; ind++)
        for (int t = 0; t <= T; t++) {
            long long notTaken = dp[ind - 1][t];
            long long taken = (coins[ind] <= t) ? dp[ind][t - coins[ind]] : 0;
            dp[ind][t] = taken + notTaken;
        }
    return dp[n - 1][T];
}
// TC: O(N * T), SC: O(N * T)

// ── SPACE OPTIMIZATION ───────────────────────────────────
int changeOpt(int T, vector<int>& coins) {
    int n = coins.size();
    vector<long long> prev(T + 1, 0), curr(T + 1, 0);
    for (int t = 0; t <= T; t++) prev[t] = (t % coins[0] == 0) ? 1 : 0;
    for (int ind = 1; ind < n; ind++) {
        for (int t = 0; t <= T; t++) {
            long long notTaken = prev[t];
            long long taken = (coins[ind] <= t) ? curr[t - coins[ind]] : 0;
            curr[t] = taken + notTaken;
        }
        prev = curr;
    }
    return prev[T];
}
// TC: O(N * T), SC: O(T)
```

---

## 📌 L23 — Unbounded Knapsack (DP 23)

```
Exactly like 0/1 Knapsack (L19), but unlimited supply of each item.
Only change from L19: the PICK branch recurses into the SAME index.
```

```cpp
// ── MEMOIZATION ─────────────────────────────────────────
int f(int ind, int W, vector<int>& wt, vector<int>& val, vector<vector<int>>& dp) {
    if (ind == 0) return (W / wt[0]) * val[0];        // take item 0 as many times as fits
    if (dp[ind][W] != -1) return dp[ind][W];
    int notTaken = f(ind - 1, W, wt, val, dp);
    int taken = INT_MIN;
    if (wt[ind] <= W) taken = val[ind] + f(ind, W - wt[ind], wt, val, dp);  // SAME ind
    return dp[ind][W] = max(taken, notTaken);
}
// TC: O(N * W), SC: O(N * W) + O(N) stack

// ── TABULATION ──────────────────────────────────────────
int unboundedKnapsackTab(int n, int W, vector<int>& wt, vector<int>& val) {
    vector<vector<int>> dp(n, vector<int>(W + 1, 0));
    for (int w = 0; w <= W; w++) dp[0][w] = (w / wt[0]) * val[0];
    for (int ind = 1; ind < n; ind++)
        for (int w = 0; w <= W; w++) {
            int notTaken = dp[ind - 1][w];
            int taken = (wt[ind] <= w) ? val[ind] + dp[ind][w - wt[ind]] : INT_MIN;
            dp[ind][w] = max(taken, notTaken);
        }
    return dp[n - 1][W];
}
// TC: O(N * W), SC: O(N * W)

// ── SPACE OPTIMIZATION — SINGLE 1D ARRAY, LEFT-TO-RIGHT ──
int unboundedKnapsackOpt(int n, int W, vector<int>& wt, vector<int>& val) {
    vector<int> prev(W + 1, 0);
    for (int w = 0; w <= W; w++) prev[w] = (w / wt[0]) * val[0];
    for (int ind = 1; ind < n; ind++) {
        for (int w = 0; w <= W; w++) {           // left-to-right THIS time — reuse is intended
            int notTaken = prev[w];
            int taken = (wt[ind] <= w) ? val[ind] + prev[w - wt[ind]] : INT_MIN;
            prev[w] = max(taken, notTaken);
        }
    }
    return prev[W];
}
// TC: O(N * W), SC: O(W)
```
**GOTCHA:** compare this loop direction to L19's — 0/1 Knapsack space-optimizes with a REVERSE loop (to avoid reusing an item), Unbounded Knapsack space-optimizes with a FORWARD loop (to deliberately allow reuse within the same row). Mixing these up is the single most common bug when adapting one knapsack solution into the other.

---

## 📌 L24 — Rod Cutting Problem (DP 24)

```
Rod of length N, price[i] = price you get for selling a piece of length
i+1. Cut the rod into pieces (any lengths) to MAXIMIZE total sale price.

KEY IDEA — this is Unbounded Knapsack in disguise: "weight" = piece
length (1 to N), "value" = price for that length, "capacity" = N. You
can use each length as many times as you want (cut multiple pieces of
the same length) — exactly unbounded supply.
```

```cpp
int rodCutting(vector<int>& price, int n) {
    vector<int> length(n);
    for (int i = 0; i < n; i++) length[i] = i + 1;
    return unboundedKnapsackOpt(n, n, length, price);   // reuse L23 directly
}
// TC: O(N^2), SC: O(N)
```


---

## 📌 L25 — Longest Common Subsequence (DP 25)

```
Two strings s1 (len n), s2 (len m). Find the length of their longest
common subsequence. FOUNDATIONAL problem for the entire "DP on Strings"
cluster (DP 25–34).

RECURRENCE (1-indexed to make base cases clean):
  f(i,j) = 1 + f(i-1,j-1)              if s1[i-1] == s2[j-1]  (match — advance both)
  f(i,j) = max(f(i-1,j), f(i,j-1))     otherwise              (skip one char from either string)
BASE CASE: f(0, j) = f(i, 0) = 0  (an empty string has LCS length 0 with anything)
```

```cpp
// ── MEMOIZATION ─────────────────────────────────────────
int f(int i, int j, string& s1, string& s2, vector<vector<int>>& dp) {
    if (i == 0 || j == 0) return 0;
    if (dp[i][j] != -1) return dp[i][j];
    if (s1[i - 1] == s2[j - 1]) return dp[i][j] = 1 + f(i - 1, j - 1, s1, s2, dp);
    return dp[i][j] = max(f(i - 1, j, s1, s2, dp), f(i, j - 1, s1, s2, dp));
}
// call as f(n, m, s1, s2, dp)
// TC: O(N*M), SC: O(N*M) + O(N+M) stack

// ── TABULATION ──────────────────────────────────────────
int lcsTab(string s1, string s2) {
    int n = s1.size(), m = s2.size();
    vector<vector<int>> dp(n + 1, vector<int>(m + 1, 0));   // row/col 0 = base case, already 0
    for (int i = 1; i <= n; i++)
        for (int j = 1; j <= m; j++) {
            if (s1[i - 1] == s2[j - 1]) dp[i][j] = 1 + dp[i - 1][j - 1];
            else dp[i][j] = max(dp[i - 1][j], dp[i][j - 1]);
        }
    return dp[n][m];
}
// TC: O(N*M), SC: O(N*M)

// ── SPACE OPTIMIZATION ───────────────────────────────────
int lcsOpt(string s1, string s2) {
    int n = s1.size(), m = s2.size();
    vector<int> prev(m + 1, 0), curr(m + 1, 0);
    for (int i = 1; i <= n; i++) {
        for (int j = 1; j <= m; j++) {
            if (s1[i - 1] == s2[j - 1]) curr[j] = 1 + prev[j - 1];
            else curr[j] = max(prev[j], curr[j - 1]);
        }
        prev = curr;
    }
    return prev[m];
}
// TC: O(N*M), SC: O(M)
```
**MEMORY AID:** 1-indexing the DP table (size (N+1) x (M+1), row/col 0 = empty-string base case) is the standard trick for every "DP on Strings" problem — it avoids a mess of `i==0`/`j==0` special-casing inside the loop that 0-indexing would otherwise force.

---

## 📌 L26 — Print the Longest Common Subsequence (DP 26)

```
Same as L25, but reconstruct the ACTUAL subsequence, not just its
length. Requires the FULL 2D table (no space optimization possible —
you need to walk the table backward to recover the choices made).

KEY IDEA: build the full tabulation table exactly like L25. Then start
at dp[n][m] and walk backward: if s1[i-1]==s2[j-1], that character IS
part of the LCS — prepend it, move diagonally (i--, j--). Otherwise
move toward whichever of dp[i-1][j] / dp[i][j-1] is larger (the
direction the max() came from).
```

```cpp
string printLCS(string s1, string s2) {
    int n = s1.size(), m = s2.size();
    vector<vector<int>> dp(n + 1, vector<int>(m + 1, 0));
    for (int i = 1; i <= n; i++)
        for (int j = 1; j <= m; j++) {
            if (s1[i - 1] == s2[j - 1]) dp[i][j] = 1 + dp[i - 1][j - 1];
            else dp[i][j] = max(dp[i - 1][j], dp[i][j - 1]);
        }

    int len = dp[n][m];
    string lcs(len, ' ');
    int i = n, j = m, idx = len - 1;
    while (i > 0 && j > 0) {
        if (s1[i - 1] == s2[j - 1]) {
            lcs[idx] = s1[i - 1];
            idx--; i--; j--;
        } else if (dp[i - 1][j] > dp[i][j - 1]) {
            i--;
        } else {
            j--;
        }
    }
    return lcs;
}
// TC: O(N*M), SC: O(N*M) — the full table is mandatory here
```

---

## 📌 L27 — Longest Common Substring (DP 27)

```
Like L25, but the matched portion must be CONSECUTIVE (a substring, not
just a subsequence). Only ONE change to the recurrence's "match" branch
matters: on a mismatch, the streak breaks completely — reset to 0
rather than falling back to max(up, left).
RECURRENCE:
  dp[i][j] = 1 + dp[i-1][j-1]   if s1[i-1] == s2[j-1]
  dp[i][j] = 0                  otherwise   (NOT max — hard reset)
ANSWER = the maximum value that ever appears anywhere in the table
         (the best streak might end at any (i,j), not necessarily at
         the bottom-right corner) — so this is tabulation-ONLY, since
         memoization's "what's the answer starting from index i" framing
         doesn't naturally track a running streak that resets.
```

```cpp
// ── TABULATION ──────────────────────────────────────────
int longestCommonSubstrTab(string s1, string s2) {
    int n = s1.size(), m = s2.size();
    vector<vector<int>> dp(n + 1, vector<int>(m + 1, 0));
    int ans = 0;
    for (int i = 1; i <= n; i++) {
        for (int j = 1; j <= m; j++) {
            if (s1[i - 1] == s2[j - 1]) {
                dp[i][j] = 1 + dp[i - 1][j - 1];
                ans = max(ans, dp[i][j]);
            } else {
                dp[i][j] = 0;               // hard reset, not max()
            }
        }
    }
    return ans;
}
// TC: O(N*M), SC: O(N*M)

// ── SPACE OPTIMIZATION ───────────────────────────────────
int longestCommonSubstrOpt(string s1, string s2) {
    int n = s1.size(), m = s2.size();
    vector<int> prev(m + 1, 0), curr(m + 1, 0);
    int ans = 0;
    for (int i = 1; i <= n; i++) {
        for (int j = 1; j <= m; j++) {
            if (s1[i - 1] == s2[j - 1]) {
                curr[j] = 1 + prev[j - 1];
                ans = max(ans, curr[j]);
            } else {
                curr[j] = 0;
            }
        }
        prev = curr;
    }
    return ans;
}
// TC: O(N*M), SC: O(M)
```
**KEY:** "Substring" (consecutive) vs "subsequence" (order-preserving but gaps allowed) is a recurring fork throughout DP on Strings — substring problems reset to 0 on a mismatch, subsequence problems fall back to a max() of neighbors instead.

---

## 📌 L28 — Longest Palindromic Subsequence (DP 28)

```
Find the length of the longest subsequence of a string that is itself
a palindrome.
KEY IDEA — reduce directly to L25: a subsequence is palindromic iff it
reads the same forward and backward, i.e. iff it's a common subsequence
between the string and ITS OWN REVERSE. So: LCS(s, reverse(s)).
```

```cpp
int longestPalindromeSubseq(string s) {
    string t = s;
    reverse(t.begin(), t.end());
    return lcsOpt(s, t);      // reuse L25 directly
}
// TC: O(N^2), SC: O(N)
```

---

## 📌 L29 — Minimum Insertions to Make String Palindrome (DP 29)

```
Minimum characters to INSERT anywhere to make the string a palindrome.
KEY IDEA: characters already part of a palindromic subsequence never
need an insertion partnered for them — only the LEFTOVER characters do.
answer = n - longestPalindromicSubsequenceLength(s)   (reuses L28)
```

```cpp
int minInsertions(string s) {
    return s.size() - longestPalindromeSubseq(s);   // reuse L28
}
// TC: O(N^2), SC: O(N)
```

---

## 📌 L30 — Minimum Insertions/Deletions to Convert String A to String B (DP 30)

```
Convert s1 into s2 using ONLY insertions and deletions (no replace).
Minimum total operations.
KEY IDEA: whatever is in the LCS of s1 and s2 never needs to be touched
— everything else in s1 must be DELETED, and everything else in s2
must be INSERTED.
  deletions = len(s1) - LCS(s1, s2)
  insertions = len(s2) - LCS(s1, s2)
  answer = deletions + insertions
```

```cpp
int minDistanceInsertDelete(string s1, string s2) {
    int lcs = lcsOpt(s1, s2);         // reuse L25
    int deletions = s1.size() - lcs;
    int insertions = s2.size() - lcs;
    return deletions + insertions;
}
// TC: O(N*M), SC: O(M)
```

---

## 📌 L31 — Shortest Common Supersequence (DP 31)

```
Build the SHORTEST string that contains both s1 and s2 as subsequences.
KEY IDEA: same backward-walk idea as L26 (Print LCS), but instead of
only appending matched characters, ALSO append the non-matched
character from whichever string the walk steps through. Length works
out to exactly len(s1) + len(s2) - LCS(s1, s2) — but building it
requires the full walk, not just the formula, since you need the
actual merged string.
```

```cpp
string shortestCommonSupersequence(string s1, string s2) {
    int n = s1.size(), m = s2.size();
    vector<vector<int>> dp(n + 1, vector<int>(m + 1, 0));
    for (int i = 1; i <= n; i++)
        for (int j = 1; j <= m; j++) {
            if (s1[i - 1] == s2[j - 1]) dp[i][j] = 1 + dp[i - 1][j - 1];
            else dp[i][j] = max(dp[i - 1][j], dp[i][j - 1]);
        }

    string result;
    int i = n, j = m;
    while (i > 0 && j > 0) {
        if (s1[i - 1] == s2[j - 1]) {
            result += s1[i - 1];
            i--; j--;
        } else if (dp[i - 1][j] > dp[i][j - 1]) {
            result += s1[i - 1]; i--;
        } else {
            result += s2[j - 1]; j--;
        }
    }
    while (i > 0) { result += s1[i - 1]; i--; }   // leftover prefix of s1
    while (j > 0) { result += s2[j - 1]; j--; }   // leftover prefix of s2
    reverse(result.begin(), result.end());
    return result;
}
// TC: O(N*M), SC: O(N*M) — full table needed for the backward walk
```


---

## 📌 L32 — Distinct Subsequences (DP 32)

```
Count how many times string t appears as a subsequence of string s
(LC Hard). First of 3 "string matching" problems in this cluster.
RECURRENCE (i indexes s, j indexes t):
  if s[i-1] == t[j-1]: f(i,j) = f(i-1,j-1) + f(i-1,j)
                                  \_match & advance both_/  \_skip s[i-1] anyway_/
                        (both options count — you might reuse an EARLIER
                         occurrence of this same character in s instead)
  else:                 f(i,j) = f(i-1,j)     (s[i-1] can't contribute — skip it)
BASE CASE: f(i, 0) = 1 (empty t is a subsequence of anything, exactly 1 way)
           f(0, j>0) = 0 (can't form a non-empty t from an empty s)
```

```cpp
// ── MEMOIZATION ─────────────────────────────────────────
int f(int i, int j, string& s, string& t, vector<vector<int>>& dp) {
    if (j == 0) return 1;
    if (i == 0) return 0;
    if (dp[i][j] != -1) return dp[i][j];
    int ans;
    if (s[i - 1] == t[j - 1])
        ans = f(i - 1, j - 1, s, t, dp) + f(i - 1, j, s, t, dp);
    else
        ans = f(i - 1, j, s, t, dp);
    return dp[i][j] = ans;
}
// TC: O(N*M), SC: O(N*M) + O(N) stack (use long long / mod for large counts)

// ── TABULATION ──────────────────────────────────────────
int numDistinctTab(string s, string t) {
    int n = s.size(), m = t.size();
    vector<vector<double>> dp(n + 1, vector<double>(m + 1, 0));
    for (int i = 0; i <= n; i++) dp[i][0] = 1;
    for (int i = 1; i <= n; i++)
        for (int j = 1; j <= m; j++) {
            if (s[i - 1] == t[j - 1]) dp[i][j] = dp[i - 1][j - 1] + dp[i - 1][j];
            else dp[i][j] = dp[i - 1][j];
        }
    return (int)dp[n][m];
}
// TC: O(N*M), SC: O(N*M)

// ── SPACE OPTIMIZATION ───────────────────────────────────
int numDistinctOpt(string s, string t) {
    int n = s.size(), m = t.size();
    vector<double> prev(m + 1, 0), curr(m + 1, 0);
    prev[0] = curr[0] = 1;
    for (int i = 1; i <= n; i++) {
        for (int j = 1; j <= m; j++) {
            if (s[i - 1] == t[j - 1]) curr[j] = prev[j - 1] + prev[j];
            else curr[j] = prev[j];
        }
        prev = curr;
    }
    return (int)prev[m];
}
// TC: O(N*M), SC: O(M)
```

---

## 📌 L33 — Edit Distance (DP 33)

```
Minimum operations (insert / delete / replace) to convert s1 into s2
(LC Hard). RECURRENCE:
  if s1[i-1] == s2[j-1]: f(i,j) = f(i-1,j-1)              (chars already match, no op needed)
  else:                  f(i,j) = 1 + min( f(i-1,j-1),      [replace]
                                            f(i-1,j),        [delete from s1]
                                            f(i,j-1) )       [insert into s1]
BASE CASE: f(0,j) = j (insert all of s2's first j chars), f(i,0) = i (delete all of s1's first i chars)
```

```cpp
// ── MEMOIZATION ─────────────────────────────────────────
int f(int i, int j, string& s1, string& s2, vector<vector<int>>& dp) {
    if (i == 0) return j;
    if (j == 0) return i;
    if (dp[i][j] != -1) return dp[i][j];
    if (s1[i - 1] == s2[j - 1]) return dp[i][j] = f(i - 1, j - 1, s1, s2, dp);
    int insertOp = f(i, j - 1, s1, s2, dp);
    int deleteOp = f(i - 1, j, s1, s2, dp);
    int replaceOp = f(i - 1, j - 1, s1, s2, dp);
    return dp[i][j] = 1 + min({insertOp, deleteOp, replaceOp});
}
// TC: O(N*M), SC: O(N*M) + O(N) stack

// ── TABULATION ──────────────────────────────────────────
int editDistanceTab(string s1, string s2) {
    int n = s1.size(), m = s2.size();
    vector<vector<int>> dp(n + 1, vector<int>(m + 1, 0));
    for (int j = 0; j <= m; j++) dp[0][j] = j;
    for (int i = 0; i <= n; i++) dp[i][0] = i;
    for (int i = 1; i <= n; i++)
        for (int j = 1; j <= m; j++) {
            if (s1[i - 1] == s2[j - 1]) dp[i][j] = dp[i - 1][j - 1];
            else dp[i][j] = 1 + min({dp[i][j - 1], dp[i - 1][j], dp[i - 1][j - 1]});
        }
    return dp[n][m];
}
// TC: O(N*M), SC: O(N*M)

// ── SPACE OPTIMIZATION ───────────────────────────────────
int editDistanceOpt(string s1, string s2) {
    int n = s1.size(), m = s2.size();
    vector<int> prev(m + 1, 0), curr(m + 1, 0);
    for (int j = 0; j <= m; j++) prev[j] = j;
    for (int i = 1; i <= n; i++) {
        curr[0] = i;
        for (int j = 1; j <= m; j++) {
            if (s1[i - 1] == s2[j - 1]) curr[j] = prev[j - 1];
            else curr[j] = 1 + min({curr[j - 1], prev[j], prev[j - 1]});
        }
        prev = curr;
    }
    return prev[m];
}
// TC: O(N*M), SC: O(M)
```

---

## 📌 L34 — Wildcard Matching (DP 34)

```
Match string s1 against pattern s2 which may contain '?' (any single
char) and '*' (any sequence, including empty) (LC Hard).
RECURRENCE:
  if s1[i-1]==s2[j-1] or s2[j-1]=='?':  f(i,j) = f(i-1,j-1)
  if s2[j-1] == '*':                    f(i,j) = f(i-1,j) OR f(i,j-1)
                                            \_'*' matches 1+ chars_/  \_'*' matches empty_/
  else: false (no match)
BASE CASE: f(0,0) = true. f(0, j>0) = true only if s2[0..j-1] is all
'*' (an all-star pattern can match an empty string). f(i>0, 0) = false.
```

```cpp
// ── MEMOIZATION ─────────────────────────────────────────
bool f(int i, int j, string& s1, string& s2, vector<vector<int>>& dp) {
    if (i == 0 && j == 0) return true;
    if (i > 0 && j == 0) return false;
    if (i == 0 && j > 0) {
        for (int k = 1; k <= j; k++) if (s2[k - 1] != '*') return false;
        return true;
    }
    if (dp[i][j] != -1) return dp[i][j];
    if (s1[i - 1] == s2[j - 1] || s2[j - 1] == '?')
        return dp[i][j] = f(i - 1, j - 1, s1, s2, dp);
    if (s2[j - 1] == '*')
        return dp[i][j] = f(i - 1, j, s1, s2, dp) || f(i, j - 1, s1, s2, dp);
    return dp[i][j] = false;
}
// TC: O(N*M), SC: O(N*M) + O(N) stack — the i==0 loop makes worst case O(N*M*M), see note below

// ── TABULATION ──────────────────────────────────────────
bool wildcardTab(string s1, string s2) {
    int n = s1.size(), m = s2.size();
    vector<vector<bool>> dp(n + 1, vector<bool>(m + 1, false));
    dp[0][0] = true;
    for (int j = 1; j <= m; j++)
        dp[0][j] = dp[0][j - 1] && (s2[j - 1] == '*');   // O(1) per cell, no inner loop needed
    for (int i = 1; i <= n; i++)
        for (int j = 1; j <= m; j++) {
            if (s1[i - 1] == s2[j - 1] || s2[j - 1] == '?')
                dp[i][j] = dp[i - 1][j - 1];
            else if (s2[j - 1] == '*')
                dp[i][j] = dp[i - 1][j] || dp[i][j - 1];
            else
                dp[i][j] = false;
        }
    return dp[n][m];
}
// TC: O(N*M), SC: O(N*M)

// ── SPACE OPTIMIZATION ───────────────────────────────────
bool wildcardOpt(string s1, string s2) {
    int n = s1.size(), m = s2.size();
    vector<bool> prev(m + 1, false), curr(m + 1, false);
    prev[0] = true;
    for (int j = 1; j <= m; j++) prev[j] = prev[j - 1] && (s2[j - 1] == '*');
    for (int i = 1; i <= n; i++) {
        curr[0] = false;
        for (int j = 1; j <= m; j++) {
            if (s1[i - 1] == s2[j - 1] || s2[j - 1] == '?')
                curr[j] = prev[j - 1];
            else if (s2[j - 1] == '*')
                curr[j] = prev[j] || curr[j - 1];
            else
                curr[j] = false;
        }
        prev = curr;
    }
    return prev[m];
}
// TC: O(N*M), SC: O(M)
```
**KEY:** the tabulation version's base-case row (`dp[0][j] = dp[0][j-1] && s2[j-1]=='*'`) is a strictly better O(1)-per-cell way to handle "can an all-star prefix match empty" than the memoized version's inner scanning loop — this base-case cleanup is a big part of why tabulation is often preferred once the recursion is fully understood, not just the removed stack overhead.


---

## 📌 L35 — Best Time to Buy and Sell Stock (DP 35)

```
Array of prices by day. AT MOST ONE buy and ONE sell (buy must precede
sell). Maximize profit. This specific problem is simple enough that
Striver solves it with a single greedy pass rather than the DP 36-40
"buy/sell state machine" template — included here for completeness
since it's the series' entry point into DP on Stocks.
```

```cpp
int maxProfit(vector<int>& prices) {
    int minPrice = INT_MAX, maxProfit = 0;
    for (int price : prices) {
        minPrice = min(minPrice, price);
        maxProfit = max(maxProfit, price - minPrice);
    }
    return maxProfit;
}
// TC: O(N), SC: O(1)
```

---

## 📌 L36 — Buy and Sell Stock II: Unlimited Transactions (DP 36)

```
Unlimited buy/sell transactions allowed, but you must SELL before you
BUY again (no overlapping holdings). Maximize total profit.
STATE: (day, canBuy) — canBuy=1 means you're free to buy today,
canBuy=0 means you're currently holding and must sell first.
RECURRENCE: f(day, buy) =
  if buy: max( -prices[day] + f(day+1, 0),  f(day+1, 1) )
              \___buy today___/              \_skip___/
  if sell: max( prices[day] + f(day+1, 1),  f(day+1, 0) )
               \___sell today___/            \_skip___/
```

```cpp
// ── MEMOIZATION ─────────────────────────────────────────
int f(int day, int buy, vector<int>& prices, vector<vector<int>>& dp) {
    if (day == prices.size()) return 0;
    if (dp[day][buy] != -1) return dp[day][buy];
    int profit;
    if (buy)
        profit = max(-prices[day] + f(day + 1, 0, prices, dp), f(day + 1, 1, prices, dp));
    else
        profit = max(prices[day] + f(day + 1, 1, prices, dp), f(day + 1, 0, prices, dp));
    return dp[day][buy] = profit;
}
// call as f(0, 1, prices, dp)
// TC: O(N*2), SC: O(N*2) + O(N) stack

// ── TABULATION ──────────────────────────────────────────
int maxProfitUnlimitedTab(vector<int>& prices) {
    int n = prices.size();
    vector<vector<int>> dp(n + 1, vector<int>(2, 0));
    for (int day = n - 1; day >= 0; day--) {
        for (int buy = 0; buy <= 1; buy++) {
            if (buy)
                dp[day][buy] = max(-prices[day] + dp[day + 1][0], dp[day + 1][1]);
            else
                dp[day][buy] = max(prices[day] + dp[day + 1][1], dp[day + 1][0]);
        }
    }
    return dp[0][1];
}
// TC: O(N*2), SC: O(N*2)

// ── SPACE OPTIMIZATION ───────────────────────────────────
int maxProfitUnlimitedOpt(vector<int>& prices) {
    int n = prices.size();
    vector<int> ahead(2, 0), curr(2, 0);
    for (int day = n - 1; day >= 0; day--) {
        for (int buy = 0; buy <= 1; buy++) {
            if (buy)
                curr[buy] = max(-prices[day] + ahead[0], ahead[1]);
            else
                curr[buy] = max(prices[day] + ahead[1], ahead[0]);
        }
        ahead = curr;
    }
    return ahead[1];
}
// TC: O(N*2), SC: O(1)
```
**KEY:** "DP on Stocks" states are always framed as (day, some small fixed-size status) — buy/sell toggle here, transaction count in L38, holding/cooldown in L39. This makes every stock problem a 2D DP that space-optimizes to O(1) once you notice the status dimension is tiny and fixed.

---

## 📌 L37 — Buy and Sell Stocks III: At Most 2 Transactions (DP 37)

```
Same as L36, but AT MOST 2 total transactions (a transaction = one
buy + one sell pair). STATE grows to (day, buy, transactionsUsed):
`transactionsUsed` counts 0,1,2,3 — cap the recursion once it hits the
limit (implemented here as a combined "operation number" 0-3, where
even = buy turn, odd = sell turn, capped at 4 total operations = 2 txns).
```

```cpp
// ── MEMOIZATION ─────────────────────────────────────────
int f(int ind, int operationNo, vector<int>& prices, vector<vector<int>>& dp) {
    if (operationNo == 4 || ind == prices.size()) return 0;
    if (dp[ind][operationNo] != -1) return dp[ind][operationNo];
    int profit;
    if (operationNo % 2 == 0)   // even = buy turn
        profit = max(-prices[ind] + f(ind + 1, operationNo + 1, prices, dp),
                      f(ind + 1, operationNo, prices, dp));
    else                        // odd = sell turn
        profit = max(prices[ind] + f(ind + 1, operationNo + 1, prices, dp),
                      f(ind + 1, operationNo, prices, dp));
    return dp[ind][operationNo] = profit;
}
// call as f(0, 0, prices, dp)
// TC: O(N*4), SC: O(N*4) + O(N) stack

// ── TABULATION ──────────────────────────────────────────
int maxProfitTwoTxnTab(vector<int>& prices) {
    int n = prices.size();
    vector<vector<int>> dp(n + 1, vector<int>(5, 0));
    for (int ind = n - 1; ind >= 0; ind--) {
        for (int op = 3; op >= 0; op--) {
            if (op % 2 == 0)
                dp[ind][op] = max(-prices[ind] + dp[ind + 1][op + 1], dp[ind + 1][op]);
            else
                dp[ind][op] = max(prices[ind] + dp[ind + 1][op + 1], dp[ind + 1][op]);
        }
    }
    return dp[0][0];
}
// TC: O(N*4), SC: O(N*4)

// ── SPACE OPTIMIZATION ───────────────────────────────────
int maxProfitTwoTxnOpt(vector<int>& prices) {
    int n = prices.size();
    vector<int> ahead(5, 0), curr(5, 0);
    for (int ind = n - 1; ind >= 0; ind--) {
        for (int op = 3; op >= 0; op--) {
            if (op % 2 == 0)
                curr[op] = max(-prices[ind] + ahead[op + 1], ahead[op]);
            else
                curr[op] = max(prices[ind] + ahead[op + 1], ahead[op]);
        }
        ahead = curr;
    }
    return ahead[0];
}
// TC: O(N*4), SC: O(1)
```

---

## 📌 L38 — Buy and Sell Stock IV: At Most K Transactions (DP 38)

```
Generalize L37 from "at most 2" to "at most K" transactions. Same
state shape, just parameterized by K instead of hardcoded to 4 operations.
```

```cpp
// ── MEMOIZATION ─────────────────────────────────────────
int f(int ind, int operationNo, int k, vector<int>& prices, vector<vector<int>>& dp) {
    if (operationNo == 2 * k || ind == prices.size()) return 0;
    if (dp[ind][operationNo] != -1) return dp[ind][operationNo];
    int profit;
    if (operationNo % 2 == 0)
        profit = max(-prices[ind] + f(ind + 1, operationNo + 1, k, prices, dp),
                      f(ind + 1, operationNo, k, prices, dp));
    else
        profit = max(prices[ind] + f(ind + 1, operationNo + 1, k, prices, dp),
                      f(ind + 1, operationNo, k, prices, dp));
    return dp[ind][operationNo] = profit;
}
// TC: O(N * 2K), SC: O(N * 2K) + O(N) stack

// ── SPACE OPTIMIZATION (tabulation follows L37's exact pattern) ──
int maxProfitKTxnOpt(int k, vector<int>& prices) {
    int n = prices.size();
    vector<int> aheadRow(2 * k + 1, 0), currRow(2 * k + 1, 0);
    for (int ind = n - 1; ind >= 0; ind--) {
        for (int op = 2 * k - 1; op >= 0; op--) {
            if (op % 2 == 0)
                currRow[op] = max(-prices[ind] + aheadRow[op + 1], aheadRow[op]);
            else
                currRow[op] = max(prices[ind] + aheadRow[op + 1], aheadRow[op]);
        }
        aheadRow = currRow;
    }
    return aheadRow[0];
}
// TC: O(N * 2K), SC: O(K)
```
**KEY:** L37 IS L38 with k hardcoded to 2 — once you can write the K-transaction version, delete L37's special-cased code entirely; it's strictly redundant.

---

## 📌 L39 — Buy and Sell Stocks With Cooldown (DP 39)

```
Unlimited transactions (like L36), but after SELLING you must wait one
day before buying again (a "cooldown"). Only change from L36: after a
sell, the next state jumps to day+2 instead of day+1.
RECURRENCE: f(day, buy) =
  if buy:  max( -prices[day] + f(day+1, 0),  f(day+1, 1) )
  if sell: max( prices[day] + f(day+2, 1),   f(day+1, 0) )   ← day+2, the cooldown
```

```cpp
// ── MEMOIZATION ─────────────────────────────────────────
int f(int day, int buy, vector<int>& prices, vector<vector<int>>& dp) {
    if (day >= prices.size()) return 0;
    if (dp[day][buy] != -1) return dp[day][buy];
    int profit;
    if (buy)
        profit = max(-prices[day] + f(day + 1, 0, prices, dp), f(day + 1, 1, prices, dp));
    else
        profit = max(prices[day] + f(day + 2, 1, prices, dp), f(day + 1, 0, prices, dp));
    return dp[day][buy] = profit;
}
// TC: O(N*2), SC: O(N*2) + O(N) stack

// ── SPACE OPTIMIZATION (needs TWO "ahead" states — day+1 and day+2!) ──
int maxProfitCooldownOpt(vector<int>& prices) {
    int n = prices.size();
    vector<int> ahead1(2, 0), ahead2(2, 0), curr(2, 0);   // day+1, day+2
    for (int day = n - 1; day >= 0; day--) {
        for (int buy = 0; buy <= 1; buy++) {
            if (buy)
                curr[buy] = max(-prices[day] + ahead1[0], ahead1[1]);
            else
                curr[buy] = max(prices[day] + ahead2[1], ahead1[0]);
        }
        ahead2 = ahead1;
        ahead1 = curr;
    }
    return ahead1[1];
}
// TC: O(N*2), SC: O(1)
```
**KEY:** whenever a recurrence reaches TWO steps ahead (day+2, not just day+1), space optimization needs TWO rolling "future" states instead of one — same principle as Fibonacci needing `prev` AND `prev2`, just relabeled.

---

## 📌 L40 — Buy and Sell Stocks With Transaction Fee (DP 40)

```
Unlimited transactions (like L36), but every SELL incurs a flat fee.
Only change from L36: subtract `fee` at the moment of selling.
```

```cpp
// ── SPACE OPTIMIZATION (memo/tabulation follow L36's exact pattern) ──
int maxProfitFeeOpt(vector<int>& prices, int fee) {
    int n = prices.size();
    vector<int> ahead(2, 0), curr(2, 0);
    for (int day = n - 1; day >= 0; day--) {
        for (int buy = 0; buy <= 1; buy++) {
            if (buy)
                curr[buy] = max(-prices[day] + ahead[0], ahead[1]);
            else
                curr[buy] = max(prices[day] - fee + ahead[1], ahead[0]);   // fee subtracted on sell
        }
        ahead = curr;
    }
    return ahead[1];
}
// TC: O(N*2), SC: O(1)
```


---

## 📌 L41 — Longest Increasing Subsequence — Memoization (DP 41)

```
Find the length of the longest STRICTLY increasing subsequence in an
array (LC 300). FOUNDATIONAL problem for the LIS cluster (DP 41-47).
RECURRENCE (index + "previous index taken", offset by 1 to represent "none yet"):
  f(ind, prev_ind) = max( f(ind+1, ind)         + 1,    [TAKE, only if prev_ind==-1 or arr[ind] > arr[prev_ind]]
                           f(ind+1, prev_ind) )           [SKIP]
```

```cpp
// ── MEMOIZATION ─────────────────────────────────────────
int f(int ind, int prevInd, vector<int>& arr, vector<vector<int>>& dp) {
    if (ind == arr.size()) return 0;
    if (dp[ind][prevInd + 1] != -1) return dp[ind][prevInd + 1];   // +1 shift for prevInd == -1
    int notTake = f(ind + 1, prevInd, arr, dp);
    int take = 0;
    if (prevInd == -1 || arr[ind] > arr[prevInd])
        take = 1 + f(ind + 1, ind, arr, dp);
    return dp[ind][prevInd + 1] = max(take, notTake);
}
// call as f(0, -1, arr, dp)
// TC: O(N*N), SC: O(N*N) + O(N) stack

// ── TABULATION ──────────────────────────────────────────
int lengthOfLISTab(vector<int>& arr) {
    int n = arr.size();
    vector<vector<int>> dp(n + 1, vector<int>(n + 1, 0));
    for (int ind = n - 1; ind >= 0; ind--) {
        for (int prevInd = ind - 1; prevInd >= -1; prevInd--) {
            int notTake = dp[ind + 1][prevInd + 1];
            int take = 0;
            if (prevInd == -1 || arr[ind] > arr[prevInd])
                take = 1 + dp[ind + 1][ind + 1];
            dp[ind][prevInd + 1] = max(take, notTake);
        }
    }
    return dp[0][0];
}
// TC: O(N*N), SC: O(N*N)
```
**KEY:** the O(N²) memo/tabulation above generalizes well and is what most interviews want first. A cleaner, more commonly-taught O(N²) formulation exists too (`dp[i]` = length of the LIS ENDING exactly at index i) — see the tabulation-with-print version in L42, which is the one to actually memorize for coding it fast under interview pressure.

---

## 📌 L42 — Printing the Longest Increasing Subsequence (DP 42)

```
Same problem, but using the more standard, PRINTABLE formulation:
  dp[i] = length of the LIS that ENDS exactly at index i (not "starting from i")
  dp[i] = 1 + max( dp[j] for all j < i where arr[j] < arr[i] ),  or 1 if none qualify
ANSWER = max(dp[i]) over all i. This shape also makes RECONSTRUCTING
the actual subsequence easy: track a hash[i] = the index that dp[i]
came from, then walk hash[] backward from whichever i had the max dp[i].
```

```cpp
// ── TABULATION (this formulation only — it's inherently "bottom-up") ──
vector<int> printLIS(vector<int>& arr) {
    int n = arr.size();
    vector<int> dp(n, 1), hash(n);
    int maxi = 1, lastIndex = 0;
    for (int i = 0; i < n; i++) {
        hash[i] = i;                         // initially, each points to itself
        for (int prevInd = 0; prevInd < i; prevInd++) {
            if (arr[prevInd] < arr[i] && 1 + dp[prevInd] > dp[i]) {
                dp[i] = 1 + dp[prevInd];
                hash[i] = prevInd;
            }
        }
        if (dp[i] > maxi) { maxi = dp[i]; lastIndex = i; }
    }
    vector<int> lis;
    lis.push_back(arr[lastIndex]);
    while (hash[lastIndex] != lastIndex) {   // walk back until a self-pointing index (chain start)
        lastIndex = hash[lastIndex];
        lis.push_back(arr[lastIndex]);
    }
    reverse(lis.begin(), lis.end());
    return lis;
}
// TC: O(N^2), SC: O(N) — this formulation never needed an N x N table to begin with
```

---

## 📌 L43 — LIS via Binary Search: O(N log N) (DP 43)

```
For N up to 10^5, the O(N²) approach TLEs. A genuinely different
technique gets this to O(N log N) — NOT a memo/tab/space-opt DP
progression, so it's presented as one clean algorithm.

KEY IDEA: maintain a working array `temp` that is NOT the actual LIS,
but has the SAME LENGTH as the true LIS at every point. For each new
element x: if x is larger than every element in temp, append it
(extends the LIS). Otherwise, binary-search for the smallest element in
temp that is >= x, and OVERWRITE it with x (keeps temp's potential for
a better/longer future subsequence without changing its current
length). temp's final SIZE is the LIS length — its contents are not
the actual LIS itself.
```

```cpp
int lengthOfLISBinarySearch(vector<int>& arr) {
    vector<int> temp;
    temp.push_back(arr[0]);
    int len = 1;
    for (int i = 1; i < arr.size(); i++) {
        if (arr[i] > temp.back()) {
            temp.push_back(arr[i]);
            len++;
        } else {
            int idx = lower_bound(temp.begin(), temp.end(), arr[i]) - temp.begin();
            temp[idx] = arr[i];
        }
    }
    return len;
}
// TC: O(N log N), SC: O(N)
```
**GOTCHA:** `temp` is a common point of confusion — it is NOT guaranteed to be an actual increasing subsequence that occurred in the array (elements can get overwritten out of their original relationship). Only its LENGTH is meaningful.

---

## 📌 L44 — Largest Divisible Subset (DP 44)

```
Find the largest subset where every pair of elements (a, b) satisfies
a % b == 0 or b % a == 0. KEY IDEA: SORT the array first — once sorted,
"every pair divides" reduces to "every CONSECUTIVE pair in the chosen
subsequence divides", turning this into LIS's exact shape (DP 42's
formulation) with the comparison `arr[prevInd] < arr[i]` swapped for
`arr[i] % arr[prevInd] == 0`.
```

```cpp
vector<int> largestDivisibleSubset(vector<int>& arr) {
    sort(arr.begin(), arr.end());               // KEY prerequisite step
    int n = arr.size();
    vector<int> dp(n, 1), hash(n);
    int maxi = 1, lastIndex = 0;
    for (int i = 0; i < n; i++) {
        hash[i] = i;
        for (int prevInd = 0; prevInd < i; prevInd++) {
            if (arr[i] % arr[prevInd] == 0 && 1 + dp[prevInd] > dp[i]) {
                dp[i] = 1 + dp[prevInd];
                hash[i] = prevInd;
            }
        }
        if (dp[i] > maxi) { maxi = dp[i]; lastIndex = i; }
    }
    vector<int> result;
    result.push_back(arr[lastIndex]);
    while (hash[lastIndex] != lastIndex) {
        lastIndex = hash[lastIndex];
        result.push_back(arr[lastIndex]);
    }
    reverse(result.begin(), result.end());
    return result;
}
// TC: O(N log N) sort + O(N^2) DP, SC: O(N)
```

---

## 📌 L45 — Longest String Chain (DP 45)

```
A "chain" is a sequence of words where each next word is formed by
inserting exactly one character into the previous word. Find the
longest such chain.
KEY IDEA: sort words by LENGTH (not lexicographically). Then it's LIS's
shape again: dp[i] = longest chain ending at word i, extended from any
earlier (shorter) word that is a valid "one insertion away" predecessor
— checked via a helper that removes one character at a time from the
longer word and compares to the shorter one.
```

```cpp
bool compare(string& a, string& b) { return a.size() < b.size(); }

bool checkPossible(string& s1, string& s2) {   // is s1 exactly one insertion away from s2?
    if (s1.size() != s2.size() + 1) return false;
    int i = 0, j = 0;
    while (i < s1.size()) {
        if (j < s2.size() && s1[i] == s2[j]) { i++; j++; }
        else i++;
    }
    return i == s1.size() && j == s2.size();
}

int longestStrChain(vector<string>& words) {
    sort(words.begin(), words.end(), compare);
    int n = words.size();
    vector<int> dp(n, 1);
    int maxi = 1;
    for (int i = 0; i < n; i++) {
        for (int prevInd = 0; prevInd < i; prevInd++) {
            if (checkPossible(words[i], words[prevInd]) && 1 + dp[prevInd] > dp[i])
                dp[i] = 1 + dp[prevInd];
        }
        maxi = max(maxi, dp[i]);
    }
    return maxi;
}
// TC: O(N log N) sort + O(N^2 * avgLen) for comparisons, SC: O(N)
```

---

## 📌 L46 — Longest Bitonic Subsequence (DP 46)

```
Find the longest subsequence that first STRICTLY INCREASES then
STRICTLY DECREASES (both parts non-empty, or a pure increasing/
decreasing run counts too depending on the exact variant).
KEY IDEA: compute two arrays using L42's exact LIS-ending-at-i DP:
  dp1[i] = length of LIS ending at i (scan left to right)
  dp2[i] = length of LIS ending at i in the REVERSED array
         = length of longest DECREASING subsequence STARTING at i
The best bitonic sequence peaking at index i has length dp1[i] + dp2[i] - 1
(the "-1" avoids double-counting index i itself). Maximize over all i.
```

```cpp
int longestBitonicSubsequence(vector<int>& arr) {
    int n = arr.size();
    vector<int> dp1(n, 1), dp2(n, 1);
    for (int i = 0; i < n; i++)                          // LIS ending at i, left to right
        for (int prevInd = 0; prevInd < i; prevInd++)
            if (arr[prevInd] < arr[i]) dp1[i] = max(dp1[i], 1 + dp1[prevInd]);

    for (int i = n - 1; i >= 0; i--)                      // LDS starting at i, right to left
        for (int prevInd = n - 1; prevInd > i; prevInd--)
            if (arr[prevInd] < arr[i]) dp2[i] = max(dp2[i], 1 + dp2[prevInd]);

    int maxi = 0;
    for (int i = 0; i < n; i++)
        if (dp1[i] > 1 && dp2[i] > 1)                      // both sides must be non-trivial
            maxi = max(maxi, dp1[i] + dp2[i] - 1);
    return maxi;
}
// TC: O(N^2), SC: O(N)
```

---

## 📌 L47 — Number of Longest Increasing Subsequences (DP 47)

```
Not just the LENGTH of the LIS — count how many DISTINCT subsequences
achieve that maximum length.
KEY IDEA: alongside dp[i] (LIS length ending at i), maintain count[i] =
number of ways to achieve that length ending at i.
  - if extending from prevInd gives a STRICTLY LONGER chain than
    currently known at i → reset count[i] = count[prevInd] (found a
    new best, old ways are no longer maximal)
  - if it TIES the current best length at i → count[i] += count[prevInd]
    (another equally-good way discovered)
Finally, sum count[i] over every i where dp[i] equals the global maximum.
```

```cpp
int findNumberOfLIS(vector<int>& arr) {
    int n = arr.size();
    vector<int> dp(n, 1), count(n, 1);
    int maxi = 1;
    for (int i = 0; i < n; i++) {
        for (int prevInd = 0; prevInd < i; prevInd++) {
            if (arr[prevInd] < arr[i]) {
                if (1 + dp[prevInd] > dp[i]) {
                    dp[i] = 1 + dp[prevInd];
                    count[i] = count[prevInd];              // reset — strictly better path found
                } else if (1 + dp[prevInd] == dp[i]) {
                    count[i] += count[prevInd];              // tie — accumulate ways
                }
            }
        }
        maxi = max(maxi, dp[i]);
    }
    int numberOfLIS = 0;
    for (int i = 0; i < n; i++)
        if (dp[i] == maxi) numberOfLIS += count[i];
    return numberOfLIS;
}
// TC: O(N^2), SC: O(N)
```
**MEMORY AID:** this "reset on strictly-better, accumulate on tie" bookkeeping pattern reappears verbatim in L38's Number of Ways to Arrive at Destination (Graph notes) — same underlying idea, different domain.


---

## 📌 L48 — Matrix Chain Multiplication — Memoization (DP 48)

```
Given an array of matrix dimensions arr[] (matrix i has dimensions
arr[i-1] x arr[i]), find the minimum number of scalar multiplications
needed to multiply the whole chain together. The order in which you
PARENTHESIZE the multiplication changes the total cost — this is what
you're optimizing. FOUNDATIONAL problem for "Partition DP" (DP 48-54).

KEY IDEA — THE PARTITION DP TEMPLATE: pick a "partition point" k between
i and j, solve the two halves independently, combine, and try EVERY
possible k — this is what makes it "Partition DP", distinct from every
prior linear/grid DP.
RECURRENCE: f(i, j) = min over k in [i, j-1] of
    f(i, k) + f(k+1, j) + arr[i-1]*arr[k]*arr[j]
BASE CASE: f(i, j) = 0 when i >= j (a single matrix needs no multiplication)
```

```cpp
// ── MEMOIZATION ─────────────────────────────────────────
int f(int i, int j, vector<int>& arr, vector<vector<int>>& dp) {
    if (i == j) return 0;
    if (dp[i][j] != -1) return dp[i][j];
    int mini = INT_MAX;
    for (int k = i; k <= j - 1; k++) {
        int cost = f(i, k, arr, dp) + f(k + 1, j, arr, dp) + arr[i - 1] * arr[k] * arr[j];
        mini = min(mini, cost);
    }
    return dp[i][j] = mini;
}
// call as f(1, n-1, arr, dp)  where n = arr.size()
// TC: O(N^2) states * O(N) partition choices = O(N^3), SC: O(N^2) + O(N) stack
```
**MEMORY AID:** think of `1 + 2 + 3 * 5` — the parenthesization `(1+2+3)*5` vs `1+(2+3*5)` gives different results; MCM is exactly this idea but for matrix multiplication cost, and "try every partition point k" is the mechanical way to search all parenthesizations without enumerating them explicitly.

---

## 📌 L49 — Matrix Chain Multiplication — Tabulation (DP 49)

```
KEY DIFFICULTY: f(i,j) depends on f(i,k) and f(k+1,j) where the FIRST
index can go UP (i to k) and the SECOND index varies too — neither i
nor j alone increases/decreases monotonically the way earlier DPs did.
FIX: loop `i` from HIGH to LOW (n-1 down to 1) and `j` from `i+1` up to
n-1 — this ordering guarantees every (i,k) and (k+1,j) pair needed has
already been computed by the time you need it, since k+1 > i always
and k < j always, keeping every dependency within the already-filled region.
```

```cpp
int mcmTab(vector<int>& arr) {
    int n = arr.size();
    vector<vector<int>> dp(n, vector<int>(n, 0));
    for (int i = n - 1; i >= 1; i--) {
        for (int j = i + 1; j < n; j++) {
            int mini = INT_MAX;
            for (int k = i; k <= j - 1; k++) {
                int cost = dp[i][k] + dp[k + 1][j] + arr[i - 1] * arr[k] * arr[j];
                mini = min(mini, cost);
            }
            dp[i][j] = mini;
        }
    }
    return dp[1][n - 1];
}
// TC: O(N^3), SC: O(N^2) — NO further space optimization is taught for
//     this pattern: unlike linear/grid DP, the (i,k)/(k+1,j) dependency
//     genuinely spans the WHOLE table, not just 1-2 previous rows.
```
**KEY:** "which direction do I loop the outer indices?" is answered the same way every time in Partition DP: figure out which index has to be SMALLER-magnitude-first for the recurrence's sub-ranges to already be computed, and loop that direction. Here: i decreasing, j increasing (relative to i) — both moving AWAY from the diagonal `i==j` base case, toward the answer at `dp[1][n-1]`.

---

## 📌 L50 — Minimum Cost to Cut the Stick (DP 50)

```
Stick of length N, an array of cut positions. Cost of a cut = current
length of the piece being cut. Minimize total cost across all cuts
(order of cuts is your choice).
KEY IDEA: add 0 and N as virtual "boundary cuts" to the cuts array and
SORT it. Now f(i, j) = min cost to perform all cuts strictly between
boundary cuts[i] and cuts[j], trying every actual cut k in between as
the partition point.
RECURRENCE: f(i, j) = min over k in (i, j) of
    (cuts[j] - cuts[i]) + f(i, k) + f(k, j)
BASE CASE: f(i, j) = 0 if j <= i + 1 (no cuts strictly between them)
```

```cpp
// ── MEMOIZATION ─────────────────────────────────────────
int f(int i, int j, vector<int>& cuts, vector<vector<int>>& dp) {
    if (i > j) return 0;
    if (dp[i][j] != -1) return dp[i][j];
    int mini = INT_MAX;
    for (int ind = i; ind <= j; ind++) {
        int cost = (cuts[j + 1] - cuts[i - 1])
                  + f(i, ind - 1, cuts, dp) + f(ind + 1, j, cuts, dp);
        mini = min(mini, cost);
    }
    return dp[i][j] = mini;
}
int minCost(int n, vector<int>& cuts) {
    int c = cuts.size();
    sort(cuts.begin(), cuts.end());
    cuts.insert(cuts.begin(), 0);
    cuts.push_back(n);
    vector<vector<int>> dp(c + 1, vector<int>(c + 1, -1));
    return f(1, c, cuts, dp);
}
// TC: O(C^3), SC: O(C^2) + O(C) stack

// ── TABULATION ──────────────────────────────────────────
int minCostTab(int n, vector<int>& cuts) {
    int c = cuts.size();
    sort(cuts.begin(), cuts.end());
    cuts.insert(cuts.begin(), 0);
    cuts.push_back(n);
    vector<vector<int>> dp(c + 2, vector<int>(c + 2, 0));
    for (int i = c; i >= 1; i--) {
        for (int j = 1; j <= c; j++) {
            if (i > j) continue;
            int mini = INT_MAX;
            for (int ind = i; ind <= j; ind++) {
                int cost = (cuts[j + 1] - cuts[i - 1]) + dp[i][ind - 1] + dp[ind + 1][j];
                mini = min(mini, cost);
            }
            dp[i][j] = mini;
        }
    }
    return dp[1][c];
}
// TC: O(C^3), SC: O(C^2) — same as MCM, no further space optimization
```
**KEY:** this is literally MCM with a different cost formula — recognizing "cut a segment at some point, pay a cost based on the segment's endpoints, recurse on both halves" as MCM's shape is the whole trick.

---

## 📌 L51 — Burst Balloons (DP 51)

```
N balloons with numbers. Bursting balloon i gives
nums[left] * nums[i] * nums[right] coins, where left/right are the
CURRENTLY ADJACENT balloons (shrinks as you burst more). Maximize total
coins to burst all balloons.

KEY IDEA — THINK BACKWARD: instead of "which balloon do I burst first?"
(hard — changes future adjacency unpredictably), ask "which balloon do
I burst LAST within range [i,j]?" If balloon k is burst LAST in that
range, its neighbors AT THAT MOMENT are guaranteed to be the boundary
elements just outside [i,j] — because everything strictly inside [i,j]
except k has already been cleared by then. This restores the clean
"pick a partition point, combine two independent sub-problems" MCM shape.
Pad the array with 1 at both ends (virtual boundary balloons).
RECURRENCE: f(i, j) = max over k in [i, j] of
    nums[i-1]*nums[k]*nums[j+1] + f(i, k-1) + f(k+1, j)
```

```cpp
// ── MEMOIZATION ─────────────────────────────────────────
int f(int i, int j, vector<int>& a, vector<vector<int>>& dp) {
    if (i > j) return 0;
    if (dp[i][j] != -1) return dp[i][j];
    int maxi = INT_MIN;
    for (int ind = i; ind <= j; ind++) {
        int cost = a[i - 1] * a[ind] * a[j + 1] + f(i, ind - 1, a, dp) + f(ind + 1, j, a, dp);
        maxi = max(maxi, cost);
    }
    return dp[i][j] = maxi;
}
int maxCoins(vector<int>& nums) {
    int n = nums.size();
    vector<int> a(n + 2, 1);
    for (int i = 0; i < n; i++) a[i + 1] = nums[i];      // pad with 1 on both ends
    vector<vector<int>> dp(n + 1, vector<int>(n + 1, -1));
    return f(1, n, a, dp);
}
// TC: O(N^3), SC: O(N^2) + O(N) stack

// ── TABULATION ──────────────────────────────────────────
int maxCoinsTab(vector<int>& nums) {
    int n = nums.size();
    vector<int> a(n + 2, 1);
    for (int i = 0; i < n; i++) a[i + 1] = nums[i];
    vector<vector<int>> dp(n + 2, vector<int>(n + 2, 0));
    for (int i = n; i >= 1; i--) {
        for (int j = i; j <= n; j++) {
            int maxi = INT_MIN;
            for (int ind = i; ind <= j; ind++) {
                int cost = a[i - 1] * a[ind] * a[j + 1] + dp[i][ind - 1] + dp[ind + 1][j];
                maxi = max(maxi, cost);
            }
            dp[i][j] = maxi;
        }
    }
    return dp[1][n];
}
// TC: O(N^3), SC: O(N^2)
```
**KEY:** "think about what's burst/removed/decided LAST, not first" is the single biggest unlock across all of Partition DP — it converts an order-dependent mess into two clean, independent sub-ranges.

---

## 📌 L52 — Evaluate Boolean Expression to True (DP 52)

```
A boolean expression string with T/F and operators &, |, ^ between
them. Count the ways to fully parenthesize it so it evaluates to True.
KEY IDEA: same partition shape — pick an operator k as the LAST one
evaluated, splitting into a left substring [i,k-1] and right substring
[k+1,j]. Track BOTH "ways to make this range True" AND "ways to make it
False" simultaneously (you need both to correctly combine across &, |, ^).
```

```cpp
// ── MEMOIZATION ─────────────────────────────────────────
int MOD = 1000000007;
pair<int,int> f(int i, int j, string& exp, vector<vector<pair<int,int>>>& dp) {
    if (i > j) return {0, 0};
    if (i == j) return exp[i] == 'T' ? make_pair(1, 0) : make_pair(0, 1);
    if (dp[i][j] != make_pair(-1, -1)) return dp[i][j];

    int trueWays = 0, falseWays = 0;
    for (int ind = i + 1; ind <= j - 1; ind += 2) {          // operators sit at odd offsets
        auto [lt, lf] = f(i, ind - 1, exp, dp);
        auto [rt, rf] = f(ind + 1, j, exp, dp);
        int totalWays = ((lt + lf) % MOD) * ((rt + rf) % MOD) % MOD;

        int tw = 0, fw = 0;
        if (exp[ind] == '&') { tw = (lt * rt) % MOD; fw = (totalWays - tw + MOD) % MOD; }
        else if (exp[ind] == '|') { fw = (lf * rf) % MOD; tw = (totalWays - fw + MOD) % MOD; }
        else { tw = (lt * rf + lf * rt) % MOD; fw = (totalWays - tw + MOD) % MOD; }   // '^'

        trueWays = (trueWays + tw) % MOD;
        falseWays = (falseWays + fw) % MOD;
    }
    return dp[i][j] = {trueWays, falseWays};
}
// TC: O(N^3), SC: O(N^2) + O(N) stack
```
**KEY:** carrying a PAIR of counts (true-ways, false-ways) through the recursion — instead of just one number — is what makes combining across `&`/`|`/`^` correct, since e.g. "left is True" alone isn't enough to know how many ways an `|` split produces False (you'd need left-False AND right-False specifically).

---

## 📌 L53 — Palindrome Partitioning II: Minimum Cuts (DP 53)

```
Minimum cuts needed to partition a string so that EVERY resulting piece
is a palindrome.
KEY IDEA — "FRONT PARTITION", a variant of Partition DP: instead of
picking a partition point somewhere in the MIDDLE of a range, decide
the LAST cut before the current prefix ends — f(i) = min cuts for
prefix s[0..i]. Try every possible LAST piece s[j+1..i]: if it's a
palindrome, 1 + f(j) is a candidate (the "1" is the cut separating that
last piece); if the WHOLE prefix s[0..i] is already a palindrome, 0
cuts needed. Precomputing "is s[i..j] a palindrome" via its own small
DP avoids recomputation.
```

```cpp
int minCutPalindromePartition(string s) {
    int n = s.size();
    vector<vector<bool>> isPalin(n, vector<bool>(n, false));
    for (int i = 0; i < n; i++) isPalin[i][i] = true;
    for (int len = 2; len <= n; len++) {
        for (int i = 0; i + len - 1 < n; i++) {
            int j = i + len - 1;
            if (s[i] == s[j]) isPalin[i][j] = (len == 2) || isPalin[i + 1][j - 1];
        }
    }
    vector<int> dp(n, 0);
    for (int i = 0; i < n; i++) {
        if (isPalin[0][i]) { dp[i] = 0; continue; }
        int mini = INT_MAX;
        for (int j = 0; j < i; j++) {
            if (isPalin[j + 1][i])
                mini = min(mini, 1 + dp[j]);
        }
        dp[i] = mini;
    }
    return dp[n - 1];
}
// TC: O(N^2) for the palindrome table + O(N^2) for the cuts DP = O(N^2), SC: O(N^2)
```
**KEY:** "front partition" DPs (this one, and L54) run a SINGLE index forward, deciding "where did the last piece begin?" — structurally simpler than MCM-style DPs which need a full 2D (i,j) RANGE table, because there's only ever one active prefix boundary to track, not two independent sub-ranges.

---

## 📌 L54 — Partition Array for Maximum Sum (DP 54)

```
Partition an array into contiguous subarrays of length AT MOST k. Every
element in a subarray gets REPLACED by that subarray's maximum. Maximize
the resulting array's total sum.
Same "front partition" shape as L53: f(i) = best achievable sum for the
prefix ending at i. Try every possible LAST group length len (1 to k):
that group is [i-len+1, i], contributing len * max(that group), plus
f(i-len) for everything before it.
```

```cpp
// ── MEMOIZATION ─────────────────────────────────────────
int f(int ind, int k, vector<int>& arr, vector<int>& dp) {
    if (ind == arr.size()) return 0;
    if (dp[ind] != -1) return dp[ind];
    int len = 0, maxi = INT_MIN, maxAns = INT_MIN;
    for (int j = ind; j < min((int)arr.size(), ind + k); j++) {
        len++;
        maxi = max(maxi, arr[j]);
        int sum = len * maxi + f(j + 1, k, arr, dp);
        maxAns = max(maxAns, sum);
    }
    return dp[ind] = maxAns;
}
// call as f(0, k, arr, dp)
// TC: O(N*K), SC: O(N) + O(N) stack

// ── TABULATION ──────────────────────────────────────────
int maxSumAfterPartitioningTab(vector<int>& arr, int k) {
    int n = arr.size();
    vector<int> dp(n + 1, 0);
    for (int ind = n - 1; ind >= 0; ind--) {
        int len = 0, maxi = INT_MIN, maxAns = INT_MIN;
        for (int j = ind; j < min(n, ind + k); j++) {
            len++;
            maxi = max(maxi, arr[j]);
            int sum = len * maxi + dp[j + 1];
            maxAns = max(maxAns, sum);
        }
        dp[ind] = maxAns;
    }
    return dp[0];
}
// TC: O(N*K), SC: O(N)
```


---

## 📌 L55 — Maximum Rectangle Area With All 1's (DP 55)

```
N x M binary matrix. Find the area of the largest rectangle containing
only 1's.
PREREQUISITE: "Largest Rectangle in Histogram" (a stack-based, not DP,
technique — for each bar, find how far it can extend left/right while
staying >= its own height, using a monotonic stack).
KEY IDEA: process the matrix row by row. Treat each row as the BASE of
a histogram, where histogram[j] = how many consecutive 1's are stacked
vertically ending at this row in column j (0 resets the count for that
column). Run "largest rectangle in histogram" on that row's histogram,
and take the max across all rows.
```

```cpp
int largestRectangleArea(vector<int>& heights) {         // monotonic stack, O(N)
    stack<int> st;
    int maxArea = 0, n = heights.size();
    for (int i = 0; i <= n; i++) {
        while (!st.empty() && (i == n || heights[st.top()] >= heights[i])) {
            int height = heights[st.top()]; st.pop();
            int width = st.empty() ? i : i - st.top() - 1;
            maxArea = max(maxArea, height * width);
        }
        st.push(i);
    }
    return maxArea;
}

int maximalRectangle(vector<vector<char>>& matrix) {
    int n = matrix.size(), m = matrix[0].size();
    vector<int> heights(m, 0);
    int maxArea = 0;
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < m; j++)
            heights[j] = (matrix[i][j] == '1') ? heights[j] + 1 : 0;   // build this row's histogram
        maxArea = max(maxArea, largestRectangleArea(heights));
    }
    return maxArea;
}
// TC: O(N*M) — each row's histogram solved in O(M), SC: O(M)
```
**KEY:** this problem isn't really "DP on Rectangles" in the memo/tab/space-opt sense — it's a clever REDUCTION (2D problem → N independent 1D histogram problems) stacked on top of a stack-based technique. Grouped here because Striver's playlist places it in the same thematic cluster as L56, which genuinely is a DP.

---

## 📌 L56 — Count Square Submatrices With All Ones (DP 56)

```
N x M binary matrix. Count how many square submatrices consist entirely
of 1's (squares of every size, not just the largest).
RECURRENCE: dp[i][j] = size of the LARGEST square with its bottom-right
corner at (i,j), assuming matrix[i][j] == 1:
  dp[i][j] = 1 + min( dp[i-1][j], dp[i][j-1], dp[i-1][j-1] )
             (bounded by the smallest of the square directly above,
              directly left, and diagonally up-left — a square can only
              be as large as its weakest neighboring corner allows)
  dp[i][j] = 0  if matrix[i][j] == 0
KEY INSIGHT: dp[i][j] itself equals the COUNT of squares ending at
(i,j) (a largest square of size k ending here means there are also k-1,
k-2, ..., 1 smaller valid squares ending at that exact same corner) —
so the answer is simply the SUM of the whole dp table.
```

```cpp
// ── TABULATION ──────────────────────────────────────────
int countSquares(vector<vector<int>>& matrix) {
    int n = matrix.size(), m = matrix[0].size();
    vector<vector<int>> dp(n, vector<int>(m, 0));
    int count = 0;
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < m; j++) {
            if (i == 0 || j == 0) {
                dp[i][j] = matrix[i][j];
            } else if (matrix[i][j] == 1) {
                dp[i][j] = 1 + min({dp[i - 1][j], dp[i][j - 1], dp[i - 1][j - 1]});
            } else {
                dp[i][j] = 0;
            }
            count += dp[i][j];
        }
    }
    return count;
}
// TC: O(N*M), SC: O(N*M)

// ── SPACE OPTIMIZATION ───────────────────────────────────
int countSquaresOpt(vector<vector<int>>& matrix) {
    int n = matrix.size(), m = matrix[0].size();
    vector<int> prev(m, 0), curr(m, 0);
    int count = 0;
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < m; j++) {
            if (i == 0 || j == 0) curr[j] = matrix[i][j];
            else if (matrix[i][j] == 1) curr[j] = 1 + min({prev[j], curr[j - 1], prev[j - 1]});
            else curr[j] = 0;
            count += curr[j];
        }
        prev = curr;
    }
    return count;
}
// TC: O(N*M), SC: O(M)
```

---

## 📌 All Patterns — Quick Revision

```
DP PATTERN CHEAT SHEET:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
THE CONVERSION RULES (apply in every single problem, in order):
  Recursion → Memoization:
    0. Declare dp[] sized to the state space, init to -1
    1. Store before returning: dp[state] = answer
    2. Check before computing: if (dp[state] != -1) return dp[state]
  Memoization → Tabulation:
    1. Same dp[] table, hardcode the BASE CASES directly (no recursion)
    2. Loop in the direction that respects dependencies (usually the
       reverse of how recursion unwound — small states → large states)
    3. Replace every recursive call with a table lookup
  Tabulation → Space Optimization:
    Ask: "how many previous rows/states does this recurrence actually
    touch?" Usually 1 or 2 → collapse the table to that many rolling
    variables/rows (`prev`/`prev2`, or `prevRow`/`currRow`)

HOW TO DESIGN THE DP STATE (before writing any code):
  1. Express the recursive/brute-force solution first — get this right,
     everything else is mechanical.
  2. Identify every variable that CHANGES between recursive calls and
     affects the answer (usually an index, sometimes a remaining
     budget/target, a boolean flag, a "previous choice" index) — that
     tuple of changing variables IS your dp state.
  3. Count sub-problems = product of each state variable's range —
     that's your dp array's shape.
  4. Identify the base case(s) — where does recursion stop?
  5. Identify the recurrence — how does a state's answer combine its
     sub-states' answers (sum? min? max? OR? AND?)

PROBLEM → PATTERN:
  1D array, f(i) depends on f(i-1)/f(i-2)   → Fibonacci-shaped (Climbing
    Stairs, Frog Jump, House Robber)
  Circular array constraint                  → solve linear version
    TWICE, once per way of breaking the circle (House Robber II)
  Grid, f(i,j) from f(i-1,j)/f(i,j-1)        → DP on Grids; space-opts
    to O(M), one rolling row
  Fixed start & end                          → straightforward grid DP
  Fixed start, variable end (or vice versa)  → same DP, min/max over
    the free row/column at the end
  Variable start AND end                     → same DP, min/max over
    BOTH the first and last row
  Two agents moving through a grid            → 3D DP (row, agent1Col,
    agent2Col); space-opts to O(C^2), two rolling 2D layers
  "Pick / not-pick" a subsequence element      → 2D DP (index, target);
    THE fundamental shape for subset-sum family and 0/1 Knapsack
  Bounded supply (each item once)              → PICK recurses to ind-1;
    single-array space-opt needs a REVERSE (right-to-left) loop
  Unbounded/infinite supply                     → PICK recurses to ind
    (same row); single-array space-opt uses a FORWARD loop
  Count ways instead of true/false               → same DP shape, sum
    instead of OR; watch for a 0-in-the-array edge case
  Target/difference framed as +/- assignment       → reduces to Count
    Subsets / Count Partitions with a derived target
  Two strings, matching/alignment                   → 2D DP (i,j),
    1-indexed table (row/col 0 = empty-string base case)
  "Substring" (consecutive)                          → hard reset to 0
    on mismatch, track a running global max
  "Subsequence" (order preserved, gaps OK)            → fall back to
    max(f(i-1,j), f(i,j-1)) on mismatch, answer = dp[n][m]
  Palindromic subsequence/insertions                  → reduces to
    LCS(s, reverse(s))
  Convert string A → B, insert+delete only              → reduces to
    LCS: deletions = lenA - LCS, insertions = lenB - LCS
  Need the ACTUAL subsequence/string, not just length    → build the
    FULL table (no space-opt), walk it backward from (n,m)
  Buy/sell with a small per-day status (holding?          → 2D DP (day,
    transaction count, cooldown?)                            status);
    space-opts to O(1) or O(status count)
  Recurrence reaches 2 steps ahead (day+2, not day+1)       → need TWO
    rolling "future" states, not one (Cooldown)
  Longest increasing/bitonic/divisible/chain subsequence    → LIS shape:
    dp[i] = best ending AT i, O(N^2); or O(N log N) via patience-sorting
    binary search (length-only, not the actual subsequence)
  Count ways to achieve the LIS length                       → track a
    parallel count[] array: reset on strictly-better, accumulate on tie
  "Try every partition point k between i and j"                → Partition
    DP / MCM shape, O(N^3); loop i decreasing, j increasing outward
    from the i==j base case; rarely space-optimizable past O(N^2)
  "What's decided/removed/burst LAST in a range?"                → think
    backward — restores independence between the two sub-ranges
    (Burst Balloons)
  Track two outcomes simultaneously (true-ways AND false-ways)     →
    carry a pair/tuple of counts through the recursion, not just one
  "Front partition": where did the LAST piece/group begin?          →
    single rolling index f(i), simpler than a full (i,j) range table
    (Palindrome Partitioning II, Partition Array for Max Sum)
  Rectangle/square of 1's in a binary matrix                         →
    largest = row-by-row histogram + monotonic stack (not really DP);
    count-all-squares = dp[i][j] = 1+min(up,left,diag), sum the table

C++ SPECIFIC TIPS:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Initialize dp[] to -1 (int) or use a sentinel your answer can never be
Prefer 1-indexed dp tables for string problems — row/col 0 = clean base case
0/1 Knapsack-family space-opt: loop capacity RIGHT-TO-LEFT (reverse)
Unbounded-family space-opt: loop capacity LEFT-TO-RIGHT (forward)
Use long long or double for counting-DP answers that can overflow int
Partition DP: loop the outer index in the direction that keeps every
  (i,k)/(k+1,j) dependency already computed — usually i decreasing, j increasing
Pad arrays with sentinel values (1 for Burst Balloons, 0/N boundary cuts
  for Min Cost to Cut Stick) to avoid special-casing the array edges
When you need the ACTUAL answer (not just its length/count), you need
  the FULL table — space optimization and path reconstruction don't mix

COMPLEXITY QUICK REF:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1D DP (Fibonacci-shaped)         O(N) time, O(1) space after opt
2D grid DP                       O(N*M) time, O(M) space after opt
3D DP (two agents)               O(R*C^2*9) time, O(C^2) space after opt
Subsequence / Knapsack DP        O(N*Target) time, O(Target) space after opt
DP on Strings (2 strings)        O(N*M) time, O(M) space after opt (O(N*M) if path needed)
DP on Stocks                     O(N*states) time, O(states) space after opt
LIS (standard)                   O(N^2) time, O(N) space
LIS (binary search)              O(N log N) time, O(N) space
Partition DP / MCM               O(N^3) time, O(N^2) space (rarely opt-able further)
Largest rectangle in histogram   O(N) time (monotonic stack), O(N) space
```

---

## 📌 LeetCode / GFG Problem Map

```
TOPIC                                       | LC / SOURCE    | DIFFICULTY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Fibonacci Number                            | LC 509          | Easy
Climbing Stairs                             | LC 70           | Easy
Frog Jump                                   | GFG             | Medium
Frog Jump with K Distances                  | GFG             | Medium
House Robber                                | LC 198          | Medium
House Robber II                             | LC 213          | Medium
Ninja's Training                            | GFG             | Medium
Unique Paths                                | LC 62           | Medium
Unique Paths II                             | LC 63           | Medium
Minimum Path Sum                            | LC 64           | Medium
Triangle                                    | LC 120          | Medium
Minimum/Maximum Falling Path Sum            | LC 931 (var)    | Medium
Cherry Pickup II                            | LC 1463         | Hard
Partition Equal Subset Sum                  | LC 416          | Medium
Partition Array — Minimum Absolute Diff     | GFG             | Medium
Count Subsets with Sum K                    | GFG             | Medium
Count Partitions With Given Difference      | GFG             | Medium
0/1 Knapsack                                | GFG             | Medium
Coin Change (Minimum Coins)                 | LC 322          | Medium
Target Sum                                  | LC 494          | Medium
Coin Change II                              | LC 518          | Medium
Unbounded Knapsack                          | GFG             | Medium
Rod Cutting Problem                         | GFG             | Medium
Longest Common Subsequence                  | LC 1143         | Medium
Print Longest Common Subsequence            | GFG             | Medium
Longest Common Substring                    | GFG             | Medium
Longest Palindromic Subsequence             | LC 516          | Medium
Minimum Insertions to Make Palindrome       | LC 1312         | Hard
Min Insertions/Deletions to Convert A to B  | LC 583          | Medium
Shortest Common Supersequence               | LC 1092         | Hard
Distinct Subsequences                       | LC 115          | Hard
Edit Distance                               | LC 72           | Hard
Wildcard Matching                           | LC 44           | Hard
Best Time to Buy and Sell Stock             | LC 121          | Easy
Best Time to Buy and Sell Stock II          | LC 122          | Medium
Best Time to Buy and Sell Stock III         | LC 123          | Hard
Best Time to Buy and Sell Stock IV          | LC 188          | Hard
Buy and Sell Stock With Cooldown            | LC 309          | Medium
Buy and Sell Stock With Transaction Fee     | LC 714          | Medium
Longest Increasing Subsequence              | LC 300          | Medium
Printing Longest Increasing Subsequence     | GFG             | Medium
LIS via Binary Search                       | LC 300 (optimal)| Medium
Largest Divisible Subset                    | LC 368          | Medium
Longest String Chain                        | LC 1048         | Medium
Longest Bitonic Subsequence                 | GFG             | Medium
Number of Longest Increasing Subsequences   | LC 673          | Medium
Matrix Chain Multiplication                 | GFG             | Hard
Minimum Cost to Cut the Stick               | LC 1547         | Hard
Burst Balloons                              | LC 312          | Hard
Evaluate Boolean Expression to True         | GFG             | Hard
Palindrome Partitioning II                  | LC 132          | Hard
Partition Array for Maximum Sum             | LC 1043         | Medium
Maximum Rectangle Area with all 1's         | LC 85           | Hard
Count Square Submatrices with All Ones      | LC 1277         | Medium
```
