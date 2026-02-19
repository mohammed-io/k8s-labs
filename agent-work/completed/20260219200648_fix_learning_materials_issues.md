# Work: fix_learning_materials_issues

**Created:** 2026-02-19T20:06:48Z
**Status:** completed

## Context
Critical issues identified in learning materials review:
1. Missing lab/manifests/deployment.yaml and service.yaml in 01-k8s-basics
2. pod.yaml hints inconsistent with solution (nginx:alpine vs nginx:1.25)
3. README references non-existent files
4. Hardcoded passwords in 04-storage and 06-self-healing solutions
5. Missing step-02.md in 07-monitoring-basics

## Value Proposition
Fixes ensure learners can successfully complete labs without confusion and learn security best practices.

## Todos
- [x] Create lab/manifests/deployment.yaml for 01-k8s-basics
- [x] Create lab/manifests/service.yaml for 01-k8s-basics
- [x] Fix pod.yaml hints to match solution (nginx:1.25, app: web)
- [x] Update 01-k8s-basics lab/README.md to match file structure
- [x] Fix hardcoded passwords in 04-storage solution (use Secret)
- [x] Fix hardcoded passwords in 06-self-healing solution (use Secret) - N/A, no passwords found
- [x] Create step-02.md for 07-monitoring-basics

## Acceptance Criteria
- All lab manifests exist and work
- Hints match solutions
- No hardcoded passwords in solutions
- All step files exist where referenced
