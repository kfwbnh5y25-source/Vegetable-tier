# Vegetable Tier List

A static, anonymous 40-vegetable S/A/B/C/D/F ranking survey.

## Deploy
The included GitHub Actions workflow deploys the site to GitHub Pages on every push to `main`. In the repository, open **Settings → Pages** and set **Build and deployment → Source** to **GitHub Actions** if it is not already selected.

## Database setup
The front end is deliberately not connected until a Supabase project is created:
1. Run `supabase/schema.sql` in the Supabase SQL Editor.
2. Put the project URL into `SUPABASE_URL` in `index.html`.
3. Put the project's **publishable** key into `SUPABASE_PUBLISHABLE_KEY`. Never use a secret or service_role key in browser code.
4. Commit the change.

RLS permits anonymous inserts only; raw submissions cannot be read from the browser. The leaderboard is exposed through a restricted aggregate RPC.

The app currently shows a pending-database message until those settings are supplied.
