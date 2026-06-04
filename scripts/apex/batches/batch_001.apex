// Power PDF KB import — Batch 1 (articles 11–60)
List<Knowledge__kav> articles = new List<Knowledge__kav>();

articles.add(new Knowledge__kav(
    Title = 'User Not Appearing in Cloud Licensing Admin Portal After Email Change',
    UrlName = 'user-not-appearing-in-cloud-licensing-admin-portal-after-email-change-ppdf-11',
    Resolution__c = '1. Review Current Attribute Mappings\nGo to\nMicrosoft Entra ID\n(Azure AD)\nNavigate to\nEnterprise Applications\nSelect your\nPower PDF\napplication\nClick\nProvisioning\nin the left menu\nSelect\nAttribute Mappings\n2. Minimize Attribute Mappings\nIn the Attribute Mappings section, review all mapped attributes\nRemove any additional attributes\nnot essential for basic user provisioning\nEnsure your mapping includes\nonly the minimal required attributes\n(as shown in this screenshot). Typically, these are:\nuserPrincipalName\n→\nuserName\nSwitch([IsSoftDeleted],,"False","True",True","False")\n→\nactive\ndisplayName\n→\ndisplayName\nmail\n→\nemails[type eq "work"].value\nobjectId\n→\nexternalId\n3. Save and Test Configuration\nSave\nthe updated attribute mapping\nGo to the\nProvisioning\nsection\nClick\nRestart provisioning\nMonitor provisioning logs for new errors\n4. Verify User Provisioning\nWait 10–15 minutes for the provisioning cycle to complete\nCheck the\nCloud Licensing Admin Portal\nConfirm the user appears under\nProducts\nwith the correct email\nIf the Issue Persists\nAdditional Troubleshooting\nGo to\nMicrosoft Entra ID\n→\nEnterprise Applications\n→\nPower PDF\n→\nProvisioning\nOpen\nProvisioning logs\nFind the error entry for the affected user\nClick the error to view details\nTake a screenshot\nof the error details, especially from the\n"Troubleshooting & Recommendations"\ntab\nNote:\nIn a couple of instances, the externalID field had to be removed in order to reprovision some users:',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'Cloud License Server license verification',
    UrlName = 'cloud-license-server-license-verification-ppdf-12',
    Resolution__c = 'The following process outlines the steps required to obtain a license for the Power PDF installation. Please adjust your backend accordingly.\nThe license administration is available at\nhttps://admin.ppdf.tungstencloud.com/\nThe Power PDF desktop application performs license validation in three steps:\n1. Sign in the user if not already signed in:\nSystem browser opens\nhttps://login.ppdf.tungstencloud.com/ppdfclsprdeuaadb2c.onmicrosoft.com/b2c_1a_powerpdf/oauth2/v2.0/authorize\n?...\n2. Check the user\'s assigned tenants (organizations):\nHTTP POST\nhttps://licensecheck.ppdf.tungstencloud.com/api/license/tenant\n3. Check the user\'s product license:\nHTTP POST\nhttps://licensecheck.ppdf.tungstencloud.com/api/license/check\nAll URIs are standard HTTPS endpoints listening on port 443, with certificates issued by a regular CA.',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'License Activation Server and Software Download Disruption',
    UrlName = 'license-activation-server-and-software-download-disruption-ppdf-13',
    Resolution__c = 'Tungsten Automation Partners and Customers (all products and solutions).\nWe experienced network issues affecting some of our internal IT systems. We have successfully restored functionality to all core systems.\nIf you encounter any licensing issues going forward, please\nopen a Critical Case\nwith Tungsten Automation Technical Support via the\nTungsten Automation Customer Portal\n. Partners should register issues through the\nTungsten Automation Partner Portal\n. We will make every effort to provide new activation codes within the same business day.',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'How to reopen a closed Support Case',
    UrlName = 'how-to-reopen-a-closed-support-case-ppdf-14',
    Resolution__c = 'Question / Problem:\nHow to reopen a closed Support Case?\nAnswer / Solution:\nSupport Cases are closed sometimes automatically by the Support Portal Software. This happens if, after a certain period, no feedback is received from our customer. Closed Cases can be reopened 14 days after that they have been closed. If the Case is older then 14 days, you will have to open a new Case. You can refer to the old Case by the old Case Number.\nTo reopen a closed Case, you need to login to your Kofax Support Account and click on Cases and then on My Cases.\nHere choose "My Closed Cases" from the menu on the left hand side.\nSearch for the closed Case in question and click on the Case Number. The closed Case will be shown. Click on "Re-open closed Case" to reopen the closed case.',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'Customizations: Adding, Updating, Troubleshooting and how to contact Professional Services',
    UrlName = 'customizations-adding-updating-troubleshooting-and-how-to-contact-professional-s-ppdf-15',
    Resolution__c = 'Customizations, even if delivered by Tungsten Automation Professional Services, are not part of standard Tungsten Automation support. If you are looking to modify a customization, or if you encounter a problem with an existing customization, and you require Tungsten Automation assistance to address it, you would need to contact Tungsten Automation Professional Services to request an engagement.\nTungsten Automation Technical Support would be unable to comment on or assist with customization related issues.\nDetails on Tungsten Automation Professional Services and how to contact them are available here:\nhttps://www.TungstenAutomation.com/professional-services\nor via email at:\nPSBusinessDevelopment@TungstenAutomation.com\nLevel of Complexity\nEasy',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'Enhancement Requests',
    UrlName = 'enhancement-requests-ppdf-16',
    Resolution__c = 'An Enhancement Request has been logged.\nWhat is the general process for Enhancement Requests?\nIs there a timeline associated with an enhancement?\nProduct Management periodically evaluates Enhancement Requests for\npossible\ninclusion in a future major release.\nTheir possible inclusion (or not), prioritization, and timing are determined by market needs and the functional/development level of complexity.\nEnhancements that are completed will be noted in the Release Notes of major releases or service packs, which will be available in the relevant Product documentation set available\nhere\n.\nFor details on how to receive notifications about releases and updates, refer to the\nRelease Announcements\narticle, which outlines how this can be achieved via the\nCommunity\n, and bookmark it as explained in the "\nFollow or bookmark a discussion\n" section.',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'Technical Specification Documents for Tungsten Automation products',
    UrlName = 'technical-specification-documents-for-tungsten-automation-products-ppdf-17',
    Resolution__c = 'You can find technical specification documentation for Tungsten Automation products centralized under the\nhttps://docshield.tungstenautomation.com/\nsite.\nLevel of Complexity\nEasy',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'How to contact Tungsten Automation Professional Services',
    UrlName = 'how-to-contact-tungsten-automation-professional-services-ppdf-18',
    Resolution__c = 'For details on the services and solutions that Tungsten Automation Professional Services offer, click on the following link:\nProfessional Services and Consulting\nTo contact Tungsten Automation Professional Services for inquiries, orders, or information, please email:\nPSBusinessDevelopment@tungstenautomation.com\nOr alternatively, you can reach out directly to your\nTungsten Automation Account Executive.\nFor\nTungsten Automation Partners:\nContact your Account Executive (Sales) or your Alliance Manager (\nTungsten Automation Partner organization\n).\nSee Also:\nRequesting assistance for a product upgrade, migration, or a new installation, and how to contact Professional Services\nWhat to do when there is a problem with a customization, or I want to add or update a customization, and how to contact Professional Services',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'Requesting assistance for a product upgrade, migration or a new installation, and how to contact Professional Services',
    UrlName = 'requesting-assistance-for-a-product-upgrade-migration-or-a-new-installation-and-ppdf-19',
    Resolution__c = 'New installations, system modifications, migrations and upgrades are not covered by the Tungsten Automation support maintenance contract. However, our Professional Services can be engaged to provide assistance in planning and executing such a project.\nDetails on Tungsten Automation Professional Services and how to contact them are available here:\nhttps://www.tungstenautomation.com/professional-services\nor via email at:\nPSBusinessDevelopment@tungstenautomation.com\nLevel of Complexity\nEasy',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'Product Release and Sunset Schedules',
    UrlName = 'product-release-and-sunset-schedules-ppdf-20',
    Resolution__c = 'You can check the\nProduct Release and Sunset Schedules\nfor more information about release, limited and end of support for Tungsten Automation products.\nLevel of Complexity\nEasy',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'Sales Support',
    UrlName = 'sales-support-ppdf-21',
    Resolution__c = 'Please navigate to Sales Support contact page for quoting, pricing, orders, and non-technical inquiries:\nSales Support',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'Rebranding Kofax to Tungsten Automation FAQ',
    UrlName = 'rebranding-kofax-to-tungsten-automation-faq-ppdf-22',
    Resolution__c = 'Information:\nSee the link below for FAQ regarding Kofax\'s rebranding to Tungsten Automation.\nhttps://www.tungstenautomation.com/faq\nIf you still require assistance regarding billing, taxes (W9), name change, or invoicing, please send an email to\nar.ams@tungstenautomation.com',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'Is Power PDF affected by the CVE-2026-34621',
    UrlName = 'is-power-pdf-affected-by-the-cve-2026-34621-ppdf-23',
    Resolution__c = 'Power PDF doesn\'t implement the related functions or similar functions and is therefore not affected by the CVE.',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'Print & Workplace - Tungsten Automation Requirements for Remote Sessions',
    UrlName = 'print-workplace-tungsten-automation-requirements-for-remote-sessions-ppdf-24',
    Resolution__c = 'Necessary requirements for remote sessions involving access to end customers\' server where Tungsten Automation software is installed. These requirements ensure smooth communication, effective troubleshooting, and compliance with contractual obligations.\n1. Access Requirements:\nRemote Access\n: Partners/customers should provide reasonable remote access to the servers where Tungsten Automation software is installed.\nLevel of Control\n: While full control may not always be granted due to security concerns, partners/customers should allow for a level of access that enables effective troubleshooting and support.\nOptions for Access\n: This may include direct access to the servers, utilizing a jump box or sub-system designated for support purposes, or consideration of providing a jump box by the customer for remote access.\n2. Knowledge of Software:\nAll Parties\n: The designated contact person should possess sufficient knowledge of Tungsten Automation software to administer it and fulfill support obligations.\nPartner Support:\nThe designated case contact is required to be properly trained/certified in Tungsten Automation software to administer and fulfill support obligations, including but not limited to, driving remote sessions.\nDirect Support:\nThe designated case contact should possess sufficient knowledge in Tungsten Automation software to administer and fulfill support obligations, including but not limited to, driving remote sessions.\n3. Minimum Requirements for Remote Sessions:\nCommunication Channels\n: Ensure clear communication channels (e.g., chat, voice call) are established prior to the remote session.\nScreen Sharing\n: Partners/customers should be able to share their screen to facilitate visual inspection and troubleshooting.\nPermission Levels\n: Define the permission levels required for different types of remote access (e.g., view-only access, control access).\nPreferred Tools\n: The preferred tools for remote sessions include:\nTeamViewer\nMicrosoft Teams with Remote Access control\nWindows Quick Assist\nWebEx\n4. Disclaimers:\nRequirements\n: If the above requirements are not met, the company may be relieved from its obligations until all requirements are met if deemed critical.\nDiscussion and Resolution\n: During discussions regarding access limitations, partners/customers should maintain a level of control while accommodating the company\'s requests to the extent possible.\nThis KB serves as a reference guide for all parties involved in remote sessions, emphasizing the importance of collaboration, communication, and adherence to contractual obligations.',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'Obtaining a Power PDF download',
    UrlName = 'obtaining-a-power-pdf-download-ppdf-25',
    Resolution__c = 'For license of Power PDF purchased directly from Tungsten Automation (formerly Kofax), your order confirmation email will contain your download information and download time limit. For physical software purchased in a retail location, your software would be located in the box.\nIf you have lost your digital download or physical media, please contact technical support for options to obtain a replacement download.\nPlease note:\nTungsten Automation cannot provide downloads to software that is past End of Support, trial versions, OEM builds, or OEM Bundles. Tungsten Automation no longer offers replacement physical media.',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'Power PDF registration, activation, and download information',
    UrlName = 'power-pdf-registration-activation-and-download-information-ppdf-26',
    Resolution__c = 'Power PDF for Business (formally Power PDF Advanced Volume)\nPower PDF Standard & Advanced (Non-volume versions)\nPower PDF for Business\n(formally Power PDF Advanced Volume)\nRegistration\nTerms and SaaS licenses\nFor Power PDF for Business Term and SaaS licenses you may sign up and register your Cloud License Server tenant using the following link:\nhttps://admin.ppdf.kofaxcloud.com/\nTo setup your Cloud License Server tenant please follow the Cloud License Server Guide on our\nDocumentation Portal\n.\nIf you are planning to use our on-premise\nTungsten License Server\nin lieu of the Cloud License Server please consult the License Server section of our\nNetwork Deployment Guide\n.\nFor Legacy Serial Keys:\nYour key was registered to your organization at the time of ordering, no further action is needed to register.\nActivation\nPlease consult the\nNetwork Deployment Guide\n. for instructions for deploying Power PDF for Business. Activation will automatically be handled based on the licensee type you are using and the configuration chosen.\nDownload\nPower PDF for Business may be obtained from our\nTungsten Automation EDelivery Portal\n.\nPower PDF Standard & Advanced\n(Non-volume versions)\nRegistration\nPower PDF Standard and Power PDF Advanced licenses are registered through\nhttps://register.kofax.com/serialregistration\n.\nPower PDF Advanced Volume licenses are non-transferable and are automatically registered to the organization at the time of purchase.\nActivation\nAn activation wizard will automatically appear after installation of Power PDF. Follow the onscreen prompts to activate your software.\nVersions of Power PDF prior to 3.1 will require our Activation Fix Utility ran in order to activate with Kofax. The tool may be downloaded at the following location:\nhttps://supportcontent.kofax.com/KDI_Activation_Fix/KDI%20Activation_Fix.zip\nExtract package, run Sethosts.exe and follow the on-screen prompts.\n*Note if you have already tried to activate Windows may have cached the location, please launch your Windows Command prompt and run the command "ipconfig /flushdns "\nClick Start, Type CMD, select Command Prompt. Type ipconfig /flushdns and press enter. Once complete try again to activate with the activation tool running.\nPower PDF will automatically deactivate upon uninstall.\nDownload\nDownload instructions for\nPower PDF Standard\nand\nPower PDF Advanced\npurchased direct from Kofax are included with your original order confirmation email. Downloads are available for the period of time stipulated in our order confirmation. Kofax is unable to provide downloads for software past the end of support date.',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'How to resolve “License could not be checked” error caused by Webex DLL interference in Power PDF',
    UrlName = 'how-to-resolve-license-could-not-be-checked-error-caused-by-webex-dll-interferen-ppdf-27',
    Resolution__c = 'Eliminate Webex DLL Interference (Primary Fix):\nNavigate to:\nC:\\Program Files (x86)\\Webex\\Plugins\\\nRename or move the\ncomponents\nfolder.\nRelaunch Power PDF.\nThis resolved:\nLicensing error\nSlow performance\nApplication crashes\n(Optional) Repair Microsoft Visual C++ Redistributables:\nRepair/reinstall:\nMicrosoft Visual C++ 2015–2022 (x86 & x64)\n(If needed) Clean Reinstallation:\nUninstall Power PDF\nReboot system\nReinstall the latest version\nLaunch app before opening PDFs',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'Power PDF for Mac - Quick Links',
    UrlName = 'power-pdf-for-mac-quick-links-ppdf-28',
    Resolution__c = 'Power PDF - Quick Links\nKnowledge and Solutions\nMost Helpful Knowledge\n(FAQ’s) Most common issues where knowledge can help\nSearch the Knowledge Portal\nDocumentation and Help files\nLinks to documentation help files\nTungsten Automation Community\nJoin the Tungsten Automation Community Discussion\nContacting Support\nProduct Information\nProduct Release Information\nProduct Download\nKofax eDelivery site\nLicensing and Subscriptions\nLicense or subscription purchase and renewal information\nOther Services\nTungsten Automation Learning Cloud\nProduct Training and Certification\nProfessional Services\nProduct implementations, upgrades, and consulting to get the most out of your Tungsten Automation solution',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'Power PDF - Quick Links',
    UrlName = 'power-pdf-quick-links-ppdf-29',
    Resolution__c = 'Knowledge and Solutions\nMost Helpful Knowledge\n(FAQ’s) Most common issues where knowledge can help\nSearch the Knowledge Portal\nDocumentation and Help files\nLinks to documentation help files\nTungsten Automation Community\nJoin the Tungsten Automation Community Discussion\nContacting Support\nProduct Information\nProduct Release Information\nProduct Download\nKofax eDelivery site\nLicensing and Subscriptions\nLicense or subscription purchase and renewal information\nOther Services\nTungsten Automation Learning Cloud\nProduct Training and Certification\nProfessional Services\nProduct implementations, upgrades, and consulting to get the most out of your Tungsten Automation solution',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'A custom button in an interactive form did not work in Power PDF (file-specific).',
    UrlName = 'a-custom-button-in-an-interactive-form-did-not-work-in-power-pdf-file-specific-ppdf-30',
    Resolution__c = 'To resolve the issue, follow these steps:\n1.\nVerify the Form’s Field Logic\n:\no\nOpen the eIntakeForm in Power PDF’s form editing mode.\no\nCheck the field properties for the Address checkboxes.\no\nEnsure that each checkbox has unique field names or IDs.\n2.\nInspect the Form’s Scripting\n:\no\nReview the JavaScript or other scripting logic controlling the toggling behavior of the checkboxes.\no\nEnsure that the script dynamically adjusts for multiple accused entries and does not conflict with existing field names.\n3.\nTest the Form\n:\no\nAdd multiple records and test the toggling behavior of the checkboxes for each entry.\no\nVerify that the checkboxes toggle correctly for all accused entries.\n4.\nApply Fix Pack 10\n:\no\nIf the issue persists, ensure that the customer is using\nTungsten Power PDF Business 5.1.1 Fix Pack 10\n, which addresses similar issues with interactive forms.\n5.\nRegression Testing\n:\no\nSince this form has been escalated previously, conduct thorough regression testing to ensure that the fix does not introduce new issues elsewhere in the form.',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'Power PDF did not detect ScanSnap iX500 scanners.',
    UrlName = 'power-pdf-did-not-detect-scansnap-ix500-scanners-ppdf-31',
    Resolution__c = 'To resolve this issue, follow one of the two solutions below:\nSolution 1: Apply Registry Fix Manually\nBack Up the Registry\n:\nOpen the Windows Registry Editor by pressing\nWin + R\n, typing\nregedit\n, and pressing Enter.\nBefore making any changes, back up the registry:\nGo to\nFile > Export\n.\nSave the backup in a secure location.\n2. Create the Missing Registry Keys\n:\nOpen a text editor (e.g., Notepad) and paste the following content:\nWindows Registry Editor Version 5.00\n\n[HKEY_LOCAL_MACHINE\\SOFTWARE\\WOW6432Node\\PFU\\ScanSnap Extension\\Tungsten Power PDF Advanced]\n@="C:\\\\Program Files\\\\Tungsten\\\\Power PDF 2025\\\\ScanSnapAdapterU.exe"\n"Adapter"="C:\\\\Program Files\\\\Tungsten\\\\Power PDF 2025\\\\bin\\\\PowerPDF.exe"\n"Config"="C:\\\\ProgramData\\\\Kofax\\\\PDF\\\\V1\\\\ScanSnap.ini"\n"Path"="C:\\\\Program Files\\\\Tungsten\\\\Power PDF 2025"\n3. Save and Import Registry File\n:\nSave the file as\nScanSnapFix.reg\n.\nDouble-click the saved\n.reg\nfile to import it into the Windows Registry.\nConfirm any prompts to apply the changes.\n4. Restart the Computer\n:\nRestart the computer to ensure the registry changes take effect.\n5. Test the Scanner\n:\nOpen Power PDF 2025.3 and verify that the Fujitsu ScanSnap scanners are now visible and functional.\nSolution 2: Update Tungsten Power PDF to Fix Compatibility\nTungsten Automation released\nPower PDF Business 2025.3 Update 2\n, which addresses the issue where ScanSnap iX500 scanners were not detected.\nDownload the Update\n:\nVisit the official Tungsten Power PDF release notes:\nPower PDF 2025.3.2 Update\n.\nInstall the Update\n:\nFollow the instructions provided in the update documentation to install the patch.\nTest the Scanner\n:\nVerify that the Fujitsu ScanSnap scanners are now working with the updated version of Power PDF.',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'Getting Help with Power PDF',
    UrlName = 'getting-help-with-power-pdf-ppdf-32',
    Resolution__c = 'Help, Documentation, and Tutorials\nAll Help and Documentation is located in Power PDF under the Help/Online Help menu\nOnline documentation for Power PDF is located on\nKofax DocShield\nCheck out the latest Power PDF articles in the\nKofax Knowledge Base\nContacting Technical Support\nStill need assistance, contact Technical Support:\nEnterprise Customers\nDo you have Power PDF for Business (Advanced Volume) license with valid M\naintenance, Term, or SaaS\nAgreement?\nVolume License customers with an active agreement, please log in to the\nSupport Portal\nto raise support issues. Partners, please register your issues in the\nPartner Portal\n.\nDo you need a Support Portal Account?\nIf you have a\nvalid contract\nand wish to request a portal account, you can\naccess the requirements\nfor access on the\nCustomer Portal Account Request page\n.\nGlobal Technical Support Contact Information\nRetail Customers\nDo you have a Power PDF Standard or Advanced, single-user license, purchased through an online or retail store\n?\nOpen a Support Case\n*Single user licenses include a\n90 day warranty\n. Support beyond the warranty period is not available. For warranty assistance, please open a case via our online form. A valid case number is required to access our\nphone system\n.\neStore Customer Service\nDo you have an issue with our Kofax Online Order, please contact our eStore Customer Service\neStore Customer Service\n‎(888) 247-1614 (USA/Canada)\n‎+31 88 000 0008 (International)',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'How to Disable Thumbnail Generation for PDF Files in Windows 11',
    UrlName = 'how-to-disable-thumbnail-generation-for-pdf-files-in-windows-11-ppdf-33',
    Resolution__c = 'To disable thumbnail generation for PDF files in Windows 11, follow the steps below based on your version of Power PDF:\nSteps to Disable Thumbnail Generation\nOpen the\nCommand Prompt\nwith administrative privileges:\nPress\nWin + S\n, type\ncmd\n, right-click on\nCommand Prompt\n, and select\nRun as administrator\n.\nRun the appropriate command for your version of Power PDF:\nPower PDF 2025.3\nregsvr32 /u "c:\\Program Files\\Tungsten\\Power PDF 2025\\bin\\zThumb.dll"\nPower PDF 5.1\nregsvr32 /u "C:\\Program Files (x86)\\Kofax\\Power PDF 51\\bin\\zThumb.dll"\nPower PDF 5.0\nregsvr32 /u "C:\\Program Files (x86)\\Kofax\\Power PDF 5\\bin\\zThumb.dll"\nIf you installed Power PDF in a custom location, adjust the file path in the command accordingly.\nAfter running the command, you should see a confirmation message indicating that the DLL has been successfully unregistered.\nRestart your computer to apply the changes.',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'How to collect x32 & x64 bit log files for Power PDF 2025.3',
    UrlName = 'how-to-collect-x32-x64-bit-log-files-for-power-pdf-2025-3-ppdf-34',
    Resolution__c = 'When logging is needed for Power PDF 2025.3, log files for both 64 and 32 bit processing should be collected.\n64-Bit:\nTo enable 64 bit logging,\nfirst remove/rename RECDIAG_LOG.ini which is 1kb in size\nthen rename the file \'RECDIAG_LOG.in_\' to \'RECDIAG_LOG.ini\' file found in the installation folder which is typically "C:\\Program Files\\Tungsten\\Power PDF 2025".\nIn some cases, renaming this file will require admin rights, but this depends on the customers environment and user permissions\n32-Bit:\nTo enable 32 bit logging,\nfirst remove/rename RECDIAG_LOG.ini which is 1kb in size\nrename the file \'RECDIAG_LOG.in_\' to \'RECDIAG_LOG.ini\' file found in the x64 folder within the installation folder which is typically " C:\\Program Files\\Tungsten\\Power PDF 2025\\x86".\nOnce the \'RECDIAG_LOG.ini\' file is in place in both locations, create a folder named \'RECDIAG\' in the C:\\TEMP folder for the logs to be written.\nIf this folder is not manually created before testing, the logs will not be created (C:\\temp\\recdiag).\nPower PDF should start writing logs to C:\\temp\\recdiag as soon as the software is launched.\nWhen testing is complete, be sure to rename the file \'RECDIAG_LOG.ini\' back to \'RECDIAG_LOG.in_\' so Power PDF does not continue logging, and send those to the support team',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'Having issues resizing PDFs with Power PDF. It is taking an unusual amount of time to resize documents. Even ones as small as 1 GB. The screen shows not responding more than 4 minutes.',
    UrlName = 'having-issues-resizing-pdfs-with-power-pdf-it-is-taking-an-unusual-amount-of-tim-ppdf-35',
    Resolution__c = 'Power PDF Fixpack 5.1.1.11 resolves the document-reducing slowness issue.\nFrom fixpack 5.1.1.11 readme file\nIssues resolved in this fix pack\n809847\n: Document reduction time increased since fix pack 5.1.1.2.',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'How to show Purview Information Protection label notification bar - by default since in version 5.1 its designed to not now by default',
    UrlName = 'how-to-show-purview-information-protection-label-notification-bar-by-default-sin-ppdf-36',
    Resolution__c = 'ISSUE:\nHow to show the Microsoft Purview Information Protection label notification bar - by default not shown after fixpack 5.1 fixpack 10 or later updates are applied - and this cannot be controlled within the network customization tool kit.\nWhere is this stored?\nSOLUTION:\nMicrosoft Purview Information Protection is a feature that is enabled in the base install and can be leveraged.\nYou can check your Security tab to see if it is there (see below) and when configured, we only prompt the label and user for authentication beyond fixpack 10 updates or later is configured and deployed for Power PDF 5.1 *and when they open an encypted document.\nA PDF itself saved with only a sensitivty label will not prompt or show a label.\nThere is a registry key, which we expect it to be set this way [out of the box; hiding the label banner]\n[HKEY_CURRENT_USER\\Software\\Kofax\\PDF\\Kofax Power PDF\\Preference]\n"ShowNotificaton"=dword:00000000 [Disabled]\nEnabled would should look like this; and this key can be pushed out to impact the checkbox in the below screenshot:\n"ShowNotificaton"=dword:00000001 [Enabled]\nThis has been also proposed to be added to the network customization tool kit but it currently has to be set via the current user registry since the new features were introduced in late 2025 with the power PDF 5.1 and 2025.3 releases [for business] offering improved Microsoft Purview document encryption abilities and features for the product.\nAfter reviewing this and planning the deployment; please open a support ticket should further questions need to be reviewed on Microsoft Purview document encryption workflows.',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'An error occurred during authorization appears with the iManage Connector in 5.1 fixpack 12',
    UrlName = 'an-error-occurred-during-authorization-appears-with-the-imanage-connector-in-5-1-ppdf-37',
    Resolution__c = 'Issue:\nAfter installing fixpack 12 to update power PDF 5.1; iManage users are reporting single sign on challenges, with the pop up\n"An error occurred during authorization" appearing when normally would complete the authentication process using the same configuration.\nCause:\nPower PDF’s work 10 connector client ID has been changed away from the documented value of: ‘00fb6221-3f3f-4b48-85e1-d2e49c8fd44f’ and instead tries to connect with ‘client_id=a150b9d5-8767-42a0-96ff-874c3e2600bc’ which causes the log in exchange to fail on iManage cloud and those that authenticate without SSO, username/password are unaffected\nSolution and fix ETA:\nPower PDF engineering has produced a fix for this issue, which is available from Support as a fixed copy of imanage10.dll as well at this link to "i\nManage10 devbin.zip\n"\nThis will be included in the upcoming fixpack 14 release, which is going through the release process and documentation and is planned to be available next week by the end of February 2026.',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'Power PDF 5.1 fixpack 12 fails to authenticate into iManage displaying the IManage 10 Connection error \'NoneType\' object has no attribute \'get\'',
    UrlName = 'power-pdf-5-1-fixpack-12-fails-to-authenticate-into-imanage-displaying-the-imana-ppdf-38',
    Resolution__c = 'and fix ETA:\nPower PDF engineering has produced a fix for this issue, which is available from Support as a fixed copy of imanage10.dll as well at this link to "i\nManage10 devbin.zip\n"\nThis will be included in the upcoming fixpack 14 release, which is going through the release process and documentation and is planned to be available next week by the end of February 2026.\nInstructions:\nExtract the zip file, right click the dll file included, choosing properties in windows explorer\nIf it shows "blocked," tick the box to unblock the file so it can be read correctly.\nClick on apply and ok with imanage.dll [if required]\nif not seeing this; consider its already unblocked; move on to replacing the files in Power PDF to fix the problem\nclose the application, and ensure that if iwsessioncache.exe is not running - if so this stores tokens so it can be closed in task manager.\nBACKUP: C:\\Program Files (x86)\\Kofax\\Power PDF 51\\bin\\Connectors\\imanage10.dll and change extension to .old\nREPLACE: the dll with the new fixed copy from this delivery in the same folder.\nOpen powerPDF, and now try to authenticate to iManage using single sign on [SSO]',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'PPDF 5.1.1.8 getting Error 500 when opening a document from iManage 10 using the connector integration - Intermittently',
    UrlName = 'ppdf-5-1-1-8-getting-error-500-when-opening-a-document-from-imanage-10-using-the-ppdf-39',
    Resolution__c = 'Upgrade to Power PDF Fixpack 5.1.1.11, and the issue is resolved.',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'Upgraded to PPDF 5.1.1.11, and opening documents from iManage became very slow.',
    UrlName = 'upgraded-to-ppdf-5-1-1-11-and-opening-documents-from-imanage-became-very-slow-ppdf-40',
    Resolution__c = 'Firm upgraded to the latest PowerPDF version (2025.3.1 as of Feb 13, 2026), and it resolved the slowness issue.',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'Is there a Tungsten Automation page that shows the status of Cloud based products',
    UrlName = 'is-there-a-tungsten-automation-page-that-shows-the-status-of-cloud-based-product-ppdf-41',
    Resolution__c = 'Current and historical information on the availability of Tungsten Automation cloud services hosted in each region can be found at\nhttps://status.tungstencloud.com/\n. Information on planned and unplanned downtime will be posted on this page. It is also possible to subscribe to service and incident updates.',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'Power PDF did not recognize the most recent Tungsten SignDoc certificate as trustworthy.',
    UrlName = 'power-pdf-did-not-recognize-the-most-recent-tungsten-signdoc-certificate-as-trus-ppdf-42',
    Resolution__c = 'Resolved in Power PDF Business 5.1.1 Fix Pack 1\n433772: Power PDF did not recognize the most recent Tungsten SignDoc certificate as trustworthy.',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'How to prepare Tungsten SignDoc server URL',
    UrlName = 'how-to-prepare-tungsten-signdoc-server-url-ppdf-43',
    Resolution__c = 'Problem:\nThe Power PDF 4.0 Help Documentation section, "\nTo Use and Configure Kofax Tungsten SignDoc,"\nis missing an essential part for the Tungsten SignDoc URL configuration\nSolution:\nIn the Server URL box, type the server URL.\nNote:\nThe URL consists of a protocol scheme (such as\nhttp://servername_or_IP:6611/cirrus\n), a Tungsten SignDoc service base path, and a port number.\nExample:\nhttp://127.0.0.1:6611/cirrus',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'Power PDF Support request submitted (German)',
    UrlName = 'power-pdf-support-request-submitted-german-ppdf-44',
    Resolution__c = 'Thank you for submitting your support request form.\nYou will receive an email confirmation of our receipt of your submission within 1 business day. If you fail to receive an email within that time period, please check your \'Junk\' or \'Spam\' email folders for an email from\nts.noreply@TungstenAutomation.com\n.\nWe strongly suggest that you whitelist the following email addresses to ensure you receive emails from Tungsten Automation support.\nts.noreply@TungstenAutomation.com\nts.case.reply@TungstenAutomation.com\nWe will process your Issue submission shortly and will contact you via email.\nSincerely,\nTungsten Automation Technical Support\nhttps://knowledge.TungstenAutomation.com/',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'Power PDF Support request submitted (Spanish)',
    UrlName = 'power-pdf-support-request-submitted-spanish-ppdf-45',
    Resolution__c = 'Thank you for submitting your support request form.\nYou will receive an email confirmation of our receipt of your submission within 1 business day. If you fail to receive an email within that time period, please check your \'Junk\' or \'Spam\' email folders for an email from\nts.noreply@TungstenAutomation.com\n.\nWe strongly suggest that you whitelist the following email addresses to ensure you receive emails from Tungsten Automation support.\nts.noreply@TungstenAutomation.com\nts.case.reply@TungstenAutomation.com\nWe will process your Issue submission shortly and will contact you via email.\nSincerely,\nTungsten Automation Technical Support\nhttps://knowledge.TungstenAutomation.com/',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'Azure AI Agent Setup',
    UrlName = 'azure-ai-agent-setup-ppdf-46',
    Resolution__c = 'To resolve this issue and successfully integrate Microsoft Foundry with Power PDF CoPilot, follow these steps:\nCreate Two Required Models in Microsoft Foundry:\nChat Deployment Model:\nCreate a model with the chat deployment type, such as\ngpt-4o\n.\nText Embedding Model:\nCreate a model with the text embedding deployment type, such as\ntext-embedding-ada-002\n.\nEnsure Both Models Are in the Same Resource:\nBoth the chat and text embedding models must be created within the same Azure resource. This is crucial because they need to share the same endpoint URL for proper integration.\nIf the models are in separate resources, you will encounter errors such as "Unknown error: -5" or issues related to endpoint settings.\nVerify Endpoint Settings:\nAfter creating both models in the same resource, confirm that the endpoint URL in your Power PDF CoPilot configuration matches the resource where both models reside.\nTest the Integration:\nAttempt to deploy the Azure AI agent again. The errors should be resolved if the models are correctly configured and located within the same resource.\nScreenshot Example of improper configuration of chat deployment model and text deployment model in separate resources instead of in the same resource:',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'Using PowerPDF with imanage10, \'Document failed to check in\' appears in the imanage agent window when checking out a PDF document when PowerPDF is set as the default',
    UrlName = 'using-powerpdf-with-imanage10-document-failed-to-check-in-appears-in-the-imanage-ppdf-47',
    Resolution__c = 'The false prompts appear since iManage10 server configuration IMWorkOptions.xml is unaware that powerPDF is an integrated application\nhave IMWorkOptions.xml - integrated process set for \'PowerPDF" to resolve this issue\n<ws_option name="integration">\n<key name="IntegratedProcesses" value="\nPowerPDF\n"/>\n</ws_option>\nAlso, if your config file already contains the key FileSave with value iManage.WorkSiteSavenSync, in some older server versions we saw issues triggered by having the setting enabled; we recommend if this is the case to test with it commented out; like in the example below: <!-- <key name="FileSave" value = "iManage.WorkSiteSavenSync" /> -->\nThe copy which gets downloaded from the server will be located at %APPDATA%\\Roaming\\iManage\\Work\\Configs\nTo customize it locally, you can edit the file and copy to %LOCALAPPDATA%\\iManage\\Work\\Configs which overrides the server copy.\nNOTE:\nYou will need to create the Config\'s directory in the local appdata path if it doesn\'t exist.\nOnce you have done all the changes, restart the machine before testing Power PDF and with the iManage workflows further and this issue should now be resolved and not reoccur.\nApplies to :\nProduct\nVersion\nBuild\nEnvironment\nHardware\nPower PDF\n4.1\nADV\nWindows\nPower PDF\n5.0\nADV\nWindows\nPower PDF for Business\n5.1\nADV\nWindows\nPower PDF for Business\n2025.3\nADV\nWindows',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'Error opening PDF after Printing Excel file to PowerPDF Printer',
    UrlName = 'error-opening-pdf-after-printing-excel-file-to-powerpdf-printer-ppdf-48',
    Resolution__c = 'You will need to save the Outlook attachment (this case was a XLSX) file locally (Documents folder)\nIn file explorer > right-click on the file and go to properties\nSee if it shows the option to Unblock like below\nCheck the Unblock box and OK\nOpen the local file in Excel and Print to the PowerPDF Printer',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'Unable to print using Power PDF',
    UrlName = 'unable-to-print-using-power-pdf-ppdf-49',
    Resolution__c = 'Please try the steps below:\nOpen\nPower PDF\n.\nClick\nFile\n>\nOptions\n>\nGeneral\n.\nUnder the\nPrinter\nsection, check the option\n“Print default options”\n.\nClick\nOK\n, close Power PDF, and then relaunch the application.\nTest the printing functionality again.',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'Modify PDF/A-1b profile settings',
    UrlName = 'modify-pdf-a-1b-profile-settings-ppdf-50',
    Resolution__c = 'To set the PDF/A-1b profile to "Embed All Fonts" in Power PDF, follow these steps:\nNavigate to the following folder\non your computer:\n%appdata%\\Kofax\\PDF\\Profiles\\ENU\\\nLocate the file\nnamed\nProfile.ini\n.\nOpen\nProfile.ini\nin a text editor\n(such as Notepad).\nModify or add the following line\nunder the [Control 2] section:\nFontEmbedSelection=2\nThis setting ensures that all fonts are embedded when using the PDF/A-1b profile.\nIf the line already exists with a different value, change it to\n2\n.\n7. Save the file\nand close the text editor.\nNote:\nAlways make a backup of configuration files before making manual changes.',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'General Printer Settings that can be changed via Network Deployment',
    UrlName = 'general-printer-settings-that-can-be-changed-via-network-deployment-ppdf-51',
    Resolution__c = ':\nGeneral Tab\n1. Paper Size - Tabloid 11 x 17 Inches\n%AppData%\\Kofax\\PDF\\PDF Driver\\ENU\\General.ini\nStandardPage=2\n2. Orientation - Landscape\n%AppData%\\Kofax\\PDF\\PDF Driver\\ENU\\General.ini\nOrientation=2\n3. Grayscale Color Mode\n%AppData%\\Kofax\\PDF\\PDF Driver\\ENU\\General.ini\nnColorMode=1\n4. Enable "View Resulting PDF" by default\n%AppData%\\Kofax\\PDF\\PDF Driver\\ENU\\General.ini\nbViewPDF=1\nPDF Settings Tab\n5. Set the Default Profile to "PDF/A-1b"\n%AppData%\\Kofax\\PDF\\PDF Driver\\ENU\\General.ini\nProfileSelection=1\n6. Naming Method - Save in named folder; auto-name file\n%AppData%\\Kofax\\PDF\\PDF Driver\\ENU\\Destination.ini\nNamingMode=3\n7. PDF Name or Folder -\n%AppData%\\Kofax\\PDF\\PDF Driver\\ENU\\Destination.ini\nPDFName=C:\\\\\\\n8. If File Exists - Replace existing file\n%AppData%\\Kofax\\PDF\\PDF Driver\\ENU\\ENU\nDestination.ini\nFileExistRule=1',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'Users Failing to Sync with Power PDF Cloud Licensing Server',
    UrlName = 'users-failing-to-sync-with-power-pdf-cloud-licensing-server-ppdf-52',
    Resolution__c = 'Verify that the attribute mapping is configured correctly. Our Cloud Licensing Server (CLS) needs and uses only the 5 following attributes\nThe \'\nexternalId\n\' <- \'\nobjectId\n\' mapping is likely the cause of sync issues if set to mail nickname, and its mandatory to be precisely mapped to objectId to ensure smooth operation on the cloud license portal. The other ones must exist too, but the values in the second column (Microsoft Entra ID Attribute) are freely configurable.\nAfter making changes, it is recommended to \'restart provisioning\' and then allow for some time for the operation to complete since the microsoft side could take up to an hour before its fully completed and ready testing with users added to the security group configured to appear.\nPlease get in touch with our support team to raise a case should further issues arise and if needed share any screenshots or details of the provisioning and troubleshooting section of the Entra portal',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'Co-Pilot Feature Availability in Tungsten Power PDF',
    UrlName = 'co-pilot-feature-availability-in-tungsten-power-pdf-ppdf-53',
    Resolution__c = 'ISSUE\nIs the Co-Pilot feature available in Tungsten Power PDF Standard or Advanced editions?\nCAUSE\nThe Co-Pilot feature is only included in the Power PDF Business (formerly Power PDF Advanced Volume) edition. It is not offered with Tungsten Power PDF Standard or Advanced retail licenses.',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'DocuSign Certificate Issue',
    UrlName = 'docusign-certificate-issue-ppdf-54',
    Resolution__c = 'To resolve this issue,\napply the Power PDF fix pack 5.1.1.11\nor a later version.\nThis update expands the list of trusted root certificates to include the new DocuSign root certificate, ensuring that DocuSign-signed documents will validate properly in Power PDF.\nIssue resolved:\n963717\n: The new DocuSign root certificate was not trusted by default.',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'Text Wrapping Issue',
    UrlName = 'text-wrapping-issue-ppdf-55',
    Resolution__c = 'This issue was addressed in\nTungsten Power PDF Business\n5.1.1 Fix Pack 11\nfor Power PDF\n963137\n: Text wrapping was not functioning in form fields.',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'When printing from Excel to PowerPDF Printer and saving new document to iManage - After you have selected the PDF, the “New Version” screen does NOT come up for you to Save.',
    UrlName = 'when-printing-from-excel-to-powerpdf-printer-and-saving-new-document-to-imanage-ppdf-56',
    Resolution__c = 'Fixpack 5.1.1.10 resolves the issue.',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'Bookmarks and Hyperlinks Not Created When Combining Word Documents',
    UrlName = 'bookmarks-and-hyperlinks-not-created-when-combining-word-documents-ppdf-57',
    Resolution__c = 'To resolve the issue with missing bookmarks and hyperlinks when combining Word documents in Power PDF:\nIdentify Third-Party Add-ins:\nOpen Microsoft Word.\nNavigate to\nFile > Options > Add-ins\n.\nReview the list of active Add-ins for any third-party software, such as Litera Create.\nUpdate Litera Create Plug-in:\nVisit the Litera support website or contact your IT department.\nDownload and install\nLitera Create version 3.13\nor later.\nRestart your computer after the update.\nRetest Combining Files:\nCombine the same set of PDF and Word files using Power PDF Advanced.\nVerify that bookmarks are now created from Word headings and that hyperlinks are preserved.\nConfirm Settings:\nIn Power PDF, ensure that the option to create bookmarks from headings is enabled under combination settings.',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'Expired Power PDF Office Add-ins certificate',
    UrlName = 'expired-power-pdf-office-add-ins-certificate-ppdf-58',
    Resolution__c = 'Starting with the FixPack 8 of Power PDF v5.1, the release notes in ReadMe-TungstenPowerPDFBusiness-5.1.1.8.htm, under the section "Special Instructions," provide guidance on the solution for the problem.\nUnderstanding Digital Signature Expiration and Trusted Publishers in Microsoft Office Add-ins\nWhen dealing with digital signatures in the context of Microsoft Office add-ins, it is important to understand how expiration periods work. The expiration date of a signature refers to the window in which the signature can be used to sign files. However, this expiration does not mean that the signed add-in is no longer valid after that date.\nTime Stamps and Long-Term Validity:\nIn practice, time stamps are often used alongside digital signatures to ensure that the signature remains verifiable even after the expiration of the signing certificate. A time stamp records the exact moment the signing occurred, ensuring the file or add-in can still be validated long after the signing certificate has expired.\nContext in Microsoft Office Add-ins:\nWhen the\nRequire Application Add-ins to be signed by Trusted Publishers\nsetting is enabled, Office checks that the add-in’s digital signature matches a trusted certificate, to ensure that only verified, secure code is executed.\nAdding Certificates to Trusted Publishers:\nTo ensure that Microsoft Word recognizes your add-ins as safe, the signing certificate should be added to the list of trusted publishers. Even if the certificate has expired, Word will still trust the signed add-in as long as the certificate was valid at the time of signing.\nWhen the Office feature for trusted publishers is enabled, it is important to install the certificate included with each new fix pack into the trusted publishers repository.\nFollow the steps below to manually add the certificate:\nDouble-click the\n.cer\nfile that comes with the fix pack.\nClick\nInstall Certificate\n.\nChoose\nCurrent User\nor\nLocal Machine\ndepending on your preference, then click\nNext\n.\nSelect\nPlace all certificates in the following store\n, then click\nBrowse\nand select\n"Trusted Publishers"\n, then click\nOK\n.\nClick\nNext\n, then\nFinish\nto confirm and complete the certificate import.',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'Does Power PDF have size handling limitations when combining large PDFs into one document?',
    UrlName = 'does-power-pdf-have-size-handling-limitations-when-combining-large-pdfs-into-one-ppdf-59',
    Resolution__c = 'Yes, due to architectural constraints, the maximum document size limit is 4 GB for processing confirmed by engineering so our official statement is that Power PDF, as of today; cannot merge files whose results would exceed 4 GB in output size.\nPlease get in touch should you have issues with smaller documents and open a support case for us to perform a deeper review.',
    Language = 'en_US'
));

articles.add(new Knowledge__kav(
    Title = 'Power PDF Cloud Editor Access',
    UrlName = 'power-pdf-cloud-editor-access-ppdf-60',
    Resolution__c = 'Power PDF Cloud Editor requires an active Power PDF for Business Term/SaaS License with a Cloud License Server. To obtain a license, please contact our Sales team:\nhttps://www.tungstenautomation.com/contact-us/product-inquiry\nFor more information, please visit:\nhttps://www.tungstenautomation.com/about/press-releases/2025/tungsten-automation-launches-power-pdf-2025-3',
    Language = 'en_US'
));

insert articles;
System.debug('Batch inserted: ' + articles.size() + ' articles');
for (Knowledge__kav kav : articles) {
    System.debug('ID: ' + kav.Id + ' | ' + kav.Title);
}