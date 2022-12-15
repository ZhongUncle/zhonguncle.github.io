```
\int_{a}^b f(x) \ dx = \lim_{\|p\| \to 0} \sum_{i=1}^{n} f(\stackrel{-}x_i)\Delta x_i
```
![](/assets/images/define_integral.png)

```
x_i &=  \tfrac{ri}{n}, \ \Delta x_i= \tfrac{r}{n} \\ 
\int_{0}^r 2 \pi r\ dx  &= \lim_{n \to \infty} \sum_{i=1}^{n} f(x_i)\Delta x_i  \\ 
&= \lim_{n \to \infty} \sum_{i=1}^{n} 2\pi \cdot  \tfrac{ri}{n}  \cdot \tfrac{r}{n} \\
&= \lim_{n \to \infty} 2\pi  \tfrac{r^2}{n^2} \sum_{i=1}^{n} i \\
&= \lim_{n \to \infty} 2\pi  \tfrac{r^2}{n^2} \tfrac{n(n+1)}{2} \\
&= \lim_{n \to \infty} (\pi r^2  + \tfrac{\pi r^2}{n}) \\
&= \lim_{n \to \infty} \pi r^2  + \lim_{n \to \infty}  \tfrac{\pi r^2}{n} \\
&=\pi r^2
```
![](/assets/images/pir2dein.png)