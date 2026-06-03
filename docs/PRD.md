# GPTfy POC1 — Product Requirements Document (PRD)

| Field | Value |
|-------|-------|
| **Project** | GPTfy POC1 (Tungsten Automation — Use Case 2) |
| **Status** | In Progress — Part 1 complete |
| **Last updated** | 2026-06-03 |
| **GitHub repo** | https://github.com/K7-CC/GPTFY-POC1 |
| **Salesforce org** | `gptfy-poc1` (`kesavpoc@gptfy.com`) |
| **Checkpoint tag** | `Part-1` |

---

## How to use this document

This PRD is a **living document**. It grows as the project grows.

| When | What to do |
|------|------------|
| After each commit / push | Run `.\scripts\update-prd-changelog.ps1` from the project root |
| After a major milestone | Add a new **Part** section and create a git tag (e.g. `Part-2`) |
| When the project is complete | Export to PDF — see [Export to PDF](#export-to-pdf) at the bottom |

---

## 1. What this project does (simple summary)

GPTfy POC1 helps customers get answers without waiting for an agent, and helps agents close cases faster.

**Three main paths:**

1. **Guest portal** — A customer fills a form, AI writes an answer, customer clicks “Yes, resolved”, case closes, email sent.
2. **Agent Resolve button** — An agent types a resolution, case closes, draft Knowledge article created.
3. **Resolution email** — When any case with a guest email closes, the customer receives the answer by email.

---

## 2. Goals

| Goal | Why it matters |
|------|----------------|
| Deflect simple support questions via AI | Reduce agent workload |
| Close cases automatically when guest confirms | Faster resolution, no manual step |
| Let agents resolve cases in one click | Less clicking, consistent data |
| Draft Knowledge articles from resolutions | Build a reusable KB over time |
| Email the answer to the guest | Customer gets proof of resolution |

---

## 3. Users

| User | What they do |
|------|--------------|
| **Guest (portal visitor)** | Submits question, reads AI answer, confirms resolution |
| **Support agent** | Uses Resolve button, reviews draft KB articles |
| **Admin / developer** | Deploys metadata, configures flows, monitors email |

---

## 4. Features built (Part 1)

### 4.1 Guest portal — Case Resolution Assistant

**What the user sees:** A form on the Experience Cloud site.

**Steps (guest journey):**

1. Guest enters first name, last name, email, product (optional), and question.
2. Guest clicks submit → a Case is created with `Origin = Web`.
3. Screen shows “loading” while AI works (polls up to 12 times, every 2.5 seconds).
4. AI answer appears in `Case.Description` (via GPTfy prompt flow).
5. Guest reads the answer and can:
   - Click **“Yes, resolved”** → case closes, resolution saved, email sent.
   - Click **“No, create a case”** → case stays open for an agent.

**Technical pieces:**

| Piece | Location |
|-------|----------|
| LWC (UI) | `force-app/main/default/lwc/caseResolutionAssistant/` |
| Apex controller | `force-app/main/default/classes/CaseResolutionController.cls` |
| Apex tests | `force-app/main/default/classes/CaseResolutionControllerTest.cls` |
| Guest permission set | `force-app/main/default/permissionsets/gptfysupport_Guest_Access.permissionset-meta.xml` |
| AI prompt flow | `force-app/main/default/flows/Case_Resolution_RTF.flow-meta.xml` |

---

### 4.2 Guest “Yes, resolved” — Case close path

**What happens behind the scenes:**

1. LWC calls `CaseResolutionController.resolveCase(caseId)`.
2. Apex publishes platform event `Case_Resolved__e` with the Case Id.
   - Guest users cannot update Cases directly — platform event runs in system context.
3. Trigger `CaseResolvedTrigger` fires:
   - Sets `Status = Closed`
   - Copies `Description` → `Resolution__c`
4. Record-triggered flow `Case_Resolution_Email_RTF` sends email (see 4.4).

**Technical pieces:**

| Piece | Location |
|-------|----------|
| Platform event | `force-app/main/default/objects/Case_Resolved__e/` |
| Trigger | `force-app/main/default/triggers/CaseResolvedTrigger.trigger` |

---

### 4.3 Agent Resolve button

**What the agent sees:** A **Resolve** button on open Cases (highlights panel).

**Steps (agent journey):**

1. Agent opens a Case where `Status ≠ Closed`.
2. Agent clicks **Resolve** → modal opens with rich-text editor.
3. Agent types resolution and clicks **Save**.
4. System:
   - Saves text to `Case.Resolution__c`
   - Sets `Status = Closed`
   - Creates or updates a **Draft** Knowledge article linked to the Case
5. Toast confirms success; page refreshes.

**One-time org setup (not in source):** Wire the Resolve action on the Case Lightning Record Page. See `docs/resolve_button_setup.md`.

**Technical pieces:**

| Piece | Location |
|-------|----------|
| LWC (modal) | `force-app/main/default/lwc/caseResolveAction/` |
| Aura wrapper | `force-app/main/default/aura/caseResolveActionAura/` |
| Apex controller | `force-app/main/default/classes/CaseResolveActionController.cls` |
| Apex tests | `force-app/main/default/classes/CaseResolveActionControllerTest.cls` |
| Quick Action | `force-app/main/default/quickActions/Case.Resolve.quickAction-meta.xml` |

---

### 4.4 Resolution email on case close

**When it runs:** Case is updated to `Status = Closed`, `SuppliedEmail` is filled, and `Resolution__c` is not blank.

**What the guest receives:**

| Field | Source |
|-------|--------|
| **To** | `Case.SuppliedEmail` |
| **Subject** | `Case.Subject` (their original question) |
| **Body** | Intro line + decoded resolution text |

**Email body fix (Part 1):** Plain text format + HTML entity decoding (`&quot;` → `"`) so quotes display correctly.

**Org settings:**

| Setting | Value |
|---------|-------|
| Org-wide email | `kesavamoorthy@cloudcompliance.app` |
| Substitute sender workaround | `EmailAuthorization.enableSubstituteFromAddress = true` |
| Actual send domain | `...@sfcustomeremail.com` (until DKIM verified) |

**Technical pieces:**

| Piece | Location |
|-------|----------|
| Email flow | `force-app/main/default/flows/Case_Resolution_Email_RTF.flow-meta.xml` |
| Email auth setting | `force-app/main/default/settings/EmailAuthorization.settings-meta.xml` |

---

## 5. End-to-end flow diagrams

### Guest portal → close → email

```
Guest form (LWC)
    → createSupportCase (Apex)
    → Case created (Origin=Web)
    → Case_Resolution_RTF flow → GPTfy AI → Description filled
    → Guest sees answer
    → "Yes, resolved" → resolveCase (Apex)
    → Case_Resolved__e published
    → CaseResolvedTrigger → Status=Closed, Resolution__c=Description
    → Case_Resolution_Email_RTF → email to SuppliedEmail
```

### Agent resolve → KB draft

```
Agent clicks Resolve (Quick Action)
    → caseResolveAction LWC modal
    → saveResolution (Apex)
    → Resolution__c saved, Status=Closed
    → Draft Knowledge article created/updated + linked to Case
    → Case_Resolution_Email_RTF (if SuppliedEmail present)
```

---

## 6. Key Salesforce fields (Case)

| Field | Purpose |
|-------|---------|
| `Subject` | Guest question / email subject |
| `Description` | AI-generated answer (portal path) |
| `Resolution__c` | Final resolution text (Html field) |
| `SuppliedEmail` | Guest email for notifications |
| `SuppliedName` | Guest name from form |
| `Origin` | `Web` for portal cases |
| `Product__c` | Product picklist for KB filtering |
| `Status` | `Closed` triggers email flow |

---

## 7. Verification scripts

All test scripts live in `scripts/apex/`. Run with:

```powershell
sf apex run --file scripts/apex/<script-name>.apex --target-org gptfy-poc1
```

| Script | What it tests |
|--------|---------------|
| `testCaseResolutionEmail.apex` | Guest close, agent close, no-email guard, re-save guard |
| `testCaseResolutionEmailBody.apex` | Email body formatting with quotes |
| `testCaseResolveActionUI.apex` | Agent resolve path |
| `testCaseResolveKbDraft.apex` | Knowledge article draft on resolve |

Test records use marker `cursor-test-{timestamp}` in Subject for easy cleanup.

---

## 8. Known limitations (Part 1)

| Limitation | Notes |
|------------|-------|
| `Resolution__c` is Html field | Quotes may store as `&quot;` — email flow decodes them |
| Email sender uses substitute address | Until DKIM verified for `cloudcompliance.app` |
| `Case_Resolution_RTF` may be Draft in org | Needs activation + prompt verification |
| Resolve button page wiring | Manual one-time Setup step |
| Product picklist values | May still need POC product values (E-Invoicing, etc.) |
| KB drafting via GPTfy AI | Direct copy shipped; full AI KCS prompt pending |

---

## 9. Pending work (after Part 1)

See `POC_CHECKLIST.md` for full checklist. High-priority items:

- [ ] Activate `Case_Resolution_RTF` flow
- [ ] Update `Product__c` picklist to POC products
- [ ] Import Tungsten DocShield / Knowledge content
- [ ] GPTfy KB drafting prompt (KCS-compliant)
- [ ] Deflection metrics and reports
- [ ] UAT and demo recording

---

## 10. Repository and checkpoints

| Item | Value |
|------|-------|
| Remote | `origin` → https://github.com/K7-CC/GPTFY-POC1.git |
| Default branch | `main` |
| Checkpoint **Part 1** | Tag `Part-1` on commit `15e9bcb` |

**Restore to Part 1:**
```powershell
git fetch origin
git checkout Part-1
```

---

## 11. Change log (auto-updated from Git)

<!-- CHANGELOG_START -->
| Date | Commit | Tag | Summary |
|------|--------|-----|---------|
| 2026-06-03 | `15e9bcb` | Part-1 | Initial commit: GPTfy POC1 Salesforce project — portal, agent resolve, resolution email flow, org verification scripts |
<!-- CHANGELOG_END -->

---

## 12. Part history (milestones)

### Part 1 — Working baseline (2026-06-03)

**Tag:** `Part-1` · **Commit:** `15e9bcb`

**Delivered:**
- Guest portal LWC + Apex + platform event close path
- Agent Resolve quick action + KB draft
- Resolution email flow with plain-text body fix
- Org verification scripts
- GitHub repo + Part 1 checkpoint

**Status:** Verified working in `gptfy-poc1` org.

---

<!-- Add Part 2, Part 3, etc. below as milestones are reached -->

---

## Export to PDF

When the project is complete, use any of these options:

### Option A — VS Code / Cursor (easiest)

1. Open `docs/PRD.md` in the editor.
2. Install extension **Markdown PDF** (yzane.markdown-pdf) if not installed.
3. Right-click the file → **Markdown PDF: Export (pdf)**.
4. Save as `docs/PRD-GPTfy-POC1-Final.pdf`.

### Option B — GitHub (no install)

1. Push latest `docs/PRD.md` to GitHub.
2. Open the file on github.com → it renders as formatted HTML.
3. Browser **Print** → **Save as PDF**.

### Option C — Pandoc (command line)

```powershell
pandoc docs/PRD.md -o docs/PRD-GPTfy-POC1-Final.pdf --pdf-engine=wkhtmltopdf
```

### Before final export

1. Run `.\scripts\update-prd-changelog.ps1` so all commits are listed.
2. Update **Status** at the top to `Complete`.
3. Fill in any remaining **Part** sections.
4. Export using one of the options above.

---

*This document is maintained in source control at `docs/PRD.md`.*
