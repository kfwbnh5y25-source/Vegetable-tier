create table if not exists public.vegetable_submissions (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  rankings jsonb not null,
  constraint rankings_is_object check (jsonb_typeof(rankings) = 'object'),
  constraint rankings_has_40_items check (jsonb_object_length(rankings) = 40),
  constraint rankings_valid_tiers check (
    not exists (
      select 1 from jsonb_each_text(rankings) e
      where e.value not in ('S','A','B','C','D','F')
    )
  )
);

alter table public.vegetable_submissions enable row level security;
revoke all on public.vegetable_submissions from anon, authenticated;
grant insert on public.vegetable_submissions to anon;
drop policy if exists "Anyone can submit a complete ranking" on public.vegetable_submissions;
create policy "Anyone can submit a complete ranking"
on public.vegetable_submissions for insert to anon
with check (
  jsonb_typeof(rankings) = 'object'
  and jsonb_object_length(rankings) = 40
  and not exists (
    select 1 from jsonb_each_text(rankings) e
    where e.value not in ('S','A','B','C','D','F')
  )
);

create or replace function public.vegetable_leaderboard()
returns table (vegetable text, average_score numeric, votes bigint)
language sql
stable
security definer
set search_path = ''
as $$
  with expanded as (
    select e.key as vegetable,
      case e.value
        when 'S' then 6 when 'A' then 5 when 'B' then 4
        when 'C' then 3 when 'D' then 2 when 'F' then 1
      end as score
    from public.vegetable_submissions s
    cross join lateral jsonb_each_text(s.rankings) e
  )
  select vegetable, round(avg(score)::numeric, 2), count(*)
  from expanded
  group by vegetable
  order by avg(score) desc, vegetable asc;
$$;
revoke all on function public.vegetable_leaderboard() from public;
grant execute on function public.vegetable_leaderboard() to anon;
