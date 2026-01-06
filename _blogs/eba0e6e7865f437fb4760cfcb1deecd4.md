---
layout: article
category: Go
date: 2025-01-31
title: 'Fix "Symbol Not Found" Error When Installing FaceFusion with Miniconda'
excerpt: "I’d been avoiding Miniconda for as long as possible, but I finally couldn’t escape it—using FaceFusion today required Miniconda. Right at the final step of installing FaceFusion, I encountered the following error"
originurl: "https://blog.csdn.net/qq_33919450/article/details/145402659"
---
I’d been avoiding Miniconda for as long as possible, but I finally couldn’t escape it—using FaceFusion today required Miniconda. Right at the final step of installing FaceFusion, I encountered the following error:

<div style="text-align: center;">
  <img alt="Error message at the final step of FaceFusion installation with Miniconda" src="/assets/images/73753ae9648d46249c71fc34bd20233a.png" style="box-shadow: 0px 0px 0px 0px; width: 70%;">
</div>

The root cause of this issue was that symbols could not be found in the library. This was not a problem with FaceFusion itself, but rather an issue with the Miniconda environment configuration.

Although minor version updates (even patch-level) for Python and its packages may seem insignificant, they often introduce substantial differences—for example, changes to function parameters. This means many projects require specific versions of Python or packages to run correctly. Without a dedicated tool, you’d have to manually install multiple Python versions and packages, then explicitly specify versions (e.g., `Python3.9`) every time you run a program—a cumbersome process. Miniconda addresses this pain point by offering "virtual environments" that automate the management of different Python and package versions for different projects.

However, Miniconda has a quirk: while it includes its own package management functionality, operating systems already have their native package managers (e.g., Homebrew for macOS, APT for Ubuntu). Miniconda sometimes fails to properly recognize or integrate with these system-level package managers, which is exactly what caused my error.

**The solution is surprisingly simple: just install `curl` via Miniconda within the required virtual environment.**

```bash
(facefusion) zhonguncle@zhonguncle-Precision-Tower-5810:~$ conda install curl
Channels:
 - defaults
Platform: linux-64
Collecting package metadata (repodata.json): done
Solving environment: done

## Package Plan ##

  environment location: /home/zhonguncle/miniconda3/envs/facefusion

  added / updated specs:
    - curl


The following packages will be downloaded:

    package                    |            build
    ---------------------------|-----------------
    curl-8.11.1                |       hdbd6064_0          90 KB
    libcurl-8.11.1             |       hc9e6f67_0         454 KB
    ------------------------------------------------------------
                                           Total:         544 KB

The following NEW packages will be INSTALLED:

  c-ares             pkgs/main/linux-64::c-ares-1.19.1-h5eee18b_0 
  curl               pkgs/main/linux-64::curl-8.11.1-hdbd6064_0 
  krb5               pkgs/main/linux-64::krb5-1.20.1-h143b758_1 
  libcurl            pkgs/main/linux-64::libcurl-8.11.1-hc9e6f67_0 
  libedit            pkgs/main/linux-64::libedit-3.1.20230828-h5eee18b_0 
  libev              pkgs/main/linux-64::libev-4.33-h7f8727e_1 
  libnghttp2         pkgs/main/linux-64::libnghttp2-1.57.0-h2d74bed_0 
  libssh2            pkgs/main/linux-64::libssh2-1.11.1-h251f7ec_0 
  lz4-c              pkgs/main/linux-64::lz4-c-1.9.4-h6a678d5_1 
  zstd               pkgs/main/linux-64::zstd-1.5.6-hc292b87_0 


Proceed ([y]/n)? y


Downloading and Extracting Packages:
                                                                                                                                    
Preparing transaction: done                                                                                                         
Verifying transaction: done
Executing transaction: done
```

I came across other solutions suggested in online blogs, but they’re not ideal:
- Some recommended uninstalling Miniconda entirely—this is a drastic "nuke it from orbit" approach that was clearly not feasible for my situation (since I needed Miniconda for FaceFusion).
- Others proposed manually creating symbolic links. While this might work as a temporary fix, it’s by no means a reliable long-term solution—managing symlinks across multiple virtual environments would be extremely tedious and error-prone.

I hope these will help someone in need~