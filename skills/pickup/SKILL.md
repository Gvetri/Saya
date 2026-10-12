---
name: pickup
description: Rebuild what an earlier session did, then check it against the current state of the task and the code.
disable-model-invocation: true
---

# pickup

An earlier session shows the goal of the work and the actions of the agent. The task and the code show the
current state. Read one source alone, and you report a fact that has already changed.

## The input

The user gives you one item:

- A session. Read that session.
- A description. Find the sessions and the task that match it.
- A task. Read the task, and find the sessions that worked on it.

If more than one item matches, use the newest item. Say which item you selected. Read the sessions of this
project only.

## Steps

1. Read the session. Collect these facts: the goal, the decisions, the files and branches that the session
   touched, and the open topics. If the session is long, give it to a read-only second agent, and keep only
   the result. With no second agent, read the session here and say so.
   Done when: you list every open topic, or you name the open topic that the session does not answer.
2. Write down the state that the session left. Name the point where the work continues. If the session has no
   such point, say why.
3. Check the current state. Read the remote branch, the local branch or the worktree, and the status of the
   task. Compare these facts with the session. If the facts disagree, the current state gives the status and
   the session gives the goal. Report each disagreement as a finding.
   - The session says that the work is complete and the code does not contain it. The work is open.
   - The task is closed and the work is not committed. The work is open.
   - The session leaves a topic open and the code answers it. The work is complete.
   Done when: you check every claim, or you mark the claim as unverified and give the reason.

## The report

Give the current state in five lines or less. Give one line for each finding. Give one line for each open topic
and what it waits on. Give the next step and the point where the work continues. Give each decision for the
user as a choice, with the cost of each option.

## Rules

- Do not repeat work that the code shows as complete.
- Check the output of a second agent, a summary, and the word "done". Each one is a claim.
