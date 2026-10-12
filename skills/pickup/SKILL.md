---
name: pickup
description: Reconstruct one prior trail, then prove it against the task's live state so nothing carries over stale.
disable-model-invocation: true
---

# pickup

A prior trail holds the intent; the task and the tree hold the state. Read alone, each reports as live
something already changed.

## The reference

You are handed a conversation, a description, or a task: one trail; the trails and the task a description
matches; the task and the trails that worked on it. Take the newest match and name what you resolved, staying
inside this project.

## Steps

1. Read the trail for intent — the goal, the decisions, the artifacts it names, the open threads. Hand the bulk
   to a read-only second reader where one can be spawned, keeping only its findings; with no second agent, read
   it inline and say so. *Done when every thread is accounted for, or the gap named.*
2. Name the resume point — the one place the work continues from, or why none exists.
3. Prove it against the live state: the pushed branch, the local branch or worktree, the task's own status.
   Where they disagree, live wins on status and the trail on intent, and each disagreement is a finding — work
   the trail calls done that the tree does not hold is open, a closed task with the work uncommitted is open, a
   thread the trail left open the tree already answers is done. *Done when every claim is checked, or marked
   unverified with the reason.*

## Report

Where it stands, in five lines or fewer. Then one line per disagreement, per open thread and what it waits on,
and the next move with the resume point named; anything only the human can decide comes as a choice with what
each option costs.

## Rules

- Work the live state already proves done is not redone.
- A second reader's findings, a summary, a claim of "done": claims, each verified like the rest.
