#!/bin/bash
TASK_NAME="${1:-task}"
TIMESTAMP=$(date -u +"%Y%m%d%H%M%S")
WORK_FILE="agent-work/${TIMESTAMP}_${TASK_NAME}.md"

cat > "$WORK_FILE" << 'TEMPLATE'
# Work: {TASK_NAME}

**Created:** {TIMESTAMP}
**Status:** active

## Context
*TODO: Describe the problem being solved*

## Value Proposition
*TODO: What value does this create?*

## Alternatives Considered
*TODO: List alternatives and trade-offs*

## Todos
- [ ] Todo 1
- [ ] Todo 2

## Acceptance Criteria
*TODO: How do we know this is done?*

## Notes
*TODO: Any additional notes*
TEMPLATE

sed -i '' "s/{TASK_NAME}/$TASK_NAME/g" "$WORK_FILE"
sed -i '' "s/{TIMESTAMP}/$(date -u +"%Y-%m-%dT%H:%M:%SZ")/g" "$WORK_FILE"

echo "Created work file: $WORK_FILE"
