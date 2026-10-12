# Feature flags and saved opt-ins

Flagsmith core stores manual opt-in preferences as boolean identity traits. Edge
Proxy evaluates those preferences alongside country and active experiment traits.
A saved opt-in is not a direct flag override. Service restrictions and Flagsmith
rollout rules still determine availability.

## Browser persistence

The existing `flagsmith_anonymous_id` cookie identifies the browser. The signed,
HTTP-only `flagsmith_optin_preferences` cookie caches registered boolean opt-ins,
bound to that identifier and application environment. Both cookies are secure in
production. Saving or refreshing preferences renews both cookies for one year
without changing the UUID. Ordinary page views do not renew them or call core.

On an ordinary request, legacy `session[:flagsmith_optin_traits]` values migrate
into the preference cookie if the browser still has its identity. Both true and
false values migrate. Existing cookie values take precedence over stale session
values. The legacy key is deleted only after the cookie write succeeds; unrelated
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
Only explicit preference saves use the persistent trait-write endpoint.

A failed core refresh keeps the cached preferences available to Edge and reports
the failure on the settings page. A failed save does not replace the cached
preference. The page shows saved preference separately from effective availability;
removing an opt-in does not exclude a browser from an automatic rollout or an
active experiment.

Rolling back to the session-based implementation loses the new cookie's benefit.
It leaves saved core preferences intact, but the old application does not read the
new cookie and may require the user to opt in again for that session.
