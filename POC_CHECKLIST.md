# Tungsten Automation — GPTfy POC Checklist

> **Source document:** `GPTfy for Tungsten Automation.pdf` (Recommended POC Scope, signed May 20, 2026)
> **POC duration:** 3 weeks · **Investment:** $9,999
> **POC products:** E-Invoicing · TotalAgility · PowerPDF
> **Current focus:** Use Case 2 — Customer Assist + KB Creation (Portal)

Legend: `[x]` done · `[ ]` pending · `[~]` partial / needs verification · `[-]` out of current scope

---

## Use Case 2 — Customer Assist + KB Creation (Portal) — IN PROGRESS

### A. Portal deflection (guest-facing)

- [x] Guest-facing LWC `caseResolutionAssistant` (form + 6 UI states)
- [x] LWC field validation (first/last name, email regex, question)
- [x] LWC polling loop for AI answer (12 attempts × 2.5s + fallback message)
- [x] Apex controller `CaseResolutionController` (`without sharing`, guest-safe)
  - [x] `createSupportCase` (sets `Origin='Web'`)
  - [x] `getRecommendation` (polled by LWC)
  - [x] `resolveCase` (publishes `Case_Resolved__e`)
  - [x] `getProductOptions` (cacheable picklist)
- [x] Apex test class `CaseResolutionControllerTest`
- [x] `Case.Product__c` picklist field exists
- [x] Platform Event `Case_Resolved__e` (HighVolume, PublishImmediately)
- [x] Trigger `CaseResolvedTrigger` (closes case + copies AI answer to `Resolution__c`)
- [x] Permission set `gptfysupport_Guest_Access` (min permissions)
- [x] Record-triggered flow `Case_Resolution_RTF` (Origin='Web' → GPTfy AI Prompt)
- [x] Case page layout `Case-GPTfy Case Layout`

### B. Configuration / unblockers (HIGH PRIORITY)

- [ ] **Update `Case.Product__c` picklist values to match POC scope**
  - Replace `GPTFY` / `DATA MASKER` / `CLOUD COMPLIANCE`
  - Add: `E-Invoicing`, `TotalAgility`, `PowerPDF`
- [ ] **Activate `Case_Resolution_RTF` flow** (currently `<status>Draft</status>`)
- [ ] Verify GPTfy `promptRequestId` (`9cf7e95aacf31f5730a118c90c6fda4676843`) points to a prompt that:
  - [ ] Uses `Case.Product__c` to filter KB retrieval
  - [ ] Writes back into `Case.Description`
- [ ] Confirm Experience Cloud (LWR) site exposes `caseResolutionAssistant`
- [ ] Confirm Guest User profile is assigned `gptfysupport_Guest_Access`

### C. Content / data (PHASE 1 — TUNGSTEN DELIVERABLES)

- [ ] DocShield URLs received from Tungsten for the 3 POC products
- [ ] DocShield content imported into GPTfy org (Knowledge or equivalent)
- [ ] Salesforce Knowledge articles created/imported with product tags
- [ ] Hashtag hierarchy table received from Tungsten
- [ ] 20–30 sample cases received from Tungsten and loaded
- [ ] Copilot SSO access info received from Tungsten

### D. KCS-compliant KB Creation (the "compounding" half — IN PROGRESS)

- [x] Design: trigger point for drafting KB — chosen: agent `Resolve` quick action (`CaseResolveActionController.saveResolution`); portal-deflected path (`CaseResolvedTrigger`) intentionally deferred
- [ ] GPTfy prompt template for KB article drafting (KCS-compliant: Title, Issue, Environment, Resolution, Cause)
- [~] Apex / Flow to invoke KB drafting prompt from resolved case — direct copy (Subject→Title, Resolution__c→Resolution__c) shipped; GPTfy AI drafting still pending
- [x] Draft Knowledge article record created in `Draft` state for review
- [x] Link drafted article back to source `Case` for traceability (via `CaseArticle` junction; dedupes on re-save)
- [ ] Approval / publish workflow (human-in-loop initially)
- [ ] Published articles re-feed into the portal KB lookup

### E. Metrics & reporting (needed for POC value story)

- [ ] Field on Case to flag agent-touchless deflection (e.g. `Deflected_By_AI__c`)
- [ ] Set the deflection flag in `CaseResolvedTrigger` when guest clicks "Yes, resolved"
- [ ] Report: deflected cases / month
- [ ] Report: KB articles auto-drafted / month
- [ ] Report: avg time-to-resolution for portal-deflected cases

### F. Testing & UAT (PHASE 3)

- [ ] End-to-end demo run with all 3 POC products
- [ ] Categorization accuracy review with Tungsten (Gareth, Mike, Lara)
- [ ] UAT sign-off on portal deflection
- [ ] UAT sign-off on KB article quality
- [ ] Polished demo recording for leadership
- [ ] Expansion roadmap delivered

---

## Use Case 1 — Case Intelligence (closure summary, sentiment, RCA, hashtags) — NOT IN CURRENT FOCUS

- [x] Schema provisioned: `GPTfy_Summary__c`, `Case_Summary__c`, `GPTfy_Sentiment__c`, `GPTfy_Sentiment_Score__c`, `Case_Sentiment__c`, `GPTfy_Root_Cause_Analysis__c`, `GPTfy_Root_Cause_Reason__c`, `Root_Cause__c`, `Topics__c`, `Intent_Analysis__c`, `Intention__c`, `Issue__c`, `Issue_Triage_Score__c`, `issue_Triage_Routing__c`, `SLA_Status__c`, `Ticket_Age_Hours__c`, `AI_Suggested_Articles__c`, `AI_Suggested_Product__c`, `Prior_Escalation_Same_Issue__c`, `Prior_Ticket_Refs__c`, etc.
- [-] Closure-triggered flow to invoke Case Intelligence prompt — pending (Use Case 1)
- [-] Hashtag hierarchy wired into categorization prompt — pending (Use Case 1)
- [-] Operational view (for reps) — pending (Use Case 1)
- [-] Executive view (for leadership) — pending (Use Case 1)
- [-] Human-in-loop → full-auto promotion path — pending (Use Case 1)

## Use Case 3 — Microsoft Copilot Integration — NOT IN CURRENT FOCUS

- [-] GPTfy Copilot agent installed from MS Marketplace — pending (Use Case 3)
- [-] SSO between Salesforce and Copilot configured — pending (Use Case 3)
- [-] Case status / sentiment / next steps surfaced in Teams — pending (Use Case 3)
- [-] Account planning queries (opps, contacts, case history) — pending (Use Case 3)

---

## POC Phase Tracker

- [~] **Phase 1 — Setup (Wk 0–1)** · ~8 hrs from Tungsten — _portal infrastructure built; awaiting content + config_
- [ ] **Phase 2 — Test & Optimize (Wk 1–3)** · ~8 hrs from Tungsten
- [ ] **Phase 3 — UAT & Demo (Wk 3–4)** · ~4 hrs from Tungsten

---

_Last updated: 2026-06-03 — agent-resolve path now drafts a linked Knowledge article on Save_
