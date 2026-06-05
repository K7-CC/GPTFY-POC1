# GPTfy POC1 — Project Walkthrough

**Audience:** Team / client presentation  
**Prepared by:** Project creator  
**Date:** June 5, 2026  
**Org:** `gptfy-poc1` (`kesavpoc@gptfy.com`)  
**Latest checkpoint:** Git tag `Part-1` · latest commit `4a5a27a`

---

## 1. Why this project exists

**Client:** Tungsten Automation  
**Product:** GPTfy (AI layer on Salesforce)  
**POC scope:** Use Case 2 — **Customer Assist + Knowledge Base Creation via Portal**

The business problem is straightforward:

- Customers wait too long for simple answers.
- Agents spend time on questions that could be self-served.
- When cases are resolved, that knowledge is rarely captured in a reusable Knowledge Base.

**What we built (Part 1 complete + Part 2 in progress):**

| Goal | How we achieve it |
|------|-------------------|
| Deflect simple support questions with AI | Guest portal + GPTfy RAG (two AI paths available) |
| Close cases automatically when the customer confirms | Platform Event + trigger |
| Let agents resolve in one click | Resolve quick action |
| Build a KB over time | Draft Knowledge articles on agent resolve + KB data pipeline |
| Email the answer to the customer | Record-triggered email flow |
| Support multiple Tungsten products | E-Invoicing, TotalAgility, PowerPDF |

**POC products:** E-Invoicing, TotalAgility, PowerPDF (3-week POC, $9,999 investment per signed scope doc).

---

## 2. Who uses the system

| Person | Role |
|--------|------|
| **Guest (portal visitor)** | Submits a question, reads the AI answer, confirms or escalates |
| **Support agent** | Uses the Resolve button, reviews draft KB articles |
| **Admin / developer** | Deploys metadata, configures flows/triggers, monitors email |

---

## 3. The big picture — three user paths, two AI modes

Everything runs on **Salesforce** in org `gptfy-poc1`, with **GPTfy** (`ccai` managed package) for AI.

### Three user-facing paths

**Path 1 — Guest Portal:** Guest on Experience Cloud site (`gptfysupport1`) → caseResolutionAssistant LWC → AI fills `Case.Description` → Platform Event closes Case.

**Path 2 — Agent Resolve:** Support Agent → Resolve Quick Action → Draft Knowledge Article created.

**Path 3 — Resolution Email:** Any case close (guest or agent) → `Case_Resolution_Email_RTF` → Email to `SuppliedEmail`.

**One rule ties it together:** whenever a Case closes with a resolution and a guest email, the customer gets that answer by email.

### Two AI resolution modes (switchable, never both active)

| Mode | Trigger | How it works |
|------|---------|-------------|
| **PATH 1 — Flow/GCP** | `Case_Resolution_RTF` record-triggered flow (active) | Invokes `ccai__AIPromptProcessingInvokable` via GPTfy/GCP; writes answer to `Case.Description` |
| **PATH 2 — Agent/RAG** | `CaseAIAgentTrigger` Apex trigger (active) | Enqueues `CaseAgentResolutionService` (Queueable + callout) → calls `ccai.AIAgenticUtility.invokeAgent()` → queries vector store → writes plain-text answer to `Case.Description` |

Both modes write to the same field. The LWC polling loop, Platform Event close path, and email flow are **shared and path-agnostic**.

> **Switch rule:** Activate exactly one. If both are active, two AI calls race to write `Case.Description`.

---

## 4. Guest Portal path (step by step)

This is the **self-service deflection** path. A customer visits the public Experience Cloud site (`gptfysupport1`).

### Step 1 — Customer fills the form

The UI is the LWC **caseResolutionAssistant**, embedded on the site home page.

Fields:

- First name, last name, email (required)
- Product (dynamic picklist — values loaded live from `Case.Product__c` via `getProductOptions()`)
- Question (required, max 255 chars)

The LWC validates input (email regex, required fields) before submit.

**Current POC products in picklist:** E-Invoicing, TotalAgility, PowerPDF.

### Step 2 — Case is created

On **Find Solution**, the LWC calls Apex: `CaseResolutionController.createSupportCase(...)`

This creates a Case with:

- `Origin = 'Web'` (critical — gates both AI modes)
- `Status = 'New'`
- `Subject` = the question (truncated to 255 chars)
- `SuppliedName`, `SuppliedEmail` = guest info
- `Product__c` = selected product (optional; null means search all products)

**Why without sharing?** Guest users on Experience Cloud cannot normally create Cases under default sharing. This controller runs elevated for these three narrow, guest-safe operations only.

### Step 3 — AI generates the answer

**PATH 1 (flow):** Case insert fires `Case_Resolution_RTF` → invokes GPTfy → writes answer to `Case.Description`.

**PATH 2 (agent):** Case insert fires `CaseAIAgentTrigger` → enqueues `CaseAgentResolutionService` → calls `ccai.AIAgenticUtility.invokeAgent()` with the cleaned subject → strips HTML from response → writes plain-text answer to `Case.Description`.

Subject cleaning (PATH 2): surrounding quotes are stripped before the RAG query (e.g. `"What is TotalAgility?"` → `What is TotalAgility?`) because they hurt vector similarity scoring.

The LWC shows a loading spinner and **polls every 2.5 seconds, up to 36 times (90 seconds total)** via `CaseResolutionController.getRecommendation(caseId)`.

- When `Description` is populated → pass through `sanitizeRecommendation()` → show the answer.
- If still empty after 90 s → show `TIMEOUT_MESSAGE`: *"Our support team has your case and will follow up with you shortly."*

### Step 4 — Low-quality response filtering

Before the answer is shown to the guest, `sanitizeRecommendation()` checks for known junk/confusion responses from the AI (e.g. "I didn't get that", "no answer found in the knowledge base", "can you repeat", etc.).

- **Exact match** — normalised lowercase against a `LOW_QUALITY_RESPONSES` set
- **Contains match** — substring scan against a `LOW_QUALITY_CONTAINS` list (catches long fallback sentences in agent system prompts)

If junk is detected → show `NO_ANSWER_MESSAGE`: *"We could not find a specific answer in our knowledge base at this time. Our support team will review your case and follow up with you shortly."*

This means guests never see raw AI error text.

### Step 5 — Customer chooses

Two buttons:

| Button | What happens |
|--------|--------------|
| **Yes, resolved** | Case closes; resolution saved; email sent |
| **No, create a case** | Case stays open; customer sees case number for agent follow-up |

### Step 6 — "Yes, resolved" (the close path)

Guest users **cannot update Cases directly** (Guest User License restriction — not bypassed by without sharing).

So we use a **Platform Event pattern**:

1. LWC calls `resolveCase(caseId)`
2. Apex publishes **Case_Resolved__e** with the Case Id
3. **CaseResolvedTrigger** runs as Automated Process (system context):
   - Sets `Status = 'Closed'`
   - Copies `Description` → `Resolution__c` (what the customer saw)
4. Case update fires the **email flow** (Path 3 below)

The LWC shows **"Closing your case..."** while this completes (usually 1–2 seconds).

---

## 5. Agent Resolve path (step by step)

When AI cannot help, or the customer clicks **No**, the case stays open for an agent.

### Step 1 — Agent opens an open Case

On the Case record page (highlights panel), the agent sees a **Resolve** button — only when `Status ≠ Closed` (Dynamic Action visibility filter; one-time Setup step documented in `docs/resolve_button_setup.md`).

### Step 2 — Agent clicks Resolve

A modal opens (LWC **caseResolveAction**, wrapped in Aura **caseResolveActionAura** because of a known Salesforce quirk with LWC quick actions on Case).

The agent types the resolution in a rich-text area.

### Step 3 — Agent clicks Save

Apex **CaseResolveActionController.saveResolution(caseId, resolutionText)** does three things:

1. **Updates the Case:** `Resolution__c` = typed text, `Status = 'Closed'`
2. **Creates or updates a Draft Knowledge article:**
   - Title = Case Subject
   - Resolution = agent's text
   - Linked to Case via `CaseArticle`
   - Dedupes: if a draft already exists for this case, it updates instead of creating a duplicate
3. **Returns a result** so the LWC can toast: *"Case resolved. Draft Knowledge article created/updated."*

KB creation is **best-effort** — if it fails, the case still closes and a warning toast is shown.

### Step 4 — Email (if guest email exists)

Same email flow as the portal path (Path 3 below).

**Design choice:** KB drafting is triggered on **agent resolve**, not on guest self-resolve. Portal-deflected closes copy AI text to `Resolution__c` but do not auto-draft KB articles yet (KCS-compliant KB drafting prompt is still pending).

---

## 6. Resolution email (automatic)

Flow: **Case_Resolution_Email_RTF** (Active)

**When it runs:**

- Case is **updated** to `Status = Closed`
- `SuppliedEmail` is not blank
- `Resolution__c` is not blank

**What the customer receives:**

| Field | Source |
|-------|--------|
| **To** | `Case.SuppliedEmail` |
| **Subject** | `Case.Subject` (their original question) |
| **Body** | Intro + decoded resolution text |
| **From** | Org-wide email `kesavamoorthy@cloudcompliance.app` |

**Technical detail:** `Resolution__c` is an HTML field, so quotes can store as `&quot;`. The flow decodes HTML entities before sending so the email looks correct.

**Note on sender domain:** Email currently sends via `...@sfcustomeremail.com` until DKIM is verified for `cloudcompliance.app`.

---

## 7. Knowledge Base data pipeline (NEW in Part 2)

Tungsten product FAQ content has been scraped, cleaned, and loaded into Salesforce Knowledge to power the RAG vector store.

### Data loaded

| Product | Source file | Approx. rows |
|---------|-------------|-------------|
| E-Invoicing | `data/einvoicing-faq-kb.csv` | ~2,600 |
| PowerPDF | `data/powerpdf-faq-kb.csv` | ~5,100 |
| TotalAgility | `data/totalagility-faq-kb.csv` | ~78,000 |

### How the pipeline works

```
Tungsten support site
    → scripts/scrape_tungsten_kb.py        (Python scraper)
    → data/*-faq-kb.csv                    (cleaned CSV)
    → scripts/batch_import_kb.py           (batch REST import)
    OR
    → scripts/generate_kb_apex.py          (generates Apex batch scripts)
    → scripts/apex/batches/batch_001.apex  (executed via sf CLI)
    → Salesforce Knowledge articles        (in gptfy-poc1 org)
    → GPTfy vector store index             (powers RAG for PATH 2)
```

### Why this matters

The vector store is only as good as the KB content loaded into it. With ~85,000 FAQ rows across three products, PATH 2 (Agent/RAG) has a rich source to query against.

---

## 8. Key Salesforce fields (Case)

| Field | Purpose |
|-------|---------|
| `Subject` | Guest question / email subject |
| `Description` | AI-generated answer (written by PATH 1 or PATH 2) |
| `Resolution__c` | Final resolution text (Html field; copied from Description on close) |
| `SuppliedEmail` | Guest email for notifications |
| `SuppliedName` | Guest name from form |
| `Origin` | `Web` for portal cases — gates both AI modes |
| `Product__c` | Product picklist — E-Invoicing / TotalAgility / PowerPDF |
| `Status` | `Closed` triggers email flow |

Many other GPTfy-related fields exist on Case (sentiment, RCA, triage, etc.) for **Use Case 1** (Case Intelligence) — provisioned in schema but **not in current focus**.

---

## 9. What's in the repo (technical inventory)

```
force-app/main/default/
├── lwc/
│   ├── caseResolutionAssistant/       ← Guest portal UI (dynamic picklist, 90s poll, response sanitization)
│   └── caseResolveAction/             ← Agent resolve modal
├── aura/
│   └── caseResolveActionAura/         ← Wrapper for quick action
├── classes/
│   ├── CaseResolutionController.cls   ← Guest Apex (without sharing; sanitizeRecommendation; getProductOptions)
│   ├── CaseResolveActionController.cls ← Agent Apex (with sharing)
│   └── *Test.cls                      ← Unit tests
├── triggers/
│   └── CaseResolvedTrigger.trigger    ← Platform event subscriber
├── objects/
│   ├── Case_Resolved__e/              ← Platform event
│   └── Case/fields/                   ← Custom fields: Resolution__c, Product__c
├── flows/
│   ├── Case_Resolution_RTF.flow       ← PATH 1: GPTfy AI prompt flow
│   └── Case_Resolution_Email_RTF.flow ← Resolution email
├── quickActions/
│   └── Case.Resolve                   ← Agent quick action
├── permissionsets/
│   └── gptfysupport_Guest_Access      ← Minimal guest permissions
├── settings/
│   └── EmailAuthorization             ← Substitute sender workaround
└── digitalExperiences/site/
    └── gptfysupport1/                 ← Experience Cloud site source

force-app-agent-path/main/default/
├── triggers/
│   └── CaseAIAgentTrigger.trigger     ← PATH 2: fires on Case insert (Origin=Web)
└── classes/
    └── CaseAgentResolutionService.cls ← PATH 2: Queueable; calls ccai.AIAgenticUtility.invokeAgent()

data/
├── einvoicing-faq-kb.csv              ← E-Invoicing KB (~2,600 rows)
├── powerpdf-faq-kb.csv                ← PowerPDF KB (~5,100 rows)
└── totalagility-faq-kb.csv            ← TotalAgility KB (~78,000 rows)

scripts/
├── scrape_tungsten_kb.py              ← Scrapes Tungsten support site
├── batch_import_kb.py                 ← Batch-imports KB CSV via REST API
├── generate_kb_apex.py                ← Generates Apex batch scripts from CSV
├── generate_kb_update_apex.py         ← Generates Apex update scripts
└── apex/
    ├── agent-path/testAgentPath.apex  ← PATH 2 smoke test
    ├── testRecommendationSanitize.apex
    ├── testIrrelevantQuestion*.apex   ← RAG quality tests
    ├── testEssentialEightRag.apex
    ├── testProductPicklist.apex
    ├── testConfigUnblockers.apex
    ├── testCaseResolutionEmail.apex
    ├── testCaseResolveActionUI.apex
    ├── testCaseResolveKbDraft.apex
    ├── describeAgent.apex             ← Agent inspection utilities
    ├── readAgentPrompt.apex
    ├── updateAgentPrompt.apex
    └── verifyAgentPrompt.apex

docs/
├── PRD.md                             ← Living product doc (auto-changelog)
└── GPTfy-POC1-Project-Walkthrough.md ← This file

POC_CHECKLIST.md                       ← Full POC tracker
```

---

## 10. What's done vs. what's still pending

### Done — Part 1 (verified in org, 2026-06-03)

- Guest portal LWC + Apex + polling
- Platform Event close path for guests
- Agent Resolve quick action + KB draft
- Resolution email with plain-text body fix
- Apex unit tests + org verification scripts
- GitHub repo + Part 1 checkpoint (`Part-1` tag)

### Done — Part 2 (in progress, 2026-06-04 → 2026-06-05)

- PATH 2: `CaseAIAgentTrigger` + `CaseAgentResolutionService` (Queueable, callout to `ccai.AIAgenticUtility`)
- Switch mechanism between PATH 1 and PATH 2
- Low-quality AI response filtering (`sanitizeRecommendation`, 30+ junk patterns)
- Dynamic product picklist (`getProductOptions`) — E-Invoicing, TotalAgility, PowerPDF
- `cleanSubject()` — strips surrounding quotes before RAG query
- `stripHtml()` — strips HTML tags and collapses blank lines in agent response
- KB data files loaded: ~85,000 FAQ rows across 3 products
- KB import/scrape pipeline (Python + Apex)
- Experience Cloud site source (`gptfysupport1`)
- Extended polling window: 30 s → 90 s
- Expanded verification scripts (RAG quality, sanitize, config, product, agent path)
- Agent prompt utility scripts (describe, read, update, verify)

### Still pending (for full POC sign-off)

| Priority | Item |
|----------|------|
| High | **Decide AI path for demo** — activate PATH 1 (flow) or PATH 2 (agent) — never both |
| High | Complete TotalAgility KB import (large dataset — batch jobs) |
| Medium | GPTfy KCS-compliant KB drafting prompt for agent resolve |
| Medium | DKIM verification for `cloudcompliance.app` email domain |
| Medium | Deflection metrics and reports |
| Medium | UAT + demo recording for leadership |
| Low | Finalize Experience Cloud site branding (`gptfysupport1`) |

**Out of scope for now:** Use Case 1 (Case Intelligence) and Use Case 3 (Microsoft Copilot).

---

## 11. How to demo this to your team/client

### Pre-demo checklist

- [ ] Confirm which AI path is active (check Setup → Apex Triggers for `CaseAIAgentTrigger`, and Flows for `Case_Resolution_RTF`)
- [ ] Verify KB articles are published in org (at least PowerPDF and E-Invoicing)
- [ ] Open Experience Cloud site URL in incognito before presenting

### Demo script — Guest portal path

1. Open the public `gptfysupport1` Experience Cloud site in incognito
2. Fill in: first name, last name, email, select a product (e.g. PowerPDF), type a question
3. Click **Find Solution** — wait for AI answer (~5–30 seconds depending on active path)
4. Show the AI answer on screen
5. Click **Yes, resolved**
6. In Salesforce: show Case status = Closed, `Resolution__c` populated, email received

### Demo script — Agent resolve path

1. Open an open Case (or one where the guest clicked **No**)
2. Click **Resolve** in the highlights panel → type a resolution → Save
3. Show: Case closed, toast confirms "Draft Knowledge article created/updated"
4. Open the linked Knowledge article in draft status
5. If `SuppliedEmail` exists on the case, show the email received by the customer

### Verification in org

```powershell
# Smoke test all paths
sf apex run --file scripts/apex/testCaseResolutionEmail.apex --target-org gptfy-poc1

# Test PATH 2 (Agent/RAG) specifically
sf apex run --file scripts/apex/agent-path/testAgentPath.apex --target-org gptfy-poc1

# Test RAG answer quality
sf apex run --file scripts/apex/testEssentialEightRag.apex --target-org gptfy-poc1
```

Test records use subject prefix `cursor-test-{timestamp}` for easy cleanup.

---

## 12. One-sentence pitch for leadership

> **GPTfy POC1 lets customers get instant AI answers on a public portal and close their own cases when satisfied — while agents resolve complex cases in one click and automatically draft Knowledge articles — with every resolution emailed back to the customer — backed by 85,000 Tungsten product FAQ articles in the vector store.**

---

## 13. Suggested talking order for your presentation

1. **Business problem** (Section 1) — 2 min
2. **Three paths + two AI modes overview** (Section 3) — 3 min
3. **Live demo: guest portal** (Section 4) — 5 min
4. **Live demo: agent resolve + KB** (Section 5) — 3 min
5. **Email confirmation** (Section 6) — 1 min
6. **KB data pipeline** (Section 7) — 2 min
7. **What's next** (Section 10) — 2 min

---

*This document is maintained in source control at `docs/GPTfy-POC1-Project-Walkthrough.md`.*
