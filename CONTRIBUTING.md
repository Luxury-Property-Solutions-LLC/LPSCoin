# Contributing to LPSCoin Core

LPSCoin Core is a blockchain platform revolutionizing luxury property transactions with privacy-enhancing Coin Mixing and rapid FastSend payments. We welcome contributions from anyone—whether through peer review, testing, or code patches—to build a secure, efficient cryptocurrency. This guide outlines the practical process and expectations for contributing.

We operate an open contributor model where all are encouraged to participate. There’s no privileged "core developer" class; trust is earned through consistent, quality contributions over time. For practicality, we have "maintainers" who merge pull requests and a "lead maintainer" overseeing releases, merging, moderation, and maintainer appointments. Join us via GitHub Issues or email (support@lpscoin.org) for discussions—community channels like Discord are coming soon!

## Contributor Workflow
We use a "contributor workflow" where all changes, without exception, are proposed via pull requests (PRs). This ensures easy collaboration, testing, and review.

To contribute a patch:
1. **Fork the Repository**: Fork [LPSCoin](https://github.com/Luxury-Property-Solutions-LLC/LPSCoin) and clone it:
   ```bash
   git clone https://github.com/<your-username>/LPSCoin.git
   cd LPSCoin
   ```
2. **Create a Topic Branch**: Name it descriptively:
   ```bash
   git checkout -b feature/add-mixing-speed
   ```
3. **Commit Patches**:
   - Adhere to [developer notes](doc/developer-notes.md) coding conventions.
   - Keep commits atomic (one change per commit) and diffs readable—don’t mix formatting fixes with logic changes.
   - Write verbose commit messages: a short subject (max 50 chars), a blank line, and detailed reasoning. Example:
     ```
     Improve Coin Mixing efficiency
     
     Optimized mixing algorithm to reduce latency by 20%. Tested with 1000 transactions.
     Refs #123.
     Signed-off-by: Your Name <your.email@example.com>
     ```
   - Reference issues (e.g., `refs #1234`, `fixes #4321`) to link discussions.
   - Sign off with DCO: `Signed-off-by: Your Name <your.email@example.com>`.
4. **Build and Test**:
   ```bash
   ./autogen.sh && ./configure --enable-tests && make && make check
   ```
5. **Push to Your Fork**:
   ```bash
   git push origin feature/add-mixing-speed
   ```
6. **Create a Pull Request**: Submit to the `main` branch on GitHub.
   - **Prefix the PR title** with the affected area:
     - `Consensus`: Consensus-critical code (e.g., `Consensus: Add OP_LUXURYCHECK`).
     - `Docs`: Documentation (e.g., `Docs: Update README with FastSend`).
     - `Qt`: GUI changes (e.g., `Qt: Add mixing status widget`).
     - `Mixing`: Coin Mixing logic (e.g., `Mixing: Optimize anonymity set`).
     - `FastSend`: FastSend features (e.g., `FastSend: Reduce confirmation delay`).
     - `Net` or `P2P`: Network code (e.g., `Net: Enhance masternode sync`).
     - `RPC/REST`: APIs (e.g., `RPC: Add getmixingstatus`).
     - `Tests`: Unit/QA tests (e.g., `Tests: Add mixing edge cases`).
     - `Trivial`: Non-code changes (e.g., `Trivial: Fix typo in wallet.cpp`).
   - Use `[WIP]` if not ready (e.g., `[WIP] Mixing: Initial refactor`).
   - Provide a detailed description with justification and references.

Expect feedback from peers. Add commits to address comments and push updates until all concerns are resolved.

## Squashing Commits
If a maintainer requests squashing, combine commits into a clean history:
```bash
git checkout feature/add-mixing-speed
git rebase -i HEAD~n  # n = number of commits
# Mark commits as 'squash' except the first, edit message, save
git push --force
```
Alternatively, enable “Allow edits from maintainers” in the PR’s GitHub sidebar and ask for help with squashing.

Avoid multiple PRs for the same change—update the existing PR instead.

## Pull Request Philosophy
PRs should be focused: one feature, bug fix, or refactor—not a mix. Avoid large, complex “super PRs” that hinder review.

### Features
New features (e.g., enhancing Coin Mixing or FastSend) require consideration of long-term maintenance. Propose only if you’re willing to maintain them, including bug fixes. Unmaintained features may be removed later.

### Refactoring
Refactoring PRs fall into:
- **Code Moves**: Relocating code without behavior changes.
- **Style Fixes**: Formatting updates (e.g., whitespace).
- **Code Refactoring**: Structural improvements.
Keep these separate, avoid mixing with functional changes, and ensure no behavior shifts. Examples:
- `Refactor: Move mixing logic to mixing.cpp`
- `Style: Standardize 4-space indentation in net.cpp`

Maintainers prioritize quick reviews for simple refactors.

## "Decision Making" Process
Merging decisions rest with maintainers and the lead maintainer, based on:
- Alignment with LPSCoin’s goals (privacy, speed, luxury asset focus).
- Meeting minimum standards (style, testing).
- Contributor consensus via GitHub Issues and discussions.

PRs must:
- Serve a clear purpose (feature, bug fix, improvement).
- Be well-reviewed.
- Adhere to style guidelines.

Consensus-critical changes (e.g., altering mixing rules) require extensive discussion on GitHub Issues, a detailed proposal, and broad technical agreement.

## Peer Review
Anyone can review PRs via GitHub comments. Reviewers check for errors, test patches, and assess merits, using:
- **ACK**: “Tested and approved” (e.g., `ACK abc123`).
- **NACK**: “Disagree, with reason” (e.g., `NACK abc123: Breaks consensus`).
- **utACK**: “Reviewed, looks good, untested” (e.g., `utACK abc123`).
- **Concept ACK**: “Support the idea” (e.g., `Concept ACK`).
- **Nit**: Minor feedback (e.g., `Nit: Rename var_x to varX`).

Include the reviewed commit hash (e.g., `ACK abc123`). Maintainers weigh reviews by expertise and commitment, raising the bar for consensus-critical code.

## Finding Reviewers
Review times vary due to volunteer availability. If your PR stalls:
- **Release Freeze**: Wait if it’s a feature during a bug-fix-only period.
- **Lack of Interest**: Reassess if it’s too broad or off-target; ask for concept feedback on GitHub Issues.
- **Complexity**: Ping authors of related code (use `git blame`) via Issues or email.
- **Long Delay**: After 1+ month on a simple PR, politely request review on Issues or via support@lpscoin.org.

## Release Policy
The lead maintainer manages releases, targeting stability and feature readiness. Releases follow a roughly quarterly cadence (e.g., v4.1.0 from `configure.ac`), with dates announced on GitHub.

## Copyright
Contributions are licensed under the MIT License unless specified in `contrib/debian/copyright` or file headers. Non-original work must retain its license and author credits.
