# Aditya Verma Stack Playlist — Questions, Approaches & C++ Solutions

A compact, interview-ready reference for the classic stack patterns covered in the playlist. Each section includes problem prompt, when to use the pattern, key idea, and a clean, self-contained C++ solution.

---

## Table of Contents
1. [Nearest Greater to Right (NGR)](#1-nearest-greater-to-right-ngr)
2. [Nearest Greater to Left (NGL)](#2-nearest-greater-to-left-ngl)
3. [Nearest Smaller to Right (NSR)](#3-nearest-smaller-to-right-nsr)
4. [Nearest Smaller to Left (NSL)](#4-nearest-smaller-to-left-nsl)
5. [Stock Span](#5-stock-span)
6. [Maximum Area in Histogram (MAH/Largest Rectangle)](#6-maximum-area-in-histogram-mahlargest-rectangle)
7. [Max Rectangle of 1s in Binary Matrix](#7-max-rectangle-of-1s-in-binary-matrix)
8. [Trapping Rain Water](#8-trapping-rain-water)
9. [Min Element in Stack — Auxiliary Stack](#9-min-element-in-stack--auxiliary-stack)
10. [Min Element in Stack — O(1) Extra Space](#10-min-element-in-stack--o1-extra-space)
11. [Helpers & Notes](#11-helpers--notes)

---

## Pattern Primer (When to reach for stacks/monotonic stacks)
- If a problem asks for **nearest/next greater or smaller** to left/right → monotonic stack.
- If you see nested scans to the left/right for a boundary (greater/smaller) → replace with a single pass using stack.
- Classic `O(n)` trick: each element is **pushed once, popped at most once**.

---

## 1) Nearest Greater to Right (NGR)

**Prompt**: For every element, find the first greater element to its right (or `-1` if none).  
**Idea**: Traverse from right→left. Maintain a **decreasing** stack of values. Pop ≤ current; the top (if any) is the answer.

```cpp
#include <bits/stdc++.h>
using namespace std;

vector<int> nextGreaterRight(const vector<int>& a){
    int n = (int)a.size();
    vector<int> ans(n, -1);
    stack<int> st; // candidate greater values
    for(int i=n-1;i>=0;--i){
        while(!st.empty() && st.top() <= a[i]) st.pop();
        ans[i] = st.empty() ? -1 : st.top();
        st.push(a[i]);
    }
    return ans;
}
```

---

## 2) Nearest Greater to Left (NGL)

**Prompt**: For every element, find the first greater element to its left (or `-1` if none).  
**Idea**: Traverse left→right with a **decreasing** stack of values.

```cpp
#include <bits/stdc++.h>
using namespace std;

vector<int> nextGreaterLeft(const vector<int>& a){
    int n = (int)a.size();
    vector<int> ans(n, -1);
    stack<int> st;
    for(int i=0;i<n;++i){
        while(!st.empty() && st.top() <= a[i]) st.pop();
        ans[i] = st.empty() ? -1 : st.top();
        st.push(a[i]);
    }
    return ans;
}
```

---

## 3) Nearest Smaller to Right (NSR)

**Prompt**: For every element, find the first smaller element to its right (or `-1` if none).  
**Idea**: Traverse right→left with an **increasing** stack of values. Pop ≥ current.

```cpp
#include <bits/stdc++.h>
using namespace std;

vector<int> nextSmallerRight(const vector<int>& a){
    int n = (int)a.size();
    vector<int> ans(n, -1);
    stack<int> st;
    for(int i=n-1;i>=0;--i){
        while(!st.empty() && st.top() >= a[i]) st.pop();
        ans[i] = st.empty() ? -1 : st.top();
        st.push(a[i]);
    }
    return ans;
}
```

---

## 4) Nearest Smaller to Left (NSL)

**Prompt**: For every element, find the first smaller element to its left (or `-1` if none).  
**Idea**: Traverse left→right with an **increasing** stack of values. Pop ≥ current.

```cpp
#include <bits/stdc++.h>
using namespace std;

vector<int> nextSmallerLeft(const vector<int>& a){
    int n = (int)a.size();
    vector<int> ans(n, -1);
    stack<int> st;
    for(int i=0;i<n;++i){
        while(!st.empty() && st.top() >= a[i]) st.pop();
        ans[i] = st.empty() ? -1 : st.top();
        st.push(a[i]);
    }
    return ans;
}
```

---

## 5) Stock Span

**Prompt**: For each day, how many consecutive days before (including today) had price ≤ today’s?  
**Idea**: Traverse left→right with a **decreasing** stack of **indices**. Pop while `price[top] ≤ price[i]`. Span = `i - (top or -1)`.

```cpp
#include <bits/stdc++.h>
using namespace std;

vector<int> stockSpan(const vector<int>& p){
    int n = (int)p.size();
    vector<int> span(n);
    stack<int> st; // holds indices
    for(int i=0;i<n;++i){
        while(!st.empty() && p[st.top()] <= p[i]) st.pop();
        span[i] = st.empty() ? (i+1) : (i - st.top());
        st.push(i);
    }
    return span;
}
```

---

## 6) Maximum Area in Histogram (MAH/Largest Rectangle)

**Prompt**: Given bar heights, find the largest rectangular area.  
**Idea**: Single pass stack of indices; when current height is smaller than top’s height, pop and compute area using current index as right boundary and new top as left boundary.

```cpp
#include <bits/stdc++.h>
using namespace std;

long long largestRectangleArea(vector<int>& h){
    int n = (int)h.size();
    stack<int> st;
    long long best = 0;
    for(int i=0;i<=n;++i){
        int cur = (i==n ? 0 : h[i]);
        while(!st.empty() && cur < h[st.top()]){
            int ht = h[st.top()]; st.pop();
            int l = st.empty() ? -1 : st.top();
            int r = i;
            long long width = r - l - 1;
            best = max(best, 1LL*ht*width);
        }
        st.push(i);
    }
    return best;
}
```

---

## 7) Max Rectangle of 1s in Binary Matrix

**Prompt**: Find largest rectangle of `1`s in a binary matrix.  
**Idea**: Build a height histogram per row (count of consecutive 1s up to that row), then call MAH for each row.

```cpp
#include <bits/stdc++.h>
using namespace std;

// reuse largestRectangleArea from above
long long largestRectangleArea(vector<int>& h){
    int n = (int)h.size();
    stack<int> st;
    long long best = 0;
    for(int i=0;i<=n;++i){
        int cur = (i==n ? 0 : h[i]);
        while(!st.empty() && cur < h[st.top()]){
            int ht = h[st.top()]; st.pop();
            int l = st.empty() ? -1 : st.top();
            int r = i;
            long long width = r - l - 1;
            best = max(best, 1LL*ht*width);
        }
        st.push(i);
    }
    return best;
}

long long maxRectangle(vector<vector<int>>& mat){
    if(mat.empty()) return 0;
    int R = (int)mat.size(), C = (int)mat[0].size();
    vector<int> h(C, 0);
    long long ans = 0;
    for(int r=0;r<R;++r){
        for(int c=0;c<C;++c) h[c] = (mat[r][c] ? h[c] + 1 : 0);
        ans = max(ans, largestRectangleArea(h));
    }
    return ans;
}
```

---

## 8) Trapping Rain Water

**Prompt**: Given bar heights, compute how much water is trapped.  
**Stack Idea**: Use indices; when current bar is higher than stack top, pop a “basin” and compute bounded water using left boundary at new top.  
**Two-Pointer Idea**: Maintain `lmax` and `rmax` while moving inward; `O(1)` space.

```cpp
#include <bits/stdc++.h>
using namespace std;

// Stack-based approach
long long trapStack(const vector<int>& h){
    long long water = 0;
    stack<int> st;
    for(int i=0;i<(int)h.size();++i){
        while(!st.empty() && h[i] > h[st.top()]){
            int mid = st.top(); st.pop();
            if(st.empty()) break;
            int L = st.top();
            long long width = i - L - 1;
            long long bounded = min(h[L], h[i]) - h[mid];
            if(bounded > 0) water += bounded * width;
        }
        st.push(i);
    }
    return water;
}

// Two-pointer approach
long long trapTwoPointer(const vector<int>& h){
    int l=0, r=(int)h.size()-1;
    long long lmax=0, rmax=0, water=0;
    while(l<r){
        if(h[l] <= h[r]){
            lmax = max<long long>(lmax, h[l]);
            water += lmax - h[l];
            ++l;
        }else{
            rmax = max<long long>(rmax, h[r]);
            water += rmax - h[r];
            --r;
        }
    }
    return water;
}
```

---

## 9) Min Element in Stack — Auxiliary Stack

**Prompt**: Implement a stack supporting `push`, `pop`, `top`, and `getMin` in `O(1)` time.  
**Idea**: Keep an auxiliary stack of minimums parallel to the main stack.

```cpp
#include <bits/stdc++.h>
using namespace std;

struct MinStackExtra {
    stack<int> s, mn;
    void push(int x){
        s.push(x);
        mn.push(mn.empty() ? x : min(x, mn.top()));
    }
    void pop(){
        s.pop();
        mn.pop();
    }
    int top(){ return s.top(); }
    int getMin(){ return mn.top(); }
    bool empty(){ return s.empty(); }
};
```

---

## 10) Min Element in Stack — O(1) Extra Space

**Prompt**: Same API as above but only `O(1)` extra space (besides the main stack).  
**Idea**: Encode values when a new min arrives. If pushing `x < curMin`, push `2*x - curMin` (a marker) and set `curMin = x`. On pop, if you pop a marker (stack top `< curMin`), recover previous min as `2*curMin - marker`.

```cpp
#include <bits/stdc++.h>
using namespace std;

struct MinStackO1Space {
    stack<long long> s;
    long long curMin;

    void push(long long x){
        if(s.empty()){
            s.push(x);
            curMin = x;
        }else if(x >= curMin){
            s.push(x);
        }else{
            // encode
            s.push(2*x - curMin);
            curMin = x;
        }
    }

    void pop(){
        long long t = s.top(); s.pop();
        if(t < curMin){
            // t is marker; restore previous min
            curMin = 2*curMin - t;
        }
    }

    long long top(){
        long long t = s.top();
        return (t < curMin) ? curMin : t;
    }

    long long getMin(){ return curMin; }
    bool empty(){ return s.empty(); }
};
```

---

## 11) Helpers & Notes

- **Complexities**  
  - NGR/NGL/NSR/NSL/Stock Span/MAH/Trap: `O(n)` time, usually `O(n)` stack space.
  - Max Rectangle in Matrix: `O(R*C)`.
  - Min Stack variants: `O(1)` per operation.

- **Printing helpers** (optional):
```cpp
template<class T>
void printVec(const vector<T>& v){
    for(size_t i=0;i<v.size();++i){
        cout << v[i] << (i+1==v.size()?'\n':' ');
    }
}
```

- **Compilation tip**: For competitive setups you can keep everything in one file with `#include <bits/stdc++.h>`; on some compilers prefer standard includes.

---

Happy practicing! If you want sample I/O for each routine or a combined driver `main()` to try all functions at once, I can add those too.
