// Import first 10 Power PDF KB articles as Draft Knowledge articles
// Tagged with cursor-test marker for easy cleanup
String marker = 'cursor-test-' + Datetime.now().format('yyyyMMdd-HHmmss');
List<Knowledge__kav> articles = new List<Knowledge__kav>();

// Article 1
articles.add(new Knowledge__kav(
    Title = 'Lifecycle Policies and End of Support Dates',
    UrlName = 'lifecycle-policies-and-end-of-support-dates-ppdf-1',
    Resolution__c = 'The\nTungsten Automation Software Lifecycle Policy\ndescribes product release types and provides a policy on the related Support timeline for products.\nThe\nTungsten Automation Printix Client Lifecycle Support Policy\ndescribes the policy on the lifecycle and support policy for the Tungsten Printix Client.\nThe\nProduct Release and Sunset Schedules\nfile is a table of Tungsten Automation products and their associated Support timelines.\nLast updated on April 29, 2026.\nThe\nTungsten Automation MFP/Network Scanner Support Policy\ndescribes MFP/Network Scanner devices that work with relevant Tungsten Automation products and provides policy on their related Support timelines.\nThe\nMFP Support Matrix\narticle contains a table of MFP/Network Scanner devices that work with relevant products and their associated Support timeline.\nThe\nMFD & Productivity Supported Devices Information\narticle contains the latest MFD & Productivity Supported Devices file(s).\nThe Tungsten Automation Support\nPortal Case Data and Attachment Policy\narticle outlines our current portal case data and attachment policy details.',
    Summary = 'Power PDF KB - imported via cursor-test',
    Language = 'en_US'
));

// Article 2
articles.add(new Knowledge__kav(
    Title = 'Power PDF Product Release Information',
    UrlName = 'power-pdf-product-release-information-ppdf-2',
    Resolution__c = 'Latest 2026.2 Releases\nFor Mac\nDescription\nRelease Date\nDownload\nPower PDF 2026.2 (2026.2, Initial Release) for Mac\nApril 27, 2026\nAvailable for download from the\nTungsten Automation Fulfillment Site\n.\nPower PDF 2026.2 for Mac product documentation - Including Release Notes and Technical Specifications\n(hosted)\nLatest 2025.3 Releases\nFor Windows\nDescription\nRelease Date\nDownload\nPower PDF 2025.3.5 (2025.3, Update 5) for Windows\nJune 02, 2026\nAvailable for download from the\nTungsten Automation Fulfillment Site\n.\nActive M&S contract required.\nPower PDF 2025.3 (2025.3, Initial Release) for Windows\nNovember 11, 2025\nPower PDF 2025.3 for Windows product documentation - Including Release Notes and Technical Specifications\n(hosted)\nLatest 5.1 Releases\nFor Mac\nDescription\nRelease Date\nDownload\nPower PDF 5.1 R2 for Mac\nNovember 12, 2024\nAvailable for download from the\nTungsten Automation Fulfillment Site\n.\nPower PDF 5.1 for Mac\nAugust 13, 2024\nPower PDF 5.1 for Mac product documentation - Including Release Notes and Technical Specifications\n(hosted)\nFor Windows\nDescription\nRelease Date\nDownload\nPower PDF 5.1.1.17 Advanced Volume (5.1, Service Pack 1, Fix Pack 17) for Windows\nMay 01, 2026\nAvailable for download from the\nTungsten Automation Fulfillment Site.\nActive M&S contract required.\nPower PDF 5.1 for Windows\nMay 30, 2024\nPower PDF 5.1 for Windows product documentation - Including Release Notes and Technical Specifications\n(hosted)\nLatest 5.0 Releases\nFor Mac\nDescription\nRelease Date\nDownload\nPower PDF 5.0 R3 for Mac\nMay 14, 2024\nAvailable for download from the\nTungsten Automation Fulfillment Site\n.\nPower PDF 5.0 for Mac product documentation - Including Release Notes and Technical Specifications\n(hosted)\nFor Windows\nThis product reached\nLimited Support\non September 30, 2025.\nDescription\nRelease Date\nDownload\nPower PDF 5.0.0.21 Advanced Volume (5.0, Fix Pack 21) for Windows\nMay 27, 2024\nAvailable for download from the\nTungsten Automation Fulfillment Site\n.\nActive M&S contract required.\nPower PDF 5.0 for Windows\nJuly 01, 2022\nPower PDF 5.0 for Windows product documentation - Including Release Notes and Technical Specifications\n(hosted)\nLatest 4.2 Releases\nFor Mac\nThis product reached\nEnd of Support\non September 23, 2025.\nDescription\nRelease Date\nDownload\nPower PDF 4.2 R2 for Mac\nJuly 22, 2024\nAvailable for download from the\nTungsten Automation Fulfillment Site\n.\nPower PDF 4.2 for Mac\nSeptember 23, 2021\nPower PDF 4.2 for Mac product documentation - Including Release Notes and Technical Specifications\n(hosted)\nLatest 4.1 Releases\nFor Mac\nThis product reached\nEnd of Support\non February 09, 2025.\nDescription\nRelease Date\nPower PDF 4.1 R2 for Mac\nThis R2 release corrects a licensing issue not a program issue. If you have installed and are successfully using the PPDF 4.1 for Mac release, you do not need to install this R2 release.\nMay 25, 2021\nPower PDF 4.1 for Mac\nFebruary 09, 2021\nPower PDF 4.1 for Mac product documentation is available for download from the\nPower PDF 4.1 for Mac\npackage found in the\nTungsten Automation Fulfillment Site\n.\nKofax Power PDF 4.1 for Mac - Technical Specifications\n(December 2020)\nFor Windows\nThis product reached\nEnd of Support\non September 23, 2025.\nDescription\nRelease Date\nPower PDF 4.1.0.30 Advanced Volume (4.1, Fix Pack 30) for Windows\nApril 29, 2025\nPower PDF 4.1 for Windows\nAugust 16, 2021\nPower PDF 4.1 for Windows - Including Release Notes and Technical Specifications\n(hosted)',
    Summary = 'Power PDF KB - imported via cursor-test',
    Language = 'en_US'
));

// Article 3
articles.add(new Knowledge__kav(
    Title = 'Getting MainEngineThread is returning 1603 Error in MSI Logs during installation of PowerPDF',
    UrlName = 'getting-mainenginethread-is-returning-1603-error-in-msi-logs-during-installation-ppdf-3',
    Resolution__c = 'Issue:\nGetting \'MainEngineThread is returning 1603 Error\' in MSI Logs during installation of PowerPDF\nResolution:\nThe Client moved the installation files (Deployment Script, *.MST) to a location other than the default and forgot to copy DATA1.CAB to the new location. DATA1.CAB is the PowerPDF installation program.\nCopied the DATA1.CAB file to a new location, and PowerPDF installed properly.',
    Summary = 'Power PDF KB - imported via cursor-test',
    Language = 'en_US'
));

// Article 4
articles.add(new Knowledge__kav(
    Title = 'SharePoint connector doesn\'t see all folders in Power PDF',
    UrlName = 'sharepoint-connector-doesn-t-see-all-folders-in-power-pdf-ppdf-4',
    Resolution__c = 'ISSUE\nSharePoint connector doesn\'t see all folders\nPROBLEM DETAILS\nWhen connecting to a SharePoint site through the SharePoint connector in Power PDF. Several folders that are visible and fully accessible in the browser (Microsoft Edge) do not appear within the connector interface.\nSOLUTION\nIn the contents, select the Settings of the library/folder they would like to check/set. Set the Content Types section, containing "Document" Content type in its list (there can be a list but the Document must be among them). If not, select "Advanced settings" and, in the Advanced Settings window, set the "Allow management content types" radio button to "Yes". After saving the setting the Content Types will appear in the Settings window, and the Folder/Library will appear in Power PDF SharePoint connector.\nPower PDF version should be on minimum versions of 20205.3 and 5.1.1.14',
    Summary = 'Power PDF KB - imported via cursor-test',
    Language = 'en_US'
));

// Article 5
articles.add(new Knowledge__kav(
    Title = 'Power PDF Essential Eight White Paper',
    UrlName = 'power-pdf-essential-eight-white-paper-ppdf-5',
    Resolution__c = 'Question\n:\nDoes Kofax have a Whitepaper that covers Essential Eight for our organization record?\nAnswer:\nKofax and the Power PDF Solution adhere to the principles in consideration of the essential Eight core secure guidelines,\nPlease find attached our white paper.\nREFERENCES\nPower PDF Essential Eight White Paper.pdf',
    Summary = 'Power PDF KB - imported via cursor-test',
    Language = 'en_US'
));

// Article 6
articles.add(new Knowledge__kav(
    Title = 'Who to contact for technical support on OEM versions of Kofax products.',
    UrlName = 'who-to-contact-for-technical-support-on-oem-versions-of-kofax-products-ppdf-6',
    Resolution__c = 'Question\nWho do I contact for technical support on OEM versions of Kofax products?\nAnswer\nIf your license for Power PDF, Omnipage, or PaperPort was included with the purchase of a product from a 3rd party, such as a Scanner or Printer, you must contact that manufacturer for technical support. Due to contractual requirements Kofax is unable to provide direct technical support on OEM versions of our products.\nApplies to\nProduct\nVersion\nBuild\nEnvironment\nHardware\nPower PDF\nAll\nWindows / Mac\nPaperPort\nAll\nWindows\nOmnipage\nAll\nWindows\n​',
    Summary = 'Power PDF KB - imported via cursor-test',
    Language = 'en_US'
));

// Article 7
articles.add(new Knowledge__kav(
    Title = 'Power PDF Availability on Google Play Store',
    UrlName = 'power-pdf-availability-on-google-play-store-ppdf-7',
    Resolution__c = 'We are aware that Power PDF is currently not available on the Google Play Store. Our team is actively investigating this issue and working towards a resolution.\nAn update will be provided in this Knowledge Base article once more information is available.\nWe appreciate your patience and understanding while this is being resolved.',
    Summary = 'Power PDF KB - imported via cursor-test',
    Language = 'en_US'
));

// Article 8
articles.add(new Knowledge__kav(
    Title = 'How to collect x32 and x64 bit log files for Power PDF 2025.3',
    UrlName = 'how-to-collect-x32-and-x64-bit-log-files-for-power-pdf-2025-3-ppdf-8',
    Resolution__c = 'Purpose\nOne of the most effective ways to troubleshoot Power PDF issues is by collecting logs for our support team to review.\nBefore beginning, ensure that the File Name extension option is selected under the View option in Folder Options in Windows Explorer.\nOpen Folder\nà\nView\nà\nCheck mark view File name extensions\nObjective:\nWhen Power PDF logging is needed, the log files for both x32 and x64 bit processing should be enabled\nStep 1\nBrowse to the default directory where Power PDF software is installed on your system.\nTypically, the file location would be:\nC:\\Program Files\\Tungsten\\Power PDF 2025\nStep 2\n2.1 If you see a file by name recdiag_log.ini with size 1 KB you may rename the file to recdiag_log_old.ini\n2.2 Search and select RECDIAG_LOG.IN_ of size 13 KB at location C:\\Program Files\\Tungsten\\Power PDF 2025\nthen rename the file to \'RECDIAG_LOG.ini\'.\nNote\n– In some cases, renaming this file will require admin rights, but this depends on the customers environment and user permissions\n32-Bit log steps\nTo also enable x86-bit logging mode, continue with the steps below and first b\nrowse to the directory where Power PDF is installed on your system.\nTypically, the file location would be C:\\Program Files\\Tungsten\\Power PDF 2025\\x86\nStep 3\nIf you see a file by name recdiag_log.ini with a size of 1 KB you may rename the file to recdiag_log_old.ini\nStep 4\nSearch and select RECDIAG_LOG.IN_ of size 13 KB at location\nC:\\Program Files\\Tungsten\\Power PDF 2025\\x86\nthen rename the file to \'RECDIAG_LOG.ini\'.\nStep 5\n5.1 Once the \'RECDIAG_LOG.ini\' file is in place in both locations, create a folder named \'RECDIAG\' in the C:\\TEMP folder for the logs to be written out to\n5.2 If this folder is not manually created before testing, the logs will not be created (C:\\temp\\recdiag).\n5.3 Power PDF should start writing logs to C:\\temp\\recdiag as soon as the software is launched.\nStep 6 -\nReproduce the issue and note the document name, date and time of the issue.\nCollect the logs from C:\\temp\\recdiag after reproducing the issue successfully.\nShare the logs with our support team.\nStep 7\nWhen testing is complete, be sure to rename the file \'RECDIAG_LOG.ini\' back to \'RECDIAG_LOG.in_\' so Power PDF does not continue logging,\nApplies to:\nProduct\nVersion\nBuild\nEnvironment\nHardware\nPower PDF\nStd and Adv\nfor Business\n2025.3.x\nWindows',
    Summary = 'Power PDF KB - imported via cursor-test',
    Language = 'en_US'
));

// Article 9
articles.add(new Knowledge__kav(
    Title = 'I have questions regarding a software demo or general questions regarding product features',
    UrlName = 'i-have-questions-regarding-a-software-demo-or-general-questions-regarding-produc-ppdf-9',
    Resolution__c = 'ISSUE\nI have questions regarding a software demo or general questions regarding product features.\nWhere can I ask those questions?\nSOLUTION\nPlease go to:\nhttps://www.tungstenautomation.de/contact-us/product-inquiry\nAnd raise your questions directly to our products teams.\nREFERENCES\nAdd any references to other internal or external articles',
    Summary = 'Power PDF KB - imported via cursor-test',
    Language = 'en_US'
));

// Article 10
articles.add(new Knowledge__kav(
    Title = 'Power PDF Product Documentation',
    UrlName = 'power-pdf-product-documentation-ppdf-10',
    Resolution__c = 'Latest 2026.2 Releases\nFor Mac\nPower PDF 2026.2 for Windows product documentation - Including Release Notes and Technical Specifications\n(hosted)\nLatest 2025.3 Releases\nFor Windows\nPower PDF 2025.3 for Windows product documentation - Including Release Notes and Technical Specifications\n(hosted)\nLatest 5.1 Releases\nFor Mac\nPower PDF 5.1 for Mac product documentation - Including Release Notes and Technical Specifications\n(hosted)\nFor Windows\nPower PDF 5.1 for Windows product documentation - Including Release Notes and Technical Specifications\n(hosted)\nLatest 5.0 Releases\nFor Mac\nPower PDF 5.0 for Mac product documentation - Including Release Notes and Technical Specifications\n(hosted)\nFor Windows\nThis product reached\nLimited Support\non September 30, 2025.\nPower PDF 5.0 for Windows product documentation - Including Release Notes and Technical Specifications\n(hosted)\nLatest 4.2 Releases\nFor Mac\nThis product reached\nEnd of Support\non September 23, 2025.\nPower PDF 4.2 for Mac product documentation - Including Release Notes and Technical Specifications\n(hosted)\nLatest 4.1 Releases\nFor Mac\nThis product reached\nEnd of Support\non February 09, 2025.\nPower PDF 4.1 for Mac product documentation is available for download from the\nPower PDF 4.1 for Mac\npackage found in the\nKofax Fulfillment Site\n.\nKofax Power PDF 4.1 for Mac - Technical Specifications\n(December 2020)\nFor Windows\nThis product reached\nEnd of Support\non September 23, 2025.\nPower PDF 4.1 for Windows documentation - including Release Notes and Technical Specifications\n(hosted)',
    Summary = 'Power PDF KB - imported via cursor-test',
    Language = 'en_US'
));

insert articles;

System.debug('=== CURSOR TEST COMPLETE ===');
System.debug('Marker: ' + marker);
System.debug('Articles inserted: ' + articles.size());
for (Knowledge__kav kav : articles) {
    System.debug('ID: ' + kav.Id + ' | Title: ' + kav.Title);
}