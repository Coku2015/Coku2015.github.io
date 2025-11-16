# VAO Basics (Part 9) – Report Template Guide


## Series Index

- [VAO Basics (1) – Introduction](https://blog.backupnext.cloud/_posts/2020-02-17-VAO-Guide-01/)
- [VAO Basics (2) – Installation & Deployment](https://blog.backupnext.cloud/_posts/2020-02-18-VAO-Guide-02/)
- [VAO Basics (3) – Core Components · Part 1](https://blog.backupnext.cloud/_posts/2020-02-19-VAO-Guide-03/)
- [VAO Basics (4) – Core Components · Part 2](https://blog.backupnext.cloud/_posts/2020-02-20-VAO-Guide-04/)
- [VAO Basics (5) – Essential Configuration Notes](https://blog.backupnext.cloud/_posts/2020-02-21-VAO-Guide-05/)
- [VAO Basics (6) – The First Step to a Successful DR Plan](https://blog.backupnext.cloud/_posts/2020-02-25-VAO-Guide-06/)
- [VAO Basics (7) – Plan Steps · Part 1](https://blog.backupnext.cloud/_posts/2020-02-27-VAO-Guide-07/)
- [VAO Basics (8) – Plan Steps · Part 2](https://blog.backupnext.cloud/_posts/2020-02-28-VAO-Guide-08/)
- [VAO Basics (9) – Report Template Guide](https://blog.backupnext.cloud/_posts/2020-03-02-VAO-Guide-09/)

For the final chapter of this series, let’s look at VAO’s documentation system.

VAO automatically generates the disaster-recovery documents you need, based on the configuration and execution of each Orchestration Plan. That means you can focus on running DR while VAO handles the tedious documentation work in the background.

Every report contains two parts: an administrator-defined **Report Template** and the dynamic content that VAO injects according to the **Report Type**. The template always occupies the beginning of the file; the second section is auto-filled with plan-specific data.

Here’s an example:

![3fvwlT.jpg](https://s2.ax1x.com/2020/03/03/3fvwlT.jpg)

The left side shows a generated Readiness Check report; the right side is the template opened in Word. The red boxes highlight the pieces provided by the template. Everything that follows is injected dynamically for that report type.

## Report Types

When you right-click a plan (or use the toolbar) you’ll see the supported report types:

| Report Type            | Purpose                                               |
| ---------------------- | ----------------------------------------------------- |
| Plan Definition Report | Documents every configuration detail in the plan      |
| Readiness Check Report | Verifies resource availability at the recovery site   |
| Datalab Test Report    | Summarizes Datalab test runs                          |
| Execution Report       | Captures the outcome of an actual restore/failover    |

Each type ships with built-in system content. You can’t edit that portion; VAO fills it according to the plan settings and execution data. (At the moment this built-in section is English-only, though any Chinese text you include in the plan still flows through.)

## Report Templates

Templates control the front half of each report. VAO includes default templates in eight languages. They’re read-only but you can **Clone** them to create editable copies. Editing requires Microsoft Word 2010 SP2 or newer installed on the machine running your browser. When you click **Edit**, VAO launches Word locally and connects it to the template.

Unlike a standard Word document, these templates support dynamic fields (variables) that VAO populates later.

## Editing Dynamic Templates in Word

1. Choose a built-in template and click **Clone**. I’ll start from “Veeam Default Template (ZH)”.  
   ![3hiViQ.png](https://s2.ax1x.com/2020/03/03/3hiViQ.png)
2. In the Clone dialog, pick which scope owns the template, provide a name/description, and click **OK**.  
   ![3hi5TS.png](https://s2.ax1x.com/2020/03/03/3hi5TS.png)
3. The new template appears in the list and the toolbar buttons become active. Select it and click **Edit**—this launches Microsoft Word on your workstation.  
   ![3hFmkD.png](https://s2.ax1x.com/2020/03/03/3hFmkD.png)
4. Word requests credentials before opening the document. You must use the same account currently logged into VAO, otherwise the file won’t open.  
   ![3hkOaT.png](https://s2.ax1x.com/2020/03/03/3hkOaT.png)
5. Once open, you’ll notice yellow-highlighted regions: those are the editable sections. Titles, headers, and footers remain locked; everything else is fair game for your text and images.  
   ![3hEw1H.png](https://s2.ax1x.com/2020/03/03/3hEw1H.png)
6. To insert variables, follow VAO’s convention of wrapping the placeholder in brackets, e.g., `[Hi, I’m a variable]`. In Word, enable the **Developer** tab and click **Design Mode**.  
   ![3heF6H.png](https://s2.ax1x.com/2020/03/03/3heF6H.png)
7. Design Mode reveals the hidden control boundaries. Select your placeholder text, click the first **Aa** icon on the Developer tab to convert it into a content control, then click **Properties** to assign a tag/name.  
   ![3hmKV1.png](https://s2.ax1x.com/2020/03/03/3hmKV1.png)
8. Fill in the **Title** and **Tag** fields (I usually make them identical). VAO recognizes the following tags, each beginning with `~`:

   | Tag               | Description                          |
   | ----------------- | ------------------------------------ |
   | ~Created          | Report generation timestamp          |
   | ~TimeZone         | Time zone of the report              |
   | ~PlanType         | Plan type                            |
   | ~PlanName         | Plan name                            |
   | ~PlanDescription  | Plan description                     |
   | ~PlanContactName  | DR contact name                      |
   | ~PlanContactEmail | DR contact email                     |
   | ~PlanContactTel   | DR contact phone                     |
   | ~Site             | Site name                            |
   | ~SiteScopeName    | Site scope name                      |
   | ~SiteDescription  | Site description                     |
   | ~SiteContactName  | Site contact name                    |
   | ~SiteContactEmail | Site contact email                   |
   | ~SiteContactTel   | Site contact phone                   |
   | ~ServerName       | Server name                          |
   | ~VmsInPlan        | VMs included in the plan             |
   | ~GroupsInPlan     | VM groups in the plan                |
   | ~ReportType       | Report type                          |
   | ~TargetRTO        | Target RTO                           |
   | ~TargetRPO        | Target RPO                           |

9. After editing, simply save or close the document—Word pushes the changes back to the VAO server automatically. Don’t use “Save As”, or the file won’t update in VAO.

Back in the VAO UI you can assign your custom template to any plan (per scope). From then on every generated report uses your branded front matter plus VAO’s dynamic data.

That wraps up the VAO Basics series. Thanks for reading, and I hope it helps you get the most from VAO!

