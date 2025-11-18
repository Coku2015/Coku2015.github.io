# VAO Basics (Part 3) – Core Components · Part 1


## Series Index

- [VAO Basics (1) – Introduction](https://blog.backupnext.cloud/_posts/2020-02-17-VAO-Guide-01/)
- [VAO Basics (2) – Installation & Deployment](https://blog.backupnext.cloud/_posts/2020-02-18-VAO-Guide-02/)
- [VAO Basics (3) – Core Components · Part 1](https://blog.backupnext.cloud/_posts/2020-02-19-VAO-Guide-03/)
- [VAO Basics (4) – Core Components · Part 2](https://blog.backupnext.cloud/_posts/2020-02-20-VAO-Guide-04/)
- [VAO Basics (5) – Key Configuration Points](https://blog.backupnext.cloud/_posts/2020-02-21-VAO-Guide-05/)
- [VAO Basics (6) – The First Step of a Successful DR Plan](https://blog.backupnext.cloud/_posts/2020-02-25-VAO-Guide-06/)
- [VAO Basics (7) – Plan Step · Part 1](https://blog.backupnext.cloud/_posts/2020-02-27-VAO-Guide-07/)
- [VAO Basics (8) – Plan Step · Part 2](https://blog.backupnext.cloud/_posts/2020-02-28-VAO-Guide-08/)
- [VAO Basics (9) – Document Template Deep Dive](https://blog.backupnext.cloud/_posts/2020-03-02-VAO-Guide-09/)

VAO defines a special set of concepts for the components it uses. Names may change as releases evolve, but this article reflects v2.0 (and later). If a future version changes again, I’ll update it in a later post.

## Scope

#### Definition & Purpose

Scope is the most fundamental concept in VAO, first introduced in v2.0. Each scope contains the elements a DR plan needs; VAO refers to them collectively as **Plan Components**:

```
 - VM Groups
 - Recovery Locations
 - Plan Steps
 - Credentials
 - Template Jobs
```

Picture a scope as a room. The furniture in that room corresponds to the components above. When we create an Orchestration Plan, we select and arrange those components—like furniture—to build a one-click recovery workflow.

In addition, each scope has one or more DataLabs of its own. In other words, every scope has one or more dedicated DataLabs. We’ll go deeper into Plan Components and DataLabs in [Part 4](https://blog.backupnext.cloud/_posts/2020-02-20-VAO-Guide-04/).

#### Types & Creation

Scopes fall into two categories. The first is the built-in `Default` scope, which can neither be renamed nor deleted. The **Administrators** role lives exclusively in this scope. If you want to grant any user the ability to perform `Administration` tasks, you must add that user to the Administrators role under `Default`. Recall from Part 2: the account we added during the initialization wizard was automatically placed in this role. You can add more administrative users later.

The second category is every additional scope you create. These can be renamed or deleted, and their roles are limited to **Plan Authors**. Under each scope’s Plan Authors role, you assign whichever users you want. Example:

![3F05i6.png](https://s2.ax1x.com/2020/02/18/3F05i6.png)

If the “room” analogy helps: each scope is a room with a lock. You cut different keys for different users. Key **A** opens room A, key **B** opens room B, etc. Translating that into VAO permissions:

```
Rooms (Scopes): A, B, C, D

User 1 holds the keys for rooms A and B.
User 2 holds the keys for rooms B, C, and D.
User 3 holds the key for room D.
```

Which in VAO terms becomes:

```
Scope A: User 1
Scope B: User 1, User 2
Scope C: User 2
Scope D: User 2, User 3
```

To assign those keys, log in with an account that has the Administrator role and open **Administration → Permissions → Users and Scope**:

![3k3G4J.png](https://s2.ax1x.com/2020/02/18/3k3G4J.png)

After saving the assignments, if User 1 logs in again, the Dashboard shows exactly which scopes they can access (for User 1 that means A and B):

![3k38N4.png](https://s2.ax1x.com/2020/02/18/3k38N4.png)

#### Assigning Plan Components

Still under **Administration → Permissions**, switch to **Plan Components**. Here you decide which components each scope can use. The selector in the red box lets you check one or multiple scopes. Technically you can configure several scopes at once, but to avoid mistakes I recommend selecting and configuring one scope at a time.

![3k3YC9.png](https://s2.ax1x.com/2020/02/18/3k3YC9.png)

## DataLabs

A VAO DataLab is simply the Virtual Lab you configured in VBR. Once a Virtual Lab exists in VBR, VAO detects it and lets you assign it to scopes. Each Virtual Lab can be assigned to **exactly one** scope.

To assign a DataLab, log in as an Administrator, go to **Administration → Permissions → Datalab Assignment**, select the Virtual Lab in the middle column, and click **Assign**. Choose the scope in the pop-up dialog:

![3kt6XR.png](https://s2.ax1x.com/2020/02/18/3kt6XR.png)

Need to move it to another scope? Select the Virtual Lab and click **Unassign**. Once unassigned, you can assign it elsewhere.

#### Lab Groups

If you’re used to VBR’s Virtual Lab, Application Group, SureBackup Job—you might wonder where the latter two went. In VAO, Application Groups correspond to **Lab Groups**. You won’t find them in the Administration console; instead, each user signs into their own VAO UI, goes to **DataLabs**, and creates Lab Groups under their scope. Lab Groups aren’t inherited from VBR—they’re created from scratch inside VAO.

![3kwKJK.png](https://s2.ax1x.com/2020/02/18/3kwKJK.png)

Usually Lab Groups can remain empty, just like Application Groups. Only when an application has dependencies—i.e., one VM depends on another—do you add those supporting systems to the Lab Group.

![3kwMRO.png](https://s2.ax1x.com/2020/02/18/3kwMRO.png)

As for SureBackup jobs: VAO no longer needs you to configure them separately. SureBackup is baked directly into each Orchestration Plan. We’ll dive deeper into that in later chapters.

That’s it for this installment—thanks for reading!

