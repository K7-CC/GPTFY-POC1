---
name: Deploy Case Resolution Assistant
overview: Build and deploy the GPTfy-powered Case Resolution Assistant from SOLUTION_DESIGN.pdf into the default org (gptfy-poc1) as a public Experience Cloud (LWR) site, with the LWC, Apex controller, and async record-triggered flow scaffolded from scratch in a new SFDX project.
todos:
  - id: phase1_setup
    content: "Phase 1 (manual): Enable Digital Experiences, create gptfysupport LWR site, make public, capture guest profile name"
    status: pending
  - id: phase2_scaffold
    content: "Phase 2: Scaffold SFDX project (sfdx-project.json, force-app structure)"
    status: pending
  - id: phase3_apex
    content: "Phase 3: Write CaseResolutionController (without sharing) + test class with createSupportCase/getRecommendation/resolveCase"
    status: pending
  - id: phase4_lwc
    content: "Phase 4: Build caseResolutionAssistant LWC (6-state CSS-class machine, 2.5s/12-attempt polling, custom CSS)"
    status: pending
  - id: phase5_flow
    content: "Phase 5: Author Case_Resolution_RTF flow XML with async path calling ccai__AIPromptProcessingInvokable, placeholder promptRequestId"
    status: pending
  - id: phase6_security
    content: "Phase 6: Author guest profile metadata - class access, Case CRUD, field-level access on Description"
    status: pending
  - id: phase7_deploy
    content: "Phase 7: Deploy to gptfy-poc1, run Apex tests, drop LWC onto Home in Experience Builder, publish site"
    status: pending
  - id: phase8_postdeploy
    content: "Phase 8 (manual): Replace placeholder promptRequestId in Flow Builder with real GPTfy prompt id, reactivate flow"
    status: pending
  - id: phase9_test
    content: "Phase 9: End-to-end smoke test in incognito - submit, recommendation, Yes/No paths, fallback message"
    status: pending
isProject: false
---

## Summary of `SOLUTION_DESIGN.pdf`

The **Case Resolution Assistant** is an AI self-service support widget on a public Salesforce Experience Cloud (LWR) site. A guest user fills out a 4-field form (First Name, Last Name, Email, Question). The LWC calls Apex (`CaseResolutionController.createSupportCase`) which inserts a `Case` (Origin = Web, Status = New). The case insert fires a record-triggered flow (`Case_Resolution_RTF`) whose `Run Asynchronously` path invokes the GPTfy managed action `ccai__AIPromptProcessingInvokable` (ExecutePrompt) — async is required because Salesforce blocks HTTP callouts in synchronous DML transactions. GPTfy calls its GCP RAG engine and writes the answer back to `Case.Description`. Meanwhile, the LWC polls `getRecommendation(caseId)` every 2.5s for up to 30s; once Description is non-blank, the recommendation is rendered. The user clicks "Yes, resolved" (closes the case via `resolveCase`) or "No, still need help" (case stays New, number shown). The whole UI is a 6-state machine (`INPUT`, `LOADING`, `RECOMMENDATION`, `RESOLVING`, `RESOLVED`, `CASE_CREATED`) rendered with CSS-class visibility (not `lwc:if`) so it renders correctly inside Experience Builder canvas. Apex runs `without sharing` and the guest user profile is granted class access plus Create/Read/Edit on Case (including `Description` for the polling read).

## Decisions confirmed

- **Org**: `gptfy-poc1` (`kesavpoc@gptfy.com`) — GPTfy `ccai` managed package already installed.
- **Site template**: Build Your Own (LWR).
- **URL prefix**: `gptfysupport`.
- **GPTfy prompt**: deploy with **placeholder** `promptRequestId`; you will edit the Flow assignment in Flow Builder post-deploy to point at a real prompt in this org.

## Architecture (recap)

```mermaid
flowchart TD
    User["Guest User on Experience Site"] -->|Submit form| LWC[caseResolutionAssistant LWC]
    LWC -->|createSupportCase| Apex[CaseResolutionController]
    Apex -->|Insert Case Origin=Web| CaseObj[(Case)]
    CaseObj -->|After Save trigger| RTF[Case_Resolution_RTF Flow]
    RTF -->|Run Immediately| EndA[End]
    RTF -->|Run Asynchronously| GPTfy["ccai__AIPromptProcessingInvokable<br/>ExecutePrompt"]
    GPTfy -->|RAG callout| GCP[GCP RAG Engine]
    GCP -->|responseBody| GPTfy
    GPTfy -->|Update Case.Description| CaseObj
    LWC -. poll every 2.5s .-> Apex
    Apex -->|getRecommendation| CaseObj
    CaseObj -->|Description populated| LWC
    LWC -->|Yes resolveCase| Apex
    Apex -->|Status=Closed| CaseObj
```

## Phase 1 — Prerequisites in Setup UI (manual, one-time, ~15 min)

Do these in the default org (`gptfy-poc1`) before any deployment:

1. **Enable Digital Experiences**: Setup → *Digital Experiences* → *Settings* → check **Enable Digital Experiences** → pick a permanent subdomain (e.g. `gptfypoc-dev-ed`) → Save. This is **irreversible** for the chosen domain.
2. **Create the site shell**: *All Sites* → **New** → template **Build Your Own (LWR)** → Name `gptfysupport` → URL `gptfysupport` → Create.
3. **Set site to Public**: Site Workspaces → `gptfysupport` → *Administration* → *Settings* → check **Public can access the site** (guest profile is auto-created).
4. **Confirm Guest Profile name**: Administration → *Pages* → note the guest profile name (typically `gptfysupport Profile`). We'll reference it when permissioning Apex/Case access.
5. Leave the site **unpublished** for now — we'll add the LWC to Home, then publish.

## Phase 2 — Scaffold the SFDX project (workspace is currently empty)

Workspace root `d:\Kesav-project-1\GPTFY POC1` only contains the PDF. We will:

- Run `sf project generate --name gptfy-case-resolution --default-package-dir force-app` to create the standard DX layout.
- Result: `sfdx-project.json`, `force-app/main/default/{classes,lwc,flows,profiles}/`, `.forceignore`, README.

## Phase 3 — Build the Apex controller

Create `force-app/main/default/classes/CaseResolutionController.cls` (and `-meta.xml` at API 64.0). Must be `without sharing` (required for guest DML on Case). Three `@AuraEnabled` methods:

- `createSupportCase(firstName, lastName, email, subject)` → inserts `Case` with `Origin='Web'`, `Status='New'`, `Priority='Medium'`, `Subject` (truncated to 255), `SuppliedName = firstName + ' ' + lastName`, `SuppliedEmail = email`. Returns `Map<String,String>{caseId, caseNumber}` (re-query for `CaseNumber` since it's autonumber).
- `getRecommendation(caseId)` → `SELECT Description FROM Case WHERE Id = :caseId`; return `null` if blank, otherwise the text. Wrap in try/catch.
- `resolveCase(caseId)` → updates `Status = 'Closed'`.

Add a companion `CaseResolutionControllerTest.cls` with at least 75% coverage (insert + read + close paths) so the deploy passes production-style validation.

## Phase 4 — Build the LWC `caseResolutionAssistant`

Path: `force-app/main/default/lwc/caseResolutionAssistant/`. Four files exactly as the design specifies:

- `caseResolutionAssistant.html` — 6 state containers (`INPUT`, `LOADING`, `RECOMMENDATION`, `RESOLVING`, `RESOLVED`, `CASE_CREATED`), **all always present in DOM**, each toggled by a getter returning `cra-state` vs `cra-state--hidden`. Form inputs bound via `onchange` to component properties. Buttons: *Find a Solution*, *Yes, resolved*, *No, still need help*, *Submit Another*, *Done*.
- `caseResolutionAssistant.js` — state machine with constants `INPUT/LOADING/RECOMMENDATION/RESOLVING/RESOLVED/CASE_CREATED`. Polling: `setTimeout` loop, 2500 ms interval, max 12 attempts, calls `getRecommendation`. Timeout fallback message exactly as in design. Imports `createSupportCase`, `getRecommendation`, `resolveCase` from `@salesforce/apex/CaseResolutionController.*`.
- `caseResolutionAssistant.css` — design says "Full custom design matching GPTfy Support Community style". Implement the visual layout from the user journey (badge "KNOWLEDGE ARTICLE FOUND", article-style card, spinner, primary/secondary buttons). Use `display:none !important` on `cra-state--hidden`.
- `caseResolutionAssistant.js-meta.xml` — `isExposed=true`, targets include `lightningCommunity__Page` and `lightningCommunity__Default` (and `lightning__AppPage` for internal testing).

## Phase 5 — Build the Record-Triggered Flow

Path: `force-app/main/default/flows/Case_Resolution_RTF.flow-meta.xml`. Hand-authored XML (faster + deterministic than UI export):

- `processType = AutoLaunchedFlow`, `start.object = Case`, `triggerType = RecordAfterSave`, `recordTriggerType = Create`.
- Entry filter: `Origin EQUALS 'Web'`.
- Two scheduled paths off Start:
  - **Run Immediately**: no actions, flows straight to End.
  - **Run Asynchronously** (`AsyncAfterCommit`): assignment to set the four variables → Action `ccai__AIPromptProcessingInvokable` (ExecutePrompt) → record update on `$Record` writing `Description = {!responseBody}` → End.
- Action inputs:
  - `EventUUID` = `{!$Flow.InterviewGuid}` (per design — NOT the Case Id).
  - `promptRequestId` = **placeholder** literal `REPLACE_ME_AFTER_DEPLOY` (you'll edit in Flow Builder).
  - `recordId` = `{!$Record.Id}`.
  - `customPromptCommand` = `{!$Record.Subject}`.
- API version 64.0, `status = Active`.

## Phase 6 — Guest user security (the bit most demos get wrong)

Create `force-app/main/default/profiles/gptfysupport Profile.profile-meta.xml` (file name must match the actual guest profile name from Phase 1.4 — adjust if Salesforce names it differently). Grant:

- `<classAccesses>` → `CaseResolutionController` enabled.
- `<objectPermissions>` on `Case` → `allowCreate`, `allowRead`, `allowEdit` = true.
- `<fieldPermissions>` on `Case.Description`, `Case.Subject`, `Case.SuppliedName`, `Case.SuppliedEmail`, `Case.Status`, `Case.Origin`, `Case.Priority` → `readable=true`, `editable=true` where needed.

If Salesforce profile-based access alone is insufficient (LWR sites sometimes require it on the guest user record too), add a Permission Set Group and assign it to the guest user via Site Workspaces → Administration → Guest User.

## Phase 7 — Deploy and wire up the page

1. `sf project deploy start --source-dir force-app --target-org gptfy-poc1` — pushes Apex, LWC, Flow, profile.
2. Run Apex tests: `sf apex run test --class-names CaseResolutionControllerTest --target-org gptfy-poc1 --result-format human --wait 10`.
3. In Experience Builder for `gptfysupport`: open **Home** page → drag `caseResolutionAssistant` from Custom Components onto the canvas → Save → **Publish** site.

## Phase 8 — Post-deploy manual configuration

1. Open **Setup → Flows → Case_Resolution_RTF** → click into the assignment element on the async path → replace `REPLACE_ME_AFTER_DEPLOY` with the real `promptRequestId` (the 36-char external id from the chosen `ccai__AI_Prompt__c` record in this org) → **Save As New Version** → Activate the new version.
2. (Optional but recommended) Identify or create the prompt in this org. The org already has many `ccai__AI_Prompt__c` records — pick one configured for RAG case resolution, or create a new one named e.g. "Case Resolution Assistant - RAG".

## Phase 9 — End-to-end smoke test

- Open `https://<your-domain>.my.site.com/gptfysupport/s/` in an **incognito** window (so no Salesforce session leaks in).
- Submit a question. Verify: form disappears → spinner shows → within ~30s, a recommendation appears.
- Click **Yes, resolved** → confirm Case in Salesforce moves to `Closed`.
- Repeat, click **No** → confirm Case number is shown, Case stays `New`.
- Negative test: temporarily break the prompt id to confirm the 30s fallback message renders.

## Risks and mitigations

- **Guest user can't insert Case**: most common failure. Mitigation: profile edits in Phase 6 + Apex `without sharing` + verify in Site Workspaces → Administration → *Guest User* that the right profile is bound.
- **Callout-in-transaction error**: only happens if the async path is misconfigured. Mitigation: confirm the GPTfy action is on the `AsyncAfterCommit` path, never on the immediate path.
- **LWR component compatibility**: `caseResolutionAssistant.js-meta.xml` must target `lightningCommunity__Page`. If using LWR specifically, also ensure no Aura-only APIs are used in the JS.
- **Polling overruns**: 12 × 2.5s = 30s hard cap is already in the design — keep it; longer polling on guest users increases load.
- **Permission set vs profile**: if Phase 6 profile edits don't take effect on the guest user, fall back to a Permission Set assigned to the guest user via Site Administration.

## Files that will be created

- `sfdx-project.json`
- `force-app/main/default/classes/CaseResolutionController.cls` + `.cls-meta.xml`
- `force-app/main/default/classes/CaseResolutionControllerTest.cls` + `.cls-meta.xml`
- `force-app/main/default/lwc/caseResolutionAssistant/caseResolutionAssistant.{html,js,css,js-meta.xml}`
- `force-app/main/default/flows/Case_Resolution_RTF.flow-meta.xml`
- `force-app/main/default/profiles/gptfysupport Profile.profile-meta.xml` (or a PermissionSet equivalent)

## What I need from you between phases

- After **Phase 1**: confirm the actual guest profile name Salesforce created (so I can name the profile metadata file correctly).
- After **Phase 8**: the real `promptRequestId` so I can document it (no code change needed).