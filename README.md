# Building AI-Powered Apps with RubyLLM

Companion code for [Carmine Paolino](mailto:carmine@paolino.me)'s hands-on workshop where you build **TaskPilot**, an AI-powered task management app, from `rails new` to multi-agent orchestration — using [RubyLLM](https://rubyllm.com).

## Branches

Each branch is a checkpoint at the end of a workshop part:

| Branch | What's built |
|--------|-------------|
| `start` | Fresh Rails app (starting point) |
| `part-1-complete` | Working AI chat with real-time streaming |
| `part-2-complete` | Custom AI personality via system prompts |
| `part-3-complete` | AI creates, lists, and completes todos via tools |
| `part-4-complete` | Agents, web search, agent-as-tool pattern |
| `part-5-complete` | Sequential pipeline and fan-out/fan-in orchestration |

## Getting Started

See [prerequisites.md](prerequisites.md) for setup instructions.

If you fall behind during the workshop, jump to any checkpoint:

```bash
git checkout part-2-complete   # or any branch
bundle install
bin/rails db:migrate
bin/dev
```

## Workshop Materials

- [prerequisites.md](prerequisites.md) — Setup instructions (complete before the workshop)
- [handout.md](handout.md) — All the code for copy-pasting during the workshop

## Interested in Attending?

This repository contains the companion code, not the full workshop. If you'd like to attend a future session, get in touch: [carmine@paolino.me](mailto:carmine@paolino.me)

## License

The application code (Ruby, HTML, configuration files) is licensed under the [MIT License](LICENSE).

The workshop materials (`handout.md`, `prerequisites.md`, and `README.md`) are licensed under [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/).
