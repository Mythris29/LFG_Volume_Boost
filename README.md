# LFG Volume Boost

A World of Warcraft addon that briefly boosts your master volume when an LFG queue pops, so you don't miss the proposal.

- **Author:** Mythris
- **Interface:** 12.0.0 (retail)
- **Category:** Audio & Video

## How it works

When the `LFG_PROPOSAL_SHOW` event fires, the addon saves your current `Sound_MasterVolume`, raises it, and restores the original value 4 seconds later.
