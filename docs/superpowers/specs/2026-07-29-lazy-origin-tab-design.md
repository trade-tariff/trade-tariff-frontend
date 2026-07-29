# Lazy-load the Origin tab on commodity show

**Date:** 2026-07-29
**Status:** Approved

## Problem

Every commodity page request with a country selected makes a separate backend API call to `RulesOfOrigin::Scheme.for_heading_and_country` before rendering. This call is only consumed by the "Origin" tab, which most users never open. The result is wasted latency on every country-filtered commodity page load.

## Solution

Defer the Rules of Origin API call and the Origin tab render to a new `GET /commodities/:id/origin` endpoint. The Origin tab panel initially shows a loading placeholder; a Stimulus controller fetches and injects the real content on first tab activation (click, or direct link via URL hash).

A loading state on direct links (`/commodities/...#rules-of-origin`) is acceptable.

## Architecture

### New route

```ruby
# config/routes.rb
resources :commodities, only: [:show] do
  member { get :origin }
end
```

Generates `origin_commodity_path(id)` → `GET /commodities/:id/origin`.
The service path prefix middleware handles `/xi/commodities/:id/origin` automatically.

### New controller action — `CommoditiesController#origin`

Moves the Rules of Origin fetching logic out of `show`:

```ruby
def origin
  if params[:country].present? && @search.geographical_area
    @rules_of_origin_schemes = declarable.rules_of_origin(params[:country])
  else
    @roo_all_schemes = Rails.cache.resilient_fetch(['roo_all_schemes', cache_key]) do
      RulesOfOrigin::Scheme.all
    end
  end

  render 'origin', layout: false
end
```

- Renders without layout (returns an HTML fragment).
- `declarable` loading is unchanged — uses the same `resilient_fetch`-cached commodity presenter as `show`.
- The `@roo_all_schemes` path uses the same cache introduced in the prior PR.

### `show` action change

Remove the RoO fetching block from `show` entirely:

```ruby
# REMOVE:
if params[:country].present? && @search.geographical_area
  @rules_of_origin_schemes = declarable.rules_of_origin(params[:country])
else
  @roo_all_schemes = Rails.cache.resilient_fetch(['roo_all_schemes', cache_key]) do
    RulesOfOrigin::Scheme.all
  end
end
```

### New view — `app/views/commodities/origin.html.erb`

Contains exactly the markup currently inside the Origin tab panel in `app/views/measures/_measures.html.erb` (the `component.with_tab(label: 'Origin')` block body). No layout wrapping.

### View change — `app/views/measures/_measures.html.erb`

The Origin tab panel body changes from full inline render to a lazy-load placeholder:

```erb
<% component.with_tab(label: 'Origin', id: 'rules-of-origin') do %>
  <div data-controller="lazy-tab"
       data-lazy-tab-url-value="<%= origin_commodity_path(declarable.code, request.query_parameters) %>">
    <p class="govuk-body">Loading…</p>
  </div>
<% end %>
```

`request.query_parameters` passes the current country, date, and meursing params through to the `origin` endpoint so it renders the correct content.

### Stimulus controller — `app/javascript/controllers/lazy_tab_controller.js`

```
Values:   url (String)
Targets:  none (operates on element itself)
```

Behaviour:

1. **`connect()`** — If `window.location.hash === '#rules-of-origin'`, call `load()` immediately (handles direct links).
2. **Tab link click listener** — On `connect()`, find the tab link with `href="#rules-of-origin"` in the nearest `govuk-tabs` ancestor. Add a one-time click listener that calls `load()`.
3. **`load()`** — Guard: if already loaded or in-flight, return. Set in-flight flag. `fetch(this.urlValue)`, `await` the response.
   - On success: replace `this.element.innerHTML` with the response text.
   - On non-2xx or network error: replace `this.element.innerHTML` with a GOV.UK error paragraph (`govuk-error-message`): "Sorry, this content could not be loaded. Please refresh the page to try again."
4. **No double-fetch**: a `loaded` boolean on the controller instance prevents repeated fetches on subsequent tab activations.

### Error handling

| Scenario | Behaviour |
|---|---|
| Backend returns non-2xx | Show inline error message in tab panel |
| Network error | Show inline error message in tab panel |
| Backend slow | Loading placeholder remains until response arrives |
| Direct link (`#rules-of-origin`) | `connect()` triggers load immediately; user sees spinner briefly |

## Files changed

| File | Change |
|---|---|
| `config/routes.rb` | Add `member { get :origin }` to commodities resource |
| `app/controllers/commodities_controller.rb` | Add `origin` action; remove RoO fetch from `show` |
| `app/views/commodities/origin.html.erb` | New — origin tab content (moved from measures partial) |
| `app/views/measures/_measures.html.erb` | Replace Origin tab body with lazy-load placeholder |
| `app/javascript/controllers/lazy_tab_controller.js` | New Stimulus controller |
| `spec/requests/commodity_spec.rb` | Add specs for `#origin`; remove RoO expectations from `#show` |

## Testing

**Request specs (`spec/requests/commodity_spec.rb`):**
- `GET /commodities/:id/origin` with country: renders origin partial without layout, assigns `@rules_of_origin_schemes`
- `GET /commodities/:id/origin` without country: renders origin partial without layout, assigns `@roo_all_schemes`
- `GET /commodities/:id/origin` for XI service: renders correct partial
- `GET /commodities/:id` (show): does not assign `@rules_of_origin_schemes` or `@roo_all_schemes`

**JavaScript specs (`spec/javascript/`):**
- `lazy_tab_controller`: triggers `load()` on tab link click
- `lazy_tab_controller`: triggers `load()` on connect when hash matches
- `lazy_tab_controller`: does not double-fetch on second click
- `lazy_tab_controller`: shows error message on non-2xx response

## Risk

🟢 Green. The `show` action's behaviour is unchanged for all non-Origin tab content. The Origin tab degrades gracefully (error message shown on failure). The new `origin` endpoint is additive. No changes to GOV.UK component rendering or layout.
