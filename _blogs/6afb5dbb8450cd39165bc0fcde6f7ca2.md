---
layout: article
category: Research
date: 2023-05-31
title: How to record TikTok's live stream on macOS
excerpt: "Recently, I saw some live broadcasts on Douyin that were really interesting, and I wanted to record them. So I studied how to record these live broadcasts. There are two methods: recording the screen and downloading from the push source."
originurl: "/index.html"
---
Recently, I saw some live broadcasts on Douyin that were really interesting, and I wanted to record them. So I studied how to record these live broadcasts. There are two methods: recording the screen and downloading from the push source.

The former is of course the simplest, but there are several problems if you use screen recording:
1. The bitrate of the screen recording is generally much higher than the actual bitrate of the live broadcast, which results in the final recording file being a bit large, but the image quality is average (in this case, transcoding will cause serious image quality loss, which is much higher than the actual bitrate of the live broadcast). The loss of image quality after transcoding of high-definition and high-bitrate videos is much greater)
2. Only one person can be recorded at a time, so it is inconvenient if there are several people.

So the latter is much better than screen recording in terms of convenience and storage. The most critical step in downloading from the push source is: how to obtain the push source.

Since this article is a general introduction to downloading, rather than an introduction to writing scripts for batch downloading (I will write a separate article later and list it here), I will only introduce the steps.

Obtaining the push source is actually very simple. On macOS, downloading videos from the push source only requires a Safari.

First open Safari, go to "Settings" - "Advanced", check "Show the "Develop" menu in the menu bar", as follows:

<img alt="In Settings - Advanced, check Show Develop menu in menu bar" src="/assets/images/dc26346f66957a977f05c991774c20f8.png" style="box-shadow: 0px 0px 0px 0px">

Then open the live broadcast room you want to record, right-click on a blank area of the webpage, click "View Elements", and then you can see the source code, elements and other content of the webpage, as follows:

![Open the Douyin live broadcast room you want to record, right-click a blank area of the web page, and click "View Elements"](/assets/images/8d402f52a20275733073b3b5aace021a.png)

<img alt="Then you can see the source code, elements and other content of the web page" src="/assets/images/4ca31da3b10bf46583c159d83fcb2751.png" style="box-shadow: 0px 0px 0px 0px">

At this time, select the "Network" section, and then search for "flv" in the upper right corner, because Douyin's live streaming uses the flv format. At this time the display is as follows:

<img alt="Select the Network section and search for flv in the upper right corner" src="/assets/images/a4ad3b528ef3c756847542890aeda1a0.png" style="box-shadow: 0px 0px 0px 0px">

Then copy the link of this file and enter it in the search bar, which will directly trigger the download. You can see that the download speed here is the bit rate of the push stream, which means the live broadcast is being recorded:

![Copy the link of this file and enter it in the search bar, it will directly trigger the download. You can see that the download speed here is the bit rate of the push stream, which means the live broadcast is being recorded](/assets/images/7390953c62a4449f8447c10e686f4aa9.png)

So how to terminate the recording? Of course, stop downloading. If the live broadcast is closed, it will become an FLV file. However, if the download is manually paused, the downloaded file will still have the `.download` suffix and cannot be viewed directly with the player.

![The downloaded file at this time still has the `.download` suffix](/assets/images/f89dd961606b56312b075d96729479a8.png)

At this time, you need to right-click, select "Show Package Contents", and then see a flv file. At this time, you can use a supported player such as VLC to view it.

<img alt="You need to right-click at this time and select "Show Package Contents"" src="/assets/images/13bff9b7b0b2b324522e934afd0aa077.png" style="box-shadow: 0px 0px 0px 0px">

<img alt="See a flv file" src="/assets/images/8524f7bfe823c93c90f38945b3c07cc1.png" style="box-shadow: 0px 0px 0px 0px">

But here you will find that there is no way to drag the progress bar, otherwise it will return to the beginning or end playback. So it’s better to transcode it. It’s pretty fast if you use hardware acceleration.

​I hope these will help someone in need~