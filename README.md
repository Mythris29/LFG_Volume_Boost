# LFG Volume Boost

A World of Warcraft addon that briefly boosts your master volume when an LFG queue pops, so you don't miss the proposal.

- **Author:** Mythris
- **Game:** World of Warcraft retail (supported version is in the `.toc`)
- **Category:** Audio & Video

## How it works

When the `LFG_PROPOSAL_SHOW` event fires, the addon saves your current `Sound_MasterVolume`, sets it to your configured boost level, and restores the original value 4 seconds later. If another proposal pops during the boost, the 4 seconds restart from the latest pop and your original volume is still the one restored.

If you `/reload` or log out during those 4 seconds, the original volume is restored when the addon next loads. A game crash during the boost can still leave the volume at the boost level.

## Settings

In **Options → AddOns → LFG Volume Boost**:

- **Boost Level**: master volume (0–100%) to use while a proposal is showing. Default 100%.
- **Use Character-Specific Settings**: gives this character its own boost level instead of the account-wide one.
