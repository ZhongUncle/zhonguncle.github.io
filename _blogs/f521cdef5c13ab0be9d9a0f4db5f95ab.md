---
layout: article
category: Python
date: 2025-02-09
title: "Access FaceFusion Across Local Network: Fix Gradio Public Link & Port Settings"
excerpt: "Sometimes we want to use FaceFusion on other devices within the local area network (LAN), which requires configuring a publicly accessible link and port."
originurl: "https://blog.csdn.net/qq_33919450/article/details/145539062"
---
Sometimes we want to use FaceFusion on other devices within the local area network (LAN), which requires configuring a publicly accessible link and port.

When you run FaceFusion, you’ll see the following prompt:

```
To create a public link, set `share=True` in `launch()`.
```

However, this prompt is **incorrect**. If you’ve researched this issue, you’ll find it’s a leftover problem from the Gradio framework. While Stable Diffusion Web UI (which also uses Gradio) fixed this by modifying the framework, FaceFusion has not implemented this adjustment.

After extensive searching, I found a user mention that you can directly modify Gradio’s environment variables. I then "drew inferences from one example" and used the same approach to change the port as well.

The solution is extremely simple:

```bash
# Set IP to 0.0.0.0 to allow access from all devices on the current network (default is 127.0.0.1)
export GRADIO_SERVER_NAME="0.0.0.0"

# Set port to 7861 (default is 7860)
export GRADIO_SERVER_PORT="7861"
```

If you want these settings to persist permanently, add the above lines to your Shell configuration file (e.g., `.bashrc`), then run `source .bashrc` to apply the changes immediately.

I hope these will help someone in need~

## References
[Running on local URL but can't access from outside - answeroverflow](https://www.answeroverflow.com/m/1204359671599603762): This post explains how to configure a publicly accessible link for Gradio-based applications.

### 总结
1. FaceFusion运行时提示的`share=True`配置方法无效，该问题源于Gradio框架，且FaceFusion未像Stable Diffusion Web UI那样对框架做定制化修改。
2. 实现局域网访问的核心是修改Gradio环境变量：`GRADIO_SERVER_NAME=0.0.0.0`允许全网段设备访问，`GRADIO_SERVER_PORT`可自定义端口避免冲突。
3. 若需永久生效，将环境变量配置写入`.bashrc`等Shell配置文件，执行`source .bashrc`即可即时生效。