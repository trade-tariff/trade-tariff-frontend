{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix/3bbec39bc90eadfa031e6f3b77272f3f60803e39";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-ruby = {
      url = "github:bobvanderlinden/nixpkgs-ruby";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      nixpkgs-stable,
      pre-commit-hooks,
      nixpkgs-ruby,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          config.permittedInsecurePackages = [
            "google-chrome-144.0.7559.97"
          ];
          overlays = [ nixpkgs-ruby.overlays.default ];
        };
        pkgs-stable = import nixpkgs-stable {
          inherit system;
          config.allowUnfree = true;
        };

        rubyVersion = builtins.head (builtins.split "\n" (builtins.readFile ./.ruby-version));
        ruby = pkgs."ruby-${rubyVersion}";

        # Worktree detection hook (partial for Bundler + pre-commit on frontend)
        # Disable Git fsmonitor for hook-local probes. If these git commands start
        # fsmonitor--daemon inside direnv's shellHook, the daemon can inherit a
        # nix-direnv pipe and keep the first `direnv exec ...` blocked after setup.
        worktree = rec {
          isWorktree = ''
            if git -c core.fsmonitor=false rev-parse --is-inside-work-tree >/dev/null 2>&1; then
              if [ "$(git -c core.fsmonitor=false rev-parse --git-dir 2>/dev/null)" != "$(git -c core.fsmonitor=false rev-parse --git-common-dir 2>/dev/null)" ]; then
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
              git -c core.fsmonitor=false rev-parse --show-toplevel | md5sum | cut -c1-8
            else
              echo "main"
            fi
          '';
        };

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

        preCommitCheck = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          configPath = ".pre-commit-config-nix.yaml";
          default_stages = [ "pre-commit" ];
          hooks = {
            actionlint = {
              enable = true;
              stages = [ "pre-commit" ];
            };
            check-added-large-files = {
              enable = true;
              stages = [ "pre-commit" ];
            };
            check-case-conflicts = {
              enable = true;
              stages = [ "pre-commit" ];
            };
            check-merge-conflicts = {
              enable = true;
              stages = [ "pre-commit" ];
            };
            check-yaml = {
              enable = true;
              excludes = [ "^spec/vcr|^vendor/|^app/assets/images" ];
              stages = [ "pre-commit" ];
            };
            deadnix = {
              enable = true;
              stages = [ "pre-commit" ];
            };
            detect-private-keys = {
              enable = true;
              stages = [ "pre-commit" ];
            };
            end-of-file-fixer = {
              enable = true;
              excludes = [ "^spec/vcr|^vendor/|^app/assets/images|^app/javascript/src/vendor/" ];
              stages = [ "pre-commit" ];
            };
            nixfmt-rfc-style = {
              package = pre-commit-hooks.inputs.nixpkgs.legacyPackages.${system}.nixfmt;
              enable = true;
              stages = [ "pre-commit" ];
            };
            shellcheck = {
              enable = true;
              args = [ "--severity=error" ];
              excludes = [ "^\\.envrc$" ];
              stages = [ "pre-commit" ];
            };
            sort-file-contents = {
              enable = true;
              files = "^\\.env\\.(development|test)$";
              stages = [ "pre-commit" ];
            };
            statix = {
              enable = true;
              settings.ignore = [ "{.direnv,.nix,.worktrees}/**" ];
              stages = [ "pre-commit" ];
            };
            terraform-format = {
              enable = true;
              package = pkgs.terraform;
              stages = [ "pre-commit" ];
            };
            terraform-validate = {
              enable = true;
              package = pkgs.terraform;
              entry = ''
                bash -c '
                  set -uo pipefail
                  status=0

                  while read -r dir; do
                    lockfile="$dir/.terraform.lock.hcl"
                    backup=$(mktemp)
                    had_lockfile=false

                    if [ -f "$lockfile" ]; then
                      cp "$lockfile" "$backup"
                      had_lockfile=true
                    fi

                    ${pkgs.terraform}/bin/terraform -chdir="$dir" init -backend=false
                    init_status=$?

                    if [ "$init_status" -eq 0 ]; then
                      ${pkgs.terraform}/bin/terraform -chdir="$dir" validate
                      validate_status=$?
                    else
                      validate_status=$init_status
                    fi

                    if [ "$had_lockfile" = true ]; then
                      cp "$backup" "$lockfile"
                    else
                      rm -f "$lockfile"
                    fi
                    rm -f "$backup"

                    if [ "$validate_status" -ne 0 ]; then
                      status=$validate_status
                    fi
                  done < <(for arg in "$@"; do dirname "$arg"; done | sort | uniq)

                  exit "$status"
                ' --
              '';
              stages = [ "pre-commit" ];
            };
            tflint = {
              enable = true;
              stages = [ "pre-commit" ];
            };
            trim-trailing-whitespace = {
              enable = true;
              excludes = [ "^spec/vcr|^vendor/|^app/assets/images" ];
              stages = [ "pre-commit" ];
            };
            trufflehog = {
              enable = true;
              stages = [
                "pre-commit"
                "pre-push"
              ];
            };

            markdownlint = {
              enable = true;
              entry = "${pkgs.markdownlint-cli}/bin/markdownlint --fix --ignore terraform";
              files = "\\.md$";
              stages = [ "pre-commit" ];
            };
            rubocop = {
              enable = true;
              name = "rubocop";
              description = "Run RuboCop through Bundler on changed Ruby files";
              entry = ''
                bash -c '
                  changed_files=$(git diff --name-only --diff-filter=ACM --merge-base main | grep -E "\\.(rb|rake)$|^(Gemfile|Rakefile|config\\.ru)$" || true)

                  if [ -n "$changed_files" ]; then
                    bundle exec rubocop --autocorrect --force-exclusion $changed_files
                  fi
                '
              '';
              files = "\\.(rb|rake)$|^(Gemfile|Rakefile|config\\.ru)$";
              pass_filenames = false;
              stages = [ "pre-commit" ];
            };
          };
        };

        preCommit = pkgs.writeShellScriptBin "pre-commit" ''
          set -euo pipefail

          has_config=false
          for arg in "$@"; do
            case "$arg" in
              -c|--config|--config=*)
                has_config=true
                ;;
            esac
          done

          if [ "$has_config" = true ]; then
            exec ${preCommitCheck.config.package}/bin/pre-commit "$@"
          fi

          if [ "''${1:-}" = "run" ]; then
            shift
            exec ${preCommitCheck.config.package}/bin/pre-commit run --config .pre-commit-config-nix.yaml "$@"
          fi

          exec ${preCommitCheck.config.package}/bin/pre-commit "$@"
        '';
      in
      {
        devShells.default = pkgs.mkShell {
          shellHook = ''
            export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers.outPath};
            export PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=true;
            export BROWSER_PATH=${chrome}/bin/chrome;

            # Worktree-aware Bundler/Ruby isolation (for long superpowers paths)
            if [ "$(${worktree.isWorktree})" = "true" ]; then
              WT_ID=$(${worktree.id})
              WT_ROOT=$(git -c core.fsmonitor=false rev-parse --show-toplevel)
              WT_BUNDLE_PATH="$WT_ROOT/.bundle"
              export GEM_HOME="$HOME/.local/share/gem/worktrees/$WT_ID"
              export BUNDLE_PATH="$WT_BUNDLE_PATH"
              export BUNDLE_APP_CONFIG="$WT_BUNDLE_PATH"
              export BUNDLE_IGNORE_CONFIG=1
              mkdir -p "$GEM_HOME" "$WT_BUNDLE_PATH"
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

            export BUNDLE_BUILD__PSYCH="${builtins.concatStringsSep " " psychBuildFlags}"

            ${preCommitCheck.shellHook}
            export PATH=${preCommit}/bin:$PATH
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
                  # Setup commands may spawn daemon helpers, such as git fsmonitor. Close
                  # inherited nix-direnv pipe fds so those helpers cannot block `direnv exec`.
                  if "$@" >"$log_file" 2>&1 \
                    3>&- 4>&- 5>&- \
                    6>&- 7>&- 8>&- 9>&-; then
                    echo "      ok (log: $log_file)"
                  else
                    status=$?
                    echo "      failed with exit $status (log: $log_file)"
                    echo "      last 80 log lines:"
                    tail -80 "$log_file" | sed 's/^/        /'
                    return "$status"
                  fi
                }

                rm -rf "$BUNDLE_PATH"
                mkdir -p "$BUNDLE_PATH"
                export BUNDLE_IGNORE_CONFIG=1
                run_setup_step "Installing gems" bundle install --jobs=4 --retry=3 || fail_worktree_setup
                run_setup_step "Installing JS dependencies" yarn install --frozen-lockfile || fail_worktree_setup
                run_setup_step "Building CSS assets" yarn build:css || fail_worktree_setup
                run_setup_step "Precompiling assets" bundle exec bin/rails assets:precompile || fail_worktree_setup
                run_setup_step "Installing pre-commit hooks" pre-commit install || fail_worktree_setup

                touch "$MARKER"
                echo ""
                echo "==> Worktree first-time setup complete."
                echo ""
              else
                export BUNDLE_IGNORE_CONFIG=1
              fi
            fi
          '';

          buildInputs =
            preCommitCheck.enabledPackages
            ++ (with pkgs; [
              chrome
              init
              nodejs_latest
              pkgs-stable.playwright-driver.browsers
              ruby
              terraform-docs
              update-providers
              worktree-info
              worktree-clean
              yarn
            ]);
        };
      }
    );
}
