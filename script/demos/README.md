# Guided-search loading prototype

Start the local backend on port 3000 and its Sidekiq search worker. From the frontend checkout:

```sh
direnv exec . env RAILS_ENV=development bin/rails assets:precompile
direnv exec . bundle exec puma script/demos/guided_search_live.ru -b tcp://127.0.0.1:3001 -w 0
```

Open <http://localhost:3001/find_commodity?search_mode=guided> and enter a product description.
The same waiting panel appears when you submit a follow-up answer.

The prototype uses real backend searches. Messages illustrate search activities; they are not
backend stage reports. Results appear as soon as the normal polling flow receives them.
Only this local launcher enables timed messages. Do not deploy the launcher.

## Configure the messages

Edit `config/guided_search_loading.yml`, then reload the page:

- `text`: the activity message beside the spinner.
- `description`: the supporting explanation beneath it.
- `min_seconds` and `max_seconds`: the range for a random delay before the next message.

Use positive numbers, with the maximum at least the minimum. Messages appear in YAML order.
The final message stays until the search responds; its delay range is unused.
A fast response skips the remaining messages. The sequence never delays results or loops.
Copy and timing changes do not need an asset rebuild.
