
<!-- README.md is generated from README.Rmd. Please edit that file -->

# wgpugd: A WebGPU Graphics Device for R

<!-- badges: start -->
<!-- badges: end -->

## Overview

### What is WebGPU?

[WebGPU](https://www.w3.org/TR/webgpu/) is an API that exposes the
capabilities of GPU hardware.

### What is wgpu?

As the name indicates, the wgpugd package uses [wgpu](https://wgpu.rs/),
a pure-Rust implementation of the WebGPU standard. wgpu is what’s behind
the WebGPU support of Firefox and Deno, and is widely used over the
Rust’s graphics ecosystem.

### Wait, Rust…? Can we use Rust in R??

Yes! [extendr](https://extendr.github.io/) is the Rust framework for
interacting with R.

### Why WebGPU for R?

The main motivation is to add post-effect to graphics with [WebGPU
Shader Language (WGSL)](https://www.w3.org/TR/WGSL/%3E). But, of course,
the power of GPU should simply contribute to high performance!

## Installation

You can install the development version of wgpugd like so:

``` r
devtools::install_github("yutannihilation/wgpugd")
```

## Usages

:warning: wgpugd is currently at its verrry early stage of the
development! :warning:

``` r
library(wgpugd)

wgpugd(10, 10)

library(ggplot2)
#> Warning in register(): Can't find generic `scale_type` in package ggplot2 to
#> register S3 method.
set.seed(10)
dsamp <- diamonds[sample(nrow(diamonds), 1000), ]
ggplot(dsamp, aes(carat, price)) +
  geom_point(aes(colour = clarity))

dev.off()
#> png 
#>   2

knitr::include_graphics("tmp_wgpugd.png")
```

<img src="tmp_wgpugd.png" width="100%" />

## References

-   wgpugd uses [extendr](https://extendr.github.io/), a Rust extension
    mechanism for R, both to communicate with the actual graphics device
    implementation in Rust from R, and to access R’s graphics API from
    Rust.
-   If you are curious about developing a Rust program with wgpu, I’d
    recommend [Learn Wgpu](https://sotrh.github.io/learn-wgpu/) to get
    started.
-   [lyon](https://github.com/nical/lyon) is a library for “path
    tessellation,” which is necessary to draw lines on GPU.
