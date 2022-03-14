# Discourse Password Purgatory
The Discourse plugin nobody asked for nor needed! Inspired by [Troy Hunt](https://www.troyhunt.com/building-password-purgatory-with-cloudflare-pages-and-workers/)

Only use this on April Fools day :) (unless you want to see your engagement stats drop)

## How to use
- [Install the plugin](https://meta.discourse.org/t/install-plugins-in-discourse/19157)
- Enable the `enable_password_purgatory` setting.
- Configure the `password_purgatory_chance` setting if desired.

## Contribute your own checks
Fork this repository, and add a new Hash in `plugin.rb` with the properties `passwd_valid` and `msg`. `passwd_valid` should be a `Proc` that accepts a single argument, `msg` should be a localized string (see `config/locales`).
