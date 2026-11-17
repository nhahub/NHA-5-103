# Global Shipping Disruption Analytics

Team project (5 members). We analyse how disruptions affect global shipping chokepoints, using IMF PortWatch data (daily chokepoint transits, chokepoint list, disruption events).
Users: a shipping and logistics manager and an executive finance manager. Output: a dashboard covering 2019 to the snapshot date.

**Read `docs/CONSTANTS.md` first.** It has every value that must be the same for everyone.

## Project phases

| Phase | Tools | What happens |
|---|---|---|
| 1 | SQL Server + dbt | Sources and schema, Bronze, Silver (cleaning), Gold (fact and dimensions), validation |
| 2 | Python | Data quality, feature engineering, EDA, business insights |
| 3 | Power BI | Data model, DAX and KPIs, Executive Overview, detailed pages, filters |

| Member | Phase 1 | Phase 2 | Phase 3 |
|---|---|---|---|
| 1 | Sources, schema, relationships | Data quality and extra cleaning | Data model and relationships |
| 2 | Bronze layer | Feature engineering | DAX measures and KPIs |
| 3 | Silver layer | Univariate EDA | Executive Overview dashboard |
| 4 | Gold layer | Bivariate and multivariate EDA | Detailed analysis dashboard |
| 5 | Validation queries and KPI checks | Combine results, business insights | Extra page, filters and interactions |

## Folders

```
data/raw/snapshot_2026-11-08/   frozen data
sql/bronze/                     Bronze table scripts and BULK INSERT
dbt_project/                    Silver and Gold (models, seeds, tests, macros)
python/notebooks/               numbered analysis notebooks
python/src/                     shared Python code
powerbi/                        the .pbix file (one editor at a time)
docs/                           data dictionary, schema, Step 4 documents
```

## Setup (once per person)

1. Install SQL Server, ODBC Driver 18 for SQL Server, Python and Git.
2. Clone the repo: `git clone https://github.com/basmalam654-lab/NHA-5-103.git`
3. In the repo folder: `python -m venv .venv`, activate it, then `pip install -r requirements.txt`
4. Run `nbstripout --install` once, so notebook outputs are cleared automatically.
5. Copy `dbt_project/profiles.example.yml` to your own dbt folder as `profiles.yml` (never commit it).

## Workflow (shared repo, pull requests)

Everyone has write access, but `main` is protected: nothing reaches `main` without a pull request that the leader merges.

Every task:
```
git checkout main
git pull
git checkout -b feature/m<number>-<short-task>
# do your work
git add .
git commit -m "feat: short description"
git push -u origin feature/m<number>-<short-task>
```
Then open a pull request into `main` on GitHub and fill in the template. The leader reviews and merges. After the merge, delete your branch and run `git checkout main` and `git pull` before the next task.

## Rules

1. Never commit to `main`. One task = one branch = one pull request.
2. Only edit your own folders (see `.github/CODEOWNERS`). Need a change in someone else's folder? Ask them.
3. Always `git pull` on `main` before creating a new branch.
4. Business-rule values live in one place only. Do not copy numbers into your code.
5. The `.pbix` file cannot be merged: announce in the group chat before you edit it, and only one person edits at a time.
6. After Gold is merged, its table and column names are frozen. Changing them needs the leader's approval and a message to the team.
7. No passwords, `profiles.yml` or `.env` files in the repo.
