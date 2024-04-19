# Rules of Origin

Rules of origin are available on their own tab on the commodities page.

Within that tab, there are tables presenting rules, and optionally if V2 rules data is available a button to start the Rules of Origin wizard

The tab contents itself is rendered with from `/app/views/rules_of_origin/_tab.html.erb` or if V2 data is not available (currently XI) then `/app/rules_of_origin/legacy/_tab.html.erb`

## Data models

These are all API entity models, held within `/app/models/rules_of_origin` and populated with JSON-API data retrieved from the `/rules_of_origin_schemes/*` API's provided by the backend. More information is provided for this in the `/docs/rules_of_origin.md` file in the backend repo.

## Wizard

The wizard utilises the DfE wizard steps gem.

In abstract, this operates as follows.

All steps share a single controller for the entire wizard process with the step being viewed identified by the `:id` in the url, eg `/rules_of_origin/steps/<step_name>`

An instance of step model is loaded (eg `RulesOfOrigin::Steps::ImportExport`) in a `before_action` and any relevant params passed to it.

All steps use a regular RESTful `#show` and `#create` actions to show a step, or receive POSTed data from a step.

The controller checks the model is `#valid?`

* if it is, then the model is saved and then the wizard class (`RulesOfOrigin::Wizard`) is asked for the `:id` of the next step.

  The Wizard determines this by walking the ordered list of steps, and finding the next step which is not `<step_class>#skip?` and which is not `<step_class>#valid?`.

  The `#create` action the redirects to the `#show` of the next step

* if the step is not `#valid?` then the page is re-rendered with an errors from the step class

### Step models

These are regular ActiveModel classes with the `Wizard::Base` mixin, and are held in `/app/models/rules_of_origin_steps`

### Step views

These are regular erb partials held within `/app/views/rules_of_origin/steps` and utilising the GovUK Form Builder

The are included in the `/app/views/rules_of_origin/show.html.erb` page template
