---
layout: article
category: Research
date: 2026-09-17
title: "Shannon Entropy, Explained"
excerpt: "In physics, entropy measures \"disorder\" or \"chaos.\" Information theory borrows this idea. But here, \"disorder\" means something more specific: how surprising a piece of information is. In other words, how random it is."
originurl: "/assets/original/%E9%A6%99%E5%86%9C%E4%BF%A1%E6%81%AF%E8%AE%BA%E7%AC%94%E8%AE%B0.md"
---

In physics, entropy measures "disorder" or "chaos." Information theory borrows this idea. But here, "disorder" means something more specific: how surprising a piece of information is. In other words, how random it is.

> "How random" isn't very precise on its own. Here's what it really means: how close the probability distribution is to a uniform distribution. The more uniform the distribution, the more random it is.
>
> If a distribution is close to uniform — meaning every outcome is roughly equally likely — we have no strong expectation about what comes next. We simply don't know which outcome will occur.
>
> But if the distribution is uneven, the story changes. Imagine a loaded die. It lands on 6 with 95% probability. Each other number gets only 1%. Now we'd guess it's probably a 6 next time, since that's the overwhelming likelihood. This die produces far less random information than a fair one.

## 1. Shannon Information Entropy

### Self-Information (Surprisal)

The word "self" here means the information content depends only on the event's own probability — nothing else.

$$
I(x) = -\log_2 p(x)
$$

- $p(x)$ is the probability of the event.
- The negative sign keeps the information content non-negative, since $\log_2 p \le 0$ whenever $p \in (0,1]$.

### (Shannon) Information Entropy

Information entropy measures how random a set of outcomes is. The higher the entropy, the more random the outcomes. It's calculated as the sum of self-information across all outcomes:

$$
H(X) = -\sum_{i=1}^{n} p_i \log_2 p_i
$$

- $p_i$ is the probability of the $i$-th outcome.
- All probabilities sum to 1: $\sum p_i = 1$.
- $H$ is the entropy. It can be measured in different units: bits ($\log_2$), nats ($\ln$), or hartleys ($\log_{10}$).

$H$ represents the theoretical minimum number of bits needed, on average, to encode a source. The more random or unpredictable the distribution, the higher $H$ climbs. The more certain the outcome, the lower $H$ drops.

**Range of values:** $0 \le H(X) \le \log_2 n$

- **Lower bound, 0:** One outcome has probability $p_i = 1$. The result is fully certain, so no bits are needed to transmit it.
- **Upper bound, $\log_2 n$:** All outcomes are equally likely. This is the fully uniform, maximally random case.

## 2. Jensen's Inequality Gives Us the Upper Bound

Jensen's inequality, in its concave-function form, states:

$$
f\left(\sum_i p_i x_i\right) \ge \sum_i p_i f(x_i)
$$

Here $f(x) = \log_2 x$ is a concave function.

> Note: math textbooks in China define "concave" and "convex" in the opposite way from the international convention.

Equality holds when every $x_i$ is equal. In our case, $x_i = \frac{1}{p_i}$, so equality holds exactly when all outcomes are equally likely — the uniform distribution.

Substituting $x_i = \frac{1}{p_i}$ into Jensen's inequality gives us:

$$
\begin{aligned}
\log_2\left(\sum_i p_i \cdot \frac{1}{p_i}\right) &\ge \sum_i p_i \log_2 \frac{1}{p_i} \\[4pt]
\underbrace{\log_2\left(\sum_i 1\right)}_{=\ \log_2 n} &\ge \underbrace{-\sum_i p_i \log_2 p_i}_{=\ H(X)} \\[4pt]
\log_2 n &\ge H(X)
\end{aligned}
$$

So $\log_2 n$ is the worst-case benchmark — the maximum possible uncertainty — under a "zero-prior" assumption. In other words, entropy is normally treated as a minimum quantity, but this ceiling on that minimum is exactly what Jensen's inequality gives us.

What is this upper bound actually useful for? Let's walk through four applications.

### Applications of the Upper Bound, $\log_2 n$

#### 1. Engineering: Setting a Safe Upper Limit on Resources

When we don't know a source's true distribution, $\log_2 n$ tells us the maximum number of bits encoding could ever require. Think of "minimum" here as describing an "upper limit" — a safe ceiling. The real result will always fall at or below this ceiling. This lets us design a system in advance, without waiting for real statistics to come in.

Take DNA as an example. It has four bases: A, T, C, and G, so $n = 4$:

$$
H_{max} = \log_2 4 = 2 \text{ bits per base}
$$

No matter how the actual base frequencies distribute in a given species, each base needs at most 2 bits to encode. We can safely design a storage format around 2 bits per base from the start, then optimize compression later based on the real frequencies observed in that species.

#### 2. Measuring Redundancy: $H_{max}$ as the Denominator

$H_{max}$ appears as the denominator in the redundancy formula, $R = 1 - \frac{H}{H_{max}}$. It's the "zero-prior" baseline. Without knowing $H_{max}$, we have no way to say how much redundancy — or savings — a statistical model has actually found.

> "Zero-prior" means we have no knowledge whatsoever of a source's true probability distribution. The only thing we know for certain is how many possible outcomes there are, $n$. Mathematically, the only defensible assumption at that point is equal probability for every outcome. There's no basis for assuming any outcome is more likely than another — any such assumption would just be an unfounded guess.

Take English text as an example: 27 symbols (26 letters plus a space). Then $H_{max} = \log_2 27 \approx 4.75$ bits per symbol. The measured real-world entropy of English is roughly $H \approx 1.0$ to $1.3$ bits per symbol:

$$
R \approx 1 - \frac{1.3}{4.75} \approx 73\%
$$

The number $H = 1.3$ bits on its own tells us nothing about how much redundancy exists in English. We need $H_{max}$ to make that comparison.

#### 3. Judging Compression Potential: Distance from the Upper Bound

If the measured entropy $H$ sits close to $H_{max}$, the source is already close to fully random (uniform), and there's little room left to compress it further. If $H$ sits well below $H_{max}$, there's still plenty of untapped statistical structure — worth digging into with more advanced models, like higher-order N-grams.

Consider two sources, both with $n = 27$ possible symbols:

- **Source A** (a near-random string of characters): measured $H \approx 4.6$ bits, close to the ceiling of $4.75$ bits. This is nearly incompressible. Further encoding tricks won't help much — we're already close to optimal.
- **Source B** (English text): measured $H \approx 1.3$ bits, far below the $4.75$-bit ceiling. This tells us letters are strongly correlated with their neighbors — for example, "q" is almost always followed by "u." That gap is worth chasing: a higher-order statistical model could get us closer to the true entropy and produce better compression, saving bandwidth.

#### 4. Security: The Theoretical Maximum Search Space in Cryptography

$\log_2 n$ tells us the maximum information a single character can carry, in bits. Equivalently, it tells us how many bits are needed to safely store one character, based on how large the character set is.

For a password of length $L$ drawn from a character set of size $n$, the theoretical maximum entropy — the size of the search space a brute-force attack must cover — is:

$$
H_{max} = L \times \log_2 n
$$

**Example:** Take an 8-character password using upper- and lowercase letters plus digits, so $n = 62$:

$$
H_{max} = 8 \times \log_2 62 \approx 8 \times 5.95 \approx 47.6 \text{ bits}
$$

This is the theoretical maximum strength, assuming the password is generated **completely at random**. It would take roughly $2^{47.6}$ attempts to guess by brute force.

But if a human picks the password — something like "password123" — its actual entropy falls far below 47.6 bits. Human-chosen passwords follow strong patterns: common words, birthdays, keyboard sequences, and so on. That gap between the theoretical ceiling and the real value is exactly what dictionary attacks and rainbow tables exploit.

## 3. Redundancy

The redundancy formula, $R$, is:

$$
R = 1 - \frac{H}{H_{max}}
$$

Where:

- $H_{max}$ is the theoretical ceiling, defined as $H_{max} = \log_2 n$.

  > Here, $n$ is the **total number of possible outcomes** a source can produce — how many distinct results the random variable can take.

- $H$ is the measured, or estimated, real-world entropy.

The closer $R$ gets to 1, the more compressible the source is. When $R = 0$, the source is already fully random and cannot be compressed any further.

For example, with English's 27 symbols, $H_{max} \approx 4.75$ and measured $H \approx 1.0$ to $1.3$, giving $R \approx 73\%$.



I hope these will help someone in need~

> This post was translated into English with the help of Claude Sonnet 5, based on the ZhongUncle's original Chinese article.
