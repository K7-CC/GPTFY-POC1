# Resolve Button — Post-Deploy Setup

The `Resolve` Quick Action and its LWC/Aura/Apex are deployed via source. The
final step — wiring the button into the Case Lightning Record Page as a
**Dynamic Action** with a "show only on open cases" filter — is a one-time
manual step in Setup, because the org's Case Lightning Record Page is not
tracked in source in this repo.

## Architecture note: why an Aura wrapper

The real UI is in the LWC `caseResolveAction`. It is hosted inside a thin Aura
wrapper `caseResolveActionAura` purely because the Salesforce metadata API in
this org rejects direct LWC references from a Case Quick Action with
`Unable to retrieve lightning component by namespace/developer name` (a known
issue for LWC quick actions on Case in some orgs). The Aura wrapper sidesteps
the validator and forwards `recordId` to the LWC. If Salesforce ever fixes
the underlying issue, the QuickAction can be repointed at `caseResolveAction`
and the Aura bundle deleted.

## One-time configuration

1. Setup → Object Manager → **Case** → Lightning Record Pages.
2. Open the Lightning Record Page currently assigned to Case (org default if
   nothing custom).
3. Select the **Highlights Panel** component on the canvas.
4. In the right-hand properties pane, click **Upgrade Now** if prompted (this
   migrates the page from page-layout-driven actions to Dynamic Actions).
5. Click **Add Action** → pick **Resolve** from the action list.
6. With **Resolve** selected, under **Set Component Visibility** click
   **Add Filter** and configure:
   - Field: `Record > Status`
   - Operator: **Does Not Equal**
   - Value: `Closed`
7. **Save** and **Activate** the page (App Default / org default as needed).

## Smoke test

- Open any case where `Status != 'Closed'` → the **Resolve** button should
  appear in the highlights panel.
- Click it → modal opens with a rich-text editor.
- Type a solution → click **Save** → toast "Case resolved" → modal closes →
  page refreshes and shows `Status = Closed` with the text now in the
  **Resolution** field.
- Open a case with `Status = 'Closed'` → the **Resolve** button should NOT
  appear.

## What lives in source

| Artifact | Path |
| --- | --- |
| LWC (modal body) | `force-app/main/default/lwc/caseResolveAction/` |
| Aura wrapper | `force-app/main/default/aura/caseResolveActionAura/` |
| Apex controller | `force-app/main/default/classes/CaseResolveActionController.cls` |
| Apex tests | `force-app/main/default/classes/CaseResolveActionControllerTest.cls` |
| Quick Action | `force-app/main/default/quickActions/Case.Resolve.quickAction-meta.xml` |
