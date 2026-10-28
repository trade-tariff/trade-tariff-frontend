# Feature flags and saved opt-ins

Flagsmith core stores manual browser opt-ins as true identity traits. A saved
opt-in enables a registered feature. Disabling removes the trait and the cached
opt-in, rather than storing false. It also unenrols the browser session from every
experiment containing that feature. Visiting an active experiment URL again can
therefore enrol all its features. The parcel and gift journey and duty
calculator are standard journeys and are not listed as opt-ins.
Unrelated enrolments and manual opt-ins remain unchanged.

An explicit environment value of `false` remains an operator OFF switch.
Service restrictions still apply. The page only lists features for the current service
that the operator has not disabled, and rejects saves for excluded features.
Without an opt-in, normal Flagsmith rollout and defaults apply.
Experiment traits stay separate from saved preferences and do not force flags on.

## Browser persistence

The existing `flagsmith_anonymous_id` cookie identifies the browser. The signed,
HTTP-only `flagsmith_optin_preferences` cookie caches registered true opt-ins,
bound to that identifier and application environment. Both cookies are secure in
production. Saving or refreshing preferences renews both cookies for one year
without changing the UUID. Ordinary page views do not renew them or call core.

On an ordinary request, legacy `session[:flagsmith_optin_traits]` values migrate
into the preference cookie if the browser still has its identity and no preference
cookie exists. Old false values are treated as unset. An existing cookie is authoritative,
including absent keys, so stale session values cannot restore a cleared opt-in.
The legacy key is deleted only after the cookie write succeeds; unrelated
session data remains. Preferences do not follow a missing or changed identity.

## Reading and changing preferences

Opening `/feature-flags` refreshes the cookie from core before any flags are
evaluated. This also recovers existing saved preferences when the old session has
already disappeared. No bulk identity scan or automatic core lookup runs for
browsers without a preference cookie. Changes made directly in core take effect
for that browser on its next settings-page refresh.

Preference reads use `POST /api/v1/identities/` with identity-level
`transient: true` and no replacement traits. The deployed Flagsmith version must
support reading existing traits without creating unknown identities in this mode.
Edge evaluation requests also mark the identity and opt-in traits as transient.
Only explicit preference saves write to core. Enable uses the single-trait POST
endpoint. Disable uses `PUT /api/v1/traits/bulk/` with a null trait value to delete
only that browser's trait without creating an unknown identity.

A failed core refresh keeps the cached preferences in use and reports
the failure on the settings page. A failed save does not replace the cached
preference. The page shows Enabled or Disabled and offers the opposite action.
A failed deletion also leaves experiment enrolment unchanged.

Rolling back to the session-based implementation loses the new cookie's benefit.
It leaves saved core preferences intact, but the old application does not read the
new cookie and may require the user to opt in again for that session.
