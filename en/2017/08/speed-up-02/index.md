# Speed Up! Speed Up! Speed Up! (Part 2)


In our last post, we explored how to [accelerate the backup engine](https://mp.weixin.qq.com/s?__biz=MzU4NzA1MTk2Mg==&mid=2247483745&idx=1&sn=c9b28d97eec1426dece66490a9655b43&chksm=fdf0a7b4ca872ea207c5d96dfdac2646fdc1b8a507b5e85cd267fdd720d3dff7d0b5e546680b&scene=21#wechat_redirect) — a critical optimization for maximizing backup performance and improving your RPO.

But that's just one piece of the performance puzzle.

Today, I want to share another game-changing accelerator that Veeam introduced: the vSphere communication acceleration technology. And trust me, the results are absolutely stunning.

## The Broker Service Revolution

Introduced in Veeam 9.5, the Broker Service is one of those features that seems simple on the surface but delivers incredible performance gains in practice.

Here's the concept: Veeam places an intelligent intermediary service between the backup infrastructure and VMware vCenter. Instead of hitting vCenter directly every time it needs information, Veeam can query this cached Broker Service instead.

The difference is dramatic.

![1745GR.jpg](https://s2.ax1x.com/2020/02/12/1745GR.jpg)

Without the Broker Service, every backup job initiates direct communication with vCenter. The response time depends entirely on vCenter's performance and network conditions — factors often outside your control.

With the Broker Service enabled, Veeam queries locally cached information while the Broker handles the heavy lifting of staying synchronized with vCenter.

## Under the Hood

The Broker Service runs as a Windows service that you can see in your Services.msc console:

![1744i9.png](https://s2.ax1x.com/2020/02/12/1744i9.png)

What makes this so efficient is how it handles inventory changes. Any modifications to your VMware vCenter infrastructure — new VMs, changed configurations, moved objects — get pushed in real-time to the Broker's cache.

And for added reliability, if no changes are detected, Veeam automatically forces a cache refresh every 15 minutes (900 seconds) to ensure everything stays accurate.

![174oxx.png](https://s2.ax1x.com/2020/02/12/174oxx.png)

## The Performance Numbers Speak for Themselves

Theory is great, but let's look at real-world performance.

Here's what happened when I tested backup job initialization without the Broker Service. Veeam needed to query vCenter to build the backup VM list, which took a full 40 seconds:

![174IR1.jpg](https://s2.ax1x.com/2020/02/12/174IR1.jpg)

Now, with the Broker Service enabled, the same operation — querying the cached information to create the backup VM list — completed in just 1 second:

![174fIJ.jpg](https://s2.ax1x.com/2020/02/12/174fIJ.jpg)

**That's a 40x performance improvement.**

I'll say that again: **forty times faster.**

This isn't just a marginal gain — it's transformative. Tasks that once took nearly a minute now complete instantly. The impact on large-scale backup operations is simply massive.

## Ready to Fly?

If you want to experience this kind of performance boost in your environment, it's time to upgrade to Veeam 9.5 Update 2. The Broker Service alone makes it worth the upgrade.

## Coming Up Next

Fast backups are incredible, but let's be honest — what really matters in a disaster scenario is recovery speed.

Everyone knows about Veeam's Instant VM Recovery, but what about the other recovery technologies? Are they just as fast?

In our next post, we'll dive deep into Veeam's recovery performance and uncover some surprising results. Trust me, you won't want to miss it.

