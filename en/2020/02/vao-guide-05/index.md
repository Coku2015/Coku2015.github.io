# VAO Basics (Part 5) – Essential Configuration Notes


## Series Index

- [VAO Basics (1) – Introduction](https://blog.backupnext.cloud/_posts/2020-02-17-VAO-Guide-01/)
- [VAO Basics (2) – Installation & Deployment](https://blog.backupnext.cloud/_posts/2020-02-18-VAO-Guide-02/)
- [VAO Basics (3) – Core Components · Part 1](https://blog.backupnext.cloud/_posts/2020-02-19-VAO-Guide-03/)
- [VAO Basics (4) – Core Components · Part 2](https://blog.backupnext.cloud/_posts/2020-02-20-VAO-Guide-04/)
- [VAO Basics (5) – Essential Configuration Notes](https://blog.backupnext.cloud/_posts/2020-02-21-VAO-Guide-05/)
- [VAO Basics (6) – The First Step of a Successful DR Plan](https://blog.backupnext.cloud/_posts/2020-02-25-VAO-Guide-06/)
- [VAO Basics (7) – Plan Step · Part 1](https://blog.backupnext.cloud/_posts/2020-02-27-VAO-Guide-07/)
- [VAO Basics (8) – Plan Step · Part 2](https://blog.backupnext.cloud/_posts/2020-02-28-VAO-Guide-08/)
- [VAO Basics (9) – Document Template Deep Dive](https://blog.backupnext.cloud/_posts/2020-03-02-VAO-Guide-09/)

In the previous articles, we've covered the basic architecture and components of VAO, all of which involve settings in the Administration section—operations that can only be performed by accounts with VAO administrator privileges. VAO administrators can set different Scopes for each application group here and assign these Scopes to relevant personnel for use. This feature enables effective grouping and isolation—isn't this somewhat similar to multi-tenancy or multi-user systems? But there are significant differences.

This article addresses some points worth noting regarding the configurations mentioned earlier.

## Core Infrastructure

**vCenter Addition**

During the installation and initial configuration process, we added vCenter to VAO. If you remember from previous posts, you might have noticed that I never mentioned configuring the embedded VBR and Veeam ONE. Actually, after completing the initial configuration, VAO very intelligently writes the vCenter information we filled in during the initialization phase into both VBR and Veeam ONE. Therefore, we don't need to add it again in VBR and Veeam ONE.

**VBR Addition**

In VAO, you can manage multiple VBR or Enterprise Manager instances. When managing non-embedded VBRs, you simply need to push the VAO Agent from the VAO console to the VBR to take control of that VBR. This operation is also quite simple. Through this method, you can easily manage large-scale backup/disaster recovery environments.

**Active Directory**

In project implementation, many user environments often don't have Active Directory, but VAO requires AD to function, which can be quite a headache. However, when you think about it, this issue is actually quite simple. Everyone can think about VDI projects—they also require AD to work, so wouldn't those projects be in a panic? Not really, because it's simple: if there's no AD, we create one. For project success, we create conditions when they don't exist. This is something that completely doesn't challenge us engineers.

## Scope

Scope is particularly difficult to understand, but once you figure it out, it's actually quite simple. Therefore, for this configuration overview, I strongly recommend everyone go back to my third article to strengthen their understanding of the Scope concept, and through practice, set up some complex scenarios in VAO to understand this Scope. Only through hands-on experience can you truly master Scope and use VAO well. This is the most critical component.

Additionally, for Scope, you can't just look at Scopes from the "Users and Scopes" perspective. You need to look at it from the 2 dimensions of Scope to make this concept vividly appear before us:

1. Users authorized to use this Scope;
2. The 5 major Components included in the Scope and corresponding DataLabs;

## Datalabs

First, understand the configuration of all DataLabs in VBR. If you still don't know how to configure DataLabs in VBR, then you won't be able to use VAO effectively, because this is a necessary component and prerequisite for VAO.

DataLabs configuration in VAO involves almost no operation; it's simply assigned to the corresponding Scope through the Assign action. In VAO, it's very difficult to know how your DataLabs are configured. If we need to use a large number of DataLabs, we might have to go back to VBR and open each configuration one by one to check, which is very unscientific. So I have a great little trick to share with everyone here. In the DataLabs information in VAO, it will get the Name, Description, Platform, and VBR Server Name of this DataLabs from VBR. At this time, everyone can make good use of this Description. You only need to copy the content of the Virtual Lab Summary when creating DataLabs in VBR and paste it into this Virtual Lab's Description. This way, the detailed configuration information about this DataLabs will be read into VAO, and we can clearly know the specific configuration of this DataLabs. As shown in the figure below, this is my final effect.

![3ZScnI.png](https://s2.ax1x.com/2020/02/19/3ZScnI.png)

## Recovery Locations

The configuration is relatively complex, and once set, it becomes fixed. However, this is just a logical combination of compute resources that actually only exists within VAO. Whether in vCenter, VBR, or Veeam ONE, this Recovery Locations will not exist. Therefore, this is also very good news: no matter how this Recovery Locations is set, it will not affect the normal operation of any other components except VAO.

A small tip for everyone: feel free to set up Recovery Locations and combine them recklessly. Even if they won't be used by actual Orchestration Plans, what's the harm in leaving them there? Who knows, maybe one day they'll be needed?

Of course, in the end, we still need to be reasonable here. Configuring reasonably according to needs can reduce the complexity of this system and ultimately achieve efficient disaster recovery services for us.

The above are the configuration points for the Administration section in VAO. Starting from the next article, we will enter the actual usage phase. Thank you for following this series.

