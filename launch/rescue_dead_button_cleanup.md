# BreakWave — BW-66 Rescue Dead-Button Cleanup

## Purpose

BW-66 removes launch-risk placeholder actions from Rescue.

## Fixed

- Start reset now gives immediate feedback instead of doing nothing.
- Open Support now routes from Rescue to the Support tab.
- RescueScreen receives an onOpenSupport callback from the shell.

## Product reason

Rescue is the highest-pressure part of BreakWave. Buttons in Rescue must either do something useful or clearly tell the user what to do next.
