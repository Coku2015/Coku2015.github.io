# Making VBR Login More Secure: A Complete Guide to v13 SAML + Azure EntraID Integration


In version v13, the most significant new features focus on enhanced security capabilities. Starting with this article, I'll provide a detailed walkthrough of the new security features introduced in v13 through practical applications.

Today, let's start with authentication. In enterprise-level backup architectures, the security of management console accounts and access governance is critically important. Veeam Backup & Replication (VBR) now supports SAML-based Single Sign-On (SSO) in v13, which means you can centralize authentication to your organization's existing Identity Provider (IdP) — such as Azure EntraID. Through SAML integration, you can unify the management of VBR login with your company's account lifecycle, group policies, MFA, and auditing: operations become clearer, permission revocation is more timely, and you achieve higher compliance. This article uses Azure EntraID as an example to demonstrate this integration in detail. For other similar solutions like Authing in China or international options like Okta and Auth0, you can follow the Azure methods to try them out.



## Configuration Prerequisites

To configure and use SAML integration, the prerequisites are quite straightforward — simply install VBR using the latest Veeam Software Appliance. Of course, since we're using network services, there are some necessary conditions for configuring SSO:

- The VBR server must be able to access Azure EntraID-related endpoints.
- Time synchronization — VBR must have NTP server correctly configured with no time deviation. SAML is timestamp-based, and authentication will fail if there's a time mismatch.
- Azure EntraID administrator account with permissions to create enterprise applications and assign users.
- VBR administrator permissions — this is fundamental for configuring VBR accounts and identity integration.
- The Windows system where the VBR Console is installed must be able to correctly resolve the VBR hostname or FQDN, otherwise the URLs in the SP/IdP Metadata won't match.

## Configuration Method

The following configuration is divided into Azure and VBR sections and has a specific order, so it's recommended to proceed sequentially.

### Generate SP Information in VBR and Export Metadata

1. First, log in to the VBR console using the veeamadmin account. In VBR, click the hamburger icon (three horizontal lines) in the top-left corner and select `Users and Roles` from the dropdown menu.

![Xnip2025-09-24_17-55-19](https://s2.loli.net/2025/09/24/qy8vVwXd1gTJCUZ.png)

2. Switch to the newly added Identity Provider interface in v13. By default, `Enable SAML Authentication` is unchecked. Check it to enable, and you'll see the Service Provider (SP) Information section below. In identity authentication, VBR now acts as the application's Service Provider (SP), so we need to install a certificate for VBR first. Click Install.

![Xnip2025-09-24_17-57-13](https://s2.loli.net/2025/09/24/vPmNyV2KuMIeaSf.png)

3. You can select one from the local certificate store. Choose `Select an existing certificate from the certificate store` and click Next.

![Xnip2025-09-24_18-05-26](https://s2.loli.net/2025/09/24/pmOMAduU3aLvrSh.png)

4. In the certificate store, find the certificate with Friendly Name `Veeam Backup Server Certificate` and click Finish to complete.

![Xnip2025-09-24_19-28-09](https://s2.loli.net/2025/09/24/qQ36kWyloODrenZ.png)

5. At this point, you'll see that Certificate information has appeared in the SP Information section, showing `CN=<backup server FQDN>`. For the next steps, we need to click the Download button below Install to download the XML file from the SP side and save it properly. This file will be used when configuring Azure later.

### Upload SP Metadata in Azure EntraID and Assign Users

1. First, create a security group for VBR, named VBR Users. Add a user to this group — for example, I added my own account.

![Xnip2025-09-24_19-40-09](https://s2.loli.net/2025/09/24/6ArDuKk4c5nmC9j.png)

2. In EntraID, find Enterprise apps. We need to create a new Application for VBR identity authentication. Click `New Application` to create one.

![Xnip2025-09-24_19-42-30](https://s2.loli.net/2025/09/24/1oCcNp9ZVa4HSA2.png)

3. When creating, don't select from the catalog. Click `Create your own application` and in the popup dialog on the right, enter the app name, then select `Integrate any other application you don't find in the gallery (Non-gallery)`. For example, I named mine vbrsso.

![Xnip2025-09-24_19-44-43](https://s2.loli.net/2025/09/24/9ip6ufav1oPqAb4.png)

4. After this Application is created, it will automatically switch to the Application Overview interface. The Getting Started interface clearly lists the next steps. You can configure them one by one according to steps 1, 2, 3, 4, 5 as needed. For VBR, we only need to configure two: `Assign users and groups` and `Set up single sign on`.

![Xnip2025-09-24_19-53-39](https://s2.loli.net/2025/09/24/5U38hXekxZHgv9f.png)

5. After assigning the Group created in step 1, VBR Users, to this application, click the second step, `Set up single sign on`, which will take you to the single sign-on configuration interface. Here, we choose the SAML option to integrate with VBR.

![Xnip2025-09-24_19-55-58](https://s2.loli.net/2025/09/24/MVTL9FXKoy5keui.png)

6. After entering the SAML configuration interface, you'll see clearly listed steps 1-2-3-4, but we don't need to edit the content here one by one. Simply find `Upload metadata file` at the top, click it, upload the XML file we just exported from VBR, and save to complete the single sign-on configuration. After uploading, you can see that the URLs in Basic SAML Configuration have been correctly updated to my VBR's FQDN.

![Xnip2025-09-24_19-59-11](https://s2.loli.net/2025/09/24/xhUFLdrAP82qXSI.png)

7. Next, find the SAML Certificates box in step 3 of the image above, and on the last line next to Federation Metadata XML, click the Download button to download another automatically-generated XML file from Azure EntraID.

![Xnip2025-09-24_20-03-36](https://s2.loli.net/2025/09/24/Usl1VRH9LrATicq.png)

At this point, all Azure configurations are complete.



### Return to VBR to Update IdP Information Configuration

1. Go back to the Identity Provider interface under Users & Roles in VBR. Find the Identity Provider (IdP) Information settings. This is the identity provider information for single sign-on, where Azure EntraID acts as the identity provider. Click Browse next to it and upload the XML file just downloaded from Azure. After uploading, you'll see that all IdP information below has been correctly updated to Microsoft's URLs.

![Xnip2025-09-24_20-10-12](https://s2.loli.net/2025/09/24/5fZX7jxBQDIrSah.png)

2. After clicking OK to complete the settings, we can reopen `Users and Roles` to add users. After clicking `Add...`, you'll see the `External user or group` option. Select it.

![Xnip2025-09-24_20-15-01](https://s2.loli.net/2025/09/24/Ha4YEzhSA27O1tR.png)

3. In the Add User dialog that pops up, enter the complete Azure EntraID email address. For example, mine is `lei.wei@xbbm365.backupnext.cloud`.

![Xnip2025-09-24_20-17-04](https://s2.loli.net/2025/09/24/RC9eID4i5OmVzSN.png)

4. Now, the entire configuration is complete. Let's test the login. Open the VBR client, and you'll see that the `Sign in with SSO` option has appeared on the client. Click this directly.

![Xnip2025-09-24_20-20-38](https://s2.loli.net/2025/09/24/gIzswZoxpBbDqiP.png)

5. After clicking, the login window will automatically pop up with the standard Microsoft login interface. After entering the password, Microsoft's MFA approval for login will also pop up.

![Xnip2025-09-24_20-22-44](https://s2.loli.net/2025/09/24/WyT7Rhi4qKlXbDI.png)

6. After approval from the phone Authenticator, the VBR Console can successfully jump to login.
7. Let's try the web interface as well. In the WebUI, we can also see the new "Sign in With SSO" option.

![Xnip2025-09-24_20-26-16](https://s2.loli.net/2025/09/24/Pqj25XhY68Mok31.png)

8. Similarly, after approving the login, we can access the Veeam-permissioned Web UI. In the top-right corner of the Web UI, we can also see that the accessing user's account and email are correctly displayed.

![Xnip2025-09-24_20-29-11](https://s2.loli.net/2025/09/24/JDPmahNHG849E6B.png)

### View Login Audit Information in Azure

In the Azure EntraID management audit interface, you can clearly see the login information from VBR.

![Xnip2025-09-24_20-50-56](https://s2.loli.net/2025/09/24/U8HrSw5j374KCmk.png)



## Configuration Summary

Following the method above, the integration between VBR and Azure EntraID can be easily configured. It's worth noting that users configured this way are only users of the backup system. They cannot log in to the Appliance's Veeam Management Console like the veeamadmin and veeamso accounts. This SSO account cannot manage the Appliance.

From a security perspective, this configuration effectively separates the permissions of the backup system. The backup system's identity authentication is completely separated from the backup infrastructure accounts, which better complies with the usage standards of large enterprises and organizations.
