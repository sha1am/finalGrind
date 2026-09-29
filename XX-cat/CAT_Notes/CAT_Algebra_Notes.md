# Algebra Notes for CAT (Quantum CAT – Chapter 13)

---

## Start here

Algebra is one of the biggest parts of CAT Quant. The book says roughly a third of QA questions touch algebra in some way. The good news: most of them need logic, not heavy calculation, and many can be cracked by checking the options.

These notes cover Chapter 13, "Elements of Algebra", in simple words. Each section has three things:

- **The idea** in plain language
- **The formula or rule** to remember
- **A small example** so you see it working

**How to use them:** read one section, close the notes, and try to say the rule out loud. Then do the matching questions from the book. Theory alone won't be enough here, practice is where algebra clicks.

**What's inside:** basic words of algebra → types of expressions → operations → functions and graphs → remainder and factor theorem → HCF/LCM → formulas → linear equations → solving methods → word problems → CAT shortcuts → final checklist.

---

## 1. The basic words of algebra

Algebra is just normal maths where some numbers are replaced by letters. Letters follow the same rules as numbers.

| Word | What it means | Example |
| --- | --- | --- |
| Literal | A letter that stands for a number | x, y, a, b |
| Constant | A value that never changes | 4, −3, 2/5 |
| Variable | A value that can change | length l, side a |
| Term | A piece of an expression, separated by + or − | In 7 + 3x − 2y², the terms are 7, 3x, −2y² |
| Coefficient | The number (or letter) multiplied with the rest of the term | In 4xy, the number coefficient is 4 |
| Constant term | The term with no letter in it | In 3x² + 7x + 8, it is 8 |
| Like terms | Terms with exactly the same letters and powers | 7xy, 4xy, −xy |
| Unlike terms | Terms whose letters or powers differ | 3x and 5x²y |

**Rules worth remembering**

- Write 4x, not x4. Write x, not 1x.
- x × 0 = 0, but x ÷ 0 is not defined. Never divide by zero.
- Any number to the power 0 is 1. So x⁰ = 1.
- A constant mixed with a variable becomes a variable. So 5x, 5 + x, x/5 are all variables.
- Multiplication and division do **not** split terms. 7x is one term. x/7 is also one term.

**Coefficient trick:** in 4xy, the coefficient of x is 4y, the coefficient of y is 4x, and the coefficient of xy is 4. Whatever is left after removing the part you're asking about is its coefficient.

---

## 2. Types of expressions and polynomials

An **algebraic expression** is numbers and letters joined by +, −, ×, ÷. We name it by how many terms it has.

| Name | Number of terms | Example |
| --- | --- | --- |
| Monomial | 1 (mono = one) | 3x, −5y, 12xy² |
| Binomial | 2 (bi = two) | 3x + 4y |
| Trinomial | 3 (tri = three) | x² + 2x + 1 |
| Polynomial | many (poly = many) | 3x⁴ − 7x³ + 3xy + 8 |

### What makes something a polynomial?

Every power of the variable must be a **whole number (0, 1, 2, 3 …)**. No negative powers, no fractional powers.

- x² − 3x + 4 → polynomial ✓
- x³ − 3x² + 4√x → **not** a polynomial, because √x = x^(1/2)
- x³ − 2x + 1/x² → **not** a polynomial, because 1/x² = x^(−2)
- 8 → polynomial of degree 0 (think of it as 8x⁰)

### Degree = the highest power

- One variable: just look for the biggest power. 7x⁵ + 3x² + 8 has degree 5.
- Two or more variables: add the powers **inside each term**, then take the biggest total.
  - 8x² − 5xy + 3x → term degrees are 2, 1+1 = 2, 1 → degree is **2**
  - 9a³b² + 12b³ → term degrees are 3+2 = 5, 3 → degree is **5**

### Substitution

Substitution means putting a number in place of the letter.

Example: if x = −3, find 4x² − 5x + 3.
→ 4(9) − 5(−3) + 3 = 36 + 15 + 3 = **54**

**Watch out:** always put negative numbers inside brackets. (−3)² = 9, but −3² = −9.

---

## 3. Adding, subtracting, multiplying, dividing

### Add and subtract: only like terms

You can only combine like terms. Add their coefficients, keep the letters the same.

- 2x + 3x + 4x = 9x
- 5xy + (−3xy) = 2xy
- 7x + 5x² stays as it is (unlike terms, can't be joined)

### The bracket sign rule

- **+ before a bracket** → open it, signs stay the same.
- **− before a bracket** → open it, **every** sign inside flips.

Example: (4x − 5y + 3z) − (3x + 2y − z) = 4x − 5y + 3z − 3x − 2y + z = **x − 7y + 4z**

Most silly mistakes in algebra happen right here. Flip every sign, not just the first one.

### Multiply: every term with every term

Multiply numbers with numbers, letters with letters, and add the powers of the same letter.

- 6xy × 7x² = 42x³y
- (a + b)(c + d) = ac + ad + bc + bd
- (5x − 4)(3x + 5) = 15x² + 25x − 12x − 20 = 15x² + 13x − 20

### Divide: cancel common parts, subtract powers

- x⁶ ÷ x⁴ = x²
- 35x³y² ÷ 7x²y² = 5x
- Dividing a long expression by one term? Divide **each** term separately.

### Long division of polynomials

Same idea as dividing numbers. Example: divide 2x² + 5x + 4 by x + 1.

1. How many times does x go into 2x²? **2x**. Multiply: 2x(x + 1) = 2x² + 2x. Subtract → 3x + 4.
2. How many times does x go into 3x? **3**. Multiply: 3(x + 1) = 3x + 3. Subtract → 1.
3. Nothing left to divide. **Quotient = 2x + 3, Remainder = 1.**

Check using: Dividend = Divisor × Quotient + Remainder → (x + 1)(2x + 3) + 1 = 2x² + 5x + 4 ✓

---

## 4. f(x) and graphs

### What is f(x)?

f(x) is just a name for an expression in x. It's like a machine: you put in x, it gives back a value.

If f(x) = x³ + 2x, then f(3) means "put 3 wherever you see x":
f(3) = 27 + 6 = **33**

The general form of a polynomial of degree n is:

> f(x) = a₀xⁿ + a₁xⁿ⁻¹ + a₂xⁿ⁻² + … + aₙ  (where a₀ ≠ 0)

### Drawing a graph

1. Pick a few x values (some negative, zero, some positive).
2. Work out y for each one.
3. Plot the (x, y) points and join them.

### Two shapes you must recognise

| Equation type | Highest power | Shape of graph | Example |
| --- | --- | --- | --- |
| Linear | 1 | Straight line | y = 2x + 1 |
| Quadratic | 2 | U-shaped curve (parabola) | y = x² + 2x − 3 |

For y = x² + 2x − 3, the curve cuts the x-axis at x = −3 and x = 1. Those are exactly the values where y = 0. This link between "where it cuts the x-axis" and "roots" comes back in the Quadratic Equations chapter.

---

## 5. Remainder theorem and factor theorem

These two save you from doing long division. They are very CAT-friendly.

### Remainder theorem

**Idea:** to find the remainder when f(x) is divided by something, set the divisor = 0, find x, and put that x into f(x). The answer is the remainder.

| Divisor | Set it to 0 | Remainder |
| --- | --- | --- |
| x − a | x = a | f(a) |
| x + a | x = −a | f(−a) |
| ax + b | x = −b/a | f(−b/a) |

**Example 1:** remainder when x³ − 2x + 5 is divided by (x − 2)?
x − 2 = 0 → x = 2 → f(2) = 8 − 4 + 5 = **9**

**Example 2:** remainder when 4x² + 2x + 1 is divided by (2x − 1)?
2x − 1 = 0 → x = 1/2 → f(1/2) = 1 + 1 + 1 = **3**

**Example 3 (finding an unknown):** x³ + 2x² + kx − 4 leaves remainder 5 when divided by (x − 1). Find k.
f(1) = 1 + 2 + k − 4 = k − 1. Set k − 1 = 5 → **k = 6**

### Factor theorem

**Idea:** if the remainder is 0, the divisor is a factor.

- If f(a) = 0 → (x − a) is a factor.
- If f(−a) = 0 → (x + a) is a factor.
- If f(−b/a) = 0 → (ax + b) is a factor.

**Example:** is (x − 3) a factor of x² − 5x + 6?
f(3) = 9 − 15 + 6 = 0 → **Yes.**

### Two quick checks (save time in the exam)

- **Is (x − 1) a factor?** Add all the coefficients. If the sum is 0, yes. (Because f(1) is just the sum of coefficients.)
- **Is (x + 1) a factor?** Sum of coefficients of even powers = sum of coefficients of odd powers? Then yes. (Remember the constant term counts as an even power, x⁰.)

Example: x³ − 6x² + 11x − 6 → 1 − 6 + 11 − 6 = 0, so (x − 1) is a factor.

---

## 6. HCF, LCM and simplifying fractions

### HCF and LCM of polynomials

Works just like HCF and LCM of numbers. First break each polynomial into factors.

- **HCF** → take only the **common** factors, each with its **smaller** power.
- **LCM** → take **every** factor that appears, each with its **bigger** power.

**Example:** P = (x + 1)²(x − 2)³ and Q = (x + 1)³(x − 2)(x + 4)

- HCF = (x + 1)²(x − 2)
- LCM = (x + 1)³(x − 2)³(x + 4)

### The golden rule

> **P(x) × Q(x) = HCF × LCM**

Use it when one polynomial is missing.

**Example:** HCF = (x − 1), LCM = (x − 1)(x + 2)(x + 3), and one polynomial is (x − 1)(x + 2). Find the other.
Other = HCF × LCM ÷ given = (x − 1)·(x − 1)(x + 2)(x + 3) ÷ [(x − 1)(x + 2)] = **(x − 1)(x + 3)**

### Rational expressions (algebra fractions)

A rational expression is one polynomial divided by another, P(x)/Q(x), where Q(x) ≠ 0.

- Every polynomial is a rational expression (just divide by 1).
- But not every rational expression is a polynomial.

**To simplify:** factorise the top and the bottom, then cancel what's common.

**Example:** (x² − 4) / (x² + 4x + 4) = (x − 2)(x + 2) / (x + 2)² = **(x − 2)/(x + 2)**

---

## 7. Must-know formulas (learn these by heart)

These identities solve a huge number of CAT questions. Write them on a card and revise daily.

### Squares

- (a + b)² = a² + 2ab + b²
- (a − b)² = a² − 2ab + b²
- (a + b)² = (a − b)² + 4ab
- (a − b)² = (a + b)² − 4ab
- a² + b² = ½ [(a + b)² + (a − b)²]
- a² − b² = (a + b)(a − b)
- (a + b + c)² = a² + b² + c² + 2(ab + bc + ca)

### Cubes

- (a + b)³ = a³ + b³ + 3ab(a + b)
- (a − b)³ = a³ − b³ − 3ab(a − b)
- a³ + b³ = (a + b)(a² − ab + b²)
- a³ − b³ = (a − b)(a² + ab + b²)

### The special one (asked a lot)

> a³ + b³ + c³ − 3abc = (a + b + c)(a² + b² + c² − ab − bc − ca)

**Shortcut:** if a + b + c = 0, then a³ + b³ + c³ = 3abc. Spot this instantly in questions.

Example: find 7³ + (−3)³ + (−4)³. Since 7 − 3 − 4 = 0, answer = 3 × 7 × (−3) × (−4) = **252**.

### Fourth and eighth powers

- a⁴ + a²b² + b⁴ = (a² + ab + b²)(a² − ab + b²)
- a⁴ − b⁴ = (a − b)(a + b)(a² + b²)
- a⁸ − b⁸ = (a − b)(a + b)(a² + b²)(a⁴ + b⁴)

### Bonus: the "x + 1/x" family

CAT loves these. Just use (a + b)² with b = 1/x.

- If x + 1/x = k, then x² + 1/x² = k² − 2
- If x + 1/x = k, then x³ + 1/x³ = k³ − 3k
- If x − 1/x = k, then x² + 1/x² = k² + 2

Example: x + 1/x = 3 → x² + 1/x² = 9 − 2 = **7**

---

## 8. Cyclic expressions and Σ (sigma) notation

This part looks scary but is simple. It's only a short way of writing long, repeating expressions.

### What Σ means here

Σ means "write this term, then rotate the letters x → y → z → x, and add all three versions".

- Σx = x + y + z
- Σxy = xy + yz + zx
- Σx²(y − z) = x²(y − z) + y²(z − x) + z²(x − y)

### Results worth knowing

| Expression | Value |
| --- | --- |
| Σ(x − y) | 0 |
| Σ(x² − y²) | 0 |
| Σx(y − z) | 0 |
| Σx²(y − z) | −(x − y)(y − z)(z − x) |
| Σx(y² − z²) | (x − y)(y − z)(z − x) |
| Σ(x − y)³ | 3(x − y)(y − z)(z − x) |

The last one is really the a + b + c = 0 shortcut again: (x − y) + (y − z) + (z − x) = 0.

### How to factorise a cyclic expression

1. Arrange terms in falling powers of one letter (say x).
2. Group terms to pull out a common factor.
3. Repeat with the next letter until nothing more comes out.

A useful result you get this way:

> (x + y)(y + z)(z + x) = (x + y + z)(xy + yz + zx) − xyz

**Exam tip:** in cyclic questions, put simple values like x = 0, y = 1, z = 2 in the question and in each option. The option that matches is your answer. Much faster than factorising.

---

## 9. Linear equations

### Basics

- **Equation** = a statement with an "=" sign and at least one letter. Example: 4x = 12.
- **Linear equation** = highest power of the letter is 1. Example: x + y = 10.
- **Solution** = the value(s) that make both sides equal.

### Rules for solving (whatever you do to one side, do to the other)

- Add or subtract the same number on both sides.
- Multiply or divide both sides by the same **non-zero** number.
- **Transposing:** move a term to the other side and flip its sign. x + 5 = 12 → x = 12 − 5.

### Graph facts

- ax + by = c is always a **straight line**.
- x = k is a vertical line (parallel to y-axis).
- y = k is a horizontal line (parallel to x-axis).
- One equation in two variables has **infinitely many** solutions (every point on the line).
- Two lines meet at a point → that point is the solution of both.

### Two equations: how many solutions? (very important)

For a₁x + b₁y = c₁ and a₂x + b₂y = c₂, compare the ratios of the coefficients.

| Condition | Lines look like | Number of solutions | Name |
| --- | --- | --- | --- |
| a₁/a₂ ≠ b₁/b₂ | Cross at one point | Exactly one | Consistent, independent |
| a₁/a₂ = b₁/b₂ = c₁/c₂ | Lie on top of each other | Infinitely many | Consistent, dependent |
| a₁/a₂ = b₁/b₂ ≠ c₁/c₂ | Parallel, never meet | None | Inconsistent |

**Easy memory line:** first two ratios different → one answer. All three equal → endless answers. First two equal but third different → no answer.

**Example:** for what k do 9x + 4y = 9 and 7x + ky = 5 have **no** solution?
Need 9/7 = 4/k (and ≠ 9/5, which is true). So k = **28/9**.

**Example:** 2x + y = 11 and 6x + 3y = 33 → every coefficient is 3 times the first. Same line, infinitely many solutions.

### Unique solution needs enough equations

You can pin down one exact answer only when you have **at least as many independent equations as unknowns**. Two unknowns need two genuinely different equations. Three unknowns need three.

---

## 10. Solving two equations: 4 methods

We'll solve the same pair every time so you can compare:
**2x + 3y = 12** and **x − y = 1**. Answer: x = 3, y = 2.

### Method 1: Substitution

Make one letter the subject, then put it into the other equation.
From x − y = 1 → x = y + 1. Put in the first: 2(y + 1) + 3y = 12 → 5y = 10 → y = 2, so x = 3.

**Best when** one equation already has a lone x or y.

### Method 2: Elimination (most used)

Make the coefficient of one letter the same, then add or subtract to kill it.
Multiply x − y = 1 by 2 → 2x − 2y = 2. Subtract from 2x + 3y = 12 → 5y = 10 → y = 2.

**Best when** numbers are small and clean.

### Method 3: Comparison

Write x in terms of y from both equations, then set them equal.
x = (12 − 3y)/2 and x = 1 + y → (12 − 3y)/2 = 1 + y → 12 − 3y = 2 + 2y → y = 2.

### Method 4: Cross multiplication (formula method)

For a₁x + b₁y = c₁ and a₂x + b₂y = c₂:

> x = (c₁b₂ − c₂b₁) / (a₁b₂ − a₂b₁)
> y = (a₁c₂ − a₂c₁) / (a₁b₂ − a₂b₁)

Here a₁ = 2, b₁ = 3, c₁ = 12, a₂ = 1, b₂ = −1, c₂ = 1.
Bottom = (2)(−1) − (1)(3) = −5. x = (−12 − 3)/(−5) = 3. y = (2 − 12)/(−5) = 2.

**Best when** numbers are ugly and elimination gets messy.

### Tricky-looking equations (turn them into normal ones)

**1. Letters in the denominator → rename them.**
3/x + 2/y = 12 and 2/x + 3/y = 13.
Let A = 1/x, B = 1/y → 3A + 2B = 12 and 2A + 3B = 13. Solve: A = 2, B = 3. So x = 1/2, y = 1/3.

The same trick works for whole brackets. If you see 1/(3x + 2y) and 1/(3x − 2y), call them A and B.

**2. Swapped coefficients → add and subtract.**
In the pair above, the numbers 3 and 2 swap places. Add both: 5A + 5B = 25 → A + B = 5. Subtract: A − B = −1. Now it's instant: A = 2, B = 3.

**3. Decimals → multiply by 10 or 100 first.**
0.04x + 0.02y = 5 becomes 4x + 2y = 500, then 2x + y = 250.

**4. Brackets → open them and tidy up first.**
4(x − 3) = 3(y + 3) becomes 4x − 3y = 21.

**5. Three unknowns → eliminate one letter using two pairs of equations.** That leaves two equations in two letters. Then solve as usual. In CAT, checking the options is often faster.

---

## 11. Word problems → equations

Most CAT algebra questions are stories. Your job is to turn the story into equations.

### 4-step method

1. **Name the unknowns.** Use letters that remind you: s for son, f for father.
2. **Translate each sentence** into one equation.
3. **Solve.**
4. **Check** the answer in the original story (or just test the options).

### English → maths dictionary

| Words | Maths |
| --- | --- |
| is, was, will be, gives | = |
| more than, added to, increased by | + |
| less than, decreased by | − |
| times, of, product | × |
| per, ratio, divided by | ÷ |
| 5 less than x | x − 5 (careful with the order!) |

### Common types with quick examples

**Heads and legs** — 20 animals (hens and goats) have 56 legs. How many goats?
If all were hens: 40 legs. Extra legs = 16. Each goat adds 2 extra → **8 goats**.
Shortcut: goats = (total legs − 2 × heads) ÷ 2. Same logic works for bikes/cars and tyres.

**Ages** — Father is 4 times his son. In 5 years, he'll be 3 times the son.
f = 4s and f + 5 = 3(s + 5) → 4s + 5 = 3s + 15 → s = 10, f = **40**.
Remember: both people age by the same amount.

**Coins** — 30 coins of ₹2 and ₹5 make ₹99. How many ₹5 coins?
a + b = 30 and 2a + 5b = 99. Subtract 2 × first → 3b = 39 → **b = 13**.

**Fractions** — numerator is 3 less than denominator. Add 2 to both and you get 3/4.
Let denominator = d → (d − 1)/(d + 2) = 3/4 → 4d − 4 = 3d + 6 → d = 10. Fraction = **7/10**.

**Speed** — two cars meet faster moving towards each other (speeds add) and slower moving the same way (speeds subtract). Write one equation for each case.

**Tip:** in CAT, plug each option into the story. The one that fits every sentence is correct. This often beats solving from scratch.

---

## 12. CAT shortcuts (from the chapter's CAT-Test questions)

The practice set at the end of this chapter keeps using a few ideas that aren't spelled out in the theory. Learn these and many "hard" questions become 30-second ones.

### Shortcut 1: AM ≥ GM (for positive numbers only)

The average of positive numbers is always at least their geometric mean. Equality happens only when all numbers are equal.

> (a + b) / 2 ≥ √(ab)

What this means in practice:

- **Sum fixed → product is biggest when all parts are equal.** If a + b = 10, max of ab = 5 × 5 = 25.
- **Product fixed → sum is smallest when all parts are equal.** If abcd = 16, min of a + b + c + d = 2 + 2 + 2 + 2 = 8.

If the parts are shifted, like (a − 3)(b − 2)(c + 1), make the shifted parts equal, not a, b, c themselves.

### Shortcut 2: ready-made inequalities (for positive a, b, c)

| Result | When is it exactly equal? |
| --- | --- |
| x + 1/x ≥ 2 | x = 1 |
| (x + y)(1/x + 1/y) ≥ 4 | x = y |
| (a + b + c)(1/a + 1/b + 1/c) ≥ 9 | a = b = c |
| (a + b)(b + c)(c + a) ≥ 8abc | a = b = c |
| (a + b + c)(ab + bc + ca) ≥ 9abc | a = b = c |

If the question says the numbers are **distinct**, the answer is "strictly greater than".

### Shortcut 3: whole-number solutions of ax + by = c

CAT often asks "how many natural-number solutions?"

1. Find one solution by trying small values.
2. Then step: increase one letter by the other letter's coefficient, decrease the other accordingly.
3. Count until one of them goes to 0 or negative.

**Example:** 3x + 5y = 47, x and y natural numbers.
y = 1 → x = 14. Now each time y goes up by 3, x goes down by 5.
(14, 1), (9, 4), (4, 7) → next would make x negative. **3 solutions.**

### Shortcut 4: put easy values

If a question works "for all x" or for any a, b, c, choose simple numbers (0, 1, 2 or all equal). Test each option. Wrong options drop out fast.

### Shortcut 5: work backwards from options

Algebra options are usually numbers. Put each into the question. Start with the middle option so you know whether to go up or down.

---

## Last-minute revision checklist

Tick each one only when you can do it without looking.

- [ ] I can tell like terms from unlike terms, and find any coefficient.
- [ ] I can say whether an expression is a polynomial and find its degree.
- [ ] I flip **every** sign when opening a bracket with − in front.
- [ ] I can do long division and check it with Dividend = Divisor × Quotient + Remainder.
- [ ] Remainder theorem: set divisor = 0, put that x into f(x).
- [ ] Factor theorem: remainder 0 means it's a factor.
- [ ] Sum of coefficients = 0 → (x − 1) is a factor.
- [ ] HCF = common factors, smaller powers. LCM = all factors, bigger powers. P × Q = HCF × LCM.
- [ ] I can write all the identities from memory.
- [ ] a + b + c = 0 → a³ + b³ + c³ = 3abc.
- [ ] x + 1/x = k → x² + 1/x² = k² − 2.
- [ ] Two equations: one solution, infinite solutions, or none, using the ratio table.
- [ ] I can use substitution, elimination and cross multiplication.
- [ ] I rename 1/x or 1/(bracket) as A and B.
- [ ] AM ≥ GM: fixed sum → max product at equal parts. Fixed product → min sum at equal parts.
- [ ] I can count whole-number solutions of ax + by = c.
- [ ] I test options or easy values before doing long algebra.

**Common mistakes to avoid**

- Forgetting brackets around negative numbers: (−3)² = 9, but −3² = −9.
- Cancelling terms instead of factors: (x + 2)/2 is **not** x + 1.
- Dividing both sides by a letter that might be 0 — you can lose a solution.
- Using AM ≥ GM when the numbers could be negative. It only works for positive numbers.
