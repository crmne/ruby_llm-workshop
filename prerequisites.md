# Building AI-Powered Apps with RubyLLM: Prerequisites

**Duration**: ~4 hours, hands-on

**What you'll build**: An AI-powered task management app called TaskPilot

Please complete the following setup **before** the workshop. This ensures we can dive straight into building.

---

## 1. Ruby & Rails

You need **Ruby 3.2+** and **Rails 8.0+**.

Ideally **Ruby 4.0** and **Rails 8.1** so we're on the same page.

```bash
ruby -v    # Should show 3.2.0 or higher
rails -v   # Should show 8.0.0 or higher
```

If you need to install or upgrade:
- **Ruby**: I recommend to install it with [mise](https://mise.jdx.dev/)
- **Rails**: `gem install rails`

## 2. SQLite3

The workshop uses SQLite for simplicity. Most systems have it already.

```bash
sqlite3 --version   # Should show 3.x.x
```

On macOS it's pre-installed.

On Ubuntu/Debian: `sudo apt install libsqlite3-dev`

On Fedora: `sudo dnf install sqlite-devel`

On Arch: `sudo pacman -Syu sqlite`

## 3. An OpenAI API Key

We use OpenAI as the primary provider during the workshop (it's the simplest to set up).

1. Go to [platform.openai.com/api-keys](https://platform.openai.com/api-keys)
2. Create a new API key with **all permissions**
3. Add **EUR 5 of credit** (the workshop costs well under EUR 1, but you need a positive balance)
4. Keep your key handy for the setup test below

**Cost estimate**: The entire workshop uses approximately EUR 0.20-0.50 in API calls.

## 4. A Code Editor

Any editor works. VS Code, RubyMine, Vim, NeoVim, Emacs, Zed — your choice.

## 5. Verify Everything Works

Copy-paste this in your shell to test everything:

```bash
# Create a test app (delete it after)
rails new test_check --skip-git
cd test_check

# The workshop may use the trunk version, so test git-based install too.
bundle add ruby_llm --git "https://github.com/crmne/ruby_llm.git"

# Add your API key to Rails credentials for this test app.
bin/rails credentials:edit
# Add this and save, without the comment:
# openai_api_key: sk-your-key-here

# No generator needed for this check. We configure RubyLLM inline.
bin/rails runner 'key = Rails.application.credentials.dig(:openai_api_key).to_s.strip; abort("Missing credentials.openai_api_key") if key.empty?; RubyLLM.configure { |c| c.openai_api_key = key }; response = RubyLLM.chat.ask("hello"); text = response.respond_to?(:content) ? response.content.to_s : response.to_s; abort("RubyLLM returned an empty response") if text.strip.empty?; puts "RubyLLM response: #{text}"'

cd ..
rm -rf test_check
```

If you see `RubyLLM response: ...`, you're good to go.

## Windows Note

I have not tested this workshop setup on Windows, including WSL2.

If you use Windows, you can try WSL2 (Ubuntu recommended) and complete the verification step above.

If the verification step fails, please bring a macOS or Linux laptop if possible.

## Troubleshooting

- If you're having trouble with any of the above, ask ChatGPT or Claude and if it fails [send me an email](mailto:carmine@paolino.me).

## What to Bring

- Your laptop with all the above installed
- Your OpenAI API key
- Curiosity and questions

See you at the workshop!
