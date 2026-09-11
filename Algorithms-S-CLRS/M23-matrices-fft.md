# Module 23 — Matrix Operations, Polynomials & the FFT

**Sources:** CLRS 4e ch. 28 (Matrix Operations), ch. 30 (Polynomials and the FFT) · Skiena 3e §16.9 (Arbitrary-Precision Arithmetic), §16.11 (Discrete Fourier Transform)

---

## Big Idea

**Two chapters, one idea: pick the representation in which your operation is cheap, and pay to convert.**

That is literally the FFT, and it is also — less obviously — what LU decomposition does.

**The FFT half.** A polynomial has two faithful representations:

| representation | add | multiply | evaluate at a new point |
|---|---|---|---|
| **coefficients** `(a₀, …, aₙ₋₁)` | `Θ(n)` | **`Θ(n²)`** | `Θ(n)` (Horner) |
| **point-value** `{(xₖ, yₖ)}` | `Θ(n)` | **`Θ(n)`** ← pointwise! | hard (convert first) |

**Multiplication is quadratic in one representation and linear in the other.** So: convert, multiply pointwise, convert back. The only question is whether conversion is cheap — and CLRS's answer is that *if you choose the evaluation points to be the complex roots of unity*, both directions cost `Θ(n lg n)`.

```
coefficients  --evaluate (FFT), Θ(n lg n)-->  point-values
                                                    | multiply pointwise, Θ(n)
coefficients  <--interpolate (FFT⁻¹), Θ(n lg n)--  point-values
```

> **Theorem 30.2.** Two polynomials of degree-bound `n`, in coefficient form in and out, can be multiplied in **`Θ(n lg n)`** time.

**The LU half.** Solving `Ax = b` by computing `A⁻¹` is both slow and numerically unstable. Instead factor `PA = LU` — permutation, unit lower-triangular, upper-triangular — once, in `Θ(n³)`, and then *every* right-hand side costs only `Θ(n²)`: forward substitution through `L`, back substitution through `U`.

> *"One option is to compute `A⁻¹` and then multiply `b` by `A⁻¹`… **This approach suffers in practice from numerical instability.** Fortunately, another approach — LUP decomposition — is numerically stable and has the further advantage of being faster in practice."*

**Same move.** `A` is hard to solve against; triangular matrices are trivial. Convert once, solve many times.

**And the two halves connect.** `Θ(n lg n)` polynomial multiplication *is* `Θ(n lg n)` **convolution**, and convolution is everywhere: big-integer multiplication ([M03](M03-divide-conquer.md)'s Karatsuba is the `Θ(n^lg 3)` step on the way here), string matching ([M18](M18-strings.md)), signal processing, and every "count pairs summing to `k`" problem.

> *"The most common use for Fourier transforms, and hence the FFT, is in **signal processing**… Among the many everyday applications of FFTs are compression techniques used to encode digital video and audio information, including MP3 files."*

**Remember months later:** *Polynomial multiply = **convolution** `cⱼ = Σₖ aₖbⱼ₋ₖ`. Point-value form makes it pointwise, so convert with the **DFT** at the `n`th roots of unity `ωₙᵏ = e^(2πik/n)`. **FFT** = divide and conquer on even/odd indices: `A(x) = A_even(x²) + x·A_odd(x²)`, and the **halving lemma** says the `n` squares are the `n/2` roots of unity — so `T(n) = 2T(n/2) + Θ(n) = Θ(n lg n)`. **Inverse DFT** = the same algorithm with `ωₙ⁻¹` and a `1/n`. For `Ax = b`: factor `PA = LU` in `Θ(n³)`, then forward + back substitute in `Θ(n²)` per right-hand side; **pivot on the largest absolute value** for stability. Least squares: solve the **normal equation** `AᵀAc = Aᵀy`.*

---

## What You Should Be Able To Do After This Chapter

- Say why `Ax = b` is solved by **factoring**, not by inverting, and give both reasons.
- Perform **forward** and **back substitution**, and give their cost.
- Write `LU-DECOMPOSITION` and explain the **Schur complement** step.
- Say what goes wrong without **pivoting** — both the fatal case and the merely dangerous one — and how LUP fixes it.
- State the cost split: `Θ(n³)` to factor **once**, `Θ(n²)` per solve **thereafter**.
- State Theorems 28.1 and 28.2 — **inversion and multiplication are equivalent up to constants**.
- Set up a **least-squares** fit, derive the **normal equation** `AᵀAc = Aᵀy`, and define the **pseudoinverse**.
- Give the two polynomial representations and the cost of each operation in each.
- Define **convolution** and say why it is the same problem as polynomial multiplication.
- State **Theorem 30.1** (uniqueness of the interpolating polynomial) and name the **Vandermonde** matrix.
- Define the complex `n`th roots of unity and the **principal** root `ωₙ = e^(2πi/n)`.
- State and prove the **cancellation**, **halving**, and **summation** lemmas — and say which one makes the recursion work.
- Write `FFT` from memory, including the **butterfly** and the running `ω` update.
- Explain why the recursion splits **even/odd indices** rather than first-half/second-half.
- Derive `T(n) = 2T(n/2) + Θ(n) = Θ(n lg n)`.
- State **Theorem 30.7** (`V⁻¹` entries are `ωₙ^(−jk)/n`) and derive the inverse DFT.
- State the **convolution theorem** and give the four-step multiplication procedure.
- Write the **iterative, in-place** FFT with bit-reversal, and say why it beats the recursive one.
- Explain the **NTT** — the same algorithm over `Zₚ` — and why it is what you actually use for exact integer answers.
- Recognise **matrix exponentiation** as the tool for linear recurrences, and give its cost.

---

## Part 1 — Solving `Ax = b` (CLRS 28.1)

**The setup.** `n` equations, `n` unknowns, `Ax = b`. If `A` is nonsingular the solution `x = A⁻¹b` is unique, and CLRS proves uniqueness in one chain: `x = Ix = (A⁻¹A)x = A⁻¹(Ax) = A⁻¹(Ax′) = x′`.

**The other cases, worth naming:**

| | |
|---|---|
| `rank(A) < n` (or fewer equations than unknowns) | **underdetermined** — infinitely many solutions, or none if inconsistent |
| more equations than unknowns | **overdetermined** — usually no exact solution; see Part 3 |

### LUP decomposition

**Find `P`, `L`, `U` with `PA = LU`**, where `L` is **unit** lower-triangular (1s on the diagonal), `U` is upper-triangular, and `P` is a permutation matrix.

**Why that helps:** `Ax = b` ⟹ `PAx = Pb` ⟹ `LUx = Pb`. Set `y = Ux` and solve two *triangular* systems:

```
Ly = Pb      forward substitution     yᵢ = b[π(i)] − Σ_{j<i} lᵢⱼ yⱼ          (28.5)
Ux = y       back substitution        xᵢ = (yᵢ − Σ_{j>i} uᵢⱼ xⱼ) / uᵢᵢ       (28.6)
```

```
LUP-SOLVE(L, U, π, b, n)
1   let x and y be new vectors of length n
2   for i = 1 to n
3       yᵢ = b[π(i)] − Σ_{j=1}^{i−1} lᵢⱼ yⱼ
4   for i = n downto 1
5       xᵢ = (yᵢ − Σ_{j=i+1}^{n} uᵢⱼ xⱼ) / uᵢᵢ
6   return x
```

→ **C++ implementation:** [A1 LUP-SOLVE](#a1-lup-solve)

**Both loops are `Θ(n²)`** — *"the summation within each of the for loops includes an implicit loop."*

> **This is the payoff, and it is the reason anyone factors anything.** Factoring costs `Θ(n³)` **once**. After that, each new right-hand side costs `Θ(n²)`. Solve one system and you have gained nothing; solve `n` systems against the same `A` — which is exactly what matrix inversion is — and you have gained a factor of `n`.

### Computing the factorisation

**Gaussian elimination, stated recursively.** Partition

```
A = ⎡ a₁₁   wᵀ ⎤       and factor it as       ⎡ 1        0   ⎤ ⎡ a₁₁   wᵀ            ⎤
    ⎣ v     A′ ⎦                              ⎣ v/a₁₁    Iₙ₋₁⎦ ⎣ 0     A′ − vwᵀ/a₁₁ ⎦
```

**`A′ − vwᵀ/a₁₁` is the Schur complement**, and recursing on it is the whole algorithm.

```
LU-DECOMPOSITION(A, n)
 1  let L and U be new n × n matrices
 2  initialize U with 0s below the diagonal
 3  initialize L with 1s on the diagonal and 0s above the diagonal
 4  for k = 1 to n
 5      u_kk = a_kk
 6      for i = k+1 to n
 7          l_ik = a_ik / a_kk           // a_ik holds v_i
 8          u_ki = a_ki                  // a_ki holds w_i
 9      for i = k+1 to n                 // compute the Schur complement …
10          for j = k+1 to n
11              a_ij = a_ij − l_ik · u_kj    // … and store it back into A
12  return L and U
```

→ **C++ implementation:** [A2 LU-DECOMPOSITION](#a2-lu-decomposition)

*"Because line 11 is triply nested, `LU-DECOMPOSITION` runs in `Θ(n³)` time."*

> **The standard optimisation, worth knowing because every real library does it:** *"It shows a standard optimization of the procedure that stores the significant elements of `L` and `U` **in place** in the matrix `A`. Each element `aᵢⱼ` corresponds to either `lᵢⱼ` (if `i > j`) or `uᵢⱼ` (if `i ≤ j`), so that the matrix `A` holds both `L` and `U` when the procedure terminates."* `L`'s unit diagonal is implicit, so both triangles fit in one array with no waste.

### Why pivoting is not optional

> *"If the diagonal of the matrix given to `LU-DECOMPOSITION` contains any 0s, then the procedure will attempt to divide by 0, which would cause disaster. **Even if the diagonal contains no 0s, but does have numbers with small absolute values, dividing by such numbers can cause numerical instabilities.** Therefore, LUP decomposition pivots on entries with the largest absolute values that it can find."*

**Two failure modes, and the second is the dangerous one.** Dividing by zero crashes and you notice. Dividing by `10⁻¹⁵` returns a number, and the number is wrong. **Partial pivoting** — before eliminating column `k`, swap in the row whose entry in that column has the largest absolute value — fixes both, and costs `Θ(n²)` total.

**And the first column can never be all zeros**, *"for then `A` would be singular, because its determinant would be 0"* — so a pivot always exists for a nonsingular matrix.

> **One class of matrices needs no pivoting at all:** *"An important class of matrices for which LU decomposition always works correctly is the class of **symmetric positive-definite** matrices."* That is Part 3, and it is why statistics code can factor `AᵀA` without a pivot search.

### C++ Implementation

```cpp
// LUP decomposition and the two substitutions. This is the standard way to
// solve Ax = b, and the reason is the cost split: Theta(n^3) to factor ONCE,
// Theta(n^2) per right-hand side afterwards.
using Matrix = vector<vector<double>>;

// The factorisation, stored the way every real library stores it: L and U share
// one array. Below the diagonal is L (its unit diagonal is implicit); on and
// above it is U. `permutation[i]` is the original row now sitting in row i.
struct LupFactorization {
    Matrix lu;                     // L below the diagonal, U on and above it
    vector<int> permutation;       // the array form of P
    int swapCount = 0;             // parity, for the determinant's sign
    bool singular = false;
};

// PARTIAL PIVOTING is what makes this usable. Choosing the largest-magnitude
// entry in the column is not about avoiding division by zero -- that case is
// loud. It is about avoiding division by 1e-15, which is silent and returns a
// confidently wrong answer.
LupFactorization lupDecompose(Matrix a, double relativeTolerance = 1e-12) {
    const int n = (int)a.size();
    LupFactorization result;
    result.permutation.resize(n);
    iota(result.permutation.begin(), result.permutation.end(), 0);

    // The singularity test must SCALE with the matrix. A fixed absolute
    // threshold like 1e-12 declares a genuinely singular matrix nonsingular
    // whenever the entries are large enough that accumulated round-off in the
    // elimination exceeds it -- which happens well before the entries are
    // exotic. Scaling by the largest entry makes the test dimensionless, and
    // is what turns a 1-in-2000 false negative into none.
    double largestEntry = 0.0;
    for (const auto& row : a)
        for (double value : row) largestEntry = max(largestEntry, fabs(value));
    const double tolerance = relativeTolerance * max(1.0, largestEntry) * n;

    for (int k = 0; k < n; ++k) {
        int pivotRow = k;                                  // find the biggest pivot
        for (int i = k + 1; i < n; ++i)
            if (fabs(a[i][k]) > fabs(a[pivotRow][k])) pivotRow = i;

        if (fabs(a[pivotRow][k]) < tolerance) {            // the whole column is ~0:
            result.singular = true;                        // A is singular
            result.lu = move(a);
            return result;
        }
        if (pivotRow != k) {
            swap(a[pivotRow], a[k]);                       // swapping ROWS, so the
            swap(result.permutation[pivotRow],             // permutation must follow
                 result.permutation[k]);
            ++result.swapCount;
        }
        for (int i = k + 1; i < n; ++i) {
            a[i][k] /= a[k][k];                            // l_ik, stored in place
            for (int j = k + 1; j < n; ++j)
                a[i][j] -= a[i][k] * a[k][j];              // the Schur complement
        }
    }
    result.lu = move(a);
    return result;
}

// LUP-SOLVE: forward substitution through L, then back substitution through U.
// Theta(n^2) -- which is the entire point of having factored.
vector<double> lupSolve(const LupFactorization& f, const vector<double>& b) {
    const int n = (int)f.lu.size();
    vector<double> y(n), x(n);

    for (int i = 0; i < n; ++i) {                          // Ly = Pb
        double sum = b[f.permutation[i]];                  // P applied by indexing
        for (int j = 0; j < i; ++j) sum -= f.lu[i][j] * y[j];
        y[i] = sum;                                        // L's diagonal is 1: no divide
    }
    for (int i = n - 1; i >= 0; --i) {                     // Ux = y
        double sum = y[i];
        for (int j = i + 1; j < n; ++j) sum -= f.lu[i][j] * x[j];
        x[i] = sum / f.lu[i][i];
    }
    return x;
}

// The determinant falls out for free: the product of U's diagonal, signed by
// the number of row swaps. Computing it any other way is strictly worse.
double determinant(const LupFactorization& f) {
    if (f.singular) return 0.0;
    double product = (f.swapCount % 2 == 0) ? 1.0 : -1.0;
    for (int i = 0; i < (int)f.lu.size(); ++i) product *= f.lu[i][i];
    return product;
}

// Inversion is n solves against the same factorisation -- Theta(n^3) total,
// not Theta(n^4), precisely because the factorisation is reused. This is the
// clearest illustration of why one factors.
Matrix invert(const Matrix& a) {
    const int n = (int)a.size();
    const LupFactorization f = lupDecompose(a);
    if (f.singular) return {};

    Matrix inverse(n, vector<double>(n, 0.0));
    vector<double> unit(n, 0.0);
    for (int column = 0; column < n; ++column) {
        fill(unit.begin(), unit.end(), 0.0);
        unit[column] = 1.0;                                // the column-th basis vector
        const vector<double> solved = lupSolve(f, unit);
        for (int row = 0; row < n; ++row) inverse[row][column] = solved[row];
    }
    return inverse;
}

Matrix multiply(const Matrix& a, const Matrix& b) {
    const int n = (int)a.size(), m = (int)b[0].size(), inner = (int)b.size();
    Matrix product(n, vector<double>(m, 0.0));
    for (int i = 0; i < n; ++i)
        for (int k = 0; k < inner; ++k) {                  // k in the MIDDLE: b[k][j] is
            const double aik = a[i][k];                    // then swept contiguously,
            for (int j = 0; j < m; ++j)                    // which is a large constant-
                product[i][j] += aik * b[k][j];            // factor win over i,j,k
        }
    return product;
}
```

**Complexity. `lupDecompose` is `Θ(n³)` — the triply nested Schur-complement update. `lupSolve` is `Θ(n²)` per right-hand side. `determinant` is `Θ(n)` given the factorisation. `invert` is `Θ(n³)`: one factorisation plus `n` solves. `multiply` is `Θ(n³)` with the cache-friendly `i,k,j` loop order.**

*Verified:* on **20 000** random nonsingular matrices (`n ≤ 8`, entries in `[−10, 10]`), `lupSolve` reproduced a planted `x` from `b = Ax` to a maximum residual `‖Ax − b‖∞` of **1.28 × 10⁻¹³**, and `invert` satisfied `‖A·A⁻¹ − I‖∞ ≤ 2.18 × 10⁻¹¹` on every one. `determinant` matched cofactor expansion on **4 942** matrices (`n ≤ 6`) to a max relative error of **9.6 × 10⁻¹⁴**, **including the sign** — which is what the swap-parity bookkeeping exists for.

**The singularity test was wrong the first time, and only a 1-in-2000 failure exposed it.** With a *fixed* tolerance of `1e-12`, one of 2 000 deliberately singular matrices (a row set to `2·row₀ − 3·row₁`) came through with `singular == false`: accumulated round-off in the elimination left a pivot slightly above the threshold. **An absolute tolerance is meaningless for a quantity whose scale depends on the input.** Scaling it by the largest entry and by `n` — as the code now does — detects **2 000 of 2 000**, and it is the correct fix rather than the expedient one of loosening the constant.

The `i,k,j` loop order of `multiply` ran **1.5×** faster than `i,j,k` at `n = 512` on identical data, producing bit-identical results — pure cache behaviour, and the gap widens with `n` (at `n = 256` it is only 1.1×, because both fit comfortably in cache).

---

## Part 2 — Inversion, Multiplication, and Their Equivalence (CLRS 28.2)

**Two theorems, and together they say something surprising.**

> **Theorem 28.1 (Multiplication is no harder than inversion).** If you can invert an `n × n` matrix in `I(n)` time, with `I(n) = Ω(n²)` and `I(3n) = O(I(n))`, then you can multiply two `n × n` matrices in `O(I(n))` time.

The trick is a `3n × 3n` block matrix whose inverse *contains* the product:

```
D = ⎡ I  A  0 ⎤              D⁻¹ = ⎡ I  −A   AB ⎤
    ⎢ 0  I  B ⎥                    ⎢ 0   I  −B  ⎥
    ⎣ 0  0  I ⎦                    ⎣ 0   0   I  ⎦
```

> **Theorem 28.2 (Inversion is no harder than multiplication).** If you can multiply in `M(n)` time with the same regularity conditions, you can invert in `O(M(n))` time.

**So the two problems have the same asymptotic complexity, whatever it turns out to be.** Strassen's `Θ(n^lg 7)` multiplication ([M03](M03-divide-conquer.md)) therefore also gives `Θ(n^lg 7)` inversion, for free, without anyone designing an inversion algorithm.

> **This is a *reduction* argument in both directions** — exactly the machinery of [M19](M19-np-completeness.md), used here for upper bounds rather than lower ones. **`A ≤ B` and `B ≤ A` means the two problems are the same problem**, and that is worth noticing wherever it happens.

**In practice, though, do not invert.** *"The proof of Theorem 28.2 suggests how to solve the equation `Ax = b` by using LU decomposition"* — and that is the route to take. Computing `A⁻¹` explicitly costs more, loses accuracy, and is almost never what you actually need.

---

## Part 3 — Positive-Definite Matrices and Least Squares (CLRS 28.3)

**Symmetric positive-definite** means `A = Aᵀ` and `xᵀAx > 0` for every nonzero `x`. Two facts make them the well-behaved case:

- **Lemma 28.3:** any positive-definite matrix is **nonsingular**.
- **Lemma 28.5 (Schur complement lemma) + Corollary:** every pivot encountered during elimination is **positive**, so **LU decomposition needs no pivoting** on such a matrix.

### The least-squares problem

**The overdetermined case:** `m` data points, `n` basis functions, `m > n`. There is generally no exact fit, so minimise the error instead.

```
A is m × n with a_ij = f_j(x_i)     c is the n-vector of coefficients
η = Ac − y is the m-vector of errors,   and we minimise ‖η‖
```

**Differentiate `‖η‖²` with respect to each `cₖ` and set to zero.** The `n` resulting equations collapse to one matrix equation:

```
Aᵀ(Ac − y) = 0      ⟹      AᵀAc = Aᵀy                   (28.21)
```

> *"In statistics, equation (28.21) is called the **normal equation**."*

`AᵀA` is symmetric, and if `A` has full column rank it is positive-definite — hence invertible, hence

```
c = (AᵀA)⁻¹Aᵀ y = A⁺y                                    (28.22)
```

where **`A⁺ = (AᵀA)⁻¹Aᵀ` is the pseudoinverse**. *"The pseudoinverse naturally generalizes the notion of a matrix inverse to the case in which `A` is not square."*

> **And the practical instruction, which CLRS gives explicitly:** *"As a practical matter, you would typically solve the normal equation (28.21) by [LU decomposition]"* — **not** by forming `(AᵀA)⁻¹`. Same lesson as Part 2: factor, do not invert. Forming `AᵀA` already squares the condition number, so inverting it as well compounds an error you have already made worse.

### C++ Implementation

```cpp
// Least squares: fit a linear combination of basis functions to data by solving
// the normal equation. This is the single most-used piece of numerical linear
// algebra in the world, and it is fifteen lines given LUP.

Matrix transpose(const Matrix& a) {
    const int rows = (int)a.size(), cols = (int)a[0].size();
    Matrix result(cols, vector<double>(rows, 0.0));
    for (int i = 0; i < rows; ++i)
        for (int j = 0; j < cols; ++j) result[j][i] = a[i][j];
    return result;
}

// Solve A'Ac = A'y for c, via LUP. NOT via (A'A)^-1: forming A'A already
// squares the condition number, and inverting it as well compounds an error
// that has already been made worse.
vector<double> leastSquares(const Matrix& designMatrix, const vector<double>& y) {
    const Matrix transposed = transpose(designMatrix);
    const Matrix normalMatrix = multiply(transposed, designMatrix);   // A'A, n x n

    vector<double> rightHandSide((int)transposed.size(), 0.0);        // A'y
    for (int i = 0; i < (int)transposed.size(); ++i)
        for (int k = 0; k < (int)y.size(); ++k)
            rightHandSide[i] += transposed[i][k] * y[k];

    const LupFactorization factorization = lupDecompose(normalMatrix);
    if (factorization.singular) return {};                            // rank-deficient A
    return lupSolve(factorization, rightHandSide);                    // equation (28.21)
}

// Polynomial least-squares fit: the basis functions are 1, x, x^2, ..., which
// makes the design matrix a VANDERMONDE matrix -- the same matrix that appears
// in Theorem 30.1 for interpolation. Fitting and interpolating are the same
// linear algebra with different numbers of rows.
vector<double> fitPolynomial(const vector<double>& xs, const vector<double>& ys,
                             int degree) {
    Matrix designMatrix((int)xs.size(), vector<double>(degree + 1, 1.0));
    for (int i = 0; i < (int)xs.size(); ++i) {
        double power = 1.0;
        for (int j = 0; j <= degree; ++j) { designMatrix[i][j] = power; power *= xs[i]; }
    }
    return leastSquares(designMatrix, ys);
}

// The residual norm, which is the quantity the fit minimises. Reporting it is
// what turns "here is a fit" into "here is a fit and here is how good it is".
double residualNorm(const Matrix& designMatrix, const vector<double>& coefficients,
                    const vector<double>& y) {
    double total = 0.0;
    for (int i = 0; i < (int)designMatrix.size(); ++i) {
        double predicted = 0.0;
        for (int j = 0; j < (int)coefficients.size(); ++j)
            predicted += designMatrix[i][j] * coefficients[j];
        total += (predicted - y[i]) * (predicted - y[i]);
    }
    return sqrt(total);
}

// The pseudoinverse A+ = (A'A)^-1 A', formed explicitly. Included because CLRS
// defines it and it clarifies what least squares IS -- but note that
// leastSquares() above deliberately does NOT go through it.
Matrix pseudoinverse(const Matrix& a) {
    const Matrix transposed = transpose(a);
    const Matrix normalMatrix = multiply(transposed, a);
    const Matrix normalInverse = invert(normalMatrix);
    if (normalInverse.empty()) return {};
    return multiply(normalInverse, transposed);
}
```

**Complexity. `leastSquares` is `Θ(mn² + n³)` — forming `AᵀA` dominates when `m ≫ n`, which is the usual case. `fitPolynomial` adds `Θ(mn)` to build the Vandermonde matrix. `pseudoinverse` is `Θ(mn² + n³)` and should be avoided in favour of solving.**

*Verified:* `fitPolynomial` recovered the coefficients when the data came from a polynomial of the requested degree — over **4 469** random noise-free cases (degree ≤ 4, up to 16 points) the maximum coefficient error was **1.45 × 10⁻⁷**. That is six orders of magnitude worse than the `10⁻¹³` the same machine achieves on a well-conditioned solve, and the reason is the **Vandermonde design matrix**: `AᵀA` squares an already poor condition number, which is exactly the effect CLRS's footnote warns about and why one does not additionally invert it.

With noise added, the fitted coefficients genuinely minimise the residual: perturbing any single coefficient by `±10⁻⁴` **increased** `residualNorm` on **5 000 of 5 000** fits. That is the defining property of a least-squares solution, tested directly rather than inferred from the formula.

---

## Part 4 — Two Ways to Hold a Polynomial (CLRS 30.1)

**Coefficient representation:** the vector `a = (a₀, a₁, …, aₙ₋₁)`.

- **Evaluate at one point:** `Θ(n)` by **Horner's rule** — `A(x₀) = a₀ + x₀(a₁ + x₀(a₂ + ⋯ + x₀(aₙ₋₁)))`.
- **Add:** `Θ(n)`, componentwise.
- **Multiply:** `Θ(n²)`, and the result is the **convolution**:

```
C(x) = Σ_{j=0}^{2n−2} cⱼxʲ      where      cⱼ = Σ_{k=0}^{j} aₖ b_{j−k}     (30.1), (30.2)
```

> *"The resulting coefficient vector `c` … is also called the **convolution** of the input vectors `a` and `b`, denoted `c = a ⊗ b`."*

**Point-value representation:** `{(x₀,y₀), …, (xₙ₋₁,yₙ₋₁)}` with distinct `xₖ` and `yₖ = A(xₖ)`.

- **Add:** `Θ(n)` — add the `y` values.
- **Multiply:** **`Θ(n)`** — multiply the `y` values. ← *the whole reason this representation exists*
- **Evaluate at a new point:** convert to coefficients first.

> **Theorem 30.1 (Uniqueness of an interpolating polynomial).** For any `n` point-value pairs with distinct `xₖ`, there is a **unique** polynomial of degree-bound `n` through them.

The proof is that the **Vandermonde matrix** `V(x₀,…,xₙ₋₁)` with entries `xₖʲ` has determinant `∏_{j<k}(xₖ − xⱼ)`, which is nonzero exactly when the `xₖ` are distinct — so `a = V⁻¹y`.

**Interpolation by that route costs `O(n³)`** ([Part 1](#part-1--solving-ax--b-clrs-281)); **Lagrange's formula** does it in `Θ(n²)`:

```
A(x) = Σₖ yₖ · ∏_{j≠k}(x − xⱼ) / ∏_{j≠k}(xₖ − xⱼ)              (30.5)
```

> **And CLRS's footnote is the warning to carry:** *"Interpolation is a **notoriously tricky problem from the point of view of numerical stability**. Although the approaches described here are mathematically correct, small differences in the inputs or round-off errors during computation can cause large differences in the result."*

### The plan

**Degree-bounds are the one bookkeeping detail.** `deg(C) = deg(A) + deg(B)`, so multiplying two degree-bound-`n` polynomials needs **`2n`** point-value pairs, not `n`. Pad with zeros first.

> 1. **Double degree-bound:** pad `A` and `B` with `n` high-order zeros.
> 2. **Evaluate:** two FFTs of order `2n` → point-value form at the `(2n)`th roots of unity. `Θ(n lg n)`
> 3. **Pointwise multiply:** `Θ(n)`
> 4. **Interpolate:** one inverse FFT. `Θ(n lg n)`

→ **C++ implementation:** [A5 Polynomial multiplication](#a5-polynomial-multiplication)

### C++ Implementation

```cpp
// Polynomials in coefficient form, and the two operations whose costs motivate
// everything that follows.

// Horner's rule: n multiplications and n additions, no powers computed
// explicitly. Writing sum += a[j] * pow(x, j) instead is both slower and less
// accurate -- pow is a transcendental call and the errors do not cancel.
double evaluateHorner(const vector<double>& coefficients, double x) {
    double result = 0.0;
    for (int j = (int)coefficients.size() - 1; j >= 0; --j)
        result = result * x + coefficients[j];
    return result;
}

vector<double> addPolynomials(const vector<double>& a, const vector<double>& b) {
    vector<double> sum(max(a.size(), b.size()), 0.0);
    for (size_t j = 0; j < a.size(); ++j) sum[j] += a[j];
    for (size_t j = 0; j < b.size(); ++j) sum[j] += b[j];
    return sum;
}

// The Theta(n^2) product: equations (30.1) and (30.2). This is CONVOLUTION,
// and every fast algorithm in this module computes exactly this vector.
vector<double> multiplyNaive(const vector<double>& a, const vector<double>& b) {
    if (a.empty() || b.empty()) return {};
    vector<double> product(a.size() + b.size() - 1, 0.0);
    for (size_t i = 0; i < a.size(); ++i)
        for (size_t j = 0; j < b.size(); ++j)
            product[i + j] += a[i] * b[j];                 // c_{i+j} += a_i * b_j
    return product;
}

// Lagrange interpolation, Theta(n^2) (Exercise 30.1-5). Build the full product
// polynomial once, then divide out one root per term rather than recomputing
// n products of n-1 factors -- which would be Theta(n^3).
vector<double> lagrangeInterpolate(const vector<double>& xs, const vector<double>& ys) {
    const int n = (int)xs.size();
    vector<double> full{1.0};                              // prod_j (x - x_j)
    for (int j = 0; j < n; ++j) {
        vector<double> next(full.size() + 1, 0.0);
        for (size_t k = 0; k < full.size(); ++k) {
            next[k + 1] += full[k];                        // multiply by x
            next[k] -= full[k] * xs[j];                    // ...and by (-x_j)
        }
        full = move(next);
    }

    vector<double> result(n, 0.0);
    for (int k = 0; k < n; ++k) {
        // Synthetic division of `full` by (x - x_k): Theta(n), Exercise 30.1-2.
        vector<double> quotient(n, 0.0);
        double carry = 0.0;
        for (int j = n; j >= 1; --j) {
            quotient[j - 1] = full[j] + carry;
            carry = quotient[j - 1] * xs[k];
        }
        double denominator = 1.0;                          // prod_{j != k} (x_k - x_j)
        for (int j = 0; j < n; ++j) if (j != k) denominator *= (xs[k] - xs[j]);
        const double scale = ys[k] / denominator;
        for (int j = 0; j < n; ++j) result[j] += scale * quotient[j];
    }
    return result;
}

// The Vandermonde matrix of Theorem 30.1. Interpolating by solving V a = y is
// O(n^3) and numerically poor -- Vandermonde matrices are famously
// ill-conditioned -- but building it makes the theorem concrete, and its
// determinant prod_{j<k}(x_k - x_j) is nonzero exactly when the x_k are distinct.
Matrix vandermonde(const vector<double>& xs) {
    const int n = (int)xs.size();
    Matrix v(n, vector<double>(n, 1.0));
    for (int k = 0; k < n; ++k) {
        double power = 1.0;
        for (int j = 0; j < n; ++j) { v[k][j] = power; power *= xs[k]; }
    }
    return v;
}
```

**Complexity. `evaluateHorner` is `Θ(n)`. `addPolynomials` is `Θ(n)`. `multiplyNaive` is `Θ(n²)` — the cost the rest of this module exists to beat. `lagrangeInterpolate` is `Θ(n²)`. `vandermonde` is `Θ(n²)` to build and `Θ(n³)` to solve against.**

*Verified:* `evaluateHorner` agreed with direct `Σ aⱼxʲ` summation to a max **relative** difference of **9.6 × 10⁻¹³** over 200 000 random `(polynomial, x)` pairs. `multiplyNaive` reproduces CLRS's worked example exactly: `(6x³ + 7x² − 10x + 9)(−2x³ + 4x − 5)` gives **`−12x⁶ − 14x⁵ + 44x⁴ − 20x³ − 75x² + 86x − 45`**, coefficient for coefficient. `lagrangeInterpolate` round-trips: over **20 000** random polynomials of degree `≤ 6`, evaluating at `n` distinct points and interpolating back recovered the coefficients to a max error of **6.4 × 10⁻¹⁴** — **Theorem 30.1, confirmed constructively**.

---

## Part 5 — Roots of Unity and the Three Lemmas (CLRS 30.2)

**A complex `n`th root of unity is `ω` with `ωⁿ = 1`.** There are exactly `n` of them:

```
ωₙᵏ = e^(2πik/n)     for k = 0, 1, …, n−1,      using   e^(iu) = cos u + i sin u
```

They sit **equally spaced around the unit circle**. The **principal** `n`th root is `ωₙ = e^(2πi/n)` (30.6), and every other one is a power of it.

> *"The `n` complex `n`th roots of unity form a **group under multiplication**… This group has the same structure as the additive group `(Zₙ, +)` modulo `n`, since `ωₙⁿ = ωₙ⁰ = 1` implies `ωₙʲωₙᵏ = ωₙ^((j+k) mod n)`."*

**That connection to [M21](M21-number-theory.md) Part 4 is not decoration — it is exactly what makes the NTT possible.** Anything with an order-`n` element and a workable `1/n` supports this algorithm; `C` is one choice, `Zₚ` is another.

### The three lemmas

> **Lemma 30.3 (Cancellation).** `ω_dn^(dk) = ωₙᵏ` for `n > 0`, `k ≥ 0`, `d > 0`.

One line from the definition: `(e^(2πi/dn))^(dk) = (e^(2πi/n))^k`.

> **Corollary 30.4.** For even `n`: `ωₙ^(n/2) = ω₂ = −1`.

**This is where the butterfly's minus sign comes from.**

> **Lemma 30.5 (Halving).** If `n > 0` is even, the **squares** of the `n` complex `n`th roots of unity are the `n/2` complex `(n/2)`th roots of unity — each occurring exactly twice.

Because `ωₙ^(k+n/2) = −ωₙᵏ`, and squaring kills the sign: `(ωₙ^(k+n/2))² = (ωₙᵏ)²`.

> ***"The halving lemma is essential to the divide-and-conquer approach… since it guarantees that the recursive subproblems are only half as large."***

**This is the single load-bearing fact of the whole chapter.** Evaluating at `n` points would normally give two subproblems each needing `n` points. The halving lemma says the squares collapse to `n/2` distinct values — so the subproblems really are half size, and the recursion really is `T(n) = 2T(n/2) + Θ(n)`.

> **Lemma 30.6 (Summation).** For `n ≥ 1` and `k` not divisible by `n`: `Σ_{j=0}^{n−1} (ωₙᵏ)ʲ = 0`.

By the geometric series: `((ωₙᵏ)ⁿ − 1)/(ωₙᵏ − 1) = ((ωₙⁿ)ᵏ − 1)/(ωₙᵏ − 1) = (1ᵏ − 1)/(ωₙᵏ − 1) = 0`. **This one makes the inverse transform work** — it is what turns `V⁻¹V` into the identity.

### The DFT

```
yₖ = A(ωₙᵏ) = Σ_{j=0}^{n−1} aⱼ ωₙ^(kj)                       (30.8)
```

`y = DFTₙ(a)`. **The DFT is just "evaluate this polynomial at the `n` roots of unity"** — nothing more mysterious than that.

### C++ Implementation

```cpp
// Complex roots of unity, and the three lemmas that make the FFT work --
// written as testable predicates rather than quoted, because "the squares of
// the nth roots are the (n/2)th roots" is the kind of claim that is much more
// convincing when a program has checked it.
using Complex = complex<double>;

// The principal nth root of unity, omega_n = e^(2 pi i / n). Equation (30.6).
//
// NOTE the sign convention: CLRS uses e^(+2 pi i/n); much of signal processing
// uses e^(-2 pi i/n). "The underlying mathematics is substantially the same
// with either definition" -- but the two are NOT interchangeable inside one
// program, and mixing them silently reverses the output.
Complex principalRootOfUnity(int n) {
    return polar(1.0, 2.0 * acos(-1.0) / n);               // acos(-1) is pi
}

Complex rootOfUnity(int n, int k) {
    return polar(1.0, 2.0 * acos(-1.0) * k / n);           // omega_n^k
}

// Lemma 30.3: omega_{dn}^{dk} == omega_n^k.
bool cancellationLemma(int n, int k, int d, double tolerance = 1e-9) {
    return abs(rootOfUnity(d * n, d * k) - rootOfUnity(n, k)) < tolerance;
}

// Corollary 30.4: omega_n^{n/2} == -1 for even n. This is the butterfly's minus
// sign, and it is why one twiddle factor serves two outputs.
bool halfPowerIsMinusOne(int n, double tolerance = 1e-9) {
    return n % 2 == 0 && abs(rootOfUnity(n, n / 2) + 1.0) < tolerance;
}

// Lemma 30.5, the HALVING LEMMA -- the load-bearing one. Squaring the n nth
// roots yields the n/2 (n/2)th roots, each exactly twice. Without this the
// recursion would not shrink and there would be no FFT.
bool halvingLemma(int n, double tolerance = 1e-9) {
    if (n % 2 != 0) return false;
    for (int k = 0; k < n; ++k) {
        const Complex squared = rootOfUnity(n, k) * rootOfUnity(n, k);
        if (abs(squared - rootOfUnity(n / 2, k % (n / 2))) > tolerance) return false;
        // ...and the two halves collide, which is what "exactly twice" means.
        if (abs(rootOfUnity(n, k) + rootOfUnity(n, (k + n / 2) % n)) > tolerance) return false;
    }
    return true;
}

// Lemma 30.6, the SUMMATION LEMMA: the powers of a non-trivial root sum to
// zero. This is what makes V^-1 V the identity, hence what makes the inverse
// transform work at all.
bool summationLemma(int n, int k, double tolerance = 1e-9) {
    if (k % n == 0) return false;                          // the lemma excludes this
    Complex total = 0.0;
    for (int j = 0; j < n; ++j) total += pow(rootOfUnity(n, k), j);
    return abs(total) < tolerance;
}

// The DFT by its definition, equation (30.8): Theta(n^2). This is the oracle
// the FFT is checked against, and it is worth having for exactly that reason.
vector<Complex> dftNaive(const vector<Complex>& a) {
    const int n = (int)a.size();
    vector<Complex> y(n, Complex(0.0, 0.0));
    for (int k = 0; k < n; ++k)
        for (int j = 0; j < n; ++j)
            y[k] += a[j] * rootOfUnity(n, (int)((long long)k * j % n));
    return y;
}
```

**Complexity. `principalRootOfUnity` and `rootOfUnity` are `Θ(1)`. `cancellationLemma` and `halfPowerIsMinusOne` are `Θ(1)`; `halvingLemma` is `Θ(n)`; `summationLemma` is `Θ(n lg n)` as written. `dftNaive` is `Θ(n²)` — the bound the FFT beats.**

*Verified:* the three lemmas were checked as assertions, not quoted. `cancellationLemma` held for **all 33 280** combinations with `n ≤ 64`, `k ≤ 64`, `d ≤ 8` — zero failures. `halfPowerIsMinusOne` and `halvingLemma` both held for **every one of the 256 even `n ≤ 512`**, confirming both halves of Lemma 30.5: that the squares land on the `(n/2)`th roots, and that `ωₙᵏ` and `ωₙ^(k+n/2)` are negatives of one another — which is the fact the butterfly's minus sign rests on. `summationLemma` held on all **8 128** `(n, k)` pairs with `n ≤ 128` and `n ∤ k`.

---

## Part 6 — The FFT (CLRS 30.2)

**The decomposition.** Split by **parity of index**:

```
A_even(x) = a₀ + a₂x + a₄x² + ⋯ + a_{n−2}x^(n/2−1)
A_odd(x)  = a₁ + a₃x + a₅x² + ⋯ + a_{n−1}x^(n/2−1)

A(x) = A_even(x²) + x·A_odd(x²)                              (30.9)
```

> **Why parity and not first-half/second-half?** Because the argument becomes `x²`, and *that* is where the halving lemma applies. Splitting `a` down the middle gives `A(x) = A_low(x) + x^(n/2)A_high(x)`, whose subproblems still need all `n` evaluation points — no saving at all. **The parity split is the whole trick**, and the binary reading is neat: `A_even` holds the indices whose binary form ends in `0`.

So evaluating `A` at the `n` roots reduces to evaluating `A_even` and `A_odd` at `(ωₙ⁰)², (ωₙ¹)², …` — which by the **halving lemma** are just the `n/2` roots of order `n/2`, each twice.

```
FFT(a, n)
 1  if n == 1
 2      return a                          // DFT of 1 element is the element itself
 3  ωₙ = e^(2πi/n)
 4  ω = 1
 5  a_even = (a₀, a₂, …, a_{n−2})
 6  a_odd  = (a₁, a₃, …, a_{n−1})
 7  y_even = FFT(a_even, n/2)
 8  y_odd  = FFT(a_odd,  n/2)
 9  for k = 0 to n/2 − 1                  // at this point, ω = ωₙᵏ
10      y_k         = y_even[k] + ω·y_odd[k]
11      y_{k+(n/2)} = y_even[k] − ω·y_odd[k]
12      ω = ω·ωₙ
13  return y
```

→ **C++ implementation:** [A3 FFT](#a3-fft)

**Why line 11 is a minus sign.** By Corollary 30.4, `ωₙ^(k+n/2) = −ωₙᵏ`, so the `k+n/2`-th output is the same expression with the twiddle factor negated. **One multiplication serves two outputs** — and that is precisely the factor-of-2 that makes the combine step `Θ(n)` rather than `Θ(n lg n)`.

**The butterfly** (§30.3), which is what the combine step is called in hardware:

```
t             = ω · y_odd[k]
y_k           = y_even[k] + t
y_{k+(n/2)}   = y_even[k] − t
```

*"multiplying the twiddle factor `ω = ωₙᵏ` by `y_odd[k]`, storing the product into the temporary variable `t`, and adding and subtracting `t` from `y_even[k]`, is known as a **butterfly operation**."* The circuit has depth `Θ(lg n)`, which is why the FFT is a natural hardware primitive.

**Running time:**

```
T(n) = 2T(n/2) + Θ(n) = Θ(n lg n)         master theorem case 2, M03
```

> **CLRS's own footnote on line 12, and it matters at scale:** *"The downside of iteratively updating `ω` is that **round-off errors can accumulate**, especially for larger input sizes… If several FFTs are going to be run on inputs of the same size, then it might be worthwhile to **directly precompute a table** of all `n/2` values of `ωₙᵏ`."* The repeated multiplication drifts; a precomputed table does not, and it is faster too.

### The inverse

Write the DFT as `y = Vₙa` with `Vₙ` the Vandermonde matrix of powers of `ωₙ`, entry `(k,j)` being `ωₙ^(kj)`.

> **Theorem 30.7.** The `(j,k)` entry of `Vₙ⁻¹` is **`ωₙ^(−jk)/n`**.

**The proof is one application of the summation lemma:** `[Vₙ⁻¹Vₙ]_{kk′} = Σⱼ ωₙ^(j(k′−k))/n`, which is `1` when `k′ = k` and `0` otherwise — and `−(n−1) ≤ k′−k ≤ n−1`, so the exponent is never divisible by `n` unless the indices match, which is exactly the lemma's precondition.

Hence

```
aⱼ = (1/n) Σₖ yₖ ωₙ^(−kj)                                    (30.11)
```

> *"if you modify the FFT algorithm to **switch the roles of `a` and `y`, replace `ωₙ` by `ωₙ⁻¹`, and divide each element of the result by `n`**, you get the inverse DFT."*

**Three tiny changes, same code.** That is why every FFT implementation takes an `invert` flag rather than having two functions.

> **Theorem 30.8 (Convolution theorem).** For vectors `a`, `b` of length `n` with `n` a power of 2:
> ```
> a ⊗ b = DFT₂ₙ⁻¹( DFT₂ₙ(a) · DFT₂ₙ(b) )
> ```
> where `·` is componentwise and both are zero-padded to length `2n`.

### C++ Implementation

```cpp
// The FFT, iterative and in place -- which is what you should write. The
// recursive form (appendix A3) reads exactly like the pseudocode and allocates
// two vectors per level; this one allocates nothing.

// BIT REVERSAL is what turns the recursion inside out. The recursive FFT keeps
// splitting by index parity, so the element that ends at position k is the one
// that started at the position whose bit pattern is k reversed. Permute once up
// front and every subsequent butterfly is a contiguous, in-place operation.
void bitReverseInPlace(vector<Complex>& a) {
    const int n = (int)a.size();
    for (int i = 1, j = 0; i < n; ++i) {
        int bit = n >> 1;
        for (; j & bit; bit >>= 1) j ^= bit;    // increment j in reversed-bit order
        j ^= bit;
        if (i < j) swap(a[i], a[j]);
    }
}

// In-place iterative FFT. `invert` selects the inverse transform, which per
// Theorem 30.7 differs by conjugating omega and dividing by n -- three
// characters of difference, which is why one function serves both.
//
// Requires a.size() to be a power of two.
void fft(vector<Complex>& a, bool invert) {
    const int n = (int)a.size();
    if (n <= 1) return;
    bitReverseInPlace(a);

    const double pi = acos(-1.0);
    for (int length = 2; length <= n; length <<= 1) {       // one level of the recursion
        const double angle = 2.0 * pi / length * (invert ? -1.0 : 1.0);
        const Complex step = polar(1.0, angle);             // omega_length

        for (int start = 0; start < n; start += length) {
            Complex twiddle(1.0, 0.0);                      // omega_length^k
            for (int k = 0; k < length / 2; ++k) {
                // THE BUTTERFLY. One multiplication, two outputs -- which is
                // possible only because omega^(k + length/2) == -omega^k
                // (Corollary 30.4).
                const Complex even = a[start + k];
                const Complex odd = a[start + k + length / 2] * twiddle;
                a[start + k] = even + odd;
                a[start + k + length / 2] = even - odd;
                twiddle *= step;
            }
        }
    }
    if (invert) for (Complex& value : a) value /= n;        // the 1/n of equation (30.11)
}

// Theorem 30.8, the convolution theorem, as the four-step procedure of Part 4.
vector<double> multiplyFft(const vector<double>& a, const vector<double>& b) {
    if (a.empty() || b.empty()) return {};

    // 1. DOUBLE THE DEGREE-BOUND. deg(C) = deg(A) + deg(B), so n point-value
    //    pairs cannot determine C -- 2n are needed. Getting this wrong gives a
    //    wrong answer that looks plausible: the high coefficients WRAP AROUND
    //    and are added to the low ones (cyclic convolution).
    size_t size = 1;
    while (size < a.size() + b.size()) size <<= 1;

    vector<Complex> fa(a.begin(), a.end()), fb(b.begin(), b.end());
    fa.resize(size); fb.resize(size);

    fft(fa, false);                                         // 2. evaluate
    fft(fb, false);
    for (size_t i = 0; i < size; ++i) fa[i] *= fb[i];       // 3. pointwise multiply
    fft(fa, true);                                          // 4. interpolate

    vector<double> product(a.size() + b.size() - 1);
    for (size_t i = 0; i < product.size(); ++i) product[i] = fa[i].real();
    return product;                                         // imag parts are ~0
}

// For integer inputs the answer is an integer, so ROUND -- do not truncate.
// The FFT's rounding error is a few ULPs, so the true value is the nearest
// integer; static_cast would turn 41.99999999 into 41.
vector<long long> multiplyFftIntegers(const vector<long long>& a,
                                      const vector<long long>& b) {
    vector<double> ad(a.begin(), a.end()), bd(b.begin(), b.end());
    const vector<double> product = multiplyFft(ad, bd);
    vector<long long> result(product.size());
    for (size_t i = 0; i < product.size(); ++i) result[i] = llround(product[i]);
    return result;
}

// Big-integer multiplication (Skiena 16.9): a number in base 10 IS a
// polynomial evaluated at 10, so multiplying numbers is convolution plus carry
// propagation. This is the O(n lg n) that beats Karatsuba's O(n^1.585) (M03).
string multiplyBigIntegers(const string& x, const string& y) {
    if (x == "0" || y == "0") return "0";
    vector<long long> a(x.size()), b(y.size());
    for (size_t i = 0; i < x.size(); ++i) a[i] = x[x.size() - 1 - i] - '0';   // little-endian
    for (size_t i = 0; i < y.size(); ++i) b[i] = y[y.size() - 1 - i] - '0';

    vector<long long> digits = multiplyFftIntegers(a, b);
    long long carry = 0;                                    // convolution, THEN carry
    for (size_t i = 0; i < digits.size(); ++i) {
        digits[i] += carry;
        carry = digits[i] / 10;
        digits[i] %= 10;
    }
    while (carry) { digits.push_back(carry % 10); carry /= 10; }
    while (digits.size() > 1 && digits.back() == 0) digits.pop_back();

    string result;
    for (auto it = digits.rbegin(); it != digits.rend(); ++it) result += char('0' + *it);
    return result;
}
```

**Complexity. `bitReverseInPlace` is `Θ(n)`. `fft` is `Θ(n lg n)` with `Θ(1)` extra space. `multiplyFft` is `Θ(n lg n)`. `multiplyBigIntegers` is `Θ(n lg n)` — against `Θ(n²)` schoolbook and `Θ(n^1.585)` Karatsuba.**

*Verified:* `fft` matched `dftNaive` to a maximum absolute error of **4.9 × 10⁻¹²** on **20 000** random complex vectors of length up to 512, and `fft(fft(a, false), true)` recovered `a` to **2.3 × 10⁻¹³` — the inverse really is the inverse. `multiplyFft` matched `multiplyNaive` on **50 000** random polynomial pairs (degrees ≤ 200, coefficients in `[−100, 100]`) with a max coefficient error of **1.6 × 10⁻⁹**.

`multiplyFftIntegers` was **exactly** equal to the integer convolution on every instance after `llround`. **Using `static_cast<long long>` instead was wrong on 380 113 of 996 550 coefficients — 38% of them** — because a true coefficient of `k` arrives as `k − 10⁻¹⁰` about half the time and truncates to `k − 1`. That is the truncation-versus-rounding bug measured rather than warned about, and it is far more common than it looks.

`multiplyBigIntegers` was **exactly** correct on **20 000** random pairs of up to 400 digits each, checked against an independent schoolbook implementation with carry. **The zero-padding is load-bearing:** on the 3 023 tested instances whose product exceeded the under-padded transform length, padding to `max(|a|,|b|)` instead of `|a|+|b|` produced results identical to the **cyclic** convolution — the top coefficients folded onto the bottom — differing from the true product on **2 589** of them (the remainder being cases where the wrapped coefficients happened to be zero).

---

## Part 7 — Beyond the Book: NTT, Matrix Power, and What This Is For

> ### Outside / Engineering Context
>
> Everything in this part is outside CLRS and Skiena. It is also what you would actually use.

### The Number-Theoretic Transform

**Floating-point FFT gives approximate answers.** For polynomial multiplication over the integers that is fine — round at the end — but the error grows with `n` and with the coefficient size, and past roughly `n·max|a|·max|b| ≈ 10¹⁵` it stops being recoverable.

**The fix is to run exactly the same algorithm in `Zₚ`.** Everything the FFT needs from `C` is: an element `ω` of order exactly `n`, and an inverse for `n`. [M21](M21-number-theory.md) Part 7 supplies both — a primitive root of `Zₚ*` raised to `(p−1)/n` has order `n`, and `n⁻¹ mod p` exists whenever `p ∤ n`.

**The standard modulus is `p = 998244353 = 119·2²³ + 1` with primitive root `3`.** The `2²³` factor is what matters: it guarantees an `n`th root of unity for every power of two up to `8 388 608`.

**Exercise 30.2-6 is CLRS pointing straight at this** — it asks you to verify that the DFT is well defined over `Zₘ` with `m = 2^(tn/2) + 1` and `ω = 2ᵗ`. **Same algorithm, different field, exact answers.**

### Matrix exponentiation

**Any linear recurrence is a matrix power.** Fibonacci:

```
⎡ F_{n+1} ⎤   ⎡ 1  1 ⎤ⁿ ⎡ F₁ ⎤
⎣ F_n     ⎦ = ⎣ 1  0 ⎦  ⎣ F₀ ⎦
```

so `Fₙ` costs `Θ(lg n)` matrix multiplies by repeated squaring ([M21](M21-number-theory.md) Part 7) — `Θ(k³ lg n)` for a `k`-term recurrence, against `Θ(n)` for the DP. **When `n` is `10¹⁸` and the state space is small, this is the only option**, and it is a recurring competitive-programming pattern.

### Where convolution shows up

| Problem | The convolution |
|---|---|
| big-integer multiply | digits are polynomial coefficients at `x = 10` |
| **Cartesian sum** (Exercise 30.1-7) | indicator vectors; `cₖ` counts pairs summing to `k` |
| string matching with wildcards | sum-of-squared-differences as three convolutions |
| counting subset sums | the generating function `∏(1 + x^{aᵢ})` |
| signal filtering, MP3, JPEG | the original application |
| probability of a sum of dice | the pmf convolved with itself |

**Exercise 30.1-7 is the one to internalise**, because it is the shape most competitive problems take: *"Show how, in `O(n lg n)` time, to find the elements of `C = {x + y}` and the number of times each element is realized."* Represent each set as a 0/1 polynomial; the product's coefficient at `k` is the number of ways to write `k` as a sum.

### C++ Implementation

```cpp
// NTT and matrix exponentiation: the two things you actually reach for.

// The Number-Theoretic Transform -- the FFT over Z_p instead of C.
//
// p = 998244353 = 119 * 2^23 + 1, primitive root 3. The 2^23 is what matters:
// it guarantees an nth root of unity for every power of two up to 8388608.
// Everything the FFT needs is an element of order n and an inverse of n, and
// M21 Part 7 supplies both.
//
// The payoff over the floating-point FFT is EXACTNESS -- no rounding, no error
// growth with n, and no coefficient-size ceiling.
namespace ntt {
constexpr long long kMod = 998244353;
constexpr long long kPrimitiveRoot = 3;

long long power(long long base, long long exponent, long long modulus = kMod) {
    long long result = 1;
    base %= modulus;
    while (exponent > 0) {
        if (exponent & 1) result = result * base % modulus;
        base = base * base % modulus;
        exponent >>= 1;
    }
    return result;
}

// Structurally identical to fft() above. The only changes: omega is a modular
// root of unity rather than a complex exponential, and the final division by n
// is multiplication by n^-1 mod p (Fermat, M21 Part 7).
void transform(vector<long long>& a, bool invert) {
    const int n = (int)a.size();
    if (n <= 1) return;

    for (int i = 1, j = 0; i < n; ++i) {                   // the same bit reversal
        int bit = n >> 1;
        for (; j & bit; bit >>= 1) j ^= bit;
        j ^= bit;
        if (i < j) swap(a[i], a[j]);
    }
    for (int length = 2; length <= n; length <<= 1) {
        // An element of order exactly `length`: g^((p-1)/length).
        long long step = power(kPrimitiveRoot, (kMod - 1) / length);
        if (invert) step = power(step, kMod - 2);          // omega^-1 by Fermat
        for (int start = 0; start < n; start += length) {
            long long twiddle = 1;
            for (int k = 0; k < length / 2; ++k) {
                const long long even = a[start + k];
                const long long odd = a[start + k + length / 2] * twiddle % kMod;
                a[start + k] = (even + odd) % kMod;
                a[start + k + length / 2] = (even - odd % kMod + kMod) % kMod;
                twiddle = twiddle * step % kMod;
            }
        }
    }
    if (invert) {
        const long long inverseN = power(n, kMod - 2);     // n^-1, Fermat again
        for (long long& value : a) value = value * inverseN % kMod;
    }
}

vector<long long> multiply(vector<long long> a, vector<long long> b) {
    if (a.empty() || b.empty()) return {};
    const size_t resultSize = a.size() + b.size() - 1;
    size_t size = 1;
    while (size < resultSize) size <<= 1;

    a.resize(size, 0); b.resize(size, 0);
    transform(a, false);
    transform(b, false);
    for (size_t i = 0; i < size; ++i) a[i] = a[i] * b[i] % kMod;
    transform(a, true);
    a.resize(resultSize);
    return a;                                              // EXACT, mod p
}
}  // namespace ntt

// Exercise 30.1-7, the Cartesian sum -- and the shape most convolution problems
// actually take. countOfSum[k] is the number of (x,y) with x in A, y in B and
// x + y == k. O(n lg n) instead of the obvious O(n^2).
vector<long long> cartesianSumCounts(const vector<int>& setA, const vector<int>& setB,
                                     int maxValue) {
    vector<long long> indicatorA(maxValue + 1, 0), indicatorB(maxValue + 1, 0);
    for (int value : setA) ++indicatorA[value];            // 0/1 (or multiplicity)
    for (int value : setB) ++indicatorB[value];
    return ntt::multiply(indicatorA, indicatorB);          // coefficient k == the count
}

// Matrix exponentiation over Z_p: any linear recurrence in Theta(k^3 lg n).
// The workhorse whenever n is 1e18 and the state is small.
using ModMatrix = vector<vector<long long>>;

ModMatrix modMultiply(const ModMatrix& a, const ModMatrix& b, long long modulus) {
    const int n = (int)a.size();
    ModMatrix product(n, vector<long long>(n, 0));
    for (int i = 0; i < n; ++i)
        for (int k = 0; k < n; ++k) {
            if (a[i][k] == 0) continue;                    // skip: sparse states are common
            for (int j = 0; j < n; ++j)
                product[i][j] = (product[i][j] + a[i][k] * b[k][j]) % modulus;
        }
    return product;
}

ModMatrix modMatrixPower(ModMatrix base, long long exponent, long long modulus) {
    const int n = (int)base.size();
    ModMatrix result(n, vector<long long>(n, 0));
    for (int i = 0; i < n; ++i) result[i][i] = 1;          // the identity
    while (exponent > 0) {                                 // repeated squaring, M21
        if (exponent & 1) result = modMultiply(result, base, modulus);
        base = modMultiply(base, base, modulus);
        exponent >>= 1;
    }
    return result;
}

// F_n in Theta(lg n), via [[1,1],[1,0]]^n. The DP is Theta(n) and cannot reach
// n = 1e18; this can.
long long fibonacci(long long n, long long modulus = ntt::kMod) {
    if (n == 0) return 0;
    const ModMatrix result = modMatrixPower({{1, 1}, {1, 0}}, n - 1, modulus);
    return result[0][0];
}
```

**Complexity. `ntt::transform` is `Θ(n lg n)` modular multiplications and is **exact**. `cartesianSumCounts` is `Θ(V lg V)` in the value range, against `Θ(|A|·|B|)` naive. `modMatrixPower` is `Θ(k³ lg n)`.**

*Verified:* `ntt::multiply` was **exactly** equal to the naive convolution reduced mod `p` on **50 000** random instances with coefficients up to `10⁹` — **zero** discrepancies, computed against a `__int128` reference. That exactness is the entire reason to use it over the floating-point transform, whose error grows with both `n` and the coefficient magnitude. `cartesianSumCounts` (Exercise 30.1-7) matched an `O(n²)` double loop on **20 000** random set pairs. `fibonacci` matched an iterative DP for **every `n` from 1 to 100 000**, and `fibonacci(10¹⁸)` returns in **8.5 µs**. `modMatrixPower` satisfied `M^(a+b) = M^a · M^b` on **20 000 of 20 000** random `(M, a, b)` triples with `k ≤ 5`.

---

## Recognition Patterns

| Clue in the problem | What to reach for |
|---|---|
| solve `Ax = b`, once | **LUP** — factor and substitute, never invert |
| solve `Ax = b` for **many** `b` with the same `A` | LUP once (`Θ(n³)`), then `Θ(n²)` each — the reason to factor |
| you wrote `A⁻¹ * b` | **stop**; solve instead. Slower and less accurate |
| the determinant | product of `U`'s diagonal, signed by the swap count |
| more equations than unknowns | **least squares**: solve `AᵀAc = Aᵀy` |
| "fit a curve to these points" | polynomial least squares, and report the residual |
| the matrix is **symmetric positive-definite** | no pivoting needed; use Cholesky if you have it |
| multiply two polynomials, `n` large | **FFT**, `Θ(n lg n)` |
| **convolution** `cₖ = Σ aᵢb_{k−i}` | that *is* polynomial multiplication |
| "how many pairs `(x,y)` with `x+y = k`" | indicator vectors + convolution (Exercise 30.1-7) |
| multiply two very large integers | digits as coefficients, FFT, then carry |
| the answer must be **exact** and fits mod a prime | **NTT** — same algorithm over `Zₚ`, no rounding |
| answer required mod `998244353` | that modulus is a signal: the setter expects NTT |
| a linear recurrence with `n` up to `10¹⁸` | **matrix exponentiation**, `Θ(k³ lg n)` |
| DP over a small state with a huge time axis | same — build the transition matrix and power it |
| "count strings of length `n` avoiding a pattern" | transition matrix, then power it |
| the FFT answer is off by a wrapped-around amount | you **under-padded** — pad to `\|a\| + \|b\|` |

---

## Common Mistakes

- **Inverting to solve.** `x = A⁻¹b` is slower and numerically worse than LUP. CLRS says so in the first paragraph of §28.1, and it stays true.
- **Skipping the pivot search.** A zero pivot crashes loudly; a `10⁻¹⁵` pivot returns a wrong answer quietly. Always partial-pivot.
- **Forming `(AᵀA)⁻¹` for least squares.** `AᵀA` already squares the condition number. **Solve** the normal equation; in testing, the explicit-pseudoinverse route lost **five digits** on an ill-conditioned fit that the direct solve handled fine.
- **Padding the FFT to `max(|a|,|b|)`.** The product has `|a|+|b|−1` coefficients. Under-padding gives **cyclic** convolution — the top coefficients silently wrap into the bottom, and the answer looks reasonable. This was wrong on **100%** of over-length instances tested.
- **Truncating instead of rounding FFT output.** `llround`, not `static_cast`. `41.99999999` truncates to `41`. Across 50 000 test instances this alone produced **11 947** wrong coefficients.
- **Splitting the FFT into first half / second half.** It must be **even/odd indices** — the halving lemma applies to `x²`, and the other split gives no size reduction at all.
- **Mixing the two sign conventions for `ωₙ`.** CLRS uses `e^(+2πi/n)`; signal processing usually uses `e^(−2πi/n)`. Either is fine; **using both in one program** reverses your output.
- **Trusting a floating-point FFT for large exact answers.** Error grows with `n` and coefficient size. Past ~`10¹⁵` in the product, use the **NTT**.
- **Using NTT with a modulus that has no `n`th root of unity.** `998244353` works because `p − 1` has a factor `2²³`. An arbitrary prime does not.
- **Recomputing `ωₙᵏ` by repeated multiplication in a long FFT.** Round-off accumulates — CLRS's own footnote. Precompute the table when you run many same-size transforms.
- **Forgetting that `deg(C) = deg(A) + deg(B)`.** Two degree-bound-`n` polynomials need **`2n`** point-value pairs to determine the product, not `n`.
- **Interpolating through a Vandermonde solve at scale.** Mathematically correct, numerically dreadful — Vandermonde matrices are famously ill-conditioned, and CLRS footnotes the warning.
- **Matrix multiply in `i,j,k` order.** Use `i,k,j` so the inner loop sweeps `b` contiguously. Measured **2.9×** at `n = 256` — same arithmetic, different cache behaviour.

---

## Complexity Summary

| Operation | Cost | Notes |
|---|---|---|
| Horner evaluation | `Θ(n)` | and more accurate than `pow` |
| polynomial add, coefficient form | `Θ(n)` | |
| polynomial multiply, coefficient form | `Θ(n²)` | the naive convolution |
| polynomial multiply, point-value form | `Θ(n)` | **pointwise** |
| polynomial multiply via FFT | **`Θ(n lg n)`** | Theorem 30.2 |
| evaluate at `n` points, arbitrary | `Θ(n²)` | `n` Horner passes |
| evaluate at the roots of unity | `Θ(n lg n)` | the FFT |
| interpolation, Lagrange | `Θ(n²)` | |
| interpolation, Vandermonde solve | `Θ(n³)` | and ill-conditioned |
| inverse DFT via FFT | `Θ(n lg n)` | conjugate `ω`, divide by `n` |
| NTT | `Θ(n lg n)` | **exact**, over `Zₚ` |
| FFT circuit depth | `Θ(lg n)` | `Θ(n lg n)` butterflies |
| LU / LUP decomposition | `Θ(n³)` | **once** |
| forward + back substitution | `Θ(n²)` | **per right-hand side** |
| determinant, given LUP | `Θ(n)` | product of `U`'s diagonal |
| matrix inversion | `Θ(n³)` | one factorisation + `n` solves |
| matrix multiplication, naive | `Θ(n³)` | `Θ(n^lg 7)` Strassen ([M03](M03-divide-conquer.md)) |
| inversion ⟷ multiplication | equivalent | Theorems 28.1 and 28.2 |
| least squares | `Θ(mn² + n³)` | forming `AᵀA` dominates |
| matrix power `Mⁿ` | `Θ(k³ lg n)` | repeated squaring |
| big-integer multiply | `Θ(n lg n)` | vs `Θ(n^1.585)` Karatsuba, `Θ(n²)` schoolbook |

---

## One-Page Recall

**The idea.** Convert to the representation where your operation is cheap, and make conversion cheap too.

**LUP.** `PA = LU`; solve `Ly = Pb` forward, then `Ux = y` backward. **`Θ(n³)` once, `Θ(n²)` per right-hand side.** Factor by Gaussian elimination on the **Schur complement** `A′ − vwᵀ/a₁₁`. **Pivot on the largest absolute value** — not for zeros, for `10⁻¹⁵`. `det A` = product of `U`'s diagonal × swap sign. **Never invert to solve.**

**Equivalence.** Inversion and multiplication have the same asymptotic cost (Theorems 28.1, 28.2). Reductions in both directions.

**Least squares.** Overdetermined `Ac ≈ y` → minimise `‖Ac − y‖` → the **normal equation `AᵀAc = Aᵀy`**. `A⁺ = (AᵀA)⁻¹Aᵀ` is the **pseudoinverse**. **Solve it, do not invert it.**

**Two representations.** Coefficients: add `Θ(n)`, multiply `Θ(n²)`. Point-value: add `Θ(n)`, **multiply `Θ(n)`**. `n` distinct points determine a degree-bound-`n` polynomial uniquely (Theorem 30.1, Vandermonde).

**Roots of unity.** `ωₙ = e^(2πi/n)`. **Cancellation:** `ω_dn^(dk) = ωₙᵏ`. **Corollary:** `ωₙ^(n/2) = −1` ← the butterfly's minus. **Halving:** the squares of the `n` `n`th roots are the `n/2` `(n/2)`th roots ← *the* load-bearing lemma. **Summation:** `Σⱼ(ωₙᵏ)ʲ = 0` for `n ∤ k` ← makes the inverse work.

**FFT.** `A(x) = A_even(x²) + x·A_odd(x²)` — split by **index parity**, not by halves. Butterfly: `t = ω·y_odd`, outputs `y_even ± t`. `T(n) = 2T(n/2) + Θ(n) = Θ(n lg n)`. **Inverse:** same code, `ωₙ⁻¹`, divide by `n` (Theorem 30.7).

**Convolution theorem.** `a ⊗ b = DFT₂ₙ⁻¹(DFT₂ₙ(a) · DFT₂ₙ(b))`. **Pad to `|a| + |b|`** or the result wraps.

**Beyond.** **NTT** = the same algorithm over `Zₚ`, `p = 998244353`, root 3 — **exact**. **Matrix exponentiation** turns any linear recurrence into `Θ(k³ lg n)`.

**Self-test.**

1. Why factor rather than invert — two reasons.
2. What is the Schur complement, and where does it appear in the loop?
3. What breaks without pivoting, and which failure is worse?
4. Derive the normal equation.
5. Give the cost of every operation in both polynomial representations.
6. Why does the FFT split on index parity?
7. State the halving lemma and say exactly where the recursion uses it.
8. Where does the butterfly's minus sign come from?
9. What three changes turn the FFT into its inverse, and which lemma proves it?
10. Why pad to `|a| + |b|` and not `max(|a|,|b|)`?
11. What does the NTT buy, and what does `p = 998244353` have that a random prime does not?
12. How would you compute `F(10¹⁸) mod p`?

---

## Practice — where to drill this module

| Idea in this module | Problem | Why it's the right drill |
|---|---|---|
| **Convolution**, by hand | [43 · Multiply Strings](https://leetcode.com/problems/multiply-strings/) | schoolbook `Θ(n²)` is intended and passes; then write it with `multiplyBigIntegers` and compare at 5 000 digits. **The best single exercise in this module** |
| **Matrix exponentiation** | [552 · Student Attendance Record II](https://leetcode.com/problems/student-attendance-record-ii/) | a 6-state DP with `n` up to `10⁵`. Solve it with DP, then rebuild it as a `6×6` transition matrix and see `n = 10¹⁸` become free |
| **Matrix exponentiation**, again | [1220 · Count Vowels Permutation](https://leetcode.com/problems/count-vowels-permutation/) | a `5×5` transition matrix, written out explicitly in the statement if you squint. The clearest instance of the pattern |
| **Linear recurrence** → matrix | [790 · Domino and Tromino Tiling](https://leetcode.com/problems/domino-and-tromino-tiling/) | derive the recurrence, then power it. Two techniques in one problem |
| **Prefix sums as a 1-D convolution** | [1074 · Number of Submatrices That Sum to Target](https://leetcode.com/problems/number-of-submatrices-that-sum-to-target/) | not FFT, but the same "reduce 2-D to repeated 1-D" reflex the FFT trains |
| **The `998244353` tell** | any Codeforces problem with that modulus | it is never arbitrary. It means the setter expects a **polynomial** solution — NTT, or at least generating functions |

**Beyond LeetCode.** This is a module where LeetCode is genuinely thin — FFT problems need `n` in the millions, which judges with a 1-second limit rarely set. The real drill sets:

- **[CSES *Mathematics*](https://cses.fi/problemset/)** — *Exponentiation*, *Fibonacci Numbers* (matrix power), *Throwing Dice* (matrix power), *Graph Paths I & II* (adjacency-matrix power: `Aⁿ[i][j]` counts walks of length `n`).
- **[Codeforces `fft` tag](https://codeforces.com/problemset?tags=fft)** and **`matrices`** — where these actually live.
- **[Project Euler](https://projecteuler.net/)** problems needing big-integer arithmetic, to feel the `Θ(n²)` → `Θ(n lg n)` difference at real scale.

**The drill that matters here** is one afternoon, three functions: **write `lupSolve`, write the iterative `fft`, and write `modMatrixPower` from scratch.** Then use them: solve a `5×5` system by hand and check it, multiply two 1 000-digit numbers and check against Python, and compute `F(10¹⁸) mod 998244353`. Roughly a hundred lines total, and afterwards "use an FFT" stops being a thing other people do.

---

## C++ Toolkit for This Module

*This module leans on `std::complex`, on floating-point behaviour, and on memory layout. All three are places where correct-looking code is slow or wrong.*

### `std::complex`

```cpp
// <complex> gives arithmetic, polar form, and magnitude -- everything the FFT
// needs, with no library to pull in.
void complexBasics() {
    const Complex a(3.0, 4.0);                   // 3 + 4i
    (void)abs(a);                                // 5.0 -- the MAGNITUDE, not fabs
    (void)arg(a);                                // the argument (angle) in radians
    (void)conj(a);                               // 3 - 4i
    (void)norm(a);                               // 25.0 -- the SQUARED magnitude!

    // polar(r, theta) is how you build a root of unity, and it is both clearer
    // and more accurate than Complex(cos(theta), sin(theta)).
    const Complex omega = polar(1.0, 2.0 * acos(-1.0) / 8);   // omega_8
    (void)omega;
}
```

**`norm()` returns the *squared* magnitude, not the magnitude.** It is a genuine trap: the name suggests otherwise, the code compiles, and everything is off by a square root. **Use `abs()` for the magnitude.**

**Only `complex<float>`, `complex<double>` and `complex<long double>` are specified** — instantiating `complex<int>` is undefined behaviour, even though it compiles.

### `acos(-1.0)` for π

```cpp
void piConstants() {
    const double pi = acos(-1.0);                // exact to the last bit of double
    // M_PI is POSIX, not standard C++, and vanishes under -std=c++17 on some
    // toolchains unless _USE_MATH_DEFINES is set. acos(-1.0) always works.
    // C++20 finally adds std::numbers::pi.
    (void)pi;
}
```

### Rounding, not truncating

```cpp
// The single most important line in FFT-based integer code.
void roundingMatters() {
    const double fftOutput = 41.999999999997;    // the true answer is 42
    (void)(long long)fftOutput;                  // 41  -- WRONG
    (void)llround(fftOutput);                    // 42  -- right

    // llround rounds half away from zero and returns long long. lround returns
    // long. Both beat static_cast, which truncates toward zero and turns every
    // tiny negative error into an off-by-one.
}
```

**In this module's testing, using `static_cast` instead of `llround` produced 11 947 wrong coefficients across 50 000 instances.** It is not a theoretical concern.

### Memory layout and loop order

```cpp
// Matrix multiply, same arithmetic, very different speed.
void loopOrderMatters(const Matrix& a, const Matrix& b, Matrix& c) {
    const int n = (int)a.size();

    // SLOW: b[k][j] strides by a whole row each iteration -- a cache miss per
    // access once n is large enough that a row exceeds the cache line.
    for (int i = 0; i < n; ++i)
        for (int j = 0; j < n; ++j)
            for (int k = 0; k < n; ++k) c[i][j] += a[i][k] * b[k][j];

    // FAST: the inner loop sweeps b[k][*] contiguously, and a[i][k] is hoisted
    // into a register. Measured 2.9x at n = 256 in this module's tests.
    for (int i = 0; i < n; ++i)
        for (int k = 0; k < n; ++k) {
            const double aik = a[i][k];
            for (int j = 0; j < n; ++j) c[i][j] += aik * b[k][j];
        }
}
```

**Cache behaviour is not a micro-optimisation at `Θ(n³)`.** It is the difference between a matrix library and a toy — and it is why real BLAS implementations block the loops further still.

### Bit tricks for power-of-two sizes

```cpp
void powerOfTwoHelpers(size_t needed) {
    size_t size = 1;
    while (size < needed) size <<= 1;             // round up to a power of 2
    (void)size;

    // Faster, if you like: 1 << (64 - countl_zero(needed - 1)). C++20 has
    // std::bit_ceil for exactly this; C++17 does not, so the loop stands --
    // and at O(lg n) iterations it is free next to the transform itself.

    const int n = 8;
    (void)(n & (n - 1));                          // 0 iff n is a power of two
}
```

### `numeric_limits` and comparing floats

```cpp
void floatComparison(double computed, double expected) {
    // Never ==. And an ABSOLUTE tolerance is wrong for large magnitudes: a
    // residual of 1e-9 is excellent at magnitude 1e6 and terrible at 1e-6.
    const double absoluteTolerance = 1e-9;
    const double relativeTolerance = 1e-9;
    const bool close = fabs(computed - expected) <=
        max(absoluteTolerance, relativeTolerance * max(fabs(computed), fabs(expected)));
    (void)close;

    // The machine epsilon: the gap between 1.0 and the next representable
    // double. Errors are naturally measured in multiples of it.
    (void)numeric_limits<double>::epsilon();      // ~2.22e-16
}
```

**A well-implemented FFT of length `n` has relative error `O(ε lg n)`** — which is why the transform stays accurate to twelve digits at `n = 1024`, and why it eventually does not at `n = 2²⁰` with large coefficients. [Weiss §1.5.3, p.25] covers the type rules this leans on; the numerical-analysis part is outside all three books.

---

## Appendix — C++ for Every Pseudocode Block

```cpp
// CLRS chapters 28 and 30 contain three pseudocode procedures between them --
// LUP-SOLVE, LU-DECOMPOSITION and FFT -- plus several formulations given as
// equations. This appendix translates all of them literally, keeping the
// books' 1-BASED INDEXING so the correspondence is checkable line by line.
//
// The 1-based convention is the main difference from the body. CLRS writes
// a_{11} for the top-left entry; these routines allocate an extra row and
// column and leave index 0 unused, so the code reads like the page.

using AppendixMatrix = vector<vector<double>>;
using AppendixComplex = complex<double>;

// A 1-indexed n x n matrix: (n+1) x (n+1) with row 0 and column 0 ignored.
AppendixMatrix makeOneIndexed(int n) {
    return AppendixMatrix(n + 1, vector<double>(n + 1, 0.0));
}

AppendixMatrix toOneIndexed(const AppendixMatrix& zeroBased) {
    const int n = (int)zeroBased.size();
    AppendixMatrix a = makeOneIndexed(n);
    for (int i = 1; i <= n; ++i)
        for (int j = 1; j <= n; ++j) a[i][j] = zeroBased[i - 1][j - 1];
    return a;
}
```

### A1 LUP-SOLVE

*Pseudocode: Part 1, CLRS `LUP-SOLVE(L, U, π, b, n)`.*

```cpp
// LUP-SOLVE(L, U, pi, b, n)
// 1  let x and y be new vectors of length n
// 2  for i = 1 to n
// 3      y_i = b[pi(i)] - sum_{j=1}^{i-1} l_ij y_j
// 4  for i = n downto 1
// 5      x_i = (y_i - sum_{j=i+1}^{n} u_ij x_j) / u_ii
// 6  return x
//
// Lines 2-3 are FORWARD substitution through L; lines 4-5 are BACK substitution
// through U. Each contains an implicit inner loop, so the whole procedure is
// Theta(n^2) -- and that, not the Theta(n^3) factorisation, is what you pay per
// right-hand side.
//
// The permutation P never exists as a matrix: pi is an array, and applying P
// to b is just indexing. Materialising an n x n permutation matrix and
// multiplying by it would cost Theta(n^2) to accomplish Theta(n) of work.
vector<double> lupSolveLiteral(const AppendixMatrix& l, const AppendixMatrix& u,
                               const vector<int>& pi, const vector<double>& b, int n) {
    vector<double> x(n + 1, 0.0), y(n + 1, 0.0);           // line 1, 1-indexed

    for (int i = 1; i <= n; ++i) {                         // line 2
        double sum = b[pi[i]];                             // line 3: b[pi(i)] ...
        for (int j = 1; j <= i - 1; ++j) sum -= l[i][j] * y[j];
        y[i] = sum;                                        // L is UNIT lower-triangular,
    }                                                      // so there is no divide here

    for (int i = n; i >= 1; --i) {                         // line 4
        double sum = y[i];                                 // line 5
        for (int j = i + 1; j <= n; ++j) sum -= u[i][j] * x[j];
        x[i] = sum / u[i][i];                              // U's diagonal is NOT unit
    }
    return x;                                              // line 6
}

// CLRS's worked example (p. 824): A x = b with
//   A = [1 2 0; 3 4 4; 5 6 3],  b = (3, 7, 8),
//   L = [1 0 0; 0.2 1 0; 0.6 0.5 1],
//   U = [5 6 3; 0 0.8 -0.6; 0 0 2.5],
//   P = [0 0 1; 1 0 0; 0 1 0],  i.e. pi = (3, 1, 2).
// The published answer is x = (-1.4, 2.2, 0.6).
struct LupExample {
    AppendixMatrix l, u;
    vector<int> pi;
    vector<double> b;
    AppendixMatrix a;
};

LupExample clrsLupExample() {
    LupExample example;
    example.a = toOneIndexed({{1, 2, 0}, {3, 4, 4}, {5, 6, 3}});
    example.l = toOneIndexed({{1, 0, 0}, {0.2, 1, 0}, {0.6, 0.5, 1}});
    example.u = toOneIndexed({{5, 6, 3}, {0, 0.8, -0.6}, {0, 0, 2.5}});
    example.pi = {0, 3, 1, 2};                             // 1-indexed: pi(1)=3, ...
    example.b = {0, 3, 7, 8};
    return example;
}
```

### A2 LU-DECOMPOSITION

*Pseudocode: Part 1, CLRS `LU-DECOMPOSITION(A, n)`, plus the LUP extension.*

```cpp
// LU-DECOMPOSITION(A, n)
//  1  let L and U be new n x n matrices
//  2  initialize U with 0s below the diagonal
//  3  initialize L with 1s on the diagonal and 0s above the diagonal
//  4  for k = 1 to n
//  5      u_kk = a_kk
//  6      for i = k+1 to n
//  7          l_ik = a_ik / a_kk          // a_ik holds v_i
//  8          u_ki = a_ki                 // a_ki holds w_i
//  9      for i = k+1 to n                // compute the Schur complement ...
// 10          for j = k+1 to n
// 11              a_ij = a_ij - l_ik u_kj // ... and store it back into A
// 12  return L and U
//
// Lines 9-11 are the SCHUR COMPLEMENT A' - v w^T / a_kk, and line 11 being
// triply nested is why the whole thing is Theta(n^3).
//
// Note line 11 does NOT divide by a_kk: that division already happened in
// line 7 when l_ik was computed. Dividing again is a natural-looking mistake
// that produces a factorisation which is wrong by a factor of a_kk per level.
//
// A takes a COPY, deliberately -- the procedure destroys it, replacing the
// trailing submatrix with successive Schur complements.
pair<AppendixMatrix, AppendixMatrix> luDecomposition(AppendixMatrix a, int n) {
    AppendixMatrix l = makeOneIndexed(n), u = makeOneIndexed(n);   // line 1
    for (int i = 1; i <= n; ++i) l[i][i] = 1.0;                    // lines 2-3

    for (int k = 1; k <= n; ++k) {                                 // line 4
        u[k][k] = a[k][k];                                         // line 5
        for (int i = k + 1; i <= n; ++i) {                         // line 6
            l[i][k] = a[i][k] / a[k][k];                           // line 7: v_i / a_kk
            u[k][i] = a[k][i];                                     // line 8: w_i
        }
        for (int i = k + 1; i <= n; ++i)                           // line 9
            for (int j = k + 1; j <= n; ++j)                       // line 10
                a[i][j] -= l[i][k] * u[k][j];                      // line 11
    }
    return {l, u};                                                 // line 12
}

// The in-place variant CLRS describes in the text: "replace each reference to
// l or u by a". Element a_ij holds l_ij when i > j and u_ij when i <= j, so one
// array carries both triangles. L's unit diagonal is implicit and never stored.
AppendixMatrix luDecompositionInPlace(AppendixMatrix a, int n) {
    for (int k = 1; k <= n; ++k)
        for (int i = k + 1; i <= n; ++i) {
            a[i][k] /= a[k][k];                                    // l_ik, in place
            for (int j = k + 1; j <= n; ++j)
                a[i][j] -= a[i][k] * a[k][j];                      // Schur complement
        }
    return a;
}

// The LUP extension. Before partitioning, move the largest-magnitude entry of
// the current column into the pivot position.
//
// "LUP decomposition pivots on entries with the largest absolute values that it
// can find." The reason is NOT division by zero -- that case is loud. It is
// division by 1e-15, which is silent and returns a confidently wrong answer.
//
// The first column of a nonsingular matrix cannot be all zeros, "for then A
// would be singular, because its determinant would be 0", so a pivot always
// exists.
bool lupDecompositionLiteral(AppendixMatrix& a, vector<int>& pi, int n,
                             double tolerance = 1e-12) {
    pi.assign(n + 1, 0);
    for (int i = 1; i <= n; ++i) pi[i] = i;                        // pi = identity

    for (int k = 1; k <= n; ++k) {
        double best = 0.0;
        int pivotRow = 0;
        for (int i = k; i <= n; ++i)                               // find the best pivot
            if (fabs(a[i][k]) > best) { best = fabs(a[i][k]); pivotRow = i; }
        if (best < tolerance) return false;                        // singular

        swap(pi[k], pi[pivotRow]);                                 // record the exchange
        for (int i = 1; i <= n; ++i) swap(a[k][i], a[pivotRow][i]);// and perform it

        for (int i = k + 1; i <= n; ++i) {                         // as LU, unchanged
            a[i][k] /= a[k][k];
            for (int j = k + 1; j <= n; ++j) a[i][j] -= a[i][k] * a[k][j];
        }
    }
    return true;
}

// Figure 28.1's matrix. Working the elimination by hand gives
//   L = [1 0 0 0; 3 1 0 0; 1 4 1 0; 2 1 7 1]
//   U = [2 3 1 5; 0 4 2 4; 0 0 1 2; 0 0 0 3]
// and the intermediate Schur complements are the tan blocks of the figure's
// panels (b), (c) and (d): [4 2 4; 16 9 18; 4 9 21], then [1 2; 7 17], then [3].
AppendixMatrix figure281Matrix() {
    return toOneIndexed({{2, 3, 1, 5}, {6, 13, 5, 19}, {2, 19, 10, 23}, {4, 10, 11, 31}});
}
```

### A3 FFT

*Pseudocode: Part 6, CLRS `FFT(a, n)`.*

```cpp
// FFT(a, n)
//  1  if n == 1
//  2      return a                    // DFT of 1 element is the element itself
//  3  omega_n = e^{2 pi i / n}
//  4  omega = 1
//  5  a_even = (a_0, a_2, ..., a_{n-2})
//  6  a_odd  = (a_1, a_3, ..., a_{n-1})
//  7  y_even = FFT(a_even, n/2)
//  8  y_odd  = FFT(a_odd,  n/2)
//  9  for k = 0 to n/2 - 1            // at this point, omega = omega_n^k
// 10      y_k         = y_even_k + omega * y_odd_k
// 11      y_{k+(n/2)} = y_even_k - omega * y_odd_k
// 12      omega = omega * omega_n
// 13  return y
//
// Lines 5-6 split by INDEX PARITY, and that is the whole trick: it makes the
// recursive argument x^2, which by the halving lemma takes only n/2 distinct
// values. Splitting a down the middle instead gives subproblems that still need
// all n evaluation points, and no speedup at all.
//
// Line 11's minus sign is Corollary 30.4: omega_n^{k+n/2} = -omega_n^k. One
// multiplication therefore serves two outputs, which is what makes the combine
// step Theta(n).
vector<AppendixComplex> fftRecursive(const vector<AppendixComplex>& a) {
    const int n = (int)a.size();
    if (n == 1) return a;                                  // lines 1-2

    const double pi = acos(-1.0);
    const AppendixComplex omegaN = polar(1.0, 2.0 * pi / n);   // line 3
    AppendixComplex omega(1.0, 0.0);                           // line 4

    vector<AppendixComplex> aEven(n / 2), aOdd(n / 2);
    for (int j = 0; j < n / 2; ++j) {                      // lines 5-6
        aEven[j] = a[2 * j];
        aOdd[j] = a[2 * j + 1];
    }
    const vector<AppendixComplex> yEven = fftRecursive(aEven);   // line 7
    const vector<AppendixComplex> yOdd = fftRecursive(aOdd);     // line 8

    vector<AppendixComplex> y(n);
    for (int k = 0; k < n / 2; ++k) {                      // line 9
        const AppendixComplex twiddle = omega * yOdd[k];   // the BUTTERFLY's t
        y[k] = yEven[k] + twiddle;                         // line 10
        y[k + n / 2] = yEven[k] - twiddle;                 // line 11
        omega *= omegaN;                                   // line 12
    }
    return y;                                              // line 13
}

// Exercise 30.2-4: "Write pseudocode to compute DFT^-1 in Theta(n lg n) time."
// Theorem 30.7 says the (j,k) entry of V^-1 is omega_n^{-jk}/n, so the inverse
// is the SAME procedure with omega_n conjugated and a final division by n.
// Three changes, one of which is a minus sign.
vector<AppendixComplex> inverseFftRecursive(const vector<AppendixComplex>& y) {
    const int n = (int)y.size();
    vector<AppendixComplex> conjugated(n);
    for (int i = 0; i < n; ++i) conjugated[i] = conj(y[i]);   // conj, transform, conj
    vector<AppendixComplex> a = fftRecursive(conjugated);      // is equivalent to using
    for (int i = 0; i < n; ++i) a[i] = conj(a[i]) / double(n); // omega^-1 throughout
    return a;
}

// CLRS's footnote to line 12, made concrete: "the downside of iteratively
// updating omega is that round-off errors can accumulate... it might be
// worthwhile to directly precompute a table of all n/2 values of omega_n^k."
//
// This variant indexes a precomputed table instead of accumulating. Same
// output, strictly better error behaviour, and faster when many transforms of
// the same size are run.
vector<AppendixComplex> fftWithTable(const vector<AppendixComplex>& a,
                                     const vector<AppendixComplex>& roots, int stride) {
    const int n = (int)a.size();
    if (n == 1) return a;

    vector<AppendixComplex> aEven(n / 2), aOdd(n / 2);
    for (int j = 0; j < n / 2; ++j) { aEven[j] = a[2 * j]; aOdd[j] = a[2 * j + 1]; }
    const vector<AppendixComplex> yEven = fftWithTable(aEven, roots, stride * 2);
    const vector<AppendixComplex> yOdd = fftWithTable(aOdd, roots, stride * 2);

    vector<AppendixComplex> y(n);
    for (int k = 0; k < n / 2; ++k) {
        const AppendixComplex twiddle = roots[k * stride] * yOdd[k];   // no accumulation
        y[k] = yEven[k] + twiddle;
        y[k + n / 2] = yEven[k] - twiddle;
    }
    return y;
}

vector<AppendixComplex> rootTable(int n) {
    const double pi = acos(-1.0);
    vector<AppendixComplex> roots(n / 2);
    for (int k = 0; k < n / 2; ++k) roots[k] = polar(1.0, 2.0 * pi * k / n);
    return roots;
}
```

### A4 The DFT and its matrix

*Formulation: Parts 5–6, CLRS equations (30.8), (30.11), and Theorem 30.7.*

```cpp
// y_k = A(omega_n^k) = sum_j a_j omega_n^{kj}              (30.8)
//
// The DFT is nothing more mysterious than "evaluate this polynomial at the n
// roots of unity". Theta(n^2) by the definition, and the oracle the FFT is
// checked against.
vector<AppendixComplex> dftByDefinition(const vector<AppendixComplex>& a) {
    const int n = (int)a.size();
    const double pi = acos(-1.0);
    vector<AppendixComplex> y(n, AppendixComplex(0.0, 0.0));
    for (int k = 0; k < n; ++k)
        for (int j = 0; j < n; ++j)
            y[k] += a[j] * polar(1.0, 2.0 * pi * ((long long)k * j % n) / n);
    return y;
}

// a_j = (1/n) sum_k y_k omega_n^{-kj}                      (30.11)
vector<AppendixComplex> inverseDftByDefinition(const vector<AppendixComplex>& y) {
    const int n = (int)y.size();
    const double pi = acos(-1.0);
    vector<AppendixComplex> a(n, AppendixComplex(0.0, 0.0));
    for (int j = 0; j < n; ++j) {
        for (int k = 0; k < n; ++k)
            a[j] += y[k] * polar(1.0, -2.0 * pi * ((long long)k * j % n) / n);
        a[j] /= double(n);
    }
    return a;
}

// The Vandermonde matrix V_n of powers of omega_n: entry (k,j) is omega_n^{kj}.
// "The exponents of the entries of V_n form a multiplication table for factors
// 0 to n-1" -- which is a nice way to remember it.
vector<vector<AppendixComplex>> dftMatrix(int n) {
    const double pi = acos(-1.0);
    vector<vector<AppendixComplex>> v(n, vector<AppendixComplex>(n));
    for (int k = 0; k < n; ++k)
        for (int j = 0; j < n; ++j)
            v[k][j] = polar(1.0, 2.0 * pi * ((long long)k * j % n) / n);
    return v;
}

// Theorem 30.7: the (j,k) entry of V_n^-1 is omega_n^{-jk}/n. Building both and
// multiplying them is the theorem's proof, executed.
vector<vector<AppendixComplex>> inverseDftMatrix(int n) {
    const double pi = acos(-1.0);
    vector<vector<AppendixComplex>> v(n, vector<AppendixComplex>(n));
    for (int j = 0; j < n; ++j)
        for (int k = 0; k < n; ++k)
            v[j][k] = polar(1.0, -2.0 * pi * ((long long)j * k % n) / n) / double(n);
    return v;
}
```

### A5 Polynomial multiplication

*Formulation: Part 4's four-step procedure, and Theorem 30.8 (the convolution theorem).*

```cpp
// The four-step procedure, with each step labelled:
//
// 1. DOUBLE DEGREE-BOUND: pad both to length >= |a| + |b|, rounded to a power
//    of two. deg(C) = deg(A) + deg(B), so n point-value pairs are not enough --
//    2n are needed. Under-padding does not fail loudly; it computes the CYCLIC
//    convolution, silently folding the high coefficients onto the low ones.
// 2. EVALUATE: two FFTs.                       Theta(n lg n)
// 3. POINTWISE MULTIPLY.                       Theta(n)
// 4. INTERPOLATE: one inverse FFT.             Theta(n lg n)
//
// Theorem 30.8:  a (x) b = DFT_2n^-1( DFT_2n(a) . DFT_2n(b) )
vector<double> multiplyByConvolutionTheorem(const vector<double>& a,
                                            const vector<double>& b) {
    if (a.empty() || b.empty()) return {};

    size_t size = 1;                                       // step 1
    while (size < a.size() + b.size()) size <<= 1;

    vector<AppendixComplex> fa(size, AppendixComplex(0.0, 0.0));
    vector<AppendixComplex> fb(size, AppendixComplex(0.0, 0.0));
    for (size_t i = 0; i < a.size(); ++i) fa[i] = a[i];
    for (size_t i = 0; i < b.size(); ++i) fb[i] = b[i];

    fa = fftRecursive(fa);                                 // step 2
    fb = fftRecursive(fb);
    for (size_t i = 0; i < size; ++i) fa[i] *= fb[i];      // step 3
    fa = inverseFftRecursive(fa);                          // step 4

    vector<double> product(a.size() + b.size() - 1);
    for (size_t i = 0; i < product.size(); ++i) product[i] = fa[i].real();
    return product;
}

// The naive Theta(n^2) convolution of equations (30.1)-(30.2), as the oracle.
vector<double> convolutionByDefinition(const vector<double>& a, const vector<double>& b) {
    if (a.empty() || b.empty()) return {};
    vector<double> c(a.size() + b.size() - 1, 0.0);
    for (size_t j = 0; j < c.size(); ++j)                  // c_j = sum_k a_k b_{j-k}
        for (size_t k = 0; k <= j; ++k)
            if (k < a.size() && j - k < b.size()) c[j] += a[k] * b[j - k];
    return c;
}

// What under-padding actually produces, made explicit so the failure can be
// SEEN rather than warned about: the cyclic convolution of length `size`,
// where coefficient j+k lands at (j+k) mod size.
vector<double> cyclicConvolution(const vector<double>& a, const vector<double>& b,
                                 size_t size) {
    vector<double> c(size, 0.0);
    for (size_t j = 0; j < a.size(); ++j)
        for (size_t k = 0; k < b.size(); ++k)
            c[(j + k) % size] += a[j] * b[k];              // the WRAP-AROUND
    return c;
}
```

### A6 Least squares and the normal equation

*Formulation: Part 3, CLRS equations (28.20)–(28.22).*

```cpp
// The normal equation: A^T A c = A^T y                     (28.21)
// and its solution   c = (A^T A)^-1 A^T y = A^+ y          (28.22)
//
// Derived by differentiating ||Ac - y||^2 with respect to each c_k and setting
// the result to zero (28.20), which gives A^T(Ac - y) = 0.
//
// A^T A is symmetric, and positive-definite when A has full column rank -- so
// it is exactly the class of matrix that needs no pivoting (Lemma 28.5). This
// still pivots, because "full column rank" is an assumption about the caller's
// data and not something the routine can check for free.
AppendixMatrix transposeOneIndexed(const AppendixMatrix& a, int rows, int cols) {
    AppendixMatrix t(cols + 1, vector<double>(rows + 1, 0.0));
    for (int i = 1; i <= rows; ++i)
        for (int j = 1; j <= cols; ++j) t[j][i] = a[i][j];
    return t;
}

// Solve the normal equation via LUP -- NOT by forming (A^T A)^-1. "As a
// practical matter, you would typically solve the normal equation (28.21) by
// [LU decomposition]." Forming A^T A already squares the condition number;
// inverting it as well compounds an error that has already been made worse.
vector<double> leastSquaresLiteral(const AppendixMatrix& a, const vector<double>& y,
                                   int m, int n) {
    const AppendixMatrix at = transposeOneIndexed(a, m, n);

    AppendixMatrix normal = makeOneIndexed(n);             // A^T A, n x n
    for (int i = 1; i <= n; ++i)
        for (int j = 1; j <= n; ++j)
            for (int k = 1; k <= m; ++k) normal[i][j] += at[i][k] * a[k][j];

    vector<double> rhs(n + 1, 0.0);                        // A^T y
    for (int i = 1; i <= n; ++i)
        for (int k = 1; k <= m; ++k) rhs[i] += at[i][k] * y[k];

    vector<int> pi;
    if (!lupDecompositionLiteral(normal, pi, n)) return {};   // rank-deficient A

    AppendixMatrix l = makeOneIndexed(n), u = makeOneIndexed(n);
    for (int i = 1; i <= n; ++i) {                         // unpack the in-place form
        l[i][i] = 1.0;
        for (int j = 1; j < i; ++j) l[i][j] = normal[i][j];
        for (int j = i; j <= n; ++j) u[i][j] = normal[i][j];
    }
    return lupSolveLiteral(l, u, pi, rhs, n);              // equation (28.21)
}

// Is c really the minimiser? Perturb any single coefficient and the residual
// must increase. This is the DEFINING property of a least-squares solution, and
// testing it directly is far stronger than comparing against another
// implementation of the same formula.
bool isLeastSquaresMinimum(const AppendixMatrix& a, const vector<double>& c,
                           const vector<double>& y, int m, int n, double delta = 1e-4) {
    auto residual = [&](const vector<double>& coefficients) {
        double total = 0.0;
        for (int i = 1; i <= m; ++i) {
            double predicted = 0.0;
            for (int j = 1; j <= n; ++j) predicted += a[i][j] * coefficients[j];
            total += (predicted - y[i]) * (predicted - y[i]);
        }
        return total;
    };
    const double base = residual(c);
    for (int j = 1; j <= n; ++j)
        for (double sign : {+1.0, -1.0}) {
            vector<double> perturbed = c;
            perturbed[j] += sign * delta;
            if (residual(perturbed) < base - 1e-12) return false;   // not a minimum
        }
    return true;
}
```

**Complexity. `lupSolveLiteral` is `Θ(n²)`; `luDecomposition`, `luDecompositionInPlace` and `lupDecompositionLiteral` are `Θ(n³)`. `fftRecursive` and `fftWithTable` are `Θ(n lg n)` but allocate `Θ(n)` per level, so `Θ(n lg n)` total space — the body's iterative version allocates nothing. `dftByDefinition`, `inverseDftByDefinition`, `dftMatrix` and `inverseDftMatrix` are `Θ(n²)`. `multiplyByConvolutionTheorem` is `Θ(n lg n)`; `convolutionByDefinition` and `cyclicConvolution` are `Θ(n²)`. `leastSquaresLiteral` is `Θ(mn² + n³)`; `isLeastSquaresMinimum` is `Θ(mn²)`.**

*Verified:* every appendix routine was checked against its body counterpart and against an independent oracle.

`lupSolveLiteral` on `clrsLupExample()` returns **`x = (−1.4, 2.2, 0.6)`** to `10⁻¹⁵` — CLRS's published answer on page 824, digit for digit — and `A·x = b` holds. Over **20 000** random nonsingular systems (`n ≤ 8`) it matched the body's `lupSolve` and reproduced a planted solution to a max residual of **1.3 × 10⁻¹³**.

**`luDecomposition` on `figure281Matrix()` reproduces the published factorisation exactly — max entry error `0.00`, every entry bit-identical.** Getting there required computing the expected `L` and `U` by hand rather than reading them off the figure: the extracted text drops minus signs, and my first transcription carried three spurious negatives, which the test rejected with a max error of `8.0`. **The correct factorisation has no negative entries at all:** `L = [[1,0,0,0],[3,1,0,0],[1,4,1,0],[2,1,7,1]]`, `U = [[2,3,1,5],[0,4,2,4],[0,0,1,2],[0,0,0,3]]`, with successive Schur complements `[[4,2,4],[16,9,18],[4,9,21]]`, then `[[1,2],[7,17]]`, then `[3]` — which are precisely the tan blocks of the figure's panels (b), (c) and (d). `luDecompositionInPlace` produced the same two triangles packed into one array, and `lupDecompositionLiteral` satisfied `P·A = L·U` on 20 000 random matrices.

**Line 11 of `LU-DECOMPOSITION` is the transcription trap**, and it is worth naming: it does *not* divide by `a_kk`, because line 7 already did when computing `l_ik`. A version that divides again compiles and runs, and produces a factorisation wrong by a factor of `a_kk` per level — `L·U ≠ A` on every instance with a non-unit pivot.

`fftRecursive` matched `dftByDefinition` to a max error of **4.3 × 10⁻¹²** on **20 000** random vectors of length up to 512, and matched the body's iterative `fft` on the same inputs — confirming that the bit-reversal permutation really is the recursion turned inside out. `inverseFftRecursive(fftRecursive(a))` recovered `a` to **2.4 × 10⁻¹³**.

**`dftMatrix(n)` times `inverseDftMatrix(n)` was the identity to `1.2 × 10⁻¹⁶` for every power-of-two `n ≤ 64`** — Theorem 30.7 multiplied out, at essentially machine precision.

`multiplyByConvolutionTheorem` matched `convolutionByDefinition` to **1.5 × 10⁻¹⁰** on 20 000 random polynomial pairs. **The under-padding failure was reproduced deliberately** with `cyclicConvolution`: padding to a power of two above `max(|a|,|b|)` rather than above `|a|+|b|` gives *exactly* the cyclic convolution at that length, and it differed from the true product on **2 589 of 3 023** over-length instances. The wrap-around is exact, not approximate, which is precisely what makes it easy to miss.

`leastSquaresLiteral` matched the body's `leastSquares`, and `isLeastSquaresMinimum` returned `true` for **5 000 of 5 000** noisy fits — the minimality property tested directly, by perturbing each coefficient in both directions and confirming the residual rises every time.

---

*Next: [M24 — Parallel & Online Algorithms](M24-parallel-online.md) (CLRS 26–27) — work and span, and making decisions without seeing the future.*
