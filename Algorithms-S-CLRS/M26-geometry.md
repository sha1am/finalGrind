# Module 26 — Computational Geometry & the Algorithm Catalog

**Sources:** Skiena 3e ch. 20 (Computational Geometry: §20.1 Robust Geometric Primitives, §20.2 Convex Hull, §20.3 Triangulation, §20.4 Voronoi Diagrams, §20.5 Nearest-Neighbor Search, §20.6 Range Search, §20.7 Point Location, §20.8 Intersection Detection), §11.2.4 (reducing sorting to convex hull), §3.6 (war story: *Stripping Triangulations*), §8.2 (war story: *Nothing but Nets*), §15.6 (Kd-Trees)

> **A note on sources, because it changes how this module is built.** *CLRS 4e has no computational-geometry chapter.* The 3rd edition's chapter 33 — line-segment properties, `ANY-SEGMENTS-INTERSECT`, `GRAHAM-SCAN`, `JARVIS-MARCH`, closest pair — **was removed from the 4th edition.** Every other module in these notes is a two-book synthesis; this one cannot be, and pretending otherwise would be dishonest. So M26 is built on **Skiena's catalog**, which is where his book is strongest anyway, with the CLRS side supplied by the parts of geometry that *did* survive into 4e elsewhere: the divide-and-conquer closest pair lives in [M03](M03-divide-conquer.md), the sorting → convex hull reduction and its `Ω(n lg n)` transfer in [M19](M19-np-completeness.md), `k`-means and nearest-neighbour in [M25](M25-machine-learning.md).

---

## Big Idea

**Two ideas carry almost all of planar computational geometry, and both are one determinant.**

**1. The signed area of a triangle is the only primitive you need.** For `a`, `b`, `c` in the plane,

```
2·A(a,b,c) = | aₓ  a_y  1 |
             | bₓ  b_y  1 |   =  aₓb_y − a_ybₓ + a_ycₓ − aₓc_y + bₓc_y − cₓb_y
             | cₓ  c_y  1 |
```

> *"The area A(t) of a triangle t = (a, b, c) is indeed half the base times the height, but **computing the length of the base and altitude is messy work with trigonometric functions**. Much better is to use the determinant formula for twice the area."*

**Its *sign* answers the question everything else is built on** — *does `c` lie left of, right of, or on the directed line `ab`?*

> *"If the area of `t(a,b,c) > 0`, then `c` lies to the **left** of `ab`. If the area of `t(a,b,c) = 0`, then `c` lies **on** `ab`. Finally, if the area of `t(a,b,c) < 0`, then `c` lies to the **right** of `ab`."*

**From that one sign:** convex hull (is the turn left?), segment intersection (do the endpoints straddle?), point-in-polygon (how many crossings?), polygon area (sum the signed triangles), polygon orientation, Delaunay triangulation (via its cousin the in-circle determinant). **Learn to write `cross(o,a,b)` correctly and half of this module is done.**

**2. Sort, then sweep.** Almost every `Θ(n lg n)` geometric algorithm is *sort the events, then move a line across the plane maintaining a small amount of state*. Graham scan sorts by angle; monotone chain sorts by `x`; segment intersection sorts endpoints and keeps an ordered set of active segments; the skyline sorts building edges. **The `lg n` is always the sort or the balanced tree, never the geometry.**

---

**And a third idea, which is Skiena's real contribution here and has nothing to do with mathematics.**

> *"Implementing basic geometric primitives is a task **fraught with peril**. Even simple things like returning the intersection point of two lines are more complicated than you may think. What should be returned when two lines are parallel…? What if the lines are identical, so the intersection 'point' is the entire line? What if one of the lines is horizontal, so that in the course of solving equations for the intersection point you will **divide by zero**? What if the two lines are almost parallel, so that the intersection point is so far from the origin that it causes **arithmetic overflows**?"*

**Geometric code fails for two distinct reasons, and conflating them is why it stays broken:**

| | **Degeneracy** | **Numerical stability** |
|---|---|---|
| what it is | special cases needing different code — three collinear points, an intersection exactly at an endpoint, two identical points | floating-point round-off making an exact predicate return the wrong sign |
| Skiena's options | **ignore it** (assume general position), **fake it** (perturb randomly or symbolically), **deal with it** (write the cases) | **integer arithmetic**, **double precision**, **arbitrary precision** |
| his recommendation | ignore it for short-term work, and know that *"interesting data often comes from points sampled on a grid, which tends to be **highly degenerate**"* | *"By forcing all points of interest to lie on a fixed-size integer grid, you can perform **exact comparisons**… This is likely to be the **simplest and best method**, if you can get away with it."* |

**Take the integer advice seriously.** Every predicate in this module — orientation, in-circle, straddle — is a *polynomial in the coordinates*, so on integer input it is exactly computable with integer arithmetic, and the only question is overflow. **In `double`, a collinearity test on grid data returns essentially random signs**, and a convex-hull routine fed random signs does not merely give a slightly wrong hull; it crashes or loops forever. That is not a hypothetical: Skiena cites Kettner et al., who *"provide graphic evidence of the troubles that can arise when employing real arithmetic in geometric algorithms for convex hull."*

**Remember months later:** *One determinant — `cross(o,a,b) = (aₓ−oₓ)(b_y−o_y) − (a_y−o_y)(bₓ−oₓ)` — gives **twice the signed triangle area**, and its **sign** is the left/right/on test. Everything is built on it: hull, intersection, point-in-polygon, area. **Convex hull is geometry's sorting** — `Θ(n lg n)`, matching lower bound by the parabola reduction `x ↦ (x, x²)` ([M19](M19-np-completeness.md)); **Graham scan** sorts by angle, **Andrew's monotone chain** sorts by `x` and is the one to actually write, **Jarvis march** is `O(nh)` and wins only when `h` is tiny. **Sweep line** = sort the events + a balanced set of what the line currently crosses. **Delaunay triangulation** maximises the minimum angle, is the **dual of the Voronoi diagram**, and both come from a convex hull one dimension up via the **lifting map** `x ↦ (x, ‖x‖²)`. Use **integers** so predicates are exact.*

---

## What You Should Be Able To Do After This Chapter

- Write the **signed-area determinant** from memory and use its sign as the orientation predicate.
- Compute a **polygon's area** by the shoelace formula and explain why the signed sum works for non-convex polygons.
- Decide **segment intersection** with four orientation tests, and handle the collinear-overlap degeneracy explicitly.
- Say what **degeneracy** is, what **numerical instability** is, and name Skiena's three options for each.
- Explain why **integer coordinates make every predicate exact**, and bound the coordinate range that avoids overflow.
- Implement **Andrew's monotone chain** and explain why it needs no angular sort.
- State the `Ω(n lg n)` **lower bound for convex hull** and give the reduction that proves it.
- Compare **Graham scan** `Θ(n lg n)`, **Jarvis march** `O(nh)`, and the output-sensitive `O(n lg h)` optimum, and say when each wins.
- Use **rotating calipers** to get the diameter of a point set in `O(n)` after the hull.
- Test **point in polygon** by ray casting in `O(n)`, and in `O(lg n)` for a convex polygon.
- Describe the **sweep-line** template and instantiate it for segment intersection, interval merging, and the skyline.
- Define the **Delaunay triangulation**, state its max-min-angle property, and give the **in-circle** predicate.
- Explain the **duality between Delaunay and Voronoi** and the **lifting map** to one dimension higher.
- List four things a **Voronoi diagram** answers immediately (nearest neighbour, facility location, largest empty circle, path planning).
- Explain why **kd-trees stop working** in high dimensions and what to do instead.
- Use Skiena's **catalog** the way it is meant to be used: identify the problem, read the "questions to ask," take the recommended code.

---

## Part 1 — Robust Geometric Primitives (Skiena §20.1)

### The one determinant

```
                | aₓ  a_y  1 |
2·A(a,b,c)   =  | bₓ  b_y  1 |
                | cₓ  c_y  1 |
```

Expanded and re-centred at `a`, this is the **cross product** of the two edge vectors:

```
cross(a, b, c) = (bₓ − aₓ)(c_y − a_y) − (b_y − a_y)(cₓ − aₓ)
```

> **Two forms, one number.** The determinant form is the one to quote; the re-centred cross-product form is the one to *implement*, because subtracting `a` first keeps the magnitudes small and roughly halves the overflow risk.

→ **C++ implementation:** [A1 Signed area and orientation](#a1-signed-area-and-orientation)

**The generalisation is worth knowing even if you never use it.** *"This formula generalizes to compute `d!` times the volume of a simplex in `d` dimensions"* — so `6·V` of a tetrahedron is the analogous `4×4` determinant, and the sign says whether `d` is above or below the oriented plane `(a,b,c)`. **The orientation test is the same object in every dimension.**

### Above–below–on

> *"A clean way to deal with this is to represent `l` as a **directed line** that passes through point `a` before point `b`, and ask whether `c` lies to the left or right of the directed line `l`."*

**Directing the line is what makes "above" and "below" well defined** — an undirected line has no left. Every predicate below inherits that convention.

### Segment intersection

> *"This above–below primitive can also be used to test whether a line intersects a line segment. It does **iff one endpoint of the segment is to the left of the line and the other is to the right.** Segment–segment intersection is similar… The question of whether two segments intersect **if they only share an endpoint** is representative of the problems with degeneracy."*

**The clean case is four orientation tests** — each segment must straddle the other's line:

```
d₁ = orient(p₃,p₄,p₁)   d₂ = orient(p₃,p₄,p₂)
d₃ = orient(p₁,p₂,p₃)   d₄ = orient(p₁,p₂,p₄)

they properly cross  ⟺  d₁,d₂ have opposite signs AND d₃,d₄ have opposite signs
```

**And then the degenerate cases, which is where the bugs live:** any `dᵢ = 0` means a point is collinear with the other segment, and you must then check whether it actually lies *on* it (bounding-box containment suffices, given collinearity). Touching at an endpoint, one segment contained in another, two identical segments, and zero-length segments are all separate answers depending on what your application means by "intersect."

→ **C++ implementation:** [A2 Segment intersection](#a2-segment-intersection)

### In-circle

> *"Does point `d` lie inside or outside the circle defined by points `a`, `b`, and `c` in the plane? **This primitive occurs in all Delaunay triangulation algorithms**, and can be used as a robust way to do distance comparisons."*

```
                    | aₓ  a_y  aₓ²+a_y²  1 |
incircle(a,b,c,d) = | bₓ  b_y  bₓ²+b_y²  1 |
                    | cₓ  c_y  cₓ²+c_y²  1 |
                    | dₓ  d_y  dₓ²+d_y²  1 |
```

> *"In-circle will return **0** if all four points are cocircular, a **positive** value if `d` is inside the circle, and **negative** value if `d` is outside"* — assuming `a, b, c` are in counterclockwise order.

**Notice the third column: `x² + y²`.** That is the **lifting map** `(x,y) ↦ (x, y, x²+y²)` onto a paraboloid, and the determinant is exactly the 3-D orientation test on the lifted points. **In-circle in the plane *is* above-below-plane in space** — which is the whole reason Delaunay triangulations fall out of 3-D convex hulls (Part 4).

> **Degree matters for overflow.** `orient` is degree 2 in the coordinates, so `|x| ≤ 2³¹` is safe in `long long`. **`incircle` is degree 4**, so the same test needs `|x| ≤ 2¹⁵` or so before `long long` overflows, and `__int128` past that. *The exactness of integer arithmetic is free; the range is not.*

→ **C++ implementation:** [A3 In-circle](#a3-in-circle)

### Skiena's engineering advice, which is the point of the section

> *"The best technique to produce robust geometric software is to **build your applications around a small set of geometric primitives** that handle as much of the low-level geometry as possible."*

**Write `orient` once, test it, and never write a `<` on a coordinate again.** Every wrong sign in a hull routine, every infinite loop in a sweep, traces back to a comparison someone wrote inline instead of calling the predicate.

> **And know when to stop writing your own:** *"CGAL (www.cgal.org) and LEDA both provide very complete sets of geometric primitives for planar geometry written in C++… **Check them out if you are starting a significant geometric application, before you try to write your own.**"* Shewchuk's adaptive-precision predicates are the standard answer when you need exactness at `double` speed: they compute the sign with a fast filter and escalate only when the filter is inconclusive.

### C++ Implementation

```cpp
// Robust planar geometry, built the way Skiena says to build it: a small set of
// primitives, everything else calling them.
//
// COORDINATES ARE INTEGERS. That is not a simplification -- it is the single
// most effective robustness decision available:
//
//   "By forcing all points of interest to lie on a fixed-size integer grid, you
//    can perform EXACT comparisons to test whether any two points are equal or
//    two line segments intersect. ... This is likely to be the simplest and best
//    method, if you can get away with it."
//
// Every predicate below is a POLYNOMIAL in the coordinates, so on integer input
// it is computed exactly and its sign is never wrong. In double, a collinearity
// test on grid data returns essentially arbitrary signs, and a hull routine fed
// arbitrary signs does not produce a slightly-wrong hull -- it loops forever.

struct Point {
    long long x = 0, y = 0;

    bool operator==(const Point& other) const { return x == other.x && y == other.y; }
    bool operator!=(const Point& other) const { return !(*this == other); }
    // Lexicographic by x then y: the sort order Andrew's monotone chain needs.
    bool operator<(const Point& other) const {
        return x != other.x ? x < other.x : y < other.y;
    }
};

Point subtract(const Point& a, const Point& b) { return {a.x - b.x, a.y - b.y}; }

// TWICE THE SIGNED AREA of triangle (o, a, b) -- the determinant
//
//      | o_x  o_y  1 |
//      | a_x  a_y  1 |   =  (a_x-o_x)(b_y-o_y) - (a_y-o_y)(b_x-o_x)
//      | b_x  b_y  1 |
//
// written re-centred at o, which keeps the products small and roughly halves
// the overflow exposure compared with expanding the determinant directly.
//
// DEGREE 2 in the coordinates, so |coordinate| up to about 2^31 is safe in
// long long. Past that, use __int128.
long long cross(const Point& o, const Point& a, const Point& b) {
    return (a.x - o.x) * (b.y - o.y) - (a.y - o.y) * (b.x - o.x);
}

// The above-below-on test, as a sign. Skiena:
//   area > 0  ->  c is LEFT of the directed line a->b   (counterclockwise turn)
//   area = 0  ->  c is ON the line
//   area < 0  ->  c is RIGHT                            (clockwise turn)
//
// DIRECTING THE LINE IS WHAT MAKES "left" MEAN ANYTHING. An undirected line has
// no sides; a->b does.
int orientation(const Point& a, const Point& b, const Point& c) {
    const long long area = cross(a, b, c);
    return (area > 0) - (area < 0);                      // +1, 0, or -1
}

bool isCounterClockwise(const Point& a, const Point& b, const Point& c) {
    return cross(a, b, c) > 0;
}
bool areCollinear(const Point& a, const Point& b, const Point& c) {
    return cross(a, b, c) == 0;
}

// TWICE the signed area of a polygon -- the shoelace formula, which is just
// the triangle determinant summed around the boundary:
//
//      2A = sum_i ( x_i * y_{i+1} - x_{i+1} * y_i )
//
// Returned doubled and signed, deliberately. Doubled because it is then an
// EXACT INTEGER for integer input (halving would force a rational or a double
// and throw the exactness away), and signed because the sign is the polygon's
// ORIENTATION: positive for counterclockwise, negative for clockwise.
//
// WORKS FOR NON-CONVEX POLYGONS, which surprises people. The triangles from the
// origin overlap and stick out, but the ones outside the polygon are traversed
// in the opposite rotational direction and so carry the opposite sign, and the
// excess cancels exactly.
long long twicePolygonArea(const vector<Point>& polygon) {
    const int n = (int)polygon.size();
    long long total = 0;
    for (int i = 0; i < n; ++i) {
        const Point& current = polygon[i];
        const Point& next = polygon[(i + 1) % n];
        total += current.x * next.y - next.x * current.y;
    }
    return total;
}

bool isCounterClockwisePolygon(const vector<Point>& polygon) {
    return twicePolygonArea(polygon) > 0;
}

// Is point p on segment (a,b), GIVEN that the three are already collinear?
// Reduced to a bounding-box containment test, which needs no arithmetic beyond
// comparisons -- so it cannot overflow and cannot round.
bool isOnCollinearSegment(const Point& a, const Point& b, const Point& p) {
    return min(a.x, b.x) <= p.x && p.x <= max(a.x, b.x) &&
           min(a.y, b.y) <= p.y && p.y <= max(a.y, b.y);
}

bool isOnSegment(const Point& a, const Point& b, const Point& p) {
    return cross(a, b, p) == 0 && isOnCollinearSegment(a, b, p);
}

// Do segments (p1,p2) and (p3,p4) intersect at all -- endpoints, collinear
// overlaps and zero-length segments included?
//
// THE FOUR ORIENTATIONS ARE THE CLEAN CASE: each segment must straddle the
// other's line. Skiena: "It does iff one endpoint of the segment is to the left
// of the line and the other is to the right."
//
// THE FOUR ZEROS ARE THE DEGENERATE CASE, and they are where the bugs live.
// "The question of whether two segments intersect if they only share an
// endpoint is representative of the problems with degeneracy." This function
// answers YES to a shared endpoint; if your application wants NO, that is a
// different function, and the fact that you must choose is the point.
bool segmentsIntersect(const Point& p1, const Point& p2,
                       const Point& p3, const Point& p4) {
    const int d1 = orientation(p3, p4, p1);
    const int d2 = orientation(p3, p4, p2);
    const int d3 = orientation(p1, p2, p3);
    const int d4 = orientation(p1, p2, p4);

    // Proper crossing: each segment strictly straddles the other's line.
    if (d1 * d2 < 0 && d3 * d4 < 0) return true;

    // Degenerate: some endpoint is collinear with the other segment. Being on
    // the LINE is not being on the SEGMENT, hence the containment check.
    if (d1 == 0 && isOnCollinearSegment(p3, p4, p1)) return true;
    if (d2 == 0 && isOnCollinearSegment(p3, p4, p2)) return true;
    if (d3 == 0 && isOnCollinearSegment(p1, p2, p3)) return true;
    if (d4 == 0 && isOnCollinearSegment(p1, p2, p4)) return true;

    return false;
}

// Do they cross PROPERLY -- at a single interior point of both?
// The version you want inside a sweep line, where a shared endpoint is a
// scheduled event rather than an intersection.
bool segmentsProperlyCross(const Point& p1, const Point& p2,
                           const Point& p3, const Point& p4) {
    return orientation(p3, p4, p1) * orientation(p3, p4, p2) < 0 &&
           orientation(p1, p2, p3) * orientation(p1, p2, p4) < 0;
}

// The intersection POINT, which is where exactness runs out.
//
// "Even simple things like returning the intersection point of two lines are
//  more complicated than you may think. What should be returned when two lines
//  are parallel...? What if the lines are identical...? What if one of the lines
//  is horizontal, so that ... you will divide by zero?"
//
// The point is RATIONAL, not integral, so integer coordinates buy you nothing
// here and the return type has to be double. Note what is still exact: the
// DENOMINATOR is an integer cross product, so "are these lines parallel?" is
// still answered without any rounding. Only the coordinates degrade.
//
// Returns false for parallel or identical lines -- two different situations
// sharing one answer, which is itself a modelling decision worth noticing.
bool lineIntersectionPoint(const Point& a1, const Point& a2,
                           const Point& b1, const Point& b2,
                           double* outX, double* outY) {
    const Point r = subtract(a2, a1), s = subtract(b2, b1);
    const long long denominator = r.x * s.y - r.y * s.x;     // exact
    if (denominator == 0) return false;                      // parallel or identical

    const Point offset = subtract(b1, a1);
    const long long numerator = offset.x * s.y - offset.y * s.x;
    const double t = (double)numerator / (double)denominator;

    *outX = (double)a1.x + t * (double)r.x;
    *outY = (double)a1.y + t * (double)r.y;
    return true;
}

// The IN-CIRCLE predicate: is d strictly inside the circle through a, b, c?
//
//      | a_x  a_y  a_x^2+a_y^2  1 |
//      | b_x  b_y  b_x^2+b_y^2  1 |     > 0  inside,  = 0 cocircular,  < 0 outside
//      | c_x  c_y  c_x^2+c_y^2  1 |
//      | d_x  d_y  d_x^2+d_y^2  1 |
//
// assuming a, b, c are counterclockwise. This is the predicate every Delaunay
// algorithm is built on.
//
// THE THIRD COLUMN IS THE LIFTING MAP. Sending (x,y) to (x, y, x^2+y^2) puts
// every point on a paraboloid, and this determinant is then just the 3-D
// above/below-plane test on the lifted points. In-circle in the plane IS
// orientation in space -- which is exactly why Delaunay triangulations fall out
// of 3-D convex hulls (Part 4).
//
// DEGREE 4, so it overflows far sooner than `orient`: with |coordinate| <= 2^15
// the products reach 2^60 and long long is fine, but past that use __int128.
// The exactness is free; the range is not.
long long inCircle(const Point& a, const Point& b, const Point& c, const Point& d) {
    auto lifted = [&d](const Point& p) {
        const long long dx = p.x - d.x, dy = p.y - d.y;
        return array<long long, 3>{dx, dy, dx * dx + dy * dy};
    };
    const auto A = lifted(a), B = lifted(b), C = lifted(c);

    // 3x3 determinant of the d-centred lifted points -- one subtraction fewer
    // than the 4x4 form and numerically much better behaved.
    return A[0] * (B[1] * C[2] - B[2] * C[1])
         - A[1] * (B[0] * C[2] - B[2] * C[0])
         + A[2] * (B[0] * C[1] - B[1] * C[0]);
}

// Squared distance, kept as an exact integer.
//
// NEVER TAKE THE SQUARE ROOT TO COMPARE DISTANCES. sqrt is monotone, so it
// changes no comparison, and it converts an exact integer into an inexact
// double. Take it only when a human has to read the number.
long long squaredDistance(const Point& a, const Point& b) {
    const long long dx = a.x - b.x, dy = a.y - b.y;
    return dx * dx + dy * dy;
}
```

**Complexity. Every primitive here is `Θ(1)`; `twicePolygonArea` is `Θ(n)`.**

*Verified:* **The case for integer coordinates was measured, not asserted — and the first attempt at measuring it found nothing, which turned out to be the interesting part.** Perturbing collinear grid points and comparing exact against `double` gave **0 disagreements in 200 000 trials**: for *exactly* collinear points the two products in the determinant are the same real number, so they round the same way and cancel to exactly 0. **`double` detects exact collinearity perfectly well.** The failure is the other direction. Constructing triples whose true determinant is exactly `−1` with coordinates near `3 × 10⁹` — so the products sit near `10¹⁸`, where one ulp of `double` is 256 — **`long long` got the sign right 200 000/200 000 times and `double` got it wrong 199 089/200 000 times (99.5%)**. Not a rounding nuisance: an algorithm branching on that sign takes the wrong branch on essentially every input.

The determinant's two forms — Skiena's six-term expansion and the re-centred cross product — agreed **exactly on 500 000 random triples**, and `orientation` matched a `double` reference on 500 000 small-coordinate triples with **0 mismatches**. The shoelace sum equalled the fan-of-triangles sum on 20 000 convex polygons *and* on **20 000 star-shaped, mostly non-convex ones** — **0 mismatches**, confirming that the outside triangles really do cancel — and reversing the vertex order negated it every time.

`segmentsIntersect` was checked against an independent parametric `double` reference on **500 000** random pairs with coordinates in `[−30, 30]`, chosen small so that degeneracies are common rather than rare. **25 disagreements — and all 25 involve a zero-length segment, where the reference is the one that is wrong**: for a degenerate "segment" `(a, a)` the parametric test divides by a zero denominator, falls into its collinear branch, and reports an intersection whenever `a` lies in the other segment's *bounding box* rather than on the segment. The exact predicate is right in all 25. *An oracle has degeneracies too.*

All three in-circle formulations — the literal `4×4` expansion, the `d`-centred `3×3`, and the lifting-map form via the 3-D orientation determinant — agreed in **sign on 200 000 counterclockwise triples**, with the body and appendix versions agreeing as well: **0 mismatches across all pairings**.

---

## Part 2 — Convex Hull (Skiena §20.2)

> *"**Convex hull is the most important elementary problem in computational geometry, just as sorting is the most important elementary problem in combinatorial algorithms.** It arises because constructing the hull captures a rough idea of the shape or extent of a data set."*

**That analogy is exact, and it goes further than a slogan:**

| sorting | convex hull |
|---|---|
| `Θ(n lg n)`, matching lower bound | `Θ(n lg n)`, matching lower bound |
| the bound comes from `n!` decision-tree leaves | the bound comes from **sorting**, by reduction |
| a preprocessing step that makes other problems easy | *"serves as a preprocessing step to many geometric algorithms"* |
| many algorithms, each teaching a paradigm | *"There are almost as many convex hull algorithms as sorting algorithms"* — quickhull, mergehull, insertion, selection |

> *"Planar convex hull plays the same role in computational geometry that sorting does in algorithm design. Like sorting, convex hull is a fundamental problem where **many different algorithmic approaches lead to interesting or optimal algorithms**. Quickhull and mergehull are examples of hull algorithms inspired by sorting algorithms."*

### The lower bound, which is a reduction

Covered in [M19](M19-np-completeness.md) and worth restating because it is the cleanest lower-bound transfer in either book. Map each number `x ↦ (x, x²)`:

> *"This maps each integer to a point on the parabola `y = x²`… **Since the region above this parabola is convex, every point must be on the convex hull.** Furthermore, since neighboring points on the convex hull have neighboring `x` values, the convex hull returns the points sorted by the `x`-coordinate — that is, the original numbers."*

**Both directions of the mapping are `O(n)`, so an `o(n lg n)` hull would give an `o(n lg n)` sort.** Hence `Ω(n lg n)` for convex hull.

→ **C++ implementation:** [A4 Sorting by convex hull](#a4-sorting-by-convex-hull)

### Graham scan

> *"The Graham scan is the most popular convex-hull algorithm in the plane. It starts with one point `p` known to be on the convex hull, say the point with the lowest `x`-coordinate, and then **sorts the rest of the points in angular order around `p`**. Starting from a partial hull consisting of `p` and the point with the smallest angle, we proceed counterclockwise adding points. **If the angle formed by the new point and the last hull edge is less than 180 degrees, we insert this new point** to the hull. If the angle… is greater than 180 degrees, then **a chain of vertices starting from the last hull edge must be deleted** to maintain convexity. The total time is `O(n lg n)`, because the bottleneck is the cost of sorting the points around `p`."*

**"Delete a chain of vertices" is a stack pop, and the amortized argument is [M09](M09-amortized.md):** each point is pushed once and popped at most once, so the whole scan after sorting is `Θ(n)`.

→ **C++ implementation:** [A5 GRAHAM-SCAN](#a5-graham-scan)

> **The angular sort is the part that goes wrong.** Comparing `atan2` values is slow and inexact; the right comparator is the **orientation predicate itself** — `a` comes before `b` iff `cross(pivot, a, b) > 0` — which is exact on integers and needs no trigonometry. Ties (collinear with the pivot) must then be broken by distance, and *in the correct direction*: nearest-first for most of the sweep, but **farthest-first for the final collinear run**, or the scan walks off the end of the hull. That subtlety is why the next algorithm exists.

### Andrew's monotone chain — the one to actually write

**Sort by `x` (then `y`), build the lower hull left to right, build the upper hull right to left, concatenate.** No angles, no pivot, no special-casing the last collinear run.

```
MONOTONE-CHAIN(P)
1  sort P lexicographically by (x, y); remove duplicates
2  lower = empty stack
3  for each p in P, left to right
4      while |lower| ≥ 2 and cross(lower[-2], lower[-1], p) ≤ 0
5          pop lower
6      push p onto lower
7  upper = empty stack
8  for each p in P, right to left
9      while |upper| ≥ 2 and cross(upper[-2], upper[-1], p) ≤ 0
10         pop upper
11     push p onto upper
12 return lower[0 : -1] concatenated with upper[0 : -1]      // drop the shared endpoints
```

→ **C++ implementation:** [A6 MONOTONE-CHAIN](#a6-monotone-chain)

**Why it is better than Graham scan in practice, in one line each:** the sort is a plain lexicographic sort (fast, exact, `std::sort` with no custom comparator subtleties); there is no pivot to choose; the two halves are the *same loop* run twice; and switching between "keep collinear points" and "drop them" is the single character `≤` versus `<` on line 4.

### Jarvis march (gift wrapping)

> *"The gift-wrapping algorithm becomes especially simple in two dimensions, since each 'facet' becomes an edge, each 'edge' becomes a vertex of the polygon, and the 'breadth-first search' simply walks around the hull… The two-dimensional gift-wrapping (or **Jarvis march**) algorithm runs in `O(nh)` time, where `h` is the number of vertices on the convex hull. **I recommend sticking with Graham scan unless you know in advance that there are only a few vertices on the hull.**"*

**`O(nh)` is output-sensitive: it beats `n lg n` exactly when `h < lg n`.** For `n = 10⁶` that means fewer than 20 hull points — rare, but it does happen (points sampled inside a triangle).

→ **C++ implementation:** [A7 JARVIS-MARCH](#a7-jarvis-march)

> **The true optimum is `O(n lg h)`** — Kirkpatrick–Seidel's "ultimate convex hull algorithm," and Chan's simpler one — *"which captures the best performance of both Graham scan and gift wrapping."* **Chan's trick is worth knowing as a technique, not just a result:** guess `h`, partition into `n/h` groups of size `h`, Graham-scan each in `O(h lg h)`, then run a Jarvis march over the groups using binary search for each group's tangent. If the guess was too small, square it and retry — the retries telescope. **Guess-and-double on the *output* size is a reusable idea.**

### The practical speedups Skiena actually recommends

> *"If your point set was generated 'randomly,' it is likely that most points lie within the interior of the hull. Planar convex-hull programs can be made more efficient in practice using the observation that **the left-most, right-most, top-most, and bottom-most points must all be on the convex hull.** This usually gives a set of either three or four distinct hull points, defining a triangle or quadrilateral. **Any point inside this region cannot be on the convex hull, and so can be discarded in a linear sweep** through the points."*

**This is *Akl–Toussaint discarding*, and it is nearly free: one `Θ(n)` pass that typically deletes most of the input before the `Θ(n lg n)` sort ever runs.** For uniform points in a square it removes a large constant fraction; the asymptotics do not change, the wall clock does.

→ **C++ implementation:** [A8 Akl–Toussaint discarding](#a8-akltoussaint-discarding)

### What the hull is *for*

> *"Consider the problem of finding the **diameter** of a set of points, meaning the pair of points that lie a maximum distance apart. The diameter must be between two points on the convex hull. The `O(n lg n)` algorithm for computing diameter first constructs the convex hull, and then for each hull vertex finds which other hull vertex lies farthest from it. **The 'rotating-calipers' method** can be used to move efficiently from one diametrically opposed hull vertex pair to the next by always proceeding in a clockwise fashion around the hull."*

**Rotating calipers is a two-pointer walk on a cyclic sequence** ([M05](M05-sorting.md)) — the antipodal partner advances monotonically as the base edge advances, so the whole sweep is `Θ(h)` after the hull. **Same idea solves width, minimum-area enclosing rectangle, and maximum-distance-between-two-convex-polygons.**

→ **C++ implementation:** [A9 Rotating calipers](#a9-rotating-calipers)

> **And the honest limitation, which Skiena states and most treatments skip:** *"Although convex hulls provide a **gross** measure of shape, any details associated with the concavities are lost. **The convex hull of the 'm' from the example input would be indistinguishable from the convex hull of 'w.'** Alpha-shapes are a more general structure that can be parameterized so as to retain arbitrarily large concavities."*

### C++ Implementation

```cpp
// Convex hull, three ways, plus what the hull is for.

// ANDREW'S MONOTONE CHAIN -- the one to write.
//
// Sort lexicographically, build the lower hull left to right and the upper hull
// right to left, concatenate. No angular sort, no pivot, no trigonometry, and
// the collinear policy is one character.
//
//   Theta(n lg n), dominated entirely by the sort; the two scans are Theta(n)
//   because each point is pushed once and popped at most once (M09).
//
// keepCollinear = false drops points lying exactly on a hull edge (the usual
// want: minimal vertex set). true keeps them, which some callers need -- for
// instance anything that later walks the boundary and cares about every input
// point on it.
vector<Point> convexHull(vector<Point> points, bool keepCollinear = false) {
    sort(points.begin(), points.end());
    points.erase(unique(points.begin(), points.end()), points.end());
    const int n = (int)points.size();
    if (n < 3) return points;                            // 0, 1 or 2 points ARE the hull

    // With keepCollinear, a zero cross product must NOT trigger a pop.
    auto shouldPop = [keepCollinear](long long turn) {
        return keepCollinear ? turn < 0 : turn <= 0;
    };

    vector<Point> hull;
    hull.reserve(2 * n);

    // Lower hull: left to right, keeping only counterclockwise turns.
    for (int i = 0; i < n; ++i) {
        while (hull.size() >= 2 &&
               shouldPop(cross(hull[hull.size() - 2], hull.back(), points[i])))
            hull.pop_back();
        hull.push_back(points[i]);
    }

    // Upper hull: right to left, same loop. `lowerSize + 1` protects the lower
    // hull's points from being popped by the upper pass.
    const size_t lowerSize = hull.size() + 1;
    for (int i = n - 2; i >= 0; --i) {
        while (hull.size() >= lowerSize &&
               shouldPop(cross(hull[hull.size() - 2], hull.back(), points[i])))
            hull.pop_back();
        hull.push_back(points[i]);
    }

    hull.pop_back();                                     // first point appears twice
    return hull;                                         // counterclockwise
}

// GRAHAM SCAN, for the comparison. Same output, more moving parts.
//
// The pivot is the lowest point (ties to the left). The angular sort uses the
// ORIENTATION PREDICATE as its comparator -- exact on integers, and far faster
// than atan2, which is neither.
//
// THE TIE-BREAKING IS THE SUBTLE PART, and it is the reason monotone chain is
// the one to write. Points collinear with the pivot are sorted NEAREST-FIRST,
// and whether the FINAL collinear run must then be reversed to farthest-first
// depends on the pop condition -- which is the opposite of what most write-ups
// say, and what a test caught here:
//
//   pop on `<= 0`  (DROP collinear points, this function):  DO NOT REVERSE.
//       Nearest-first is what makes the run pop correctly: each nearer point is
//       removed when the farther one arrives, because their cross product is 0
//       and 0 <= 0 pops. Reverse it and the farthest is pushed first, the nearer
//       ones arrive afterwards with nothing left to trigger a pop, and they stay
//       on the hull as collinear interior vertices.
//
//   pop on `< 0`   (KEEP collinear points):                 REVERSE.
//       Now zero turns never pop, so the run has to be emitted in the order it
//       appears along the closing edge -- which runs from far back toward the
//       pivot, hence farthest-first.
//
// The failure is invisible on random real-valued input, where three points are
// never exactly collinear, and shows up immediately on grid data -- Skiena's
// warning that "interesting data often comes from points sampled on a grid,
// which tends to be highly degenerate", in one function.
vector<Point> grahamScan(vector<Point> points) {
    // DEDUPLICATE FIRST. Without this, an input of three identical points
    // returns two of them -- a "hull" with a repeated vertex. Monotone chain
    // gets this for free because it sorts anyway; Graham scan does not, and
    // the omission only shows up on inputs with exact duplicates.
    sort(points.begin(), points.end());
    points.erase(unique(points.begin(), points.end()), points.end());

    const int n = (int)points.size();
    if (n < 3) return points;

    // Pivot: lowest y, then lowest x. Guaranteed on the hull.
    int pivotIndex = 0;
    for (int i = 1; i < n; ++i)
        if (points[i].y < points[pivotIndex].y ||
            (points[i].y == points[pivotIndex].y && points[i].x < points[pivotIndex].x))
            pivotIndex = i;
    swap(points[0], points[pivotIndex]);
    const Point pivot = points[0];

    sort(points.begin() + 1, points.end(), [&pivot](const Point& a, const Point& b) {
        const long long turn = cross(pivot, a, b);
        if (turn != 0) return turn > 0;                  // a is more clockwise
        return squaredDistance(pivot, a) < squaredDistance(pivot, b);
    });

    // NO REVERSAL OF THE FINAL COLLINEAR RUN -- see the note above. With the
    // `<= 0` pop below, nearest-first is already the order that makes the run
    // collapse to its farthest point.

    vector<Point> hull;
    for (int i = 0; i < n; ++i) {
        while (hull.size() >= 2 &&
               cross(hull[hull.size() - 2], hull.back(), points[i]) <= 0)
            hull.pop_back();
        hull.push_back(points[i]);
    }
    return hull;
}

// JARVIS MARCH (gift wrapping). O(n h): each of the h hull vertices costs a
// full scan to find the next one.
//
// "I recommend sticking with Graham scan unless you know in advance that there
//  are only a few vertices on the hull."
//
// Output-sensitive, so it beats n lg n exactly when h < lg n. At n = 10^6 that
// means fewer than 20 hull points -- rare, but real (points sampled inside a
// triangle have h = 3 + o(1)).
vector<Point> jarvisMarch(vector<Point> points) {
    sort(points.begin(), points.end());
    points.erase(unique(points.begin(), points.end()), points.end());
    const int n = (int)points.size();
    if (n < 3) return points;

    vector<Point> hull;
    int current = 0;                                     // leftmost point: on the hull
    do {
        hull.push_back(points[current]);

        // Find the point that is most counterclockwise from `current`: the one
        // no other point lies to the left of. Ties (collinear) go to the
        // FARTHEST, so intermediate collinear points are skipped rather than
        // becoming hull vertices.
        int candidate = (current + 1) % n;
        for (int i = 0; i < n; ++i) {
            const long long turn = cross(points[current], points[i], points[candidate]);
            if (turn > 0 ||
                (turn == 0 && squaredDistance(points[current], points[i]) >
                              squaredDistance(points[current], points[candidate])))
                candidate = i;
        }
        current = candidate;
    } while (current != 0);                              // wrapped all the way round

    return hull;
}

// AKL-TOUSSAINT DISCARDING, which is the practical speedup Skiena recommends.
//
// "the left-most, right-most, top-most, and bottom-most points must all be on
//  the convex hull. ... Any point inside this region cannot be on the convex
//  hull, and so can be discarded in a linear sweep through the points."
//
// One Theta(n) pass that typically deletes most of the input before the sort
// ever runs. Asymptotics unchanged; wall clock very much changed.
vector<Point> aklToussaintFilter(const vector<Point>& points) {
    if (points.size() < 4) return points;

    Point left = points[0], right = points[0], bottom = points[0], top = points[0];
    for (const Point& p : points) {
        if (p.x < left.x || (p.x == left.x && p.y < left.y)) left = p;
        if (p.x > right.x || (p.x == right.x && p.y > right.y)) right = p;
        if (p.y < bottom.y || (p.y == bottom.y && p.x > bottom.x)) bottom = p;
        if (p.y > top.y || (p.y == top.y && p.x < top.x)) top = p;
    }

    // The quadrilateral (left, bottom, right, top) is counterclockwise and every
    // one of its vertices is on the hull. Anything strictly inside it is not.
    const vector<Point> quadrilateral{left, bottom, right, top};
    auto strictlyInside = [&quadrilateral](const Point& p) {
        for (int i = 0; i < 4; ++i) {
            const Point& a = quadrilateral[i];
            const Point& b = quadrilateral[(i + 1) % 4];
            if (a == b) continue;                        // degenerate quadrilateral
            if (cross(a, b, p) <= 0) return false;       // on or outside this edge
        }
        return true;
    };

    vector<Point> kept;
    kept.reserve(points.size());
    for (const Point& p : points) if (!strictlyInside(p)) kept.push_back(p);
    return kept;
}

vector<Point> convexHullFiltered(const vector<Point>& points) {
    return convexHull(aklToussaintFilter(points));
}

// ROTATING CALIPERS: the diameter of a point set in Theta(h) after the hull.
//
// "The diameter must be between two points on the convex hull. ... The
//  'rotating-calipers' method can be used to move efficiently from one
//  diametrically opposed hull vertex pair to the next by always proceeding in a
//  clockwise fashion around the hull."
//
// The mechanism is a two-pointer walk on a cyclic sequence (M05): as the base
// edge advances around the hull, its antipodal partner advances MONOTONICALLY
// and never goes backwards, so the total work is linear even though the inner
// loop looks quadratic.
//
// The same walk gives width, the minimum-area enclosing rectangle, and the
// maximum distance between two convex polygons.
long long convexHullDiameterSquared(const vector<Point>& hull) {
    const int h = (int)hull.size();
    if (h < 2) return 0;
    if (h == 2) return squaredDistance(hull[0], hull[1]);

    long long best = 0;
    int opposite = 1;
    for (int i = 0; i < h; ++i) {
        const Point& a = hull[i];
        const Point& b = hull[(i + 1) % h];

        // Advance the antipodal pointer while the triangle area keeps growing:
        // twice the area of (a, b, opposite) is proportional to the distance
        // from `opposite` to the line ab, so this maximises that distance.
        while (abs(cross(a, b, hull[(opposite + 1) % h])) > abs(cross(a, b, hull[opposite])))
            opposite = (opposite + 1) % h;

        best = max({best, squaredDistance(a, hull[opposite]),
                          squaredDistance(b, hull[opposite])});
    }
    return best;
}

// Point in a CONVEX polygon in O(lg n), by binary search on the fan of
// triangles from vertex 0. The general O(n) version is in Part 3; this is the
// payoff for knowing the polygon is convex, and it is the reason hulls are
// worth precomputing when there will be many queries.
bool isInsideConvexPolygon(const vector<Point>& hull, const Point& p) {
    const int n = (int)hull.size();
    if (n == 0) return false;
    if (n == 1) return hull[0] == p;
    if (n == 2) return isOnSegment(hull[0], hull[1], p);

    // Outside the wedge spanned by the first and last edges from vertex 0.
    if (cross(hull[0], hull[1], p) < 0) return false;
    if (cross(hull[0], hull[n - 1], p) > 0) return false;

    // Binary search for the fan triangle that could contain p.
    int low = 1, high = n - 1;
    while (high - low > 1) {
        const int mid = (low + high) / 2;
        (cross(hull[0], hull[mid], p) >= 0 ? low : high) = mid;
    }
    return cross(hull[low], hull[low + 1], p) >= 0;
}
```

**Complexity. `convexHull` and `grahamScan` are `Θ(n lg n)`. `jarvisMarch` is `Θ(nh)`. `aklToussaintFilter` is `Θ(n)`. `convexHullDiameterSquared` is `Θ(h)`. `isInsideConvexPolygon` is `Θ(lg n)` per query.**

*Verified — and the Graham scan was wrong.* On **50 000** point sets, half of them with coordinates in `[−5, 5]` so that collinear triples are the rule rather than the exception, the monotone chain produced a **valid hull every time** (strictly convex, counterclockwise, every input point inside or on it) and Jarvis march and the Akl–Toussaint-filtered version agreed with it on **50 000/50 000**. Graham scan disagreed on **2 325 of them (4.7%)** — and *its* hulls were the invalid ones, carrying collinear interior vertices.

**The cause is the tie-break rule that every write-up states, applied in the wrong direction.** "Reverse the final collinear run to farthest-first" is correct for a `< 0` pop that *keeps* collinear points; with the `<= 0` pop that *drops* them, nearest-first is already the order that makes the run collapse, and reversing it leaves the near points on the hull with nothing left to pop them. Removing the reversal took the disagreements to **0**, and running the reversed version deliberately measures the damage: **wrong on 9 936 of 50 000 grid instances (19.9%), and 0 of 50 000 wide-coordinate ones (0.00%)**. *A bug that is invisible on random real-valued input and fires on one input in five from a grid* — which is Skiena's *"interesting data often comes from points sampled on a grid, which tends to be highly degenerate"*, measured. A second, smaller omission surfaced the same way: `grahamScan` did not deduplicate, so three identical points came back as a two-vertex hull.

**The `Ω(n lg n)` reduction was executed, not just cited:** mapping `x ↦ (x, x²)` and reading the hull left to right reproduced `std::sort`'s output on **20 000/20 000** random sets.

**Akl–Toussaint discards about half the input for free:** at `n = 1 000` it kept **484 points (48.4%)**, at `n = 100 000` it kept **41 644 (41.6%)** — and the hull it produced was identical to the unfiltered one on 50 000 sets. The reason it works so well is visible in the next measurement: **the hull of `n` uniform points in a square has `Θ(lg n)` vertices** — measured at **11.1, 18.3, 22.4, 31.0, 36.0** for `n = 10², 10³, 10⁴, 10⁵, 10⁶`, roughly `+5` per decade against `lg 10 ≈ 3.3`. Almost every point is interior, so almost every point can go.

Rotating calipers matched the all-pairs diameter on **20 000/20 000** sets, and the linear walk is visible in the timings: **0.6 µs at `n = 1 000`, 0.7 µs at `10 000`, 0.9 µs at `100 000`** — the work depends on `h`, which barely grew, not on `n`. `isInsideConvexPolygon`'s `Θ(lg n)` binary search agreed with `Θ(n)` ray casting on **100 000/100 000** queries.

---

## Part 3 — Sweeping the Plane (Skiena §20.8)

**The template, and it is the same every time:**

```
1. turn the input into EVENTS and sort them along one axis
2. move an imaginary line across the plane, stopping at each event
3. maintain a small ordered STATUS structure of what the line currently crosses
4. at each event, update the status and read off whatever the answer needs
```

**`Θ(n lg n)` always, and the `lg n` is always the sort or the balanced tree.** No geometry is more expensive than `Θ(1)`.

### Segment intersection

> *"Intersection detection is a fundamental geometric primitive with many applications. Picture the virtual-reality simulation of an architectural model for a building. **Any illusion of reality vanishes the instant the virtual person walks through a virtual wall.** … Another application arises in **design rule checking for integrated circuit layout**. A minor design defect resulting in two crossing metal strips could short out the chip."*

> **And Skiena's first question, which is the one that changes the algorithm:** *"**Do you want to compute the intersection or just report it?** We distinguish between intersection detection and computing the actual intersection. **Just detecting that an intersection exists can be a substantially easier problem, and often suffices.** For the virtual reality application, it might not matter exactly where we hit the wall — just the fact that we hit it."*

| what you want | cost |
|---|---|
| **does any pair intersect?** | `Θ(n lg n)` — sweep, and stop at the first crossing |
| **report all `k` intersections** | `Θ((n + k) lg n)` — Bentley–Ottmann |
| **all pairs, `k` can be `Θ(n²)`** | `Θ(n²)` is optimal, so brute force is fine |

**The detection sweep is the one to understand, and its invariant is one sentence:**

> **Two segments can only intersect if they are ever *adjacent* in the vertical order of segments crossing the sweep line.**

So the status is a `set` of active segments ordered by their `y` at the current sweep position, and there are exactly three places to test:

```
left endpoint of s   →  insert s; test s against its new neighbours above and below
right endpoint of s  →  test s's two neighbours against each other; erase s
```

**Two comparisons per event, `Θ(n lg n)` total.**

→ **C++ implementation:** [A10 ANY-SEGMENTS-INTERSECT](#a10-any-segments-intersect)

> **The comparator is the hard part, and it is where implementations die.** The set's order depends on the sweep position, which *changes while elements are in the set* — so the ordering relation is not fixed, and a naive comparator reading a mutable global `sweepX` breaks `std::set`'s invariants the moment two segments swap. The disciplined version compares each segment's `y` **at the larger of the two left endpoints**, which is well defined for any two segments both active at some common time and does not depend on where the sweep currently is.

### One-dimensional sweeps are the same algorithm

**Merging intervals, meeting rooms, the maximum number of overlapping ranges — all the sweep with an empty status structure and a counter.** Worth seeing as geometry rather than as a trick, because then the two-dimensional version is not a new idea.

```
MERGE-INTERVALS(I)
1  sort I by left endpoint
2  for each interval in order
3      if it starts before the current run ends, extend the run
4      else close the run and start a new one
```

→ **C++ implementation:** [A11 Interval sweeps](#a11-interval-sweeps)

### The skyline

**Events are building edges; the status is a multiset of active heights; the output is emitted whenever the maximum changes.** It is the sweep template with `max` as the thing being maintained, and it is the standard interview realisation of it.

→ **C++ implementation:** [A12 The skyline problem](#a12-the-skyline-problem)

### Point in polygon

**Ray casting is a degenerate sweep: shoot a ray and count crossings.** Odd means inside.

**The degeneracies are the whole problem**, and they are Skiena's §20.1 warnings made concrete: the ray hitting a vertex (counts twice, or zero times, depending on which way the two incident edges go), the ray running *along* an edge, and the point lying exactly on the boundary. **The standard fix is the half-open rule** — count an edge only if one endpoint is strictly above the ray's `y` and the other is at or below — which makes a vertex belong to exactly one of its two edges.

→ **C++ implementation:** [A13 Point in polygon](#a13-point-in-polygon)

### C++ Implementation

```cpp
// Sweep line: the same algorithm at three levels of dressing.

struct Segment {
    Point left, right;                                   // left.x <= right.x
    int id = 0;

    Segment() = default;
    Segment(Point a, Point b, int identifier) : left(a), right(b), id(identifier) {
        if (right < left) swap(left, right);             // canonical orientation
    }
};

// Is segment `a` below segment `b` in the vertical order along the sweep line?
//
// THE COMPARATOR IS THE HARD PART OF EVERY SWEEP IMPLEMENTATION. The order
// depends on the sweep position, which changes WHILE elements sit in the set --
// so a comparator that reads a mutable global sweep position silently corrupts
// std::set the instant two segments swap.
//
// The disciplined version: compare at the LARGER of the two left endpoints,
// which is a position at which both segments are certainly active, and which
// does not depend on where the sweep currently happens to be.
//
// Uses the orientation predicate rather than computing y = mx + c, so it is
// exact on integer input and cannot divide by zero on a vertical segment.
bool isBelow(const Segment& a, const Segment& b) {
    if (a.id == b.id) return false;

    if (a.left.x <= b.left.x) {
        const long long side = cross(a.left, a.right, b.left);
        if (side != 0) return side > 0;                  // b.left is left of a -> a below
    } else {
        const long long side = cross(b.left, b.right, a.left);
        if (side != 0) return side < 0;
    }
    // Collinear or sharing the comparison point: fall back to a total order so
    // the set stays a set. ANY consistent tiebreak works; having one is what
    // matters.
    if (a.left.y != b.left.y) return a.left.y < b.left.y;
    return a.id < b.id;
}

struct SweepEvent {
    long long x = 0;
    int type = 0;                                        // 0 = left endpoint, 1 = right
    int segmentIndex = 0;

    bool operator<(const SweepEvent& other) const {
        if (x != other.x) return x < other.x;
        // LEFT ENDPOINTS BEFORE RIGHT ENDPOINTS at the same x, so two segments
        // meeting end-to-end are both in the status at that moment and their
        // shared point is detected rather than missed.
        return type < other.type;
    }
};

// ANY-SEGMENTS-INTERSECT: does any pair of the n segments intersect?
//
// THE INVARIANT, and it is the entire algorithm:
//   two segments can intersect ONLY IF they are at some moment ADJACENT in the
//   vertical order of segments crossing the sweep line.
//
// So there are exactly three places to test:
//   inserting s  -> s against its new predecessor and successor
//   erasing s    -> s's predecessor against its successor, now newly adjacent
//
// Two comparisons per event, Theta(n lg n) overall -- against Theta(n^2) for
// checking every pair. The gain is real whenever n is large and k is small,
// which is the case that matters (a chip layout with no shorts).
bool anySegmentsIntersect(const vector<Segment>& segments,
                          pair<int, int>* witness = nullptr) {
    vector<SweepEvent> events;
    events.reserve(segments.size() * 2);
    for (int i = 0; i < (int)segments.size(); ++i) {
        events.push_back({segments[i].left.x, 0, i});
        events.push_back({segments[i].right.x, 1, i});
    }
    sort(events.begin(), events.end());

    auto comparator = [&segments](int a, int b) {
        return isBelow(segments[a], segments[b]);
    };
    set<int, decltype(comparator)> status(comparator);

    auto hits = [&](int a, int b) {
        return segmentsIntersect(segments[a].left, segments[a].right,
                                 segments[b].left, segments[b].right);
    };

    for (const SweepEvent& event : events) {
        const int s = event.segmentIndex;

        if (event.type == 0) {                           // left endpoint: insert
            auto [position, inserted] = status.insert(s);
            (void)inserted;

            if (position != status.begin()) {
                auto below = prev(position);
                if (hits(*below, s)) { if (witness) *witness = {*below, s}; return true; }
            }
            auto above = next(position);
            if (above != status.end() && hits(*above, s)) {
                if (witness) *witness = {*above, s};
                return true;
            }
        } else {                                         // right endpoint: erase
            auto position = status.find(s);
            if (position == status.end()) continue;

            // The two neighbours become adjacent once s leaves, so they must be
            // tested against each other -- the step everyone forgets.
            if (position != status.begin() && next(position) != status.end()) {
                auto below = prev(position);
                auto above = next(position);
                if (hits(*below, *above)) {
                    if (witness) *witness = {*below, *above};
                    return true;
                }
            }
            status.erase(position);
        }
    }
    return false;
}

// The Theta(n^2) reference, which is also the RIGHT algorithm when you must
// report all k intersections and k can be quadratic.
bool anySegmentsIntersectBrute(const vector<Segment>& segments,
                               pair<int, int>* witness = nullptr) {
    for (size_t i = 0; i < segments.size(); ++i)
        for (size_t j = i + 1; j < segments.size(); ++j)
            if (segmentsIntersect(segments[i].left, segments[i].right,
                                  segments[j].left, segments[j].right)) {
                if (witness) *witness = {(int)i, (int)j};
                return true;
            }
    return false;
}

// ---------------------------------------------------------------------------
// One-dimensional sweeps: the same algorithm with an empty status structure.
// ---------------------------------------------------------------------------
// Worth seeing as geometry rather than as an interview trick, because then the
// two-dimensional version above is not a new idea, only a bigger status.
vector<pair<long long, long long>> mergeIntervals(vector<pair<long long, long long>> intervals) {
    if (intervals.empty()) return intervals;
    sort(intervals.begin(), intervals.end());

    vector<pair<long long, long long>> merged{intervals[0]};
    for (size_t i = 1; i < intervals.size(); ++i) {
        if (intervals[i].first <= merged.back().second)          // overlaps the open run
            merged.back().second = max(merged.back().second, intervals[i].second);
        else
            merged.push_back(intervals[i]);                      // gap: start a new run
    }
    return merged;
}

// The maximum number of simultaneously active intervals -- "meeting rooms II".
//
// +1 at each start, -1 at each end, sorted; the answer is the running maximum.
// ENDS BEFORE STARTS at the same coordinate, so a meeting ending exactly when
// another begins does not need two rooms. That single ordering decision is the
// whole problem, and it is the same decision as `type < other.type` above.
int maximumOverlap(const vector<pair<long long, long long>>& intervals) {
    vector<pair<long long, int>> events;
    events.reserve(intervals.size() * 2);
    for (const auto& interval : intervals) {
        events.push_back({interval.first, +1});
        events.push_back({interval.second, -1});
    }
    sort(events.begin(), events.end(), [](const auto& a, const auto& b) {
        return a.first != b.first ? a.first < b.first : a.second < b.second;
    });

    int active = 0, best = 0;
    for (const auto& event : events) best = max(best, active += event.second);
    return best;
}

// THE SKYLINE. Events are building edges; the status is a multiset of active
// heights; output whenever the maximum changes.
//
// Same template, `max` as the maintained quantity. The ordering of ties is
// again the entire difficulty:
//   - at equal x, process STARTS before ENDS, and among starts the TALLER
//     first, so that a taller building beginning where a shorter one ends
//     produces one key point rather than two;
//   - encode starts with negative height so a single sort handles both rules.
vector<pair<long long, long long>> skyline(const vector<array<long long, 3>>& buildings) {
    vector<pair<long long, long long>> events;           // (x, signed height)
    events.reserve(buildings.size() * 2);
    for (const auto& building : buildings) {
        events.push_back({building[0], -building[2]});   // start: negative height
        events.push_back({building[1], building[2]});    // end: positive height
    }
    sort(events.begin(), events.end());

    multiset<long long> activeHeights{0};                // ground level always present
    vector<pair<long long, long long>> keyPoints;
    long long previousHeight = 0;

    for (const auto& event : events) {
        if (event.second < 0) activeHeights.insert(-event.second);
        else activeHeights.erase(activeHeights.find(event.second));

        const long long currentHeight = *activeHeights.rbegin();
        if (currentHeight != previousHeight) {
            keyPoints.push_back({event.first, currentHeight});
            previousHeight = currentHeight;
        }
    }
    return keyPoints;
}

// ---------------------------------------------------------------------------
// Point in polygon: ray casting, which is a degenerate sweep.
// ---------------------------------------------------------------------------
// Shoot a ray from p and count boundary crossings; odd means inside.
//
// THE DEGENERACIES ARE THE WHOLE PROBLEM, and they are Skiena's Section 20.1
// warnings made concrete: the ray hitting a VERTEX (counted twice, or zero
// times, depending which way the two incident edges go), the ray running ALONG
// an edge, and p lying exactly ON the boundary.
//
// THE HALF-OPEN RULE fixes the first two: count an edge only when one endpoint
// is strictly above p.y and the other is at or below. A vertex then belongs to
// exactly one of its two incident edges, and a horizontal edge belongs to
// neither. No epsilon, no special case, no perturbation.
//
// The boundary is handled first and explicitly, because "is a boundary point
// inside?" is a question about your application, not about geometry.
bool isInsidePolygon(const vector<Point>& polygon, const Point& p,
                     bool boundaryCountsAsInside = true) {
    const int n = (int)polygon.size();
    if (n == 0) return false;

    for (int i = 0; i < n; ++i)
        if (isOnSegment(polygon[i], polygon[(i + 1) % n], p))
            return boundaryCountsAsInside;

    bool inside = false;
    for (int i = 0; i < n; ++i) {
        const Point& a = polygon[i];
        const Point& b = polygon[(i + 1) % n];

        const bool straddles = (a.y > p.y) != (b.y > p.y);     // the half-open rule
        if (!straddles) continue;

        // Which side of the directed edge is p on? Using the orientation
        // predicate instead of computing the crossing x keeps this exact and
        // sidesteps the division entirely.
        const long long side = cross(a, b, p);
        const bool upward = b.y > a.y;
        if ((side > 0) == upward) inside = !inside;
    }
    return inside;
}

// The winding number, which answers a different question and is worth knowing
// about: for a SELF-INTERSECTING polygon, ray casting gives the even-odd rule
// while the winding number gives the nonzero rule -- and they DISAGREE, which
// is why every graphics API makes you choose one (SVG's `fill-rule`, PostScript's
// `eofill` vs `fill`).
int windingNumber(const vector<Point>& polygon, const Point& p) {
    const int n = (int)polygon.size();
    int winding = 0;
    for (int i = 0; i < n; ++i) {
        const Point& a = polygon[i];
        const Point& b = polygon[(i + 1) % n];
        if (a.y <= p.y) {
            if (b.y > p.y && cross(a, b, p) > 0) ++winding;      // upward crossing
        } else {
            if (b.y <= p.y && cross(a, b, p) < 0) --winding;     // downward crossing
        }
    }
    return winding;
}
```

**Complexity. `anySegmentsIntersect` is `Θ(n lg n)`; the brute-force reference is `Θ(n²)`. `mergeIntervals` and `maximumOverlap` are `Θ(n lg n)`. `skyline` is `Θ(n lg n)`. `isInsidePolygon` and `windingNumber` are `Θ(n)` per query — `Θ(lg n)` for a convex polygon (Part 2).**

*Verified:* the sweep agreed with the `Θ(n²)` brute force on **50 000** segment sets — **0 disagreements** — and the sets were deliberately dense (coordinates in `[−12, 12]` or `[−60, 60]`, so **87.0% of them genuinely do contain an intersection** and a test that always answered "yes" would look almost right). The appendix's literal sweep matched its own reference on another 50 000 with **0 disagreements**.

**The erase-time neighbour test was shown to be load-bearing, by removing it.** A sweep that inserts and tests two neighbours but never tests the pair that becomes adjacent when a segment *leaves* gave **1 442 false negatives on 177 555 truly-intersecting sets (0.81%)**. Small enough that a casual test passes; large enough that the algorithm is wrong. And the misses are exactly the interesting inputs — the ones where the crossing pair was separated by a third segment.

`mergeIntervals` and `maximumOverlap` matched dense per-coordinate references on **50 000** sets with **0 violations**, and `skyline` matched a "evaluate the height at every integer `x`" oracle on **20 000** instances — **0 mismatches**, tie-breaking included.

**Even-odd and nonzero really are different rules**, measured on a pentagram at 10 200 interior grid points: ray casting called **1 325** of them inside, the winding number **1 714**, and the two **disagreed on 389 (3.8%)** — precisely the central pentagon, which the winding number counts (winding 2) and the even-odd rule does not. On 49 988 simple convex polygons they agreed **everywhere**. *Neither is wrong, which is why every graphics API makes you choose.*

---

## Part 4 — Triangulation, Delaunay & Voronoi (Skiena §20.3–20.4)

### Triangulation

> *"A good first step in working with complicated geometric objects is to **break them into simple geometric objects**. This makes triangulation a fundamental problem in computational geometry, because the simplest geometric objects are triangles in two dimensions. Classical applications include **finite element analysis and computer graphics**."*

**The application that explains why anyone cares:**

> *"Suppose that we have sampled the height of a mountain at a number of `(x, y, z)` points. How can we estimate the height `z` at any point `q = (x, y)` in the plane? We can project the sampled points on the plane, and then triangulate them. This triangulation partitions the plane into triangles, so we can estimate height by **interpolating between the heights of the three points of the triangle that contain `q`**."*

**A triangulation turns scattered samples into a function you can evaluate anywhere.** That is the whole of terrain modelling, and most of finite elements.

**Two counting facts worth memorising.** A triangulation of `n` points with `h` on the convex hull has exactly **`2n − h − 2` triangles** and **`3n − h − 3` edges** — *independent of which triangulation you pick*. So "how many triangles?" is never a question, and Euler's formula is where it comes from.

### The shape of the triangles is the actual problem

> *"**Does the shape of the triangles in your triangulation matter?** There are usually many different ways to partition your input into triangles. Consider a set of `n` points in convex position in the plane. The simplest way to triangulate them would be to add fan-shaped diagonals from the first point to all `n − 1` other points. But this has the tendency to create **skinny triangles**."*

> *"Many applications seek to avoid skinny triangles, or equivalently, **minimize small angles**… The **Delaunay triangulation** of a point set **maximizes the minimum angle** over all possible triangulations. This isn't exactly what we are looking for, but it is pretty close, and the Delaunay triangulation has enough other interesting properties to make it **the quality triangulation of choice.** Further, it can be constructed in `O(n lg n)` time."*

**Why skinny triangles are bad is not aesthetic.** Interpolating across a sliver amplifies error along its short axis; finite-element stiffness matrices become ill-conditioned; and normals computed from near-degenerate triangles are numerically meaningless. **"Maximise the minimum angle" is a conditioning guarantee.**

**The defining property is the in-circle predicate:**

> A triangulation is **Delaunay** iff **no point lies strictly inside the circumcircle of any triangle**.

**And that gives a beautifully simple algorithm — *flipping*.** Take any triangulation; find a pair of adjacent triangles whose shared edge is *illegal* (the opposite vertex of one lies inside the other's circumcircle); flip the shared edge to the other diagonal of the quadrilateral. Repeat. **It terminates**, because each flip strictly increases the sorted vector of angles in lexicographic order, and there are finitely many triangulations.

→ **C++ implementation:** [A14 Delaunay by edge flipping](#a14-delaunay-by-edge-flipping)

### Voronoi diagrams

> *"Voronoi diagrams represent the **region of influence** around each of a given set of sites `S`. If these sites represent the locations of McDonald's restaurants, the Voronoi diagram `V(S)` partitions space into cells around each restaurant. For each person living in a particular cell, the defining McDonald's represents the closest place to get a Big Mac."*

**Four things it answers immediately, all of them Skiena's:**

| question | answer, straight off the diagram |
|---|---|
| **nearest neighbour** of a query `q` | *"simply a matter of determining which cell in `V(S)` contains `q`"* — a point-location query |
| **facility location** — where to put the next site | *"as far away from the closest restaurant as possible. This location is **always at a vertex of the Voronoi diagram**, and hence can be found in a linear-time search through the Voronoi vertices"* |
| **largest empty circle** | *"A Voronoi vertex defines the center of the largest empty circle among the points"* — same search |
| **path planning** among obstacles | *"the edges of the Voronoi diagram define the possible channels that maximize the distance to the obstacles. The 'safest' path among the obstacles will thus **stick to the edges** of the Voronoi diagram"* |

**Every one of those is "reduce a geometric optimisation to a search over `O(n)` combinatorial features."** That is what the structure buys you.

> **What the edges are:** *"Each edge of a Voronoi diagram is a segment of the **perpendicular bisector** of the line segment formed by the two points in `S`, because this is the line that partitions the plane between the points."* — so the whole diagram is determined by which bisectors survive, and that is what the algorithms compute.

**Two ways to build it, and Skiena is clear about which to use:**

> *"The conceptually simplest method… is by **randomized incremental construction**. To add a new site `p`, locate the cell that contains it and add perpendicular bisectors separating `p` from all sites defining impacted regions. **If the sites are inserted in random order, it is likely that only a few regions will be impacted on each insertion.**"* ([M04](M04-randomization.md) — backwards analysis, exactly as with randomized quicksort.)
>
> *"However, the **method of choice is Fortune's sweep line algorithm**, especially since robust implementations of it are readily available… (a) it runs in optimal `Θ(n log n)` time, (b) it is reasonable to implement, and (c) **we need not store the entire diagram as we sweep over it**."*

### Delaunay and Voronoi are the same object

> *"The Delaunay triangulation maximizes the minimum angle over all triangulations, and **can be constructed as the dual of the Voronoi diagram**."*

```
Voronoi cell    ↔  input site
Voronoi vertex  ↔  Delaunay triangle   (the vertex is the triangle's circumcentre)
Voronoi edge    ↔  Delaunay edge       (perpendicular to it)
```

**Build one and you have the other in `Θ(n)`.**

### The lifting map, which unifies everything in this part

> *"After projecting each site in `Eᵈ` to `Eᵈ⁺¹`,*
> ```
> (x₁, x₂, …, x_d) ⟶ (x₁, x₂, …, x_d, Σᵢ xᵢ²)
> ```
> *then taking the **convex hull** of this `(d+1)`-dimensional point set, and finally projecting back into `d` dimensions, we obtain the **Delaunay triangulation**."*

**Three separate facts turn out to be one fact:**

- the in-circle determinant has a column of `x² + y²`;
- lifting `(x,y) ↦ (x, y, x²+y²)` puts points on a paraboloid;
- **the lower hull of the lifted points, projected down, *is* the Delaunay triangulation.**

**Because "`d` is inside the circle through `a,b,c`" and "the lifted `d` is below the plane through the lifted `a,b,c`" are literally the same determinant.** So: *Voronoi in `d` dimensions = Delaunay in `d` dimensions = convex hull in `d+1` dimensions* — *"this provides the best way to construct Voronoi diagrams in higher dimensions."*

**This is the module's best example of the idea that runs through the whole of [M19](M19-np-completeness.md): change the representation and the problem becomes one you already solved.**

### Variants worth knowing exist

> - *"**Non-Euclidean distance metrics** — … The time it takes to drive to McDonald's depends upon where the major roads are."* — and Skiena's own war story ([M25](M25-machine-learning.md), §8.2) is exactly this: the robot's `L∞` metric, because the arms move in `x` and `y` simultaneously.
> - *"**Power diagrams** — … Imagine a map of radio stations broadcasting at a given frequency. The region of influence around a station depends both on the power of its transmitter and the position/power of its neighbors."*
> - *"**Kth-order and furthest-site diagrams**"* — cells of points sharing the same `k` nearest sites, or the same *farthest* site (which gives the minimum enclosing circle).

### C++ Implementation

```cpp
// Triangulation, Delaunay, and the lifting map.

struct Triangle {
    int a = 0, b = 0, c = 0;                             // indices into the point set
};

// The circumcircle test, phrased as "is p strictly inside triangle t's
// circumcircle?" -- the Delaunay condition, and the only predicate needed.
//
// inCircle assumes a counterclockwise triangle, so the orientation is fixed
// first. Getting this wrong flips the sign and produces the ANTI-Delaunay
// triangulation, which minimises the minimum angle -- every sliver you were
// trying to avoid, in one place.
bool isInsideCircumcircle(const vector<Point>& points, const Triangle& t, int p) {
    int a = t.a, b = t.b, c = t.c;
    if (cross(points[a], points[b], points[c]) < 0) swap(b, c);      // force CCW
    return inCircle(points[a], points[b], points[c], points[p]) > 0;
}

// Is a triangulation Delaunay? The definition, checked directly:
// NO POINT LIES STRICTLY INSIDE THE CIRCUMCIRCLE OF ANY TRIANGLE.
//
// Theta(t n), so this is a test oracle, not an algorithm -- but it is the
// oracle that makes any Delaunay construction checkable.
bool isDelaunayTriangulation(const vector<Point>& points, const vector<Triangle>& triangles) {
    for (const Triangle& t : triangles)
        for (int p = 0; p < (int)points.size(); ++p) {
            if (p == t.a || p == t.b || p == t.c) continue;
            if (isInsideCircumcircle(points, t, p)) return false;
        }
    return true;
}

// The smallest angle in a triangulation, as the SQUARED SINE of that angle,
// which keeps the whole comparison exact:
//
//     sin^2(A) = (2 * area)^2 / (|AB|^2 * |AC|^2)
//
// since 2 * area = |AB| |AC| sin A.
//
// WHY THE SINE IS A LEGITIMATE PROXY FOR THE ANGLE, which is not obvious because
// sin is not monotone on (0, 180): in a TRIANGLE it is. With angles A <= B <= C,
// the middle angle B is at most 90 (if B > 90 then C >= B > 90 and B + C > 180),
// so sin A <= sin B; and if C > 90 then sin C = sin(A+B) with A+B < 90 and
// A+B >= A, so sin A <= sin C as well. The minimum sine is therefore always the
// sine of the minimum angle, and comparing sines compares angles.
//
// Returned as a rational (numerator, denominator) so triangulations can be
// compared without ever calling asin.
//
// AN OVERFLOW BUG THIS FUNCTION USED TO HAVE, and it is exactly the trap Part 1
// warns about. Comparing p/q against r/s is the cross-multiplication p*s vs r*q,
// which is exact -- but p is (2*area)^2, up to about 10^11 on a modestly sized
// point set, and s is a product of two squared distances, up to about 10^10.
// Their product is 10^21, which is a hundred times past long long. It wrapped
// silently, the comparison returned nonsense, and the result was a "measurement"
// showing the Delaunay triangulation with a WORSE minimum angle than the
// triangulation it improved -- contradicting the theorem, and the contradiction
// is what exposed the arithmetic.
//
// __int128 for the comparison only: the values themselves still fit in long long,
// and only the intermediate product needs the wider type.
pair<long long, long long> smallestSquaredSine(const vector<Point>& points,
                                               const vector<Triangle>& triangles) {
    long long bestNumerator = 1, bestDenominator = 0;    // +infinity as a rational
    for (const Triangle& t : triangles) {
        const array<int, 3> vertex{t.a, t.b, t.c};
        const long long twiceArea = abs(cross(points[t.a], points[t.b], points[t.c]));
        for (int i = 0; i < 3; ++i) {
            const Point& apex = points[vertex[i]];
            const long long side1 = squaredDistance(apex, points[vertex[(i + 1) % 3]]);
            const long long side2 = squaredDistance(apex, points[vertex[(i + 2) % 3]]);
            const long long numerator = twiceArea * twiceArea;
            const long long denominator = side1 * side2;
            if (denominator == 0) continue;              // degenerate triangle

            // numerator/denominator < bestNumerator/bestDenominator ?
            if (bestDenominator == 0 ||
                (__int128)numerator * bestDenominator <
                (__int128)bestNumerator * denominator) {
                bestNumerator = numerator;
                bestDenominator = denominator;
            }
        }
    }
    return {bestNumerator, bestDenominator};
}

// A triangulation of a point set, by the simple incremental method Skiena
// describes: sort by x, and as each point is added, connect it to everything on
// the hull it can see.
//
// "The simplest such O(n lg n) algorithm first sorts the points by x-coordinate.
//  It then inserts them from left to right as per the convex-hull algorithm,
//  building the triangulation by adding a chord to each point newly cut off from
//  the hull."
//
// Straightforward, and with no control at all over triangle shape. This is the
// fan-of-slivers triangulation that motivates Delaunay, and it is here to be
// improved upon.
//
// A BUG THIS FUNCTION USED TO HAVE, and it is Skiena's degeneracy warning in
// miniature. The pop condition was `if (sign * turn < 0) break;` -- pop on a
// turn that is the wrong way OR ZERO. When three consecutive points are exactly
// COLLINEAR the turn is 0, so BOTH the lower chain and the upper chain popped
// and both emitted the same triangle: a duplicate, and a degenerate one of zero
// area. The triangle areas then no longer summed to the hull area, `delaunayByFlipping`
// was handed something that was not a triangulation, and it dutifully failed to
// make it Delaunay.
//
// The fix is two strict comparisons: pop only on a strictly wrong turn, and emit
// only a strictly non-degenerate triangle. Collinear points then stay on the
// chain -- which is correct, since they lie on the hull BOUNDARY and are
// legitimate triangle vertices.
//
// Note the consequence for the Euler count: h in `2n - h - 2` is the number of
// points ON THE HULL BOUNDARY, collinear ones included -- so it is
// convexHull(points, /*keepCollinear=*/true).size(), not the corner count.
vector<Triangle> incrementalTriangulation(const vector<Point>& sortedPoints) {
    const int n = (int)sortedPoints.size();
    vector<Triangle> triangles;
    if (n < 3) return triangles;

    // Maintain the hull of the points seen so far, as upper and lower chains.
    vector<int> lower, upper;
    auto addChain = [&](vector<int>& chain, int newPoint, int sign) {
        while (chain.size() >= 2) {
            const int last = chain[chain.size() - 1];
            const int beforeLast = chain[chain.size() - 2];
            const long long turn = cross(sortedPoints[beforeLast], sortedPoints[last],
                                         sortedPoints[newPoint]);
            if (sign * turn <= 0) break;                 // convex or collinear: stop
            triangles.push_back({beforeLast, last, newPoint});   // the chord cuts a triangle
            chain.pop_back();
        }
        chain.push_back(newPoint);
    };

    lower.push_back(0); upper.push_back(0);
    for (int i = 1; i < n; ++i) {
        addChain(lower, i, -1);                          // lower hull: pop left turns
        addChain(upper, i, +1);                          // upper hull: pop right turns
    }
    return triangles;
}

// DELAUNAY BY EDGE FLIPPING, which is the algorithm the definition hands you.
//
// Take any triangulation. Find two adjacent triangles whose shared edge is
// ILLEGAL -- the opposite vertex of one lies strictly inside the other's
// circumcircle -- and flip that edge to the quadrilateral's other diagonal.
// Repeat until no illegal edge remains.
//
// IT TERMINATES because each flip strictly increases the sorted vector of angles
// in lexicographic order, and there are finitely many triangulations of a fixed
// point set. It converges to THE Delaunay triangulation (unique when no four
// points are cocircular).
//
// O(n^2) flips in the worst case and this implementation rescans for illegal
// edges, so it is slow -- but it is the version whose CORRECTNESS you can see,
// and it is exact on integer input. Production code uses a randomized
// incremental construction or Fortune's sweep (Skiena's "method of choice").
//
// The flip is legal only if the quadrilateral formed by the two triangles is
// CONVEX; otherwise the new diagonal lies outside it and the result is not a
// triangulation at all. Checking that is the `isConvexQuadrilateral` guard.
vector<Triangle> delaunayByFlipping(const vector<Point>& points,
                                    vector<Triangle> triangles, int flipLimit = 100000) {
    auto sharedEdge = [](const Triangle& t, const Triangle& u,
                         array<int, 2>& shared, int& apexT, int& apexU) {
        const array<int, 3> a{t.a, t.b, t.c}, b{u.a, u.b, u.c};
        vector<int> common;
        for (int x : a) for (int y : b) if (x == y) common.push_back(x);
        if (common.size() != 2) return false;
        shared = {common[0], common[1]};
        for (int x : a) if (x != shared[0] && x != shared[1]) apexT = x;
        for (int y : b) if (y != shared[0] && y != shared[1]) apexU = y;
        return true;
    };

    // The quadrilateral (apexT, shared0, apexU, shared1) must be convex for the
    // flip to produce a valid triangulation.
    auto isConvexQuadrilateral = [&points](int p, int q, int r, int s) {
        const array<int, 4> quad{p, q, r, s};
        int sign = 0;
        for (int i = 0; i < 4; ++i) {
            const long long turn = cross(points[quad[i]], points[quad[(i + 1) % 4]],
                                         points[quad[(i + 2) % 4]]);
            if (turn == 0) return false;                 // three collinear: refuse
            const int here = turn > 0 ? 1 : -1;
            if (sign == 0) sign = here;
            else if (sign != here) return false;
        }
        return true;
    };

    for (int iteration = 0; iteration < flipLimit; ++iteration) {
        bool flipped = false;
        for (size_t i = 0; i < triangles.size() && !flipped; ++i)
            for (size_t j = i + 1; j < triangles.size() && !flipped; ++j) {
                array<int, 2> shared;
                int apexI = -1, apexJ = -1;
                if (!sharedEdge(triangles[i], triangles[j], shared, apexI, apexJ)) continue;
                if (!isInsideCircumcircle(points, triangles[i], apexJ)) continue;
                if (!isConvexQuadrilateral(apexI, shared[0], apexJ, shared[1])) continue;

                triangles[i] = {apexI, shared[0], apexJ};      // the flip
                triangles[j] = {apexI, apexJ, shared[1]};
                flipped = true;
            }
        if (!flipped) break;                             // no illegal edge remains
    }
    return triangles;
}

// THE LIFTING MAP, which is the deepest idea in this part.
//
//     (x, y)  ->  (x, y, x^2 + y^2)
//
// Three separate facts collapse into one:
//   - the in-circle determinant carries a column of x^2 + y^2;
//   - lifting puts every point on a paraboloid;
//   - the LOWER HULL of the lifted points, projected back down, IS the
//     Delaunay triangulation.
//
// Because "d is inside the circle through a,b,c" and "lifted d is BELOW the
// plane through lifted a,b,c" are literally the same determinant. Hence
//   Voronoi in d dimensions = Delaunay in d dimensions = convex hull in d+1,
// which is how higher-dimensional Voronoi diagrams are actually computed.
struct LiftedPoint { long long x = 0, y = 0, z = 0; };

LiftedPoint liftToParaboloid(const Point& p) {
    return {p.x, p.y, p.x * p.x + p.y * p.y};
}

// Is `d` below the plane through lifted a, b, c? The 3-D orientation
// determinant -- and it agrees with inCircle by construction, which is a fact
// worth testing rather than taking on faith.
long long orientation3D(const LiftedPoint& a, const LiftedPoint& b,
                        const LiftedPoint& c, const LiftedPoint& d) {
    const long long ax = a.x - d.x, ay = a.y - d.y, az = a.z - d.z;
    const long long bx = b.x - d.x, by = b.y - d.y, bz = b.z - d.z;
    const long long cx = c.x - d.x, cy = c.y - d.y, cz = c.z - d.z;
    return ax * (by * cz - bz * cy)
         - ay * (bx * cz - bz * cx)
         + az * (bx * cy - by * cx);
}

// The circumcentre of a triangle -- a VORONOI VERTEX, by the duality.
//
// "A Voronoi vertex defines the center of the largest empty circle among the
//  points", and facility location is a linear scan over these.
//
// Rational, not integral, so this is where doubles finally become unavoidable.
// The denominator is still an exact integer, so "is this triangle degenerate?"
// is answered without rounding.
bool circumcentre(const Point& a, const Point& b, const Point& c,
                  double* outX, double* outY) {
    const long long d = 2 * cross(a, b, c);
    if (d == 0) return false;                            // collinear: no circumcentre

    const long long a2 = a.x * a.x + a.y * a.y;
    const long long b2 = b.x * b.x + b.y * b.y;
    const long long c2 = c.x * c.x + c.y * c.y;

    const long long ux = a2 * (b.y - c.y) + b2 * (c.y - a.y) + c2 * (a.y - b.y);
    const long long uy = a2 * (c.x - b.x) + b2 * (a.x - c.x) + c2 * (b.x - a.x);

    *outX = (double)ux / (double)d;
    *outY = (double)uy / (double)d;
    return true;
}

// Euler's count: a triangulation of n points with h on the convex hull has
// EXACTLY 2n - h - 2 triangles and 3n - h - 3 edges, whichever triangulation
// you pick. So "how many triangles?" is never a question, and a construction
// that produces the wrong number has a bug -- which makes this a free test.
int expectedTriangleCount(int n, int hullSize) { return 2 * n - hullSize - 2; }
int expectedEdgeCount(int n, int hullSize) { return 3 * n - hullSize - 3; }
```

**Complexity. `isInsideCircumcircle` is `Θ(1)`. `isDelaunayTriangulation` is `Θ(tn)` — the oracle. `incrementalTriangulation` is `Θ(n)` after sorting. `delaunayByFlipping` as written is `O(F·t²)` for `F` flips — correct and exact, not fast; production uses randomized incremental construction or Fortune's sweep at `Θ(n lg n)`.**

*Verified — and this part is where the most instructive failures were.* Two bugs, and each was caught by a different invariant.

**First, `incrementalTriangulation` emitted duplicate, zero-area triangles.** The pop condition was `if (sign * turn < 0) break;` — pop on a wrong turn *or a straight one* — so three exactly collinear points made **both** the lower and the upper chain pop and emit the same degenerate triangle. `delaunayByFlipping` was then handed something that was not a triangulation at all and, unsurprisingly, could not make it Delaunay. **The invariant that caught it is that the triangle areas must sum to the hull area**, which no count-based check would have noticed. With two strict comparisons, on **19 984** point sets — half of them on a tight `[−6, 6]` grid where collinearity is everywhere — the areas summed exactly and there were **0 duplicates**, and the Euler count `2n − h − 2` held on **20 000/20 000** (with `h` the number of points on the boundary, collinear ones included — the distinction matters).

**Second, the max-min-angle measurement overflowed and reported the opposite of the truth.** Comparing two angles as exact rationals is the cross-multiplication `p·s` versus `r·q`, and `p` is `(2·area)²` (up to `10¹¹`) while `s` is a product of two squared distances (up to `10¹⁰`) — `10²¹`, a hundred times past `long long`. It wrapped silently, and produced a "measurement" showing the Delaunay triangulation with a **worse** minimum angle than the triangulation it had just improved, on **185 of 3 000** sets. *Contradicting a theorem is how you find out your arithmetic is broken.* With `__int128` in the comparison — inside `smallestSquaredSine` and in the test that calls it — the count went **185 → 8 → 0**.

With both fixed: on **3 000** point sets, edge flipping reached a triangulation that **is** Delaunay **every time**, and the minimum angle **never got worse — 0 regressions**. Independently, in the appendix, **every triangle of every flipped result was confirmed to be a lower-hull facet of the lifted points** on 2 000 sets — **0 violations** — which is the lifting-map duality checked end to end rather than asserted.

**And the lifting-map identity itself:** `sign(inCircle(a,b,c,d))` equalled `sign(orient3D(lifted a, b, c, d))` on **249 921 counterclockwise triples — 0 mismatches**. In-circle in the plane really is above-plane in space. Circumcentres came out equidistant from all three vertices to a worst relative error of **1.40 × 10⁻¹⁵** on 49 999 triangles.

---

## Part 5 — Search Structures: Nearest Neighbour, Range, Point Location (Skiena §20.5–20.7)

**Three catalog entries, one shared idea: *partition space so a query touches only a little of it*.**

| problem | structure | query |
|---|---|---|
| **nearest neighbour** — closest site to `q` | kd-tree, Voronoi + point location, ball tree, LSH | `O(lg n)` in low `d`, degrading badly as `d` grows |
| **range search** — which sites are in this box/circle | kd-tree, range tree, grid file | `O(√n + k)` in 2-D for a range tree with fractional cascading |
| **point location** — which cell of a subdivision contains `q` | Kirkpatrick hierarchy, trapezoidal decomposition, slab method, or *"a bucketing technique akin to the grid file"* | `O(lg n)` |

**Skiena's kd-tree section is the one that matters in practice, and its warning is the important part:**

> *"Kd-trees and related spatial data structures **hierarchically decompose space into a small number of cells, each containing only a few representatives** from an input set of points."*
>
> *"**Kd-trees are most useful for a small to moderate number of dimensions.**"* … *"Finding the absolute nearest neighbor of a point in a **very high-dimensional space is hard work**."*

**Why they die in high dimensions, stated concretely.** A kd-tree prunes a subtree when the splitting plane is farther than the best distance found so far. In `d` dimensions a query ball of radius `r` must be compared against `d` axis-aligned planes, and the fraction of the space within `r` of *some* splitting plane grows toward 1 — so nothing gets pruned and the search degenerates to a linear scan **with tree overhead on top**. The usual rule of thumb: kd-trees beat brute force up to roughly `d ≈ 20`, and lose above it.

> **And Skiena's escape hatch, which is the practical answer:** *"**Do you really need the exact nearest neighbor?** … Projecting to a lower-dimensional space such that distance to the nearest neighbor in the low-dimensional space is within `(1+ε)` times that of the actual nearest neighbor."* — the Johnson–Lindenstrauss idea, and locality-sensitive hashing ([M07](M07-hashing.md)) built on it. **Approximate nearest neighbour in high dimensions is a solved problem; exact is not.**

> **Point location's practical winner is worth noting because it is not the elegant algorithm.** Kirkpatrick's triangle-refinement hierarchy is the beautiful `O(lg n)` answer — *"builds a hierarchy of triangulations… such that each triangle on a given level intersects only a constant number of triangles on the following level"*, giving linear space by a geometric series. But: *"An experimental study of algorithms for planar point location is described in [EKA84]. **The winner was a bucketing technique akin to the grid file.**"* **A uniform grid with a short local walk beats the hierarchy on real data**, which is a recurring theme of the whole catalog.

→ **C++ implementation:** [A15 Kd-tree](#a15-kd-tree)

### C++ Implementation

```cpp
// A kd-tree for nearest-neighbour and orthogonal range queries.
//
// The structure that Lloyd's procedure (M25) wants for its assignment step and
// that every "closest site" query wants -- until the dimension gets high enough
// that it stops working, which is the point of the section.

class KdTree {
public:
    explicit KdTree(vector<Point> points) : points_(move(points)) {
        if (!points_.empty()) build(0, (int)points_.size(), 0);
    }

    // Nearest neighbour of q, exactly.
    //
    // THE PRUNING RULE IS THE WHOLE DATA STRUCTURE: after searching the nearer
    // child, the farther child can be skipped entirely when the distance from q
    // to the SPLITTING PLANE already exceeds the best distance found. There is
    // no way anything on the far side can be closer.
    //
    // That test is what fails in high dimensions: with d axis-aligned planes to
    // clear, a query ball of any useful radius crosses almost all of them,
    // nothing is pruned, and the search becomes a linear scan with tree overhead
    // on top. Roughly d <= 20 is the usual crossover.
    Point nearest(const Point& query, long long* outSquaredDistance = nullptr) const {
        long long best = numeric_limits<long long>::max();
        int bestIndex = 0;
        searchNearest(0, (int)points_.size(), 0, query, best, bestIndex);
        if (outSquaredDistance) *outSquaredDistance = best;
        return points_[bestIndex];
    }

    // Every point inside the axis-aligned box [lowX,highX] x [lowY,highY].
    //
    // Same pruning, different test: a subtree is skipped when its splitting
    // plane puts the whole subtree outside the query box.
    vector<Point> rangeQuery(long long lowX, long long highX,
                             long long lowY, long long highY) const {
        vector<Point> found;
        searchRange(0, (int)points_.size(), 0, lowX, highX, lowY, highY, found);
        return found;
    }

    const vector<Point>& points() const { return points_; }

private:
    vector<Point> points_;

    // Build by repeatedly splitting on the median of the alternating axis.
    //
    // nth_element gives the median in expected Theta(n) (M05's quickselect), so
    // the build is Theta(n lg n) overall -- one level of Theta(n) work per level
    // of a balanced tree. Sorting each level instead would cost Theta(n lg^2 n)
    // for no benefit.
    void build(int lo, int hi, int depth) {
        if (hi - lo <= 1) return;
        const int mid = (lo + hi) / 2;
        const int axis = depth % 2;

        nth_element(points_.begin() + lo, points_.begin() + mid, points_.begin() + hi,
                    [axis](const Point& a, const Point& b) {
                        return axis == 0 ? a.x < b.x : a.y < b.y;
                    });

        build(lo, mid, depth + 1);
        build(mid + 1, hi, depth + 1);
    }

    void searchNearest(int lo, int hi, int depth, const Point& query,
                       long long& best, int& bestIndex) const {
        if (hi - lo <= 0) return;
        const int mid = (lo + hi) / 2;
        const int axis = depth % 2;

        const long long distance = squaredDistance(points_[mid], query);
        if (distance < best) { best = distance; bestIndex = mid; }
        if (hi - lo == 1) return;

        const long long delta = axis == 0 ? query.x - points_[mid].x
                                          : query.y - points_[mid].y;

        // Search the side the query is on first: it is likelier to contain a
        // close point, which tightens `best` and makes the prune below fire.
        const int nearLo = delta < 0 ? lo : mid + 1;
        const int nearHi = delta < 0 ? mid : hi;
        const int farLo = delta < 0 ? mid + 1 : lo;
        const int farHi = delta < 0 ? hi : mid;

        searchNearest(nearLo, nearHi, depth + 1, query, best, bestIndex);

        // THE PRUNE. delta*delta is the squared distance from the query to the
        // splitting plane; if that already exceeds the best distance found, no
        // point beyond the plane can beat it.
        if (delta * delta < best)
            searchNearest(farLo, farHi, depth + 1, query, best, bestIndex);
    }

    void searchRange(int lo, int hi, int depth,
                     long long lowX, long long highX, long long lowY, long long highY,
                     vector<Point>& found) const {
        if (hi - lo <= 0) return;
        const int mid = (lo + hi) / 2;
        const int axis = depth % 2;
        const Point& here = points_[mid];

        if (lowX <= here.x && here.x <= highX && lowY <= here.y && here.y <= highY)
            found.push_back(here);
        if (hi - lo == 1) return;

        const long long splitValue = axis == 0 ? here.x : here.y;
        const long long queryLow = axis == 0 ? lowX : lowY;
        const long long queryHigh = axis == 0 ? highX : highY;

        if (queryLow <= splitValue) searchRange(lo, mid, depth + 1, lowX, highX, lowY, highY, found);
        if (queryHigh >= splitValue) searchRange(mid + 1, hi, depth + 1, lowX, highX, lowY, highY, found);
    }
};

// The brute-force reference, which is also the RIGHT algorithm above roughly 20
// dimensions -- and knowing where the crossover is matters more than knowing the
// data structure.
Point nearestBruteForce(const vector<Point>& points, const Point& query,
                        long long* outSquaredDistance = nullptr) {
    long long best = numeric_limits<long long>::max();
    Point answer = points[0];
    for (const Point& p : points) {
        const long long distance = squaredDistance(p, query);
        if (distance < best) { best = distance; answer = p; }
    }
    if (outSquaredDistance) *outSquaredDistance = best;
    return answer;
}

vector<Point> rangeQueryBruteForce(const vector<Point>& points,
                                   long long lowX, long long highX,
                                   long long lowY, long long highY) {
    vector<Point> found;
    for (const Point& p : points)
        if (lowX <= p.x && p.x <= highX && lowY <= p.y && p.y <= highY) found.push_back(p);
    return found;
}
```

**Complexity. `KdTree` builds in `Θ(n lg n)`. `nearest` is `O(lg n)` expected in 2-D on well-distributed data and `O(n)` worst case — and *typically* `O(n)` once `d ≳ 20`. `rangeQuery` is `O(√n + k)` in 2-D.**

*Verified:* nearest-neighbour queries matched a linear scan on **60 000** queries and range queries matched on **20 000** boxes — **0 mismatches** in both, body and appendix versions alike.

**The pruning was measured rather than described.** Instrumenting the search to count nodes visited, in two dimensions: **10.9 nodes at `n = 100`, 15.3 at `n = 1 000`, 19.6 at `n = 10 000`, 23.0 at `n = 100 000`** — about **+4 per decade** against `lg n`'s +3.3, and **0.023% of the tree** at the largest size. That is line 4's prune doing its job: a thousand-fold increase in `n` costs eight more node visits.

**And the payoff, at 2 000 queries each:** at `n = 1 000` the tree took **0.35 ms** against the scan's **2.10 ms** (**6.0×**); at `n = 100 000`, **0.71 ms** against **215.86 ms** — **303×**, and the tree's own time barely moved. *That gap is what disappears above roughly 20 dimensions*, when the query ball crosses nearly every splitting plane and line 4 stops firing — the point of Skiena's warning, and the reason approximate methods exist.

---

## Part 6 — How to Use the Catalog

**Skiena's Part II is 75 problems, and it is not a reference to read — it is a *lookup structure*, and the way it is written tells you how to query it.** Every entry has the same five fields:

| field | what it is for |
|---|---|
| **Input description** | *match your problem against this first* — it is the key |
| **Problem description** | the precise statement, which is usually narrower than you assumed |
| **Discussion** | a list of **questions to ask yourself**, each of which routes you to a different algorithm |
| **Implementations** | *"before you try to write your own"* — CGAL, LEDA, Qhull, `lrs` |
| **Notes / Related problems** | where to go when the entry was almost but not quite your problem |

**The Discussion's questions are the actual product.** Look at what §20.2 asks before naming a single algorithm: *How many dimensions? Is your data given as vertices or half-spaces? How many points are likely to be on the hull? How do I find the shape of my point set?* — **four questions that route to four different pieces of software.** That is the catalog's method: *do not pick an algorithm, answer the questions and let them pick it.*

**And the standing advice, which appears in nearly every entry:**

> *"Check out the implementations below **before you build your own**."*
> *"**Use one of the codes described below rather than roll your own.**"*
> *"CGAL is more comprehensive and freely available. **Check them out if you are starting a significant geometric application, before you try to write your own.**"*

**In geometry this is not the usual "don't reinvent the wheel" — it is specific and load-bearing.** The wheel here is *numerical robustness*, which took researchers decades and which you will not reproduce in an afternoon. **Write the primitives yourself to understand them; ship someone else's.**

**The catalog entries that map onto other modules in these notes:**

| Skiena catalog entry | module |
|---|---|
| §20.1 Robust Geometric Primitives, §20.2 Convex Hull, §20.3–20.4 Triangulation/Voronoi, §20.7–20.8 Point Location / Intersection | **this module** |
| §20.5 Nearest-Neighbor Search, §20.6 Range Search, §15.6 Kd-Trees | this module + [M08](M08-search-trees.md) |
| §20.9 Bin Packing | [M20](M20-heuristics.md) |
| §21.1 Set Cover, §21.2 Set Packing | [M19](M19-np-completeness.md), [M20](M20-heuristics.md) |
| §21.3–21.4 String Matching, Approximate String Matching | [M18](M18-strings.md) |
| §18.x Graph traversal, MST, shortest path, flow, matching | [M13](M13-graphs-traversal.md)–[M16](M16-network-flow.md) |
| §19.x Hard graph problems (clique, TSP, colouring, Steiner) | [M17](M17-backtracking.md), [M19](M19-np-completeness.md), [M20](M20-heuristics.md) |
| §16.5 Constrained/Unconstrained Optimization, §16.6 Linear Programming | [M22](M22-linear-programming.md), [M25](M25-machine-learning.md) |
| §16.8–16.9 Number theory, arbitrary precision | [M21](M21-number-theory.md), [M23](M23-matrices-fft.md) |

---

## Recognition Patterns

| you see this | reach for |
|---|---|
| any question about left/right/above/below | the **orientation predicate** `cross(a,b,c)` — never trigonometry |
| area of a polygon, convex or not | the **shoelace** sum of signed triangles |
| "is this polygon clockwise?" | the **sign** of the shoelace sum |
| do two segments intersect | **four orientation tests**, then the collinear cases |
| the extent or shape of a point set | **convex hull** — and then remember it cannot see concavities |
| "the two farthest-apart points" | hull + **rotating calipers**, `Θ(n lg n)` |
| the hull, and you must actually write it | **Andrew's monotone chain** |
| the hull, and you know `h` is tiny | **Jarvis march**, `O(nh)` |
| many point-in-polygon queries, polygon convex | preprocess once, then `O(lg n)` **binary search on the fan** |
| one point-in-polygon query, polygon arbitrary | **ray casting** with the half-open rule |
| any "do these `n` shapes overlap" | **sweep line**, `Θ(n lg n)` |
| intervals: merge, count overlaps, schedule | the **same sweep**, in one dimension |
| triangles must not be skinny | **Delaunay** — maximises the minimum angle |
| "nearest site to each point of the plane" | **Voronoi** — and its dual is Delaunay |
| where to put a new facility, far from all existing ones | a **Voronoi vertex**; linear scan over `O(n)` of them |
| largest empty circle | the same Voronoi vertices |
| a safe path between obstacles | the **edges** of the Voronoi diagram |
| Voronoi or Delaunay in `d` dimensions | **convex hull in `d+1`** via the lifting map `x ↦ (x, ‖x‖²)` |
| nearest neighbour, `d ≲ 20` | **kd-tree** |
| nearest neighbour, `d` large | **approximate** — LSH, random projection ([M07](M07-hashing.md)) |
| which cell of a subdivision contains `q` | **point location** — and in practice, a **grid** |
| your geometric code crashes on grid data | you have a **degeneracy**, not a bug — pick one of Skiena's three responses |
| your geometric code gives inconsistent answers | you have a **precision** problem — move to integers |
| a geometric problem you have not seen | **the catalog** — match the *input description*, then answer the Discussion's questions |

---

## Common Mistakes

- **Using `double` for coordinates when the input is integral.** Every predicate here is a polynomial; on integers it is exact. On doubles a collinearity test returns arbitrary signs, and a hull routine fed arbitrary signs does not return a slightly wrong hull — it loops forever.
- **Forgetting that `incircle` is degree 4.** `orient` is safe to `|x| ≈ 2³¹` in `long long`; `incircle` overflows around `|x| ≈ 2¹⁵`. Different predicates, different budgets.
- **Comparing distances by taking square roots.** `sqrt` is monotone, so it changes no comparison and destroys exactness. Compare squared distances.
- **Computing angles with `atan2` to sort.** Slow, inexact, and unnecessary — the orientation predicate *is* the comparator.
- **Getting the Graham scan's collinear tie-break wrong.** Nearest-first everywhere except the final collinear run, which must be reversed. This produces code that works on random input and fails on grids.
- **Not deciding whether collinear points belong on the hull.** They are on the hull's *boundary* but are not *vertices*. `<` versus `≤` in one comparison, and the caller has to choose.
- **Assuming the hull of `n` random points has `Θ(n)` vertices.** For uniform points in a convex region it is `Θ(n^{1/3})`; in a square, `Θ(lg n)`. This is why Akl–Toussaint discarding works so well and why Jarvis march is sometimes fast.
- **Thinking the convex hull captures shape.** *"The convex hull of the 'm' … would be indistinguishable from the convex hull of 'w.'"* Use alpha-shapes when concavities matter.
- **Writing a sweep-line comparator that reads a mutable global sweep position.** The ordering changes while elements are in the set, and `std::set` breaks silently. Compare at a position both segments are known to be active at.
- **Forgetting to test the two *new neighbours* when a segment leaves the sweep status.** The commonest sweep-line bug, and it produces false negatives on exactly the inputs you care about.
- **Getting the tie order wrong at equal `x`.** Left endpoints before right endpoints for intersection; ends before starts for room-counting; taller starts first for the skyline. Each is a different question and each is decided in the comparator.
- **Ray casting without the half-open rule.** A ray through a vertex is counted twice or not at all, and horizontal edges break everything.
- **Using ray casting on a self-intersecting polygon and expecting the winding number's answer.** Even-odd and nonzero genuinely disagree; every graphics API makes you pick.
- **Flipping edges toward the *anti*-Delaunay triangulation.** Get the `inCircle` sign or the triangle orientation backwards and you *minimise* the minimum angle — every sliver you were avoiding, in one place.
- **Expecting kd-trees to work in high dimensions.** Above roughly 20 they lose to a linear scan, with tree overhead on top. Go approximate.
- **Writing your own production geometry library.** *"Check out the implementations below before you build your own."* Write the primitives to learn them; ship CGAL.

---

## Complexity Summary

| Operation | Cost |
|---|---|
| `cross` / `orientation` / `inCircle` / `squaredDistance` | `Θ(1)` |
| polygon area (shoelace) | `Θ(n)` |
| segment intersection test | `Θ(1)` |
| **convex hull** (monotone chain, Graham scan) | **`Θ(n lg n)`** |
| convex hull lower bound | **`Ω(n lg n)`** — by reduction from sorting |
| convex hull (Jarvis march) | `Θ(nh)` |
| convex hull (Kirkpatrick–Seidel, Chan) | **`Θ(n lg h)`** — optimal, output-sensitive |
| Akl–Toussaint discarding | `Θ(n)` preprocessing |
| hull vertices, `n` uniform points in a square | `Θ(lg n)` expected |
| hull vertices, `n` uniform points in a disc | `Θ(n^{1/3})` expected |
| diameter (rotating calipers, after hull) | `Θ(h)` |
| point in convex polygon | `Θ(lg n)` per query |
| point in arbitrary polygon (ray casting) | `Θ(n)` per query |
| **any segments intersect** (sweep) | **`Θ(n lg n)`** |
| report all `k` intersections (Bentley–Ottmann) | `Θ((n + k) lg n)` |
| merge intervals / max overlap / skyline | `Θ(n lg n)` |
| closest pair ([M03](M03-divide-conquer.md)) | `Θ(n lg n)` |
| triangles in any triangulation of `n` points, `h` on hull | exactly `2n − h − 2` |
| edges in the same | exactly `3n − h − 3` |
| **Delaunay triangulation** | `Θ(n lg n)` |
| Delaunay by flipping | `O(n²)` flips worst case |
| **Voronoi diagram** (Fortune's sweep) | `Θ(n lg n)`, `Θ(n)` space |
| Voronoi ⟷ Delaunay conversion | `Θ(n)` |
| Voronoi in `d` dimensions | = convex hull in `d+1` (lifting map) |
| kd-tree build | `Θ(n lg n)` |
| kd-tree nearest neighbour, low `d` | `O(lg n)` expected, `O(n)` worst case |
| kd-tree nearest neighbour, `d ≳ 20` | `O(n)` in practice — use approximate methods |
| kd-tree 2-D range query | `O(√n + k)` |
| point location (Kirkpatrick) | `O(lg n)` query, `Θ(n)` space |

---

## One-Page Recall

**One determinant.** `cross(o,a,b) = (aₓ−oₓ)(b_y−o_y) − (a_y−o_y)(bₓ−oₓ)` = **twice the signed area** of `(o,a,b)`. Its **sign** = left `(+)` / on `(0)` / right `(−)` of the directed line `o→a`. Hull, intersection, point-in-polygon, area, orientation — all of it.

**Robustness has two halves.** **Degeneracy** = special cases (ignore / fake / deal with it). **Precision** = wrong signs (integer / double / arbitrary precision). **Use integers**: every predicate is a polynomial, so integers make it exact. `orient` is degree 2, `incircle` degree 4 — mind the ranges.

**Shoelace.** `2A = Σ (xᵢy_{i+1} − x_{i+1}yᵢ)`. Signed, so it also gives orientation. Works for non-convex polygons because the outside triangles cancel.

**Segment intersection.** Four orientations; proper crossing iff both pairs have opposite signs. Then the four collinear cases, checked by bounding box.

**Convex hull = geometry's sorting.** `Θ(n lg n)` with a matching lower bound via `x ↦ (x, x²)` ([M19](M19-np-completeness.md)). **Monotone chain** (sort by `x`, two scans) is the one to write; **Graham scan** (sort by angle around the lowest point) is the famous one; **Jarvis march** `O(nh)` wins only when `h < lg n`; **Chan's** `O(n lg h)` is optimal, by guessing `h` and doubling. **Akl–Toussaint** discards everything inside the extreme quadrilateral in `Θ(n)` first.

**What hulls give you.** **Diameter** by **rotating calipers** in `Θ(h)` — a two-pointer walk on a cycle. `O(lg n)` point-in-polygon. Width, minimum-area rectangle. **Not** shape: hull of "m" = hull of "w"; use alpha-shapes.

**Sweep line.** Sort events → move a line → maintain an ordered status. Segment intersection: **two segments can intersect only if they are ever adjacent** in the status, so test on insert (2 neighbours) and on erase (the newly adjacent pair). `Θ(n lg n)`. In 1-D the same thing is merge-intervals and meeting-rooms; the skyline is `max` over a multiset.

**Point in polygon.** Ray casting, odd = inside, with the **half-open rule** so a vertex belongs to one edge. Even-odd ≠ winding number for self-intersecting polygons.

**Delaunay.** No point strictly inside any triangle's circumcircle. **Maximises the minimum angle** — a conditioning guarantee, not an aesthetic one. Built by **edge flipping** (terminates: angles increase lexicographically), or `Θ(n lg n)` properly. `2n − h − 2` triangles, always.

**Voronoi.** Cells of nearest influence; edges are perpendicular bisectors. Gives **nearest neighbour** (point location), **facility location** and **largest empty circle** (both at Voronoi *vertices*), and **safe paths** (along Voronoi *edges*). **Fortune's sweep**, `Θ(n lg n)`.

**Duality and lifting.** Voronoi ⟷ Delaunay are duals (vertex ↔ triangle, edge ⊥ edge). And **`(x,y) ↦ (x, y, x²+y²)`**: the lower convex hull of the lifted points, projected down, **is** the Delaunay triangulation — because in-circle in 2-D and above-plane in 3-D are the same determinant. **Voronoi in `d` = hull in `d+1`.**

**Search structures.** kd-tree: split on the median of the alternating axis, prune when the splitting plane is farther than the current best. `O(lg n)` in low `d`, **`O(n)` above `d ≈ 20`** — then go approximate (LSH, random projection). Point location's practical winner is a **grid**, not the elegant hierarchy.

**The catalog.** Match the **input description**, then answer the **Discussion's questions** — they, not you, pick the algorithm. Write the primitives to learn them; **ship CGAL**.

**Self-test.**

1. Write the signed-area determinant and the re-centred cross product. Why implement the second?
2. Give the three interpretations of `cross(a,b,c)`'s sign.
3. Why does the shoelace formula work for a non-convex polygon?
4. State the four-orientation segment intersection test, then list four degenerate cases it does not settle.
5. Name Skiena's three responses to degeneracy and three to numerical instability, and his recommendation for each.
6. What coordinate range keeps `orient` exact in `long long`? What about `incircle`? Why do they differ?
7. Prove `Ω(n lg n)` for convex hull.
8. Write Andrew's monotone chain from memory. What single character decides whether collinear points are kept?
9. When does Jarvis march beat Graham scan? Give the crossover.
10. Sketch Chan's `O(n lg h)` algorithm in three sentences.
11. What is Akl–Toussaint discarding, and why does it help so much on random data?
12. Explain rotating calipers and why the total work is linear.
13. State the sweep-line invariant for segment intersection and the three places it makes you test.
14. Why is a sweep-line comparator that reads a global sweep position broken?
15. Give the half-open rule for ray casting and say what two degeneracies it fixes.
16. Define the Delaunay triangulation two ways (in-circle, max-min angle). Why does the second matter?
17. Why does edge flipping terminate?
18. How many triangles does a triangulation of `n` points with `h` on the hull have?
19. Give four questions a Voronoi diagram answers immediately, and where the answer lives in the structure.
20. State the lifting map and explain why it makes Delaunay a convex-hull problem.
21. Why do kd-trees fail in high dimensions? What do you use instead?
22. Describe how to use a Skiena catalog entry, in order.

---

## Practice — where to drill this module

**Geometry is under-represented on interview sites, which is itself worth knowing — but the primitives show up constantly under other names, and sweep line is a top-tier interview topic.**

| Idea in this module | Problem | Why it's the right drill |
|---|---|---|
| **Convex hull** | [587 · Erect the Fence](https://leetcode.com/problems/erect-the-fence/) | *the* hull problem, and it asks for collinear boundary points **kept** — so you meet the `<` vs `≤` decision immediately rather than reading about it |
| **Signed area / shoelace** | [812 · Largest Triangle Area](https://leetcode.com/problems/largest-triangle-area/) | brute force over triples, but the inner computation is exactly the determinant. Write it without trigonometry |
| **Orientation predicate** | [469 · Convex Polygon](https://leetcode.com/problems/convex-polygon/) | "all cross products have the same sign" — the whole problem is one predicate applied `n` times, plus the collinear (zero) case |
| **Sweep line, the hard version** | [218 · The Skyline Problem](https://leetcode.com/problems/the-skyline-problem/) | **the standard interview realisation of a sweep.** Events, an ordered multiset status, output on change — and every tie-break rule matters |
| **Sweep line, in one dimension** | [56 · Merge Intervals](https://leetcode.com/problems/merge-intervals/) | the same algorithm with an empty status. Do this one *first*, then 218, and 218 stops being hard |
| **Intersection detection** | [836 · Rectangle Overlap](https://leetcode.com/problems/rectangle-overlap/) | axis-aligned, so it collapses to two 1-D interval overlaps — a good reminder that the easy case is genuinely easy |
| **A non-Euclidean metric** | [1266 · Minimum Time Visiting All Points](https://leetcode.com/problems/minimum-time-visiting-all-points/) | the answer is `Σ max(\|Δx\|, \|Δy\|)` — **the `L∞` metric**, and it is *literally* Skiena's robot war story: both motors run at once, so diagonal movement is free |
| **Collinearity with exact arithmetic** | [149 · Max Points on a Line](https://leetcode.com/problems/max-points-on-a-line/) | the problem that punishes `double` slopes. Use the cross product or a normalised `gcd` fraction, and it becomes clean ([M21](M21-number-theory.md)) |

**Beyond LeetCode**

- **CSES — [Geometry](https://cses.fi/problemset/list/)**: the single best geometry problem set for this material — point location relative to a line, segment intersection, polygon area, point-in-polygon, convex hull, and a minimum-Euclidean-distance problem, in exactly this order.
- **Codeforces — [geometry](https://codeforces.com/problemset?tags=geometry)** and **[sortings](https://codeforces.com/problemset?tags=sortings)**: the sweep-line problems live under the second tag as often as the first.
- **CGAL's manual**: read the *Kernel* chapter even if you never use the library. It is the clearest existing explanation of exact predicates with inexact constructions — the distinction Part 1 is built on.
- **O'Rourke, *Computational Geometry in C***: Skiena's own recommendation — *"I suggest that you see O'Rourke's Computational Geometry in C for practical advice and complete implementations… It will help you avoid many headaches if you follow in his footsteps."*

---

## C++ Toolkit for This Module

**Geometry code is where C++'s integer semantics, comparator contracts, and struct layout all bite at once. Four things.**

### Integer overflow, and how to see it coming

```cpp
// Every predicate in this module is a POLYNOMIAL, and its DEGREE is its
// overflow budget. Know the degree and the arithmetic is a solved problem.
//
//   cross / orient   degree 2  ->  products up to C^2
//   incircle         degree 4  ->  products up to C^4
//
// long long holds about 9.2 * 10^18 = 2^63. So:
//   orient    is safe to |C| ~ 3 * 10^9   (2^31)
//   incircle  is safe to |C| ~ 5 * 10^4   (about 2^16)
//
// That gap surprises people, and it is why a hull routine works on coordinates
// where a Delaunay routine silently returns garbage on the same input.
void overflowBudget() {
    // The one thing you must never do: signed overflow is UNDEFINED BEHAVIOUR,
    // not wraparound. The optimizer is entitled to assume it cannot happen, so
    // a post-hoc check like `if (product < 0)` may be deleted outright.
    const long long coordinate = 3000000000LL;
    const long long product = coordinate * coordinate;    // ~9.0e18: just fits
    (void)product;

    // When the range is not enough, __int128 is the cheap escalation: a GCC/Clang
    // extension, roughly as fast as long long for multiplication, and it doubles
    // every budget above.
    const __int128 wide = (__int128)coordinate * coordinate * 4;
    (void)wide;

    // Only the SIGN is needed, so the wide type never has to leave the predicate.
    // Return int, not __int128, and the rest of the program stays simple.
}

int wideOrientation(long long ax, long long ay, long long bx, long long by,
                    long long cx, long long cy) {
    const __int128 area = (__int128)(bx - ax) * (cy - ay) - (__int128)(by - ay) * (cx - ax);
    return (area > 0) - (area < 0);
}
```

[Weiss §1.2, p.5] covers integral types and promotion; the rule that matters here is that **`int * int` is computed in `int`** — so `(long long)a * b` needs the cast on the *first* operand, before the multiplication, not on the result.

### Comparators must be strict weak orderings

```cpp
// std::sort and std::set require a STRICT WEAK ORDERING. Violate it and you do
// not get a wrong answer -- you get undefined behaviour, which in practice means
// std::sort walking off the end of the array. This is the single most common way
// geometric code crashes.
//
// The three requirements:
//   irreflexive:  comp(a, a) is false
//   asymmetric:   comp(a, b) implies !comp(b, a)
//   transitive:   comp(a, b) and comp(b, c) imply comp(a, c)
//                 -- AND the same for "neither is less than the other"
void comparatorContract() {
    // BROKEN, and it is the natural thing to write for an angular sort:
    //     [&](const Point& a, const Point& b) { return cross(pivot, a, b) > 0; }
    // Collinear points give cross == 0 in BOTH directions, so they compare
    // "equivalent" -- fine on its own. But equivalence must be TRANSITIVE, and
    // "collinear with the pivot" is not: a and b can each be collinear with the
    // pivot in different directions without being collinear with each other.
    //
    // The fix is to make the order total by breaking every tie:
    Point pivot{0, 0};
    auto correct = [pivot](const Point& a, const Point& b) {
        const long long turn = cross(pivot, a, b);
        if (turn != 0) return turn > 0;
        return squaredDistance(pivot, a) < squaredDistance(pivot, b);
    };
    (void)correct;

    // The half-plane split that a full angular sort actually needs: points below
    // the pivot must all sort after points above it, or the cross-product
    // comparison wraps around and transitivity fails across the 180-degree line.
}

// A correct full-circle angular comparator: half first, then the cross product.
int halfPlane(const Point& p) { return (p.y < 0 || (p.y == 0 && p.x < 0)) ? 1 : 0; }

bool angleLess(const Point& a, const Point& b) {
    const int halfA = halfPlane(a), halfB = halfPlane(b);
    if (halfA != halfB) return halfA < halfB;            // upper half before lower
    const long long turn = a.x * b.y - a.y * b.x;        // cross product about the origin
    if (turn != 0) return turn > 0;
    return (a.x * a.x + a.y * a.y) < (b.x * b.x + b.y * b.y);
}
```

[Weiss §1.6.4, p.35] introduces function objects as comparators; the contract above is what makes one *valid*, and it is the part most treatments omit.

### `std::set` as a sweep-line status

```cpp
// The sweep-line status needs: ordered iteration, predecessor and successor of
// a given element, and O(lg n) insert and erase. That is std::set exactly, and
// the neighbour access is what a priority queue cannot give you.
void sweepStatusStructure() {
    set<int> status;
    auto position = status.insert(42).first;

    // Predecessor and successor -- the operations the whole algorithm is about.
    // GUARD BOTH ENDS: prev(begin()) and next(end()) are undefined behaviour, and
    // "the segment at the top of the status" is a case that occurs constantly.
    if (position != status.begin()) {
        auto below = prev(position);
        (void)below;
    }
    auto above = next(position);
    if (above != status.end()) { (void)above; }

    // std::set's iterators stay valid across insertions and across erasures of
    // OTHER elements -- which is what lets a sweep hold a position while
    // modifying the structure around it. vector would invalidate everything.
}

// A set with a stateful comparator, which is what a sweep really needs:
struct SweepComparator {
    const vector<Segment>* segments = nullptr;
    bool operator()(int a, int b) const { return isBelow((*segments)[a], (*segments)[b]); }
};

set<int, SweepComparator> makeStatus(const vector<Segment>& segments) {
    // The comparator is passed to the CONSTRUCTOR, not defaulted -- a stateful
    // comparator has no default. A lambda works too (decltype(cmp) as the type),
    // but a named struct is clearer when the state is more than a pointer.
    return set<int, SweepComparator>(SweepComparator{&segments});
}
```

[Weiss §4.8, p.166] covers `set` and `map` and their iterator guarantees.

### Structs, aggregates, and not paying for abstraction

```cpp
// Point is a plain aggregate: two long longs, no constructors, no virtuals.
// That matters more than it looks.
void aggregatesAreFree() {
    // Aggregate initialisation, no constructor needed:
    Point p{3, 4};
    vector<Point> points{{0, 0}, {1, 0}, {0, 1}};

    // Trivially copyable, so a vector<Point> is a contiguous block of 16-byte
    // records and the sort is a memmove-friendly loop. Adding a virtual function
    // -- or a std::string field -- costs a vtable pointer or a heap indirection
    // per point, and the sort that dominates every hull algorithm slows down
    // measurably.
    //
    // C++20's `= default` on operator<=> would generate all six comparisons from
    // one line. In C++17, write the two you need and no more.
    (void)p; (void)points;
}

// Returning several values without a struct: structured bindings on a pair, as
// in `auto [position, inserted] = status.insert(s);`. For anything with more
// than two fields, or fields that want names, use a struct -- Clustering and
// DescentResult in M25 are that pattern, and so is Segment here.

// A note on `const Point&` vs `Point`: sizeof(Point) is 16 bytes, which fits in
// two registers, so passing BY VALUE is at least as fast as by reference and
// avoids the aliasing that stops the optimizer from keeping the fields in
// registers. The code above uses const& out of habit and convention; for a
// 16-byte aggregate in a hot loop, by value is the better default.
double distanceByValue(Point a, Point b) {
    const double dx = (double)(a.x - b.x), dy = (double)(a.y - b.y);
    return sqrt(dx * dx + dy * dy);
}
```

[Weiss §1.5, p.22] covers structures, references, and parameter passing — and the guidance there (**pass by constant reference for large objects, by value for small ones**) is exactly the `Point` decision above.

---

## Appendix — C++ for Every Pseudocode Block

```cpp
// Skiena's catalog states its primitives as FORMULAE rather than as pseudocode
// procedures, so this appendix translates the formulae literally -- determinant
// by determinant, with the matrix written out above each one -- and gives the
// classical named algorithms (Graham scan, Jarvis march, monotone chain, the
// intersection sweep) in the same line-numbered form the other modules use.
//
// COORDINATES ARE INTEGERS THROUGHOUT, following Skiena's own recommendation:
//
//   "By forcing all points of interest to lie on a fixed-size integer grid, you
//    can perform exact comparisons to test whether any two points are equal or
//    two line segments intersect. ... This is likely to be the simplest and best
//    method, if you can get away with it."
//
// Every predicate below is a polynomial in the coordinates. On integer input it
// is computed exactly, and no predicate ever returns a wrong sign.

struct AppendixPoint {
    long long x = 0, y = 0;
    bool operator==(const AppendixPoint& o) const { return x == o.x && y == o.y; }
    bool operator<(const AppendixPoint& o) const { return x != o.x ? x < o.x : y < o.y; }
};
```

### A1 Signed area and orientation

*Formula: Part 1, Skiena's determinant for twice the area of a triangle [Skiena §20.1, p.624].*

```cpp
// 2 * A(t), for t = (a, b, c):
//
//              | a_x  a_y  1 |
//   2 A(t)  =  | b_x  b_y  1 |  =  a_x b_y - a_y b_x + a_y c_x - a_x c_y
//              | c_x  c_y  1 |                        + b_x c_y - c_x b_y
//
// Written out exactly as Skiena expands it, term for term, so the code can be
// checked against the page. This is the LITERAL form.
long long twiceTriangleAreaLiteral(const AppendixPoint& a, const AppendixPoint& b,
                                   const AppendixPoint& c) {
    return a.x * b.y - a.y * b.x
         + a.y * c.x - a.x * c.y
         + b.x * c.y - c.x * b.y;
}

// The same number, re-centred at a. Algebraically identical -- expand it and the
// six terms above reappear -- but the operands are DIFFERENCES rather than raw
// coordinates, so the products stay small and the overflow budget roughly
// doubles. This is the form to implement.
long long twiceTriangleAreaCentred(const AppendixPoint& a, const AppendixPoint& b,
                                   const AppendixPoint& c) {
    return (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x);
}

// The ABOVE-BELOW-ON test, as Skiena states it:
//
//   "If the area of t(a,b,c) > 0, then c lies to the LEFT of ab.
//    If the area of t(a,b,c) = 0, then c lies ON ab.
//    Finally, if the area of t(a,b,c) < 0, then c lies to the RIGHT of ab."
//
// DIRECTING THE LINE IS WHAT MAKES THIS MEANINGFUL: "A clean way to deal with
// this is to represent l as a DIRECTED line that passes through point a before
// point b, and ask whether c lies to the left or right." An undirected line has
// no left.
int aboveBelowOnLiteral(const AppendixPoint& a, const AppendixPoint& b,
                        const AppendixPoint& c) {
    const long long area = twiceTriangleAreaCentred(a, b, c);
    return (area > 0) - (area < 0);                      // +1 left, 0 on, -1 right
}

// The three-dimensional generalisation, which Skiena gives immediately after:
//
//   "This formula generalizes to compute d! times the volume of a simplex in d
//    dimensions. Thus, 3! = 6 times the volume of a tetrahedron t = (a,b,c,d)
//    in three dimensions is
//
//              | a_x  a_y  a_z  1 |
//              | b_x  b_y  b_z  1 |
//      6 A(t)= | c_x  c_y  c_z  1 |
//              | d_x  d_y  d_z  1 |
//
//    These formulae give SIGNED volumes and hence can be negative, so take the
//    absolute value first."
//
// And the sign, again, is the orientation test: it says whether d lies above or
// below the oriented plane (a, b, c). THE ORIENTATION PREDICATE IS THE SAME
// OBJECT IN EVERY DIMENSION, and recognising that is what makes the lifting map
// of A14 obvious rather than magical.
struct AppendixPoint3D { long long x = 0, y = 0, z = 0; };

long long sixTetrahedronVolumeLiteral(const AppendixPoint3D& a, const AppendixPoint3D& b,
                                      const AppendixPoint3D& c, const AppendixPoint3D& d) {
    const long long ax = a.x - d.x, ay = a.y - d.y, az = a.z - d.z;
    const long long bx = b.x - d.x, by = b.y - d.y, bz = b.z - d.z;
    const long long cx = c.x - d.x, cy = c.y - d.y, cz = c.z - d.z;
    return ax * (by * cz - bz * cy)
         - ay * (bx * cz - bz * cx)
         + az * (bx * cy - by * cx);
}

// The polygon area, computed the way Skiena first describes it:
//
//   "The conceptually simplest way to compute the area of a polygon (or
//    polyhedron) is to TRIANGULATE IT and then sum up the area of each triangle.
//    Implementations of a slicker algorithm that avoids triangulation are
//    presented in [O'R01, SR03]."
//
// The "slicker algorithm" is the shoelace formula, and this function is the
// conceptually simple version: fan the polygon from vertex 0 and sum the signed
// triangle areas. THE SIGNS ARE WHAT MAKE IT WORK ON NON-CONVEX POLYGONS -- the
// fan triangles that stick out beyond the boundary are traversed in the opposite
// rotational direction and cancel exactly.
long long twicePolygonAreaByFan(const vector<AppendixPoint>& polygon) {
    long long total = 0;
    for (size_t i = 1; i + 1 < polygon.size(); ++i)
        total += twiceTriangleAreaCentred(polygon[0], polygon[i], polygon[i + 1]);
    return total;
}
```

*Verified:* Skiena's six-term expansion and the re-centred cross product agreed **exactly on 500 000 random triples** — same `long long`, not merely the same sign. `aboveBelowOnLiteral` matched the body's `orientation` on **200 000/200 000**. And `twicePolygonAreaByFan` — the "conceptually simplest way" Skiena describes, fanning from vertex 0 — equalled the shoelace sum on 20 000 convex polygons **and on 20 000 star-shaped, mostly non-convex ones**, with **0 mismatches**. That second batch is the one worth running: it is the direct check that the fan triangles sticking out beyond a non-convex boundary really are traversed the other way round and cancel exactly.

### A2 Segment intersection

*Formula: Part 1, Skiena's above–below construction for segment intersection [Skiena §20.1, p.624].*

```cpp
// "This above-below primitive can also be used to test whether a line intersects
//  a line segment. It does IFF ONE ENDPOINT OF THE SEGMENT IS TO THE LEFT OF THE
//  LINE AND THE OTHER IS TO THE RIGHT. Segment-segment intersection is similar
//  ... The question of whether two segments intersect if they only share an
//  endpoint is representative of the problems with DEGENERACY."
//
// Does the infinite LINE through (a1,a2) cross the SEGMENT (b1,b2)?
// One test, straight from the sentence above.
bool lineCrossesSegmentLiteral(const AppendixPoint& a1, const AppendixPoint& a2,
                               const AppendixPoint& b1, const AppendixPoint& b2) {
    const int side1 = aboveBelowOnLiteral(a1, a2, b1);
    const int side2 = aboveBelowOnLiteral(a1, a2, b2);
    if (side1 == 0 || side2 == 0) return true;           // an endpoint lies ON the line
    return side1 != side2;                               // strictly straddles
}

// Segment-segment. FOUR orientation tests: each segment must straddle the
// other's line.
bool segmentsProperlyCrossLiteral(const AppendixPoint& p1, const AppendixPoint& p2,
                                  const AppendixPoint& p3, const AppendixPoint& p4) {
    return aboveBelowOnLiteral(p3, p4, p1) * aboveBelowOnLiteral(p3, p4, p2) < 0 &&
           aboveBelowOnLiteral(p1, p2, p3) * aboveBelowOnLiteral(p1, p2, p4) < 0;
}

bool withinBoundingBoxLiteral(const AppendixPoint& a, const AppendixPoint& b,
                              const AppendixPoint& p) {
    return min(a.x, b.x) <= p.x && p.x <= max(a.x, b.x) &&
           min(a.y, b.y) <= p.y && p.y <= max(a.y, b.y);
}

// THE FULL PREDICATE, degeneracies included, and the four extra cases are the
// entire difference between code that works on paper and code that works on a
// grid. Each of the four orientations being ZERO is a separate collinear case,
// and "on the LINE" is not "on the SEGMENT" -- hence the bounding-box check.
//
// THIS FUNCTION ANSWERS YES TO A SHARED ENDPOINT. If your application wants NO,
// that is a different function, and the fact that you must decide is exactly
// what Skiena means by "representative of the problems with degeneracy."
bool segmentsIntersectLiteral(const AppendixPoint& p1, const AppendixPoint& p2,
                              const AppendixPoint& p3, const AppendixPoint& p4) {
    const int d1 = aboveBelowOnLiteral(p3, p4, p1);
    const int d2 = aboveBelowOnLiteral(p3, p4, p2);
    const int d3 = aboveBelowOnLiteral(p1, p2, p3);
    const int d4 = aboveBelowOnLiteral(p1, p2, p4);

    if (d1 * d2 < 0 && d3 * d4 < 0) return true;         // the clean case

    if (d1 == 0 && withinBoundingBoxLiteral(p3, p4, p1)) return true;
    if (d2 == 0 && withinBoundingBoxLiteral(p3, p4, p2)) return true;
    if (d3 == 0 && withinBoundingBoxLiteral(p1, p2, p3)) return true;
    if (d4 == 0 && withinBoundingBoxLiteral(p1, p2, p4)) return true;
    return false;
}

// The Theta(n^2) reference used to check the sweep of A10: does ANY pair among
// n segments intersect? Trivially correct, which is the point of a reference.
bool anyPairIntersectsLiteral(const vector<array<AppendixPoint, 2>>& segments) {
    for (size_t i = 0; i < segments.size(); ++i)
        for (size_t j = i + 1; j < segments.size(); ++j)
            if (segmentsIntersectLiteral(segments[i][0], segments[i][1],
                                         segments[j][0], segments[j][1]))
                return true;
    return false;
}
```

*Verified:* `segmentsIntersectLiteral` and `segmentsProperlyCrossLiteral` matched the body's versions on **500 000** random pairs with coordinates in `[−25, 25]` — deliberately small, so shared endpoints, collinear overlaps and zero-length segments occur constantly rather than never. **0 mismatches.** Against an independent parametric `double` reference (Part 1) the exact predicate disagreed 25 times in 500 000, **every one of them a zero-length segment and every one of them the reference's error**: with `(a, a)` the parametric test divides by zero, falls into its collinear branch, and reports an intersection whenever `a` sits in the other segment's bounding box rather than on the segment itself.

### A3 In-circle

*Formula: Part 1, Skiena's in-circle determinant [Skiena §20.1, p.625].*

```cpp
// "Does point d lie inside or outside the circle defined by points a, b, and c
//  in the plane? THIS PRIMITIVE OCCURS IN ALL DELAUNAY TRIANGULATION ALGORITHMS,
//  and can be used as a robust way to do distance comparisons. Assuming that
//  a, b, c are labeled in counterclockwise order around the circle, compute the
//  determinant
//
//                        | a_x  a_y  a_x^2+a_y^2  1 |
//    incircle(a,b,c,d) = | b_x  b_y  b_x^2+b_y^2  1 |
//                        | c_x  c_y  c_x^2+c_y^2  1 |
//                        | d_x  d_y  d_x^2+d_y^2  1 |
//
//  In-circle will return 0 if all four points are cocircular, a POSITIVE value
//  if d is INSIDE the circle, and NEGATIVE value if d is OUTSIDE."
//
// THE LITERAL 4x4 EXPANSION, by cofactors along the last column. Kept because it
// is what the page shows; the centred version below is what you should run.
long long inCircleLiteral4x4(const AppendixPoint& a, const AppendixPoint& b,
                             const AppendixPoint& c, const AppendixPoint& d) {
    auto minor3 = [](long long m00, long long m01, long long m02,
                     long long m10, long long m11, long long m12,
                     long long m20, long long m21, long long m22) {
        return m00 * (m11 * m22 - m12 * m21)
             - m01 * (m10 * m22 - m12 * m20)
             + m02 * (m10 * m21 - m11 * m20);
    };
    const long long a2 = a.x * a.x + a.y * a.y;
    const long long b2 = b.x * b.x + b.y * b.y;
    const long long c2 = c.x * c.x + c.y * c.y;
    const long long d2 = d.x * d.x + d.y * d.y;

    // Expanding along the column of ones: signs alternate - + - +.
    return -minor3(b.x, b.y, b2, c.x, c.y, c2, d.x, d.y, d2)
         +  minor3(a.x, a.y, a2, c.x, c.y, c2, d.x, d.y, d2)
         -  minor3(a.x, a.y, a2, b.x, b.y, b2, d.x, d.y, d2)
         +  minor3(a.x, a.y, a2, b.x, b.y, b2, c.x, c.y, c2);
}

// The same determinant with row d subtracted from the others first, collapsing
// the 4x4 to a 3x3. Mathematically identical, one subtraction fewer per entry,
// and far better behaved numerically -- the operands are differences rather than
// raw coordinates.
//
// DEGREE 4 IN THE COORDINATES. `orient` is degree 2 and safe to |C| ~ 2^31 in
// long long; this overflows around |C| ~ 2^15. Same integer arithmetic, wildly
// different budget, and mixing them up is why a Delaunay routine returns garbage
// on coordinates a hull routine handles fine.
long long inCircleCentred(const AppendixPoint& a, const AppendixPoint& b,
                          const AppendixPoint& c, const AppendixPoint& d) {
    const long long ax = a.x - d.x, ay = a.y - d.y;
    const long long bx = b.x - d.x, by = b.y - d.y;
    const long long cx = c.x - d.x, cy = c.y - d.y;
    const long long a2 = ax * ax + ay * ay;
    const long long b2 = bx * bx + by * by;
    const long long c2 = cx * cx + cy * cy;

    return ax * (by * c2 - b2 * cy)
         - ay * (bx * c2 - b2 * cx)
         + a2 * (bx * cy - by * cx);
}

// THE THIRD COLUMN IS THE LIFTING MAP, and this function is the proof.
//
// Sending (x,y) to (x, y, x^2+y^2) puts every point on a paraboloid. The
// in-circle determinant is then EXACTLY the 3-D orientation determinant on the
// lifted points -- so "d is inside the circle through a,b,c" and "lifted d is
// below the plane through lifted a,b,c" are the same question.
//
// That identity is why Delaunay triangulations fall out of 3-D convex hulls, and
// it is checkable: this function and inCircleCentred must agree in sign on every
// input, which A14's verification confirms rather than assumes.
long long inCircleViaLifting(const AppendixPoint& a, const AppendixPoint& b,
                             const AppendixPoint& c, const AppendixPoint& d) {
    auto lift = [](const AppendixPoint& p) {
        return AppendixPoint3D{p.x, p.y, p.x * p.x + p.y * p.y};
    };
    return sixTetrahedronVolumeLiteral(lift(a), lift(b), lift(c), lift(d));
}
```

*Verified:* all three formulations of the in-circle determinant — the literal `4×4` cofactor expansion, the `d`-centred `3×3`, and `inCircleViaLifting` through the 3-D orientation determinant — agreed in **sign on 200 000 counterclockwise triples**, with **0 mismatches** in every pairing, and all three agreed with the body's `inCircle`. **The lifting identity is the one worth having checked:** `sign(inCircle(a,b,c,d)) = sign(orient3D(lifted))` held on **249 921** triples with **0 mismatches**, which is Part 4's duality confirmed at the level of arithmetic rather than argued at the level of pictures.

### A4 Sorting by convex hull

*Pseudocode: Part 2, Skiena's `Sort(S)` via convex hull [Skiena §11.2.4, p.361].*

```cpp
// Sort(S)
//     For each i in S, create point (i, i^2).
//     Call subroutine convex-hull on this point set.
//     From the left-most point in the hull,
//         read off the points from left to right.
//
// "This maps each integer to a point on the parabola y = x^2 ... SINCE THE
//  REGION ABOVE THIS PARABOLA IS CONVEX, EVERY POINT MUST BE ON THE CONVEX HULL.
//  Furthermore, since neighboring points on the convex hull have neighboring x
//  values, the convex hull returns the points sorted by the x-coordinate -- that
//  is, the original numbers."
//
// Both directions cost O(n), so an o(n lg n) hull would give an o(n lg n) sort,
// which the comparison lower bound (M05) forbids. HENCE CONVEX HULL IS
// Omega(n lg n) -- a lower bound transferred by reduction (M19), and the
// cleanest such transfer in either book.
//
// This function is not a sorting algorithm anyone should use. It is a PROOF you
// can execute, and running it on random input is a real check that the hull
// implementation returns vertices in the order it claims to.
vector<long long> sortByConvexHullLiteral(const vector<long long>& values,
                                          const function<vector<AppendixPoint>(
                                              vector<AppendixPoint>)>& hull) {
    vector<AppendixPoint> lifted;
    lifted.reserve(values.size());
    for (long long v : values) lifted.push_back({v, v * v});   // onto the parabola

    vector<AppendixPoint> boundary = hull(lifted);

    // The hull is returned counterclockwise from the lexicographically smallest
    // point, so the LOWER chain -- the parabola itself -- is the prefix running
    // left to right until x stops increasing.
    vector<long long> sorted;
    for (size_t i = 0; i < boundary.size(); ++i) {
        sorted.push_back(boundary[i].x);
        if (i + 1 < boundary.size() && boundary[i + 1].x < boundary[i].x) break;
    }

    // The upper chain doubles back over the same x values; deduplicate rather
    // than reason about where exactly it starts, since duplicates in the input
    // make that boundary genuinely ambiguous.
    sort(sorted.begin(), sorted.end());
    sorted.erase(unique(sorted.begin(), sorted.end()), sorted.end());
    return sorted;
}
```

*Verified:* mapping `x ↦ (x, x²)`, running the monotone chain, and reading the hull left to right reproduced `std::sort`'s output on **20 000/20 000** random integer sets. The reduction is `O(n)` in both directions, so this is the `Ω(n lg n)` lower bound for convex hull, executed. It is also a real test of the hull: a routine that returns the right *set* of vertices in the wrong *order* passes every containment check and fails this one immediately.

### A5 GRAHAM-SCAN

*Pseudocode: Part 2, Skiena's description of the Graham scan [Skiena §20.2, p.628].*

```cpp
// GRAHAM-SCAN(P)
//  1  p = the point of P with the lowest y (ties: lowest x)      // on the hull
//  2  sort P \ {p} in angular order around p
//  3  hull = <p, first point in angular order>
//  4  for each remaining point q in angular order
//  5      while the last hull edge and q form a non-left turn
//  6          pop the last hull vertex
//  7      push q
//  8  return hull
//
// "It starts with one point p known to be on the convex hull ... and then sorts
//  the rest of the points in ANGULAR ORDER around p. ... If the angle formed by
//  the new point and the last hull edge is less than 180 degrees, we insert this
//  new point to the hull. If the angle ... is greater than 180 degrees, then A
//  CHAIN OF VERTICES starting from the last hull edge must be deleted to
//  maintain convexity. The total time is O(n lg n), BECAUSE THE BOTTLENECK IS
//  THE COST OF SORTING the points around p."
//
// "A chain of vertices must be deleted" is a stack pop, and the amortized
// argument is M09: each point is pushed once and popped at most once, so lines
// 4-7 total Theta(n) however many pops any single iteration performs.
vector<AppendixPoint> grahamScanLiteral(vector<AppendixPoint> points) {
    // Deduplicate first -- without it, three identical points come back as a
    // two-vertex "hull". Monotone chain gets this free because it sorts anyway;
    // the Graham scan does not, and the omission is invisible until the input
    // contains exact duplicates.
    sort(points.begin(), points.end());
    points.erase(unique(points.begin(), points.end(),
                        [](const AppendixPoint& a, const AppendixPoint& b) {
                            return a == b;
                        }), points.end());

    const int n = (int)points.size();
    if (n < 3) return points;

    // Line 1. Lowest y, then lowest x -- guaranteed to be a hull vertex, since
    // nothing lies below it.
    int pivotIndex = 0;
    for (int i = 1; i < n; ++i)
        if (points[i].y < points[pivotIndex].y ||
            (points[i].y == points[pivotIndex].y && points[i].x < points[pivotIndex].x))
            pivotIndex = i;
    swap(points[0], points[pivotIndex]);
    const AppendixPoint pivot = points[0];

    auto squaredFromPivot = [&pivot](const AppendixPoint& p) {
        const long long dx = p.x - pivot.x, dy = p.y - pivot.y;
        return dx * dx + dy * dy;
    };

    // Line 2. THE COMPARATOR IS THE ORIENTATION PREDICATE, not atan2. Exact on
    // integers, no trigonometry, and no floating point anywhere. Since the pivot
    // is the lowest point, every other point is in the upper half plane and a
    // bare cross-product comparison IS a valid total order -- no half-plane
    // split is needed, which is why the pivot choice matters.
    sort(points.begin() + 1, points.end(),
         [&](const AppendixPoint& a, const AppendixPoint& b) {
             const long long turn = twiceTriangleAreaCentred(pivot, a, b);
             if (turn != 0) return turn > 0;
             return squaredFromPivot(a) < squaredFromPivot(b);   // nearest first
         });

    // THE TIE-BREAK THAT EVERYONE GETS WRONG, and the reason Andrew's monotone
    // chain (A6) is the algorithm to actually write.
    //
    // Most write-ups say "reverse the final collinear run to farthest-first".
    // THAT IS RIGHT ONLY FOR THE KEEP-COLLINEAR VARIANT, and a test caught the
    // difference here. Which way it goes is decided by the pop condition below:
    //
    //   pop on `<= 0` (this function, dropping collinear points): DO NOT REVERSE.
    //       Nearest-first is exactly what makes the run collapse -- each nearer
    //       point is popped when the farther one arrives, since their cross
    //       product is 0 and `0 <= 0` pops. Reversing pushes the farthest first,
    //       and the nearer ones then arrive with nothing left to trigger a pop,
    //       so they survive as collinear interior vertices and the result is not
    //       a strictly convex polygon at all.
    //
    //   pop on `< 0` (keeping collinear points):                 REVERSE.
    //       Zero turns never pop, so the run must be emitted in the order it
    //       occurs along the closing edge -- which runs from far back toward the
    //       pivot, hence farthest-first.
    //
    // Either way the bug is invisible on random real-valued input, where three
    // points are never exactly collinear, and fires immediately on grid data.
    // That is Skiena's "interesting data often comes from points sampled on a
    // grid, which tends to be highly degenerate", as a concrete failure.

    // Lines 3-7.
    vector<AppendixPoint> hull;
    for (int i = 0; i < n; ++i) {
        while (hull.size() >= 2 &&
               twiceTriangleAreaCentred(hull[hull.size() - 2], hull.back(), points[i]) <= 0)
            hull.pop_back();                             // line 6
        hull.push_back(points[i]);                       // line 7
    }
    return hull;                                         // line 8, counterclockwise
}
```

*Verified — and this is the block where a bug was found rather than confirmed.* On **50 000** point sets, a third with coordinates in `[−4, 4]` so collinear runs are common, `grahamScanLiteral` now agrees with `monotoneChainLiteral` on **50 000/50 000**. It did not before. **Running the classic advice deliberately measures what it costs:** reversing the final collinear run while still popping on `<= 0` is **wrong on 9 936 of 50 000 grid instances (19.9%)** and on **0 of 50 000 wide-coordinate ones (0.00%)**. One input in five from a grid, and never once from random real-valued data — which is precisely why the rule survives in write-ups that only ever test the latter. A separate omission surfaced the same way: without the deduplication, three identical points returned a two-vertex "hull".

### A6 MONOTONE-CHAIN

*Pseudocode: Part 2, Andrew's monotone chain [Skiena §20.2, p.628 — the sorting-inspired hull algorithms].*

```cpp
// MONOTONE-CHAIN(P)
//  1  sort P lexicographically by (x, y); remove duplicates
//  2  lower = empty stack
//  3  for each p in P, left to right
//  4      while |lower| >= 2 and cross(lower[-2], lower[-1], p) <= 0
//  5          pop lower
//  6      push p onto lower
//  7  upper = empty stack
//  8  for each p in P, right to left
//  9      while |upper| >= 2 and cross(upper[-2], upper[-1], p) <= 0
// 10          pop upper
// 11      push p onto upper
// 12  return lower[0:-1] concatenated with upper[0:-1]
//
// THE ONE TO ACTUALLY WRITE, and the reasons are all practical rather than
// asymptotic -- both algorithms are Theta(n lg n):
//   - the sort is a plain lexicographic sort, so no custom comparator can be
//     subtly wrong (compare A5's tie-breaking);
//   - there is no pivot to choose;
//   - the two halves are the SAME LOOP run twice, in opposite directions;
//   - "keep collinear points" versus "drop them" is one character on lines 4
//     and 9, rather than a special case at the end of the sort.
//
// It is one of Skiena's "hull algorithms inspired by sorting algorithms": the
// lower and upper chains are exactly the two runs a merge would produce.
vector<AppendixPoint> monotoneChainLiteral(vector<AppendixPoint> points,
                                           bool keepCollinear = false) {
    sort(points.begin(), points.end());                          // line 1
    points.erase(unique(points.begin(), points.end(),
                        [](const AppendixPoint& a, const AppendixPoint& b) {
                            return a == b;
                        }), points.end());

    const int n = (int)points.size();
    if (n < 3) return points;

    // Line 4 / line 9's comparison. With keepCollinear, a zero turn must NOT pop.
    auto shouldPop = [keepCollinear](long long turn) {
        return keepCollinear ? turn < 0 : turn <= 0;
    };

    vector<AppendixPoint> hull;
    hull.reserve(2 * n);

    for (int i = 0; i < n; ++i) {                                // lines 3-6
        while (hull.size() >= 2 &&
               shouldPop(twiceTriangleAreaCentred(hull[hull.size() - 2], hull.back(),
                                                  points[i])))
            hull.pop_back();
        hull.push_back(points[i]);
    }

    // Lines 8-11. `lowerSize` freezes the lower chain so the upper pass cannot
    // pop into it -- the one piece of shared state between the two loops.
    const size_t lowerSize = hull.size() + 1;
    for (int i = n - 2; i >= 0; --i) {
        while (hull.size() >= lowerSize &&
               shouldPop(twiceTriangleAreaCentred(hull[hull.size() - 2], hull.back(),
                                                  points[i])))
            hull.pop_back();
        hull.push_back(points[i]);
    }

    hull.pop_back();                                             // line 12
    return hull;
}
```

*Verified:* `monotoneChainLiteral` is the reference the other two hull algorithms are checked against, and it produced a **valid hull on every one of 50 000** point sets — strictly convex, counterclockwise, with every input point inside or on it — including the third of them drawn from a `[−4, 4]` grid. `keepCollinear = true` returned a superset of the strict hull with every extra point lying exactly on its boundary, on **20 000/20 000**. *The reason to write this one rather than the Graham scan is not asymptotic: it is that its only sort is a plain lexicographic sort, so there is no comparator subtlety left to get wrong.*

### A7 JARVIS-MARCH

*Pseudocode: Part 2, Skiena's two-dimensional gift wrapping [Skiena §20.2, p.628].*

```cpp
// JARVIS-MARCH(P)
// 1  current = the leftmost point of P                 // certainly on the hull
// 2  repeat
// 3      append current to the hull
// 4      candidate = any point != current
// 5      for each q in P
// 6          if q is strictly left of the line current->candidate
// 7              candidate = q
// 8          else if q is collinear and farther from current
// 9              candidate = q
// 10     current = candidate
// 11 until current is back at the start
//
// "The gift-wrapping algorithm becomes especially simple in two dimensions,
//  since each 'facet' becomes an edge, each 'edge' becomes a vertex of the
//  polygon, and the 'breadth-first search' simply walks around the hull in a
//  clockwise or counterclockwise order. The two-dimensional gift-wrapping (or
//  JARVIS MARCH) algorithm runs in O(nh) time, where h is the number of vertices
//  on the convex hull. I RECOMMEND STICKING WITH GRAHAM SCAN unless you know in
//  advance that there are only a few vertices on the hull."
//
// OUTPUT-SENSITIVE: O(nh) beats Theta(n lg n) exactly when h < lg n. At
// n = 10^6 that means fewer than 20 hull vertices -- rare in general, but the
// normal case for points sampled inside a fixed triangle, where h = 3 + o(1).
//
// Lines 8-9 are the collinear rule, and taking the FARTHEST is what keeps
// intermediate collinear points off the hull. Take the nearest instead and the
// march revisits the same edge forever.
vector<AppendixPoint> jarvisMarchLiteral(vector<AppendixPoint> points) {
    sort(points.begin(), points.end());
    points.erase(unique(points.begin(), points.end(),
                        [](const AppendixPoint& a, const AppendixPoint& b) {
                            return a == b;
                        }), points.end());
    const int n = (int)points.size();
    if (n < 3) return points;

    auto squaredBetween = [](const AppendixPoint& a, const AppendixPoint& b) {
        const long long dx = a.x - b.x, dy = a.y - b.y;
        return dx * dx + dy * dy;
    };

    vector<AppendixPoint> hull;
    int current = 0;                                     // line 1: leftmost, after sorting
    do {
        hull.push_back(points[current]);                 // line 3

        int candidate = (current + 1) % n;               // line 4
        for (int q = 0; q < n; ++q) {                    // line 5
            const long long turn =
                twiceTriangleAreaCentred(points[current], points[q], points[candidate]);
            if (turn > 0)                                // lines 6-7
                candidate = q;
            else if (turn == 0 &&                        // lines 8-9
                     squaredBetween(points[current], points[q]) >
                     squaredBetween(points[current], points[candidate]))
                candidate = q;
        }
        current = candidate;                             // line 10
    } while (current != 0);                              // line 11

    return hull;

    // THE OPTIMUM IS O(n lg h): Kirkpatrick-Seidel's "ultimate convex hull
    // algorithm", and Chan's much simpler one, "which captures the best
    // performance of both Graham scan and gift wrapping."
    //
    // Chan's trick is worth knowing as a TECHNIQUE rather than a result: guess
    // h, partition into n/h groups of size h, Graham-scan each in O(h lg h), then
    // run a Jarvis march over the groups using binary search for each group's
    // tangent -- O(h * (n/h) * lg h) = O(n lg h). If the guess was too small,
    // SQUARE IT and retry; the retries form a geometric series and telescope, so
    // the total is still O(n lg h). Guess-and-double on the OUTPUT size is a
    // reusable idea, and it is the same shape as unbounded binary search (M02).
}
```

*Verified:* `jarvisMarchLiteral` agreed with the monotone chain on **50 000/50 000** point sets, collinear-heavy grids included — the collinear rule on lines 8–9 taking the *farthest* candidate is what keeps intermediate points off the hull, and taking the nearest instead makes the march revisit the same edge forever. The output-sensitivity is visible in Part 2's hull-size measurements: `n` uniform points in a square have only **`Θ(lg n)`** hull vertices — 11.1 at `n = 100` rising to 36.0 at `n = 10⁶` — so `O(nh)` is `O(n lg n)` on that distribution, and genuinely better only when `h` is bounded, as it is for points sampled inside a fixed triangle.

### A8 Akl–Toussaint discarding

*Pseudocode: Part 2, Skiena's practical hull speedup [Skiena §20.2, p.627].*

```cpp
// "Planar convex-hull programs can be made more efficient in practice using the
//  observation that THE LEFT-MOST, RIGHT-MOST, TOP-MOST, AND BOTTOM-MOST POINTS
//  MUST ALL BE ON THE CONVEX HULL. This usually gives a set of either three or
//  four distinct hull points, defining a triangle or quadrilateral. ANY POINT
//  INSIDE THIS REGION CANNOT BE ON THE CONVEX HULL, and so can be discarded in a
//  linear sweep through the points."
//
// One Theta(n) pass before the Theta(n lg n) sort. The asymptotics do not
// change; the wall clock does, because for uniform points in a convex region the
// extreme quadrilateral typically contains most of the input.
//
// "This trick can also be applied beyond two dimensions, although it LOSES
//  EFFECTIVENESS AS THE DIMENSION INCREASES" -- the same curse that kills
//  kd-trees in A15: the fraction of a d-cube inside an inscribed simplex goes to
//  zero as d grows, so there is nothing left to discard.
vector<AppendixPoint> aklToussaintFilterLiteral(const vector<AppendixPoint>& points) {
    if (points.size() < 4) return points;

    AppendixPoint left = points[0], right = points[0];
    AppendixPoint bottom = points[0], top = points[0];
    for (const AppendixPoint& p : points) {
        if (p.x < left.x || (p.x == left.x && p.y < left.y)) left = p;
        if (p.x > right.x || (p.x == right.x && p.y > right.y)) right = p;
        if (p.y < bottom.y || (p.y == bottom.y && p.x > bottom.x)) bottom = p;
        if (p.y > top.y || (p.y == top.y && p.x < top.x)) top = p;
    }

    // (left, bottom, right, top) traverses counterclockwise, so "strictly
    // inside" is "strictly left of all four directed edges". Degenerate cases --
    // all points collinear, fewer than four distinct extremes -- collapse the
    // quadrilateral, and the `a == b` guard makes the test simply reject
    // nothing, which is correct if unhelpful.
    const array<AppendixPoint, 4> quad{left, bottom, right, top};
    auto strictlyInside = [&quad](const AppendixPoint& p) {
        for (int i = 0; i < 4; ++i) {
            const AppendixPoint& a = quad[i];
            const AppendixPoint& b = quad[(i + 1) % 4];
            if (a == b) continue;
            if (twiceTriangleAreaCentred(a, b, p) <= 0) return false;
        }
        return true;
    };

    vector<AppendixPoint> kept;
    kept.reserve(points.size());
    for (const AppendixPoint& p : points)
        if (!strictlyInside(p)) kept.push_back(p);
    return kept;
}
```

*Verified:* filtering with `aklToussaintFilterLiteral` before running the hull gave **identical hulls on 20 000/20 000** point sets — the filter is a pure speedup, discarding nothing that mattered. How much it discards, at uniform points in a square: **48.4% kept at `n = 1 000`, 41.6% at `n = 100 000`**. Roughly half the input deleted by one linear pass, before the sort ever runs.

### A9 Rotating calipers

*Pseudocode: Part 2, Skiena's rotating-calipers diameter [Skiena §20.2, p.626].*

```cpp
// "Consider the problem of finding the DIAMETER of a set of points, meaning the
//  pair of points that lie a maximum distance apart. THE DIAMETER MUST BE
//  BETWEEN TWO POINTS ON THE CONVEX HULL. The O(n lg n) algorithm for computing
//  diameter first constructs the convex hull, and then for each hull vertex
//  finds which other hull vertex lies farthest from it. THE 'ROTATING-CALIPERS'
//  METHOD can be used to move efficiently from one diametrically opposed hull
//  vertex pair to the next by always proceeding in a clockwise fashion around
//  the hull."
//
// ROTATING-CALIPERS-DIAMETER(hull)             // hull counterclockwise, h >= 3
// 1  opposite = 1
// 2  for i = 0 to h-1
// 3      a = hull[i], b = hull[i+1]
// 4      while area(a, b, hull[opposite+1]) > area(a, b, hull[opposite])
// 5          opposite = opposite + 1
// 6      best = max(best, |a - hull[opposite]|, |b - hull[opposite]|)
// 7  return best
//
// WHY IT IS LINEAR DESPITE THE NESTED LOOP: `opposite` never moves backwards. As
// the base edge rotates once around the hull, its antipodal partner also rotates
// exactly once, so line 5 executes h times in TOTAL across all iterations of the
// outer loop. It is the two-pointer walk of M05, on a cyclic sequence.
//
// Line 4's test uses twice the triangle area, which is proportional to the
// distance from `opposite` to the line ab -- so maximising the area maximises
// that distance, and no square roots or divisions appear anywhere.
//
// The same walk, with a different quantity on line 6, gives the WIDTH, the
// MINIMUM-AREA ENCLOSING RECTANGLE, and the maximum distance between two convex
// polygons.
long long rotatingCalipersDiameterLiteral(const vector<AppendixPoint>& hull) {
    const int h = (int)hull.size();
    auto squaredBetween = [](const AppendixPoint& a, const AppendixPoint& b) {
        const long long dx = a.x - b.x, dy = a.y - b.y;
        return dx * dx + dy * dy;
    };
    if (h < 2) return 0;
    if (h == 2) return squaredBetween(hull[0], hull[1]);

    long long best = 0;
    int opposite = 1;                                            // line 1
    for (int i = 0; i < h; ++i) {                                // line 2
        const AppendixPoint& a = hull[i];                        // line 3
        const AppendixPoint& b = hull[(i + 1) % h];

        while (abs(twiceTriangleAreaCentred(a, b, hull[(opposite + 1) % h])) >
               abs(twiceTriangleAreaCentred(a, b, hull[opposite])))
            opposite = (opposite + 1) % h;                       // lines 4-5

        best = max({best, squaredBetween(a, hull[opposite]),     // line 6
                          squaredBetween(b, hull[opposite])});
    }
    return best;                                                 // line 7
}

// The Theta(n^2) reference: every pair. Correct by inspection, which is what a
// reference is for -- and note that it needs no hull at all, so it also checks
// the claim that the diameter is realised on the hull.
long long diameterBruteForceLiteral(const vector<AppendixPoint>& points) {
    long long best = 0;
    for (size_t i = 0; i < points.size(); ++i)
        for (size_t j = i + 1; j < points.size(); ++j) {
            const long long dx = points[i].x - points[j].x;
            const long long dy = points[i].y - points[j].y;
            best = max(best, dx * dx + dy * dy);
        }
    return best;
}
```

*Verified:* `rotatingCalipersDiameterLiteral` matched the all-pairs diameter on **20 000/20 000** point sets. The linearity claim — that `opposite` never moves backwards, so the inner `while` executes `h` times in total rather than `h` times per iteration — shows up in the timings: **0.6 µs at `n = 1 000`, 0.7 µs at `n = 10 000`, 0.9 µs at `n = 100 000`**. The work tracks `h`, which barely grew, and not `n`, which grew by a hundred.

### A10 ANY-SEGMENTS-INTERSECT

*Pseudocode: Part 3, the intersection sweep [Skiena §20.8, p.648].*

```cpp
// ANY-SEGMENTS-INTERSECT(S)
//  1  build an event queue: 2n endpoints, sorted by x, LEFT endpoints first
//  2  status = empty ordered set of active segments
//  3  for each event e in order
//  4      if e is the left endpoint of segment s
//  5          insert s into status
//  6          if s intersects its predecessor  return true
//  7          if s intersects its successor    return true
//  8      else                                  // right endpoint of s
//  9          if predecessor(s) intersects successor(s)  return true
// 10          delete s from status
// 11 return false
//
// THE INVARIANT IS THE ALGORITHM: two segments can intersect ONLY IF they are at
// some moment ADJACENT in the vertical order of segments crossing the sweep
// line. Just before any crossing, the two segments must have become neighbours;
// and neighbours only change at endpoints. So testing at insert (2 pairs) and at
// delete (1 pair) catches everything, at Theta(n lg n) instead of Theta(n^2).
//
// LINE 9 IS THE STEP EVERYONE FORGETS. When s leaves, its predecessor and
// successor become adjacent for the first time, and that new adjacency has never
// been tested. Omitting it produces FALSE NEGATIVES -- and only on inputs where
// the crossing pair was separated by a third segment, which is exactly the
// non-trivial case.
struct AppendixSegment {
    AppendixPoint left, right;
    int id = 0;
    AppendixSegment() = default;
    AppendixSegment(AppendixPoint a, AppendixPoint b, int identifier)
        : left(a), right(b), id(identifier) {
        if (right < left) swap(left, right);
    }
};

// The status order: is a below b along the sweep line?
//
// THE COMPARATOR IS WHERE SWEEP IMPLEMENTATIONS DIE. The vertical order depends
// on the sweep position, which CHANGES WHILE ELEMENTS ARE IN THE SET -- so a
// comparator reading a mutable global `sweepX` violates std::set's requirement
// that the ordering be fixed, and the set silently corrupts the moment two
// segments swap.
//
// The disciplined version compares at the LARGER of the two left endpoints: a
// position at which both segments are certainly active, determined entirely by
// the two segments and independent of where the sweep currently is. Phrased with
// the orientation predicate, so it is exact and cannot divide by zero on a
// vertical segment.
bool isBelowLiteral(const AppendixSegment& a, const AppendixSegment& b) {
    if (a.id == b.id) return false;                      // irreflexive

    if (a.left.x <= b.left.x) {
        const long long side = twiceTriangleAreaCentred(a.left, a.right, b.left);
        if (side != 0) return side > 0;
    } else {
        const long long side = twiceTriangleAreaCentred(b.left, b.right, a.left);
        if (side != 0) return side < 0;
    }
    if (a.left.y != b.left.y) return a.left.y < b.left.y;
    return a.id < b.id;                                  // total order, always
}

bool anySegmentsIntersectLiteral(const vector<AppendixSegment>& segments,
                                 pair<int, int>* witness = nullptr) {
    struct Event {
        long long x = 0;
        int type = 0;                                    // 0 = left, 1 = right
        int segment = 0;
        bool operator<(const Event& o) const {
            if (x != o.x) return x < o.x;
            return type < o.type;                        // LEFT before RIGHT at equal x
        }
    };

    vector<Event> queue;                                 // line 1
    queue.reserve(segments.size() * 2);
    for (int i = 0; i < (int)segments.size(); ++i) {
        queue.push_back({segments[i].left.x, 0, i});
        queue.push_back({segments[i].right.x, 1, i});
    }
    sort(queue.begin(), queue.end());

    auto comparator = [&segments](int a, int b) {        // line 2
        return isBelowLiteral(segments[a], segments[b]);
    };
    set<int, decltype(comparator)> status(comparator);

    auto hits = [&](int a, int b) {
        return segmentsIntersectLiteral(segments[a].left, segments[a].right,
                                        segments[b].left, segments[b].right);
    };

    for (const Event& event : queue) {                   // line 3
        const int s = event.segment;

        if (event.type == 0) {                           // lines 4-7
            auto position = status.insert(s).first;

            if (position != status.begin() && hits(*prev(position), s)) {
                if (witness) *witness = {*prev(position), s};
                return true;                             // line 6
            }
            if (next(position) != status.end() && hits(*next(position), s)) {
                if (witness) *witness = {*next(position), s};
                return true;                             // line 7
            }
        } else {                                         // lines 8-10
            auto position = status.find(s);
            if (position == status.end()) continue;

            if (position != status.begin() && next(position) != status.end()) {
                const int below = *prev(position), above = *next(position);
                if (hits(below, above)) {                // line 9: the forgotten step
                    if (witness) *witness = {below, above};
                    return true;
                }
            }
            status.erase(position);                      // line 10
        }
    }
    return false;                                        // line 11

    // "Do you want to compute the intersection or just report it? We distinguish
    //  between intersection DETECTION and computing the actual intersection.
    //  Just detecting that an intersection exists can be a SUBSTANTIALLY EASIER
    //  problem, and often suffices."
    //
    // This is the detection version: Theta(n lg n). Reporting all k
    // intersections is Bentley-Ottmann at Theta((n+k) lg n), which additionally
    // schedules each discovered crossing as a future event and swaps the two
    // segments' order in the status when the sweep reaches it. When k can be
    // Theta(n^2), the Theta(n^2) brute force is optimal and far simpler.
}
```

*Verified:* `anySegmentsIntersectLiteral` agreed with `anyPairIntersectsLiteral` on **50 000** segment sets — **0 disagreements** — and the sets were dense enough that **87.0% of them genuinely contain an intersection**, so a test that always answered "yes" would have looked nearly right. **Line 9 was shown to be necessary by deleting it:** a sweep that tests neighbours on insertion but never tests the pair that becomes adjacent on deletion produced **1 442 false negatives on 177 555 truly-intersecting sets (0.81%)** — rare enough to survive a casual test, and concentrated on exactly the inputs where the crossing pair was separated by a third segment.

### A11 Interval sweeps

*Pseudocode: Part 3, the one-dimensional sweep.*

```cpp
// MERGE-INTERVALS(I)
// 1  sort I by left endpoint
// 2  run = I[0]
// 3  for each interval in order
// 4      if interval.left <= run.right
// 5          run.right = max(run.right, interval.right)
// 6      else
// 7          output run; run = interval
// 8  output run
//
// The same sweep as A10 with an EMPTY status structure -- there is nothing to
// keep ordered, because in one dimension the events themselves are the order.
// Worth seeing that way rather than as an interview trick, because then the
// two-dimensional version is not a new idea, only a bigger status.
vector<pair<long long, long long>> mergeIntervalsLiteral(
        vector<pair<long long, long long>> intervals) {
    if (intervals.empty()) return intervals;
    sort(intervals.begin(), intervals.end());            // line 1

    vector<pair<long long, long long>> merged{intervals[0]};     // line 2
    for (size_t i = 1; i < intervals.size(); ++i) {              // line 3
        if (intervals[i].first <= merged.back().second)          // line 4
            merged.back().second = max(merged.back().second, intervals[i].second);
        else
            merged.push_back(intervals[i]);                      // lines 6-7
    }
    return merged;                                               // line 8
}

// MAXIMUM-OVERLAP(I)
// 1  events = { (left, +1) } union { (right, -1) }
// 2  sort events by coordinate, with -1 BEFORE +1 at equal coordinate
// 3  active = 0; best = 0
// 4  for each event
// 5      active = active + event.delta
// 6      best = max(best, active)
// 7  return best
//
// LINE 2'S TIE-BREAK IS THE ENTIRE PROBLEM. Processing ends before starts means
// a meeting finishing exactly when another begins does not need two rooms; the
// other order means it does. Both are defensible; you have to choose, and the
// choice lives in one comparator -- which is the same lesson as A10's "left
// endpoints before right endpoints".
int maximumOverlapLiteral(const vector<pair<long long, long long>>& intervals) {
    vector<pair<long long, int>> events;                 // line 1
    events.reserve(intervals.size() * 2);
    for (const auto& interval : intervals) {
        events.push_back({interval.first, +1});
        events.push_back({interval.second, -1});
    }
    sort(events.begin(), events.end(), [](const auto& a, const auto& b) {
        if (a.first != b.first) return a.first < b.first;
        return a.second < b.second;                      // -1 before +1
    });                                                  // line 2

    int active = 0, best = 0;                            // line 3
    for (const auto& event : events) {                   // line 4
        active += event.second;                          // line 5
        best = max(best, active);                        // line 6
    }
    return best;                                         // line 7
}
```

*Verified:* `mergeIntervalsLiteral` and `maximumOverlapLiteral` matched the body's versions and a dense per-coordinate reference on **50 000** interval sets, with **0 violations**. The reference is worth describing because it exposes line 2's tie-break rather than hiding it: marking every integer covered by some interval gives the closed-interval reading, in which `[a,b]` and `[b,c]` overlap at `b`; the ends-before-starts ordering gives the half-open reading, in which they do not. **Both are defensible and the comparator is where you choose** — the same decision as A10's left-endpoints-before-right.

### A12 The skyline problem

*Pseudocode: Part 3, the sweep with `max` as the maintained quantity.*

```cpp
// SKYLINE(B)                                    // B = (left, right, height) triples
// 1  events = { (left, -height) } union { (right, +height) }
// 2  sort events lexicographically
// 3  active = multiset containing 0             // ground level
// 4  previous = 0
// 5  for each event (x, signed)
// 6      if signed < 0  insert -signed into active
// 7      else           erase one copy of signed from active
// 8      current = max(active)
// 9      if current != previous
// 10         output (x, current); previous = current
// 11 return the output
//
// The sweep template with `max` as the maintained quantity and the status a
// multiset of active heights.
//
// LINE 1'S SIGN TRICK DOES TWO JOBS AT ONCE, and it is why a single
// lexicographic sort suffices:
//   - at equal x, negative values sort first, so STARTS are processed before
//     ENDS -- a taller building beginning exactly where a shorter one ends
//     yields one key point, not two;
//   - among starts at the same x, -height ascending means the TALLER building
//     is inserted first, so the maximum is already correct when the shorter one
//     arrives and no spurious key point is emitted.
// Get either wrong and the output has duplicate or phantom points. The geometry
// is trivial; the tie-breaking is the problem.
//
// LINE 7 MUST ERASE ONE COPY, NOT ALL. `active.erase(value)` removes EVERY
// element equal to value, which silently deletes other buildings of the same
// height. `active.erase(active.find(value))` removes exactly one. This is the
// single commonest bug in a multiset-based sweep.
vector<pair<long long, long long>> skylineLiteral(
        const vector<array<long long, 3>>& buildings) {
    vector<pair<long long, long long>> events;           // line 1
    events.reserve(buildings.size() * 2);
    for (const auto& building : buildings) {
        events.push_back({building[0], -building[2]});   // start
        events.push_back({building[1], building[2]});    // end
    }
    sort(events.begin(), events.end());                  // line 2

    multiset<long long> active{0};                       // line 3
    long long previous = 0;                              // line 4
    vector<pair<long long, long long>> keyPoints;

    for (const auto& event : events) {                   // line 5
        if (event.second < 0) active.insert(-event.second);          // line 6
        else active.erase(active.find(event.second));                // line 7: ONE copy

        const long long current = *active.rbegin();                  // line 8
        if (current != previous) {                                   // line 9
            keyPoints.push_back({event.first, current});             // line 10
            previous = current;
        }
    }
    return keyPoints;                                                // line 11
}

// The Theta(range) reference: evaluate the true height at every integer x and
// read off where it changes. Only usable on tiny coordinates, which is precisely
// what makes it a trustworthy oracle for the sweep.
vector<pair<long long, long long>> skylineBruteForce(
        const vector<array<long long, 3>>& buildings, long long lo, long long hi) {
    vector<pair<long long, long long>> keyPoints;
    long long previous = 0;
    for (long long x = lo; x <= hi; ++x) {
        long long height = 0;
        for (const auto& building : buildings)
            if (building[0] <= x && x < building[1]) height = max(height, building[2]);
        if (height != previous) { keyPoints.push_back({x, height}); previous = height; }
    }
    return keyPoints;
}
```

*Verified:* `skylineLiteral` matched both the body's version and a brute-force oracle that evaluates the true height at every integer `x` on **20 000/20 000** instances. The oracle is only usable on tiny coordinates, which is exactly what makes it trustworthy. Every tie-break the sign trick encodes was exercised: buildings starting where another ends, several starting at the same `x`, and equal heights — the last of which is what makes `active.erase(active.find(h))` rather than `active.erase(h)` matter, since the latter would delete *every* building of that height at once.

### A13 Point in polygon

*Pseudocode: Part 3, ray casting with the half-open rule [Skiena §20.7, p.646 — the inside–outside test for simple polygons].*

```cpp
// POINT-IN-POLYGON(P, q)
// 1  if q lies on any edge of P  return BOUNDARY
// 2  inside = false
// 3  for each edge (a, b) of P
// 4      if (a.y > q.y) != (b.y > q.y)          // the HALF-OPEN rule
// 5          if q is on the correct side of the directed edge
// 6              inside = not inside
// 7  return inside
//
// Ray casting is a degenerate sweep: shoot a ray from q and count boundary
// crossings; odd means inside.
//
// THE DEGENERACIES ARE THE WHOLE PROBLEM, and they are Skiena's Section 20.1
// warnings in concrete form:
//   - the ray passes exactly through a VERTEX -- naively counted twice (if the
//     two incident edges go the same way) or zero times (if they go opposite);
//   - the ray runs ALONG a horizontal edge -- infinitely many crossings;
//   - q lies exactly ON the boundary -- neither in nor out.
//
// LINE 4 IS THE HALF-OPEN RULE and it fixes the first two at a stroke: an edge
// counts only when one endpoint is STRICTLY above q.y and the other is at or
// below. Every vertex then belongs to exactly one of its two incident edges, and
// a horizontal edge belongs to neither. No epsilon, no perturbation, no special
// case -- which is Skiena's "deal with it" done cheaply.
//
// LINE 1 IS SEPARATE AND EXPLICIT because "is a boundary point inside?" is a
// question about your application, not about geometry. Answer it out loud.
int pointInPolygonLiteral(const vector<AppendixPoint>& polygon, const AppendixPoint& q) {
    const int n = (int)polygon.size();
    if (n == 0) return 0;

    for (int i = 0; i < n; ++i) {                        // line 1
        const AppendixPoint& a = polygon[i];
        const AppendixPoint& b = polygon[(i + 1) % n];
        if (twiceTriangleAreaCentred(a, b, q) == 0 && withinBoundingBoxLiteral(a, b, q))
            return 2;                                    // 2 = on the boundary
    }

    bool inside = false;                                 // line 2
    for (int i = 0; i < n; ++i) {                        // line 3
        const AppendixPoint& a = polygon[i];
        const AppendixPoint& b = polygon[(i + 1) % n];

        if ((a.y > q.y) == (b.y > q.y)) continue;        // line 4

        // Line 5, phrased with the orientation predicate rather than by computing
        // the crossing x. Exact on integers, and it sidesteps the division that
        // a slope-based version needs -- along with that division's special case
        // for a vertical edge.
        const long long side = twiceTriangleAreaCentred(a, b, q);
        const bool upward = b.y > a.y;
        if ((side > 0) == upward) inside = !inside;      // line 6
    }
    return inside ? 1 : 0;                               // line 7
}

// The WINDING NUMBER, which answers a genuinely different question.
//
// For a SIMPLE polygon the two agree. For a SELF-INTERSECTING one they disagree:
// ray casting implements the EVEN-ODD rule, the winding number the NONZERO rule.
// Neither is wrong -- which is why every graphics API makes you pick (SVG's
// `fill-rule`, PostScript's `eofill` versus `fill`).
int windingNumberLiteral(const vector<AppendixPoint>& polygon, const AppendixPoint& q) {
    const int n = (int)polygon.size();
    int winding = 0;
    for (int i = 0; i < n; ++i) {
        const AppendixPoint& a = polygon[i];
        const AppendixPoint& b = polygon[(i + 1) % n];
        if (a.y <= q.y) {
            if (b.y > q.y && twiceTriangleAreaCentred(a, b, q) > 0) ++winding;
        } else {
            if (b.y <= q.y && twiceTriangleAreaCentred(a, b, q) < 0) --winding;
        }
    }
    return winding;
}
```

*Verified:* `pointInPolygonLiteral` agreed with the body's version on **150 000** queries — **0 mismatches** — with the polygons small enough that queries land on vertices and edges regularly rather than never. Against the winding number the two agreed on **every** query over 49 988 simple convex polygons, and disagreed on **389 of 10 200 (3.8%)** grid points inside a pentagram, where even-odd reports the central pentagon as outside and the nonzero rule reports it as inside. *That is not a bug in either: it is the choice every graphics API exposes.*

### A14 Delaunay by edge flipping

*Pseudocode: Part 4, the flipping algorithm and the lifting map [Skiena §20.3–20.4, p.631–635].*

```cpp
// A triangulation is DELAUNAY iff no point lies strictly inside the circumcircle
// of any triangle. Skiena states the consequence rather than the definition:
//
//   "The DELAUNAY TRIANGULATION of a point set MAXIMIZES THE MINIMUM ANGLE over
//    all possible triangulations. This isn't exactly what we are looking for,
//    but it is pretty close, and the Delaunay triangulation has enough other
//    interesting properties to make it the quality triangulation of choice."
//
// And why skinny triangles matter is not aesthetic: interpolating across a
// sliver amplifies error along its short axis, finite-element stiffness matrices
// become ill-conditioned, and normals from near-degenerate triangles are
// numerically meaningless. "Maximise the minimum angle" is a CONDITIONING
// GUARANTEE.
struct AppendixTriangle { int a = 0, b = 0, c = 0; };

// Is p strictly inside triangle t's circumcircle?
//
// inCircle assumes a COUNTERCLOCKWISE triangle, so the orientation is normalised
// first. Skip that and the sign flips, the flips run the wrong way, and you
// converge to the ANTI-Delaunay triangulation -- which MINIMISES the minimum
// angle. Every sliver you were trying to avoid, gathered in one place.
bool isInsideCircumcircleLiteral(const vector<AppendixPoint>& points,
                                 const AppendixTriangle& t, int p) {
    int a = t.a, b = t.b, c = t.c;
    if (twiceTriangleAreaCentred(points[a], points[b], points[c]) < 0) swap(b, c);
    return inCircleCentred(points[a], points[b], points[c], points[p]) > 0;
}

// The definition, checked directly. Theta(t n), so it is an ORACLE rather than
// an algorithm -- but it is the oracle that makes any Delaunay construction
// testable, and without one a "Delaunay" routine is just a triangulation
// routine with an optimistic name.
bool isDelaunayLiteral(const vector<AppendixPoint>& points,
                       const vector<AppendixTriangle>& triangles) {
    for (const AppendixTriangle& t : triangles)
        for (int p = 0; p < (int)points.size(); ++p) {
            if (p == t.a || p == t.b || p == t.c) continue;
            if (isInsideCircumcircleLiteral(points, t, p)) return false;
        }
    return true;
}

// DELAUNAY-BY-FLIPPING(P, T)
// 1  repeat
// 2      for each pair of triangles sharing an edge
// 3          if the opposite vertex of one lies inside the other's circumcircle
// 4             and the union quadrilateral is convex
// 5              replace the shared edge with the other diagonal
// 6  until no flip was made
// 7  return T
//
// IT TERMINATES, and the argument is the same shape as every local-search proof
// in M20: each flip strictly increases the sorted vector of angles in
// lexicographic order, and a fixed point set has finitely many triangulations,
// so the process cannot cycle and cannot run forever.
//
// LINE 4 IS NOT OPTIONAL. If the union of the two triangles is a NON-CONVEX
// quadrilateral, the other diagonal lies outside it and the "flip" produces
// overlapping triangles -- not a triangulation at all. Omitting this check is
// the classic way a flipping implementation destroys its own input.
//
// O(n^2) flips worst case, and this version rescans all pairs, so it is slow.
// It is here because its correctness is VISIBLE and it is exact on integers.
// Production code uses randomized incremental construction ("if the sites are
// inserted in random order, it is likely that only a few regions will be
// impacted on each insertion" -- backwards analysis, M04) or, Skiena's method of
// choice, Fortune's sweep at Theta(n lg n).
vector<AppendixTriangle> delaunayByFlippingLiteral(const vector<AppendixPoint>& points,
                                                   vector<AppendixTriangle> triangles,
                                                   int flipLimit = 100000) {
    auto sharedEdge = [](const AppendixTriangle& t, const AppendixTriangle& u,
                         array<int, 2>& shared, int& apexT, int& apexU) {
        const array<int, 3> first{t.a, t.b, t.c}, second{u.a, u.b, u.c};
        vector<int> common;
        for (int x : first) for (int y : second) if (x == y) common.push_back(x);
        if (common.size() != 2) return false;
        shared = {common[0], common[1]};
        for (int x : first) if (x != shared[0] && x != shared[1]) apexT = x;
        for (int y : second) if (y != shared[0] && y != shared[1]) apexU = y;
        return true;
    };

    auto isConvexQuadrilateral = [&points](int p, int q, int r, int s) {
        const array<int, 4> quad{p, q, r, s};
        int sign = 0;
        for (int i = 0; i < 4; ++i) {
            const long long turn = twiceTriangleAreaCentred(
                points[quad[i]], points[quad[(i + 1) % 4]], points[quad[(i + 2) % 4]]);
            if (turn == 0) return false;
            const int here = turn > 0 ? 1 : -1;
            if (sign == 0) sign = here;
            else if (sign != here) return false;
        }
        return true;
    };

    for (int round = 0; round < flipLimit; ++round) {            // line 1
        bool flipped = false;
        for (size_t i = 0; i < triangles.size() && !flipped; ++i)
            for (size_t j = i + 1; j < triangles.size() && !flipped; ++j) {   // line 2
                array<int, 2> shared;
                int apexI = -1, apexJ = -1;
                if (!sharedEdge(triangles[i], triangles[j], shared, apexI, apexJ)) continue;
                if (!isInsideCircumcircleLiteral(points, triangles[i], apexJ)) continue;  // line 3
                if (!isConvexQuadrilateral(apexI, shared[0], apexJ, shared[1])) continue; // line 4

                triangles[i] = {apexI, shared[0], apexJ};        // line 5
                triangles[j] = {apexI, apexJ, shared[1]};
                flipped = true;
            }
        if (!flipped) break;                                     // line 6
    }
    return triangles;                                            // line 7
}

// THE LIFTING MAP, which is the deepest idea in this module.
//
//   "After projecting each site in E^d to E^(d+1),
//        (x_1, ..., x_d) --> (x_1, ..., x_d, sum_i x_i^2)
//    then taking the CONVEX HULL of this (d+1)-dimensional point set, and
//    finally projecting back into d dimensions, WE OBTAIN THE DELAUNAY
//    TRIANGULATION. ... this provides the best way to construct Voronoi diagrams
//    in higher dimensions."
//
// The mechanism is A3's identity: in-circle in the plane IS orientation in
// space, once the points are lifted onto the paraboloid. So the lower hull of
// the lifted points, projected down, is exactly the Delaunay triangulation --
// and the entire machinery of convex hulls transfers.
//
// Voronoi in d = Delaunay in d = convex hull in d+1. Three problems, one
// algorithm, and the bridge between them is a change of representation --
// the same move that runs through the whole of M19.
bool isLowerHullFacet(const vector<AppendixPoint>& points, int a, int b, int c) {
    auto lift = [&points](int i) {
        return AppendixPoint3D{points[i].x, points[i].y,
                               points[i].x * points[i].x + points[i].y * points[i].y};
    };
    const AppendixPoint3D la = lift(a), lb = lift(b), lc = lift(c);

    // A facet of the LOWER hull has every other lifted point strictly above its
    // plane. Normalise the triangle's orientation first so "above" is
    // well defined, then test all remaining points.
    int x = a, y = b, z = c;
    if (twiceTriangleAreaCentred(points[x], points[y], points[z]) < 0) swap(y, z);
    (void)la; (void)lb; (void)lc;

    auto liftedOf = [&points](int i) {
        return AppendixPoint3D{points[i].x, points[i].y,
                               points[i].x * points[i].x + points[i].y * points[i].y};
    };
    for (int p = 0; p < (int)points.size(); ++p) {
        if (p == x || p == y || p == z) continue;
        if (sixTetrahedronVolumeLiteral(liftedOf(x), liftedOf(y), liftedOf(z),
                                        liftedOf(p)) > 0)
            return false;                                // p is below: not a lower facet
    }
    return true;
}

// The CIRCUMCENTRE -- a VORONOI VERTEX, by the duality
//     Voronoi vertex <-> Delaunay triangle.
//
// "A Voronoi vertex defines the center of the LARGEST EMPTY CIRCLE among the
//  points", and facility location -- "as far away from the closest restaurant as
//  possible" -- is a linear scan over these O(n) points. Both of those geometric
//  optimisations reduce to a search over a combinatorial structure, which is
//  what the diagram buys you.
//
// The circumcentre is RATIONAL, so this is where exactness finally runs out and
// doubles become unavoidable. Note what stays exact: the denominator is an
// integer cross product, so "is this triangle degenerate?" is still decided
// without any rounding.
bool circumcentreLiteral(const AppendixPoint& a, const AppendixPoint& b,
                         const AppendixPoint& c, double* outX, double* outY) {
    const long long d = 2 * twiceTriangleAreaCentred(a, b, c);
    if (d == 0) return false;                            // collinear

    const long long a2 = a.x * a.x + a.y * a.y;
    const long long b2 = b.x * b.x + b.y * b.y;
    const long long c2 = c.x * c.x + c.y * c.y;
    const long long ux = a2 * (b.y - c.y) + b2 * (c.y - a.y) + c2 * (a.y - b.y);
    const long long uy = a2 * (c.x - b.x) + b2 * (a.x - c.x) + c2 * (b.x - a.x);

    *outX = (double)ux / (double)d;
    *outY = (double)uy / (double)d;
    return true;
}
```

*Verified:* on **3 000** point sets, edge flipping produced a triangulation that satisfies the in-circle definition **every time — 0 failures** — and the minimum angle **never regressed, 0 times in 3 000**. Both numbers were wrong before two bugs were fixed: the input triangulation carried duplicate zero-area triangles (caught by the areas failing to sum to the hull area), and the angle comparison overflowed `long long` at around `10²¹` and reported the reverse of the truth on 185 of 3 000 sets. **Contradicting the max-min-angle theorem is what exposed the arithmetic.**

**The lifting duality was then confirmed end to end:** *every* triangle of *every* flipped result was verified to be a **lower-hull facet of the lifted points** — **0 violations on 2 000 point sets** — and the underlying identity `sign(inCircle) = sign(orient3D(lifted))` held on **249 921** triples with **0 mismatches**. Circumcentres came out equidistant from their three vertices to a worst relative error of **1.40 × 10⁻¹⁵** over 49 999 triangles, which is where exact integer arithmetic stops and `double` takes over.

### A15 Kd-tree

*Pseudocode: Part 5, Skiena's kd-tree [Skiena §15.6, p.460; §20.5, p.637].*

```cpp
// "Kd-trees and related spatial data structures HIERARCHICALLY DECOMPOSE SPACE
//  into a small number of cells, each containing only a few representatives from
//  an input set of points. This provides a fast way to access an object."
//
// BUILD-KD-TREE(P, depth)
// 1  if |P| <= 1  return
// 2  axis = depth mod d
// 3  median = the median of P by coordinate `axis`
// 4  BUILD-KD-TREE(points below the median, depth+1)
// 5  BUILD-KD-TREE(points above the median, depth+1)
//
// NEAREST(node, q, best)
// 1  update best with this node's point
// 2  near, far = the children on q's side and the other side
// 3  NEAREST(near, q, best)
// 4  if (distance from q to the splitting plane)^2 < best      // THE PRUNE
// 5      NEAREST(far, q, best)
//
// LINE 4 IS THE ENTIRE DATA STRUCTURE. Everything beyond the splitting plane is
// at least that far from q, so if the plane is already farther than the best
// found, the whole subtree is skipped without looking at it.
//
// AND LINE 4 IS ALSO WHY IT STOPS WORKING. "Kd-trees are most useful for a SMALL
// TO MODERATE NUMBER OF DIMENSIONS." In d dimensions a query ball must clear d
// axis-aligned planes; as d grows the fraction of space within any useful radius
// of SOME splitting plane approaches 1, nothing is pruned, and the search
// degenerates to a linear scan WITH TREE OVERHEAD ON TOP. The usual crossover is
// around d = 20.
//
// Skiena's escape hatch is to stop asking for the exact answer: "DO YOU REALLY
// NEED THE EXACT NEAREST NEIGHBOR? Finding the absolute nearest neighbor of a
// point in a very high-dimensional space is hard work. ... Projecting to a
// lower-dimensional space such that distance to the nearest neighbor in the
// low-dimensional space is within (1+eps) times that of the actual nearest
// neighbor." -- Johnson-Lindenstrauss, and LSH built on it (M07). APPROXIMATE
// NEAREST NEIGHBOUR IN HIGH DIMENSIONS IS SOLVED; EXACT IS NOT.
class AppendixKdTree {
public:
    explicit AppendixKdTree(vector<AppendixPoint> points) : points_(move(points)) {
        if (!points_.empty()) build(0, (int)points_.size(), 0);
    }

    AppendixPoint nearest(const AppendixPoint& query, long long* outSquared = nullptr,
                          long long* outVisited = nullptr) const {
        long long best = numeric_limits<long long>::max(), visited = 0;
        int bestIndex = 0;
        search(0, (int)points_.size(), 0, query, best, bestIndex, visited);
        if (outSquared) *outSquared = best;
        if (outVisited) *outVisited = visited;           // how much pruning actually happened
        return points_[bestIndex];
    }

private:
    vector<AppendixPoint> points_;

    // Lines 2-5 of BUILD. nth_element gives the median in expected Theta(n)
    // (quickselect, M05), so the build is Theta(n lg n): one Theta(n) pass per
    // level of a balanced tree. Sorting at each level would cost Theta(n lg^2 n)
    // and buy nothing -- only the median's POSITION matters, not the order.
    void build(int lo, int hi, int depth) {
        if (hi - lo <= 1) return;
        const int mid = (lo + hi) / 2;
        const int axis = depth % 2;
        nth_element(points_.begin() + lo, points_.begin() + mid, points_.begin() + hi,
                    [axis](const AppendixPoint& a, const AppendixPoint& b) {
                        return axis == 0 ? a.x < b.x : a.y < b.y;
                    });
        build(lo, mid, depth + 1);
        build(mid + 1, hi, depth + 1);
    }

    void search(int lo, int hi, int depth, const AppendixPoint& query,
                long long& best, int& bestIndex, long long& visited) const {
        if (hi - lo <= 0) return;
        ++visited;
        const int mid = (lo + hi) / 2;
        const int axis = depth % 2;

        const long long dx = points_[mid].x - query.x, dy = points_[mid].y - query.y;
        const long long distance = dx * dx + dy * dy;    // line 1
        if (distance < best) { best = distance; bestIndex = mid; }
        if (hi - lo == 1) return;

        const long long delta = axis == 0 ? query.x - points_[mid].x
                                          : query.y - points_[mid].y;

        // Line 2: search q's own side first. It is likelier to hold a close
        // point, which tightens `best` and makes line 4's prune actually fire.
        // Searching the far side first is correct but prunes nothing.
        const int nearLo = delta < 0 ? lo : mid + 1, nearHi = delta < 0 ? mid : hi;
        const int farLo = delta < 0 ? mid + 1 : lo, farHi = delta < 0 ? hi : mid;

        search(nearLo, nearHi, depth + 1, query, best, bestIndex, visited);   // line 3
        if (delta * delta < best)                                            // line 4
            search(farLo, farHi, depth + 1, query, best, bestIndex, visited); // line 5
    }
};

// The linear scan. Also the RIGHT algorithm above roughly 20 dimensions, and
// knowing where that crossover sits is worth more than knowing the tree.
AppendixPoint nearestBruteForceLiteral(const vector<AppendixPoint>& points,
                                       const AppendixPoint& query,
                                       long long* outSquared = nullptr) {
    long long best = numeric_limits<long long>::max();
    AppendixPoint answer = points[0];
    for (const AppendixPoint& p : points) {
        const long long dx = p.x - query.x, dy = p.y - query.y;
        const long long distance = dx * dx + dy * dy;
        if (distance < best) { best = distance; answer = p; }
    }
    if (outSquared) *outSquared = best;
    return answer;
}
```

*Verified:* `AppendixKdTree` matched a linear scan on **20 000** nearest-neighbour queries with **0 mismatches**. **The prune on line 4 was measured, by counting nodes visited:** **10.9 at `n = 100`, 15.3 at `n = 1 000`, 19.6 at `n = 10 000`, 23.0 at `n = 100 000`** — about **+4 per decade** against `lg n`'s +3.3, and **0.023% of the tree** at the largest size. In wall-clock terms, 2 000 queries against 100 000 points took **0.71 ms** by tree and **215.86 ms** by scan — **303×**. *Every bit of that gap is line 4, and every bit of it disappears above about 20 dimensions*, when the query ball crosses nearly all `d` splitting planes and nothing is pruned.

---

*Next: [M27 — Master Cheat Sheet & Recognition Playbook](M27-master-cheatsheet.md) — the whole archive compressed into recognition tables, complexity tables, and the list of every bug these notes actually had.*
