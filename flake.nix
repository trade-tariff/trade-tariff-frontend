{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs-ruby = {
      url = "github:bobvanderlinden/nixpkgs-ruby";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, nixpkgs-stable, nixpkgs-ruby }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          system = system;
          config.allowUnfree = true;
          config.permittedInsecurePackages = [
            "google-chrome-144.0.7559.97"
          ];
          overlays = [nixpkgs-ruby.overlays.default];
        };
        pkgs-stable = import nixpkgs-stable {
          system = system;
          config.allowUnfree = true;
        };

        rubyVersion = builtins.head (builtins.split "\n" (builtins.readFile ./.ruby-version));
        ruby = pkgs."ruby-${rubyVersion}";

        # Worktree detection hook (partial for Bundler + pre-commit on frontend)
        worktree = rec {
          isWorktree = ''
            if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
              if [ "$(git rev-parse --git-dir 2>/dev/null)" != "$(git rev-parse --git-common-dir 2>/dev/null)" ]; then
                echo "true"
              else
                echo "false"
              fi
            else
              echo "false"
            fi
          '';

          id = ''
            if [ "$(${isWorktree})" = "true" ]; then
              git rev-parse --show-toplevel | md5sum | cut -c1-8
            else
              echo "main"
            fi
          '';
        };


        lint = pkgs.writeShellScriptBin "lint" ''
          changed_files=$(git diff --name-only --diff-filter=ACM --merge-base main)

          bundle exec rubocop --autocorrect-all --force-exclusion $changed_files Gemfile
        '';
        chrome = pkgs.writeShellScriptBin "chrome" ''
          binary=$(find ${pkgs.google-chrome.outPath} -type f -name 'google-chrome-stable')
          exec $binary "$@"
        '';

        psychBuildFlags = with pkgs; [
          "--with-libyaml-include=${libyaml.dev}/include"
          "--with-libyaml-lib=${libyaml.out}/lib"
        ];
        init = pkgs.writeShellScriptBin "init" ''
          cd terraform && terraform init -backend=false
        '';
        update-providers = pkgs.writeShellScriptBin "update-providers" ''
          cd terraform && terraform init -backend=false -reconfigure -upgrade
        '';

        worktree-info = pkgs.writeShellScriptBin "worktree-info" ''
          if [ "$(${worktree.isWorktree})" = "true" ]; then
            WT_ID=$(${worktree.id})
            echo "Worktree mode enabled"
            echo "  ID:          $WT_ID"
            echo "  GEM_HOME:    $HOME/.local/share/gem/worktrees/$WT_ID"
            echo "  BUNDLE_PATH: .bundle"
          else
            echo "Normal checkout (not a worktree)"
          fi
        '';

        worktree-clean = pkgs.writeShellScriptBin "worktree-clean" ''
          set -euo pipefail
          if [ "$(${worktree.isWorktree})" != "true" ]; then
            echo "Not inside a worktree. Nothing to clean."
            exit 0
          fi

          WT_ID=$(${worktree.id})
          echo "Cleaning worktree $WT_ID..."

          # Remove per-worktree Bundler/Ruby state
          rm -rf ".bundle"
          rm -rf "$HOME/.local/share/gem/worktrees/$WT_ID" 2>/dev/null || true
          rm -rf "$HOME/.cache/bundle/worktrees/$WT_ID" 2>/dev/null || true

          # Remove per-worktree Yarn cache and generated assets
          rm -rf "$HOME/.local/share/yarn/worktrees/$WT_ID"
          rm -rf public/packs public/packs-test app/assets/builds 2>/dev/null || true

          echo "Worktree $WT_ID cleaned (bundle + gem + yarn + assets)."
        '';
      in {
        devShells.default = pkgs.mkShell {
          shellHook = ''
            export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers.outPath};
            export PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=true;
            export BROWSER_PATH=${chrome}/bin/chrome;

            # Worktree-aware Bundler/Ruby isolation (for long superpowers paths)
            if [ "$(${worktree.isWorktree})" = "true" ]; then
              WT_ID=$(${worktree.id})
              export GEM_HOME="$HOME/.local/share/gem/worktrees/$WT_ID"
              export BUNDLE_PATH=".bundle"
              export BUNDLE_APP_CONFIG=".bundle"
              export BUNDLE_IGNORE_CONFIG=1
              export BUNDLE_FORCE_RUBY_PLATFORM=1
              mkdir -p "$GEM_HOME" ".bundle"
              echo "Worktree Bundler isolation enabled (ID: $WT_ID)"
            else
              export GEM_HOME=$PWD/.nix/ruby/$(${ruby}/bin/ruby -e "puts RUBY_VERSION")
              mkdir -p $GEM_HOME
            fi

            # Per-worktree Yarn cache (classic Yarn 1) so yarn install works in long paths
            if [ "$(${worktree.isWorktree})" = "true" ]; then
              export YARN_CACHE_FOLDER="$HOME/.local/share/yarn/worktrees/$WT_ID"
              mkdir -p "$YARN_CACHE_FOLDER"
            fi

            export GEM_PATH=$GEM_HOME
            export PATH=${ruby}/bin:$GEM_HOME/bin:$PATH

            export BUNDLE_BUILD__PSYCH="${
              builtins.concatStringsSep " " psychBuildFlags
            }"

            ${worktree-info}/bin/worktree-info

            # === Automatic first-time frontend asset setup in worktrees ===
            if [ "$(${worktree.isWorktree})" = "true" ]; then
              WT_ID=$(${worktree.id})
              MARKER="$HOME/.local/share/yarn/worktrees/$WT_ID/.worktree-initialized"

              if [ ! -f "$MARKER" ]; then
                echo ""
                echo "==> First time in this worktree ($WT_ID) - running full setup..."
                echo ""

                fail_worktree_setup() {
                  echo ""
                  echo "==> Worktree setup failed. Fix the error above, then re-enter the shell."
                  exit 1
                }

                run_setup_step() {
                  label="$1"
                  shift
                  log_file="/tmp/worktree-$WT_ID-$(echo "$label" | tr '[:upper:] /:' '[:lower:]---').log"

                  echo "    $label..."
                  if "$@" >"$log_file" 2>&1; then
                    echo "      ok (log: $log_file)"
                  else
                    status=$?
                    echo "      failed with exit $status (log: $log_file)"
                    echo "      last 80 log lines:"
                    tail -80 "$log_file" | sed 's/^/        /'
                    return "$status"
                  fi
                }

                rm -rf .bundle
                export BUNDLE_PATH=".bundle"
                export BUNDLE_APP_CONFIG=".bundle"
                export BUNDLE_IGNORE_CONFIG=1
                export BUNDLE_FORCE_RUBY_PLATFORM=1
                run_setup_step "Installing gems" bundle install --jobs=4 --retry=3 || fail_worktree_setup
                run_setup_step "Installing JS dependencies" yarn install --frozen-lockfile || fail_worktree_setup
                run_setup_step "Building CSS assets" yarn build:css || fail_worktree_setup
                run_setup_step "Precompiling assets" bundle exec bin/rails assets:precompile || fail_worktree_setup
                run_setup_step "Installing pre-commit hooks" pre-commit install --install-hooks || fail_worktree_setup

                touch "$MARKER"
                echo ""
                echo "==> Worktree first-time setup complete."
                echo ""
              else
                export BUNDLE_PATH=".bundle"
                export BUNDLE_APP_CONFIG=".bundle"
                export BUNDLE_IGNORE_CONFIG=1
                export BUNDLE_FORCE_RUBY_PLATFORM=1
              fi
            fi
          '';

          buildInputs = with pkgs; [
            chrome
            init
            lint
            nodejs_latest
            pkgs.pre-commit
            pkgs-stable.playwright-driver.browsers
            ruby
            terraform-docs
            update-providers
            worktree-info
            worktree-clean
            yarn
          ];
        };
      });
}
