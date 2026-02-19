# Work Tracking

- Status: completed (2026-02-19T19:09:53Z)
- Task: full_repo_lab_remediation
- Created (UTC): 20260219190700

## Context
Repository labs are partially non-compliant with AGENTS.md format and have weak verification scripts. User requested remediation for all scenarios.

## Value Proposition
Make every scenario structurally consistent, technically safer, and actually verifiable to improve learner outcomes and reduce broken instructions.

## Alternatives Considered
- Minimal patch only for broken files: fast but leaves inconsistent quality.
- Full standardization (chosen): more effort, consistent and maintainable.

## Todos
- [x] Remove `.DS_Store` files under `learning-materials/`.
- [x] Standardize all `problem.md` files to required section headings and include verification sections.
- [x] Replace all weak `lab/verify.sh` scripts with scenario-aware checks.
- [x] Fix incorrect/unsafe instructions in `solution.md` and `lab/README.md` (service mismatches, cleanup scope).
- [x] Run consistency checks and summarize results.

## Acceptance Criteria
- All scenario `problem.md` files include required AGENTS headings.
- Every `lab/verify.sh` validates scenario resources beyond cluster connectivity.
- No `kubectl delete all --all` remains in lab READMEs.
- Known command mismatch in OpenTelemetry solution corrected.

## Notes
Perform edits with scripts + targeted patches for repeatability.
