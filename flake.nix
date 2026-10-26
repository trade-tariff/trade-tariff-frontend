{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
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

        reviewTools =
          import
            (builtins.fetchTree {
              type = "github";
              owner = "NixOS";
              repo = "nixpkgs";
              rev = "4a29d733e8a7d5b824c3d8c958a946a9867b3eb2";
              narHash = "sha256-f+JACbTqzZ+G92DSnXOUGRhGANb8Blh7CoeYOeBF8/U=";
            })
            {
              inherit system;
              config.allowUnfree = true;
            };
        reviewMarkdownTools = import (builtins.fetchTree {
          type = "github";
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "55ba7f49ef2962b42cbd126522b7df5f95037679";
          narHash = "sha256-sm6DclXJudZfP/pcDBQQsRqyMxBcQsuw+7yQr4rBBLE=";
        }) { inherit system; };
        reviewLatestTools = import (builtins.fetchTree {
          type = "github";
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "55bfb4d7437bd4e09ab7cba58a43bd68eb310044";
          narHash = "sha256-jBYGPi4udQ9uo4KQp9m2J0546nJVQitG15gvZSaVVAs=";
        }) { inherit system; };
        reviewTerraformHooks = builtins.fetchTree {
          type = "github";
          owner = "antonbabenko";
          repo = "pre-commit-terraform";
          rev = "05fd71a57a467ccf5598f7e836d3af4cf9225abb"; # v1.108.0
          narHash = "sha256-VUdFQXiLBQUhXTKFFg/2r+bdF/p961Q03zvAGGozB5I=";
        };
        reviewRubyHooks = builtins.fetchTree {
          type = "github";
          owner = "mattlqx";
          repo = "pre-commit-ruby";
          rev = "1f893f2c0db4068fafa19b8ea7d7db1253ea0cc1"; # v1.3.6
          narHash = "sha256-7S84RvncmcXVIjgNhzFyN4HnKJk+tKxHYvfOLcuiw8c=";
        };
        reviewTrufflehogScan = pkgs.writeShellScript "trufflehog-pre-commit" ''
          set -euo pipefail
          exclude_file="$(mktemp)"
          trap 'rm -f "$exclude_file"' EXIT
          printf '%s\n' '(^|/)\.git(/|$)' '(^|/)\.terraform(/|$)' '(^|/)\.terragrunt-cache(/|$)' > "$exclude_file"
          while IFS= read -r ignored; do
            [ -n "$ignored" ] || continue
            escaped="$(printf '%s' "''${ignored%/}" | sed 's/[][(){}.^$*+?|\\]/\\&/g')"
            case "$ignored" in
              */) printf '(^|/)%s(/|$)\n' "$escaped" >> "$exclude_file" ;;
              *) printf '(^|/)%s$\n' "$escaped" >> "$exclude_file" ;;
            esac
          done < <(git ls-files --others --ignored --exclude-standard --directory)
          exec ${reviewLatestTools.trufflehog}/bin/trufflehog filesystem "$(pwd -P)" --exclude-paths="$exclude_file" --results=verified,unknown --fail
        '';
        reviewPreCommitConfig = pkgs.writeText "review-pre-commit.json" (
          builtins.toJSON {
            default_install_hook_types = [
              "pre-commit"
              "pre-push"
            ];
            default_stages = [ "pre-commit" ];
            repos = [
              {
                repo = "local";
                hooks = [
                  {
                    id = "terraform_fmt";
                    name = "Terraform fmt";
                    language = "system";
                    entry = "${reviewTerraformHooks}/hooks/terraform_fmt.sh";
                    files = "\\.(tf|tofu|tfvars|(tftest|tofutest|tfmock|tfquery)\\.hcl)$";
                    exclude = "\\.terraform/.*$";
                  }
                  {
                    id = "terraform_validate";
                    name = "Terraform validate";
                    language = "system";
                    entry = "${reviewTerraformHooks}/hooks/terraform_validate.sh";
                    files = "\\.(tf|tofu|tfvars|terraform\\.lock\\.hcl)$";
                    exclude = "\\.terraform/.*$";
                    require_serial = true;
                  }
                  {
                    id = "terraform_tflint";
                    name = "Terraform validate with tflint";
                    language = "system";
                    entry = "${reviewTerraformHooks}/hooks/terraform_tflint.sh";
                    files = "\\.(tf|tofu|tfvars)$";
                    exclude = "\\.terraform/.*$";
                    require_serial = true;
                  }
                  {
                    id = "terraform_docs";
                    name = "Terraform docs";
                    language = "system";
                    entry = "${reviewTerraformHooks}/hooks/terraform_docs.sh";
                    files = "\\.(tf|tofu|terraform\\.lock\\.hcl)$";
                    exclude = "\\.terraform/.*$";
                    require_serial = true;
                    args = [
                      "--hook-config=--add-to-existing-file=true"
                      "--hook-config=--path-to-file=README.md"
                      "--hook-config=--create-file-if-not-exist=true"
                    ];
                  }
                  {
                    id = "trailing-whitespace";
                    name = "trim trailing whitespace";
                    language = "system";
                    entry = "${reviewTools.python3Packages.pre-commit-hooks}/bin/trailing-whitespace-fixer";
                    types = [ "text" ];
                    stages = [
                      "pre-commit"
                      "pre-push"
                      "manual"
                    ];
                    exclude = "^spec/vcr|vendor/|app/assets/images";
                  }
                  {
                    id = "end-of-file-fixer";
                    name = "fix end of files";
                    language = "system";
                    entry = "${reviewTools.python3Packages.pre-commit-hooks}/bin/end-of-file-fixer";
                    types = [ "text" ];
                    stages = [
                      "pre-commit"
                      "pre-push"
                      "manual"
                    ];
                    exclude = "^spec/vcr|vendor/|app/assets/images";
                  }
                  {
                    id = "check-yaml";
                    name = "check yaml";
                    language = "system";
                    entry = "${reviewTools.python3Packages.pre-commit-hooks}/bin/check-yaml";
                    types = [ "yaml" ];
                    exclude = "^spec/vcr|vendor/|app/assets/images";
                  }
                  {
                    id = "file-contents-sorter";
                    name = "file contents sorter";
                    language = "system";
                    entry = "${reviewTools.python3Packages.pre-commit-hooks}/bin/file-contents-sorter";
                    files = ".env.development|.env.test";
                  }
                  {
                    id = "markdownlint-fix";
                    name = "markdownlint-fix";
                    language = "system";
                    entry = "${reviewMarkdownTools.markdownlint-cli}/bin/markdownlint --fix";
                    types = [ "markdown" ];
                    args = [
                      "--ignore"
                      "terraform"
                    ];
                  }
                  {
                    id = "rubocop";
                    name = "Check Ruby style with rubocop";
                    language = "system";
                    entry = "${reviewRubyHooks}/bin/rubocop-wrapper.sh";
                    types = [ "ruby" ];
                    pass_filenames = true;
                    args = [ "--autocorrect" ];
                  }
                  {
                    id = "actionlint-docker";
                    name = "Lint GitHub Actions workflow files";
                    language = "system";
                    entry = "${reviewTools.actionlint}/bin/actionlint";
                    types = [ "yaml" ];
                    files = "^\\.github/workflows/";
                  }
                  {
                    id = "trufflehog";
                    name = "TruffleHog";
                    language = "system";
                    entry = "${reviewTrufflehogScan}";
                    pass_filenames = false;
                    require_serial = true;
                    stages = [
                      "pre-commit"
                      "pre-push"
                    ];
                  }
                ];
              }
            ];
          }
        );
        reviewEnvironment = ''
          if [ "''${REVIEW_SANDBOX:-}" != 1 ] || [ "$PWD" != /workspace ]; then
            echo 'Run review commands inside a disposable review sandbox.' >&2
            exit 64
          fi
          export TMPDIR=/workspace/.review/tmp PRE_COMMIT_HOME=/workspace/.review/pre-commit
          export XDG_CACHE_HOME="$TMPDIR/cache"
          export GEM_HOME=/workspace/.review/gems
          export GEM_PATH="$GEM_HOME''${REVIEW_GEM_CACHE:+:$REVIEW_GEM_CACHE}"
          export PATH="$GEM_HOME/bin:$PATH" BUNDLE_BIN="$GEM_HOME/bin"
          export BUNDLE_IGNORE_CONFIG=1 BUNDLE_PATH__SYSTEM=true BUNDLE_FROZEN=true
          export RAILS_ENV=test CI=true AWS_EC2_METADATA_DISABLED=true TF_IN_AUTOMATION=1 TF_INPUT=0 CHECKPOINT_DISABLE=1
          export TF_CLI_CONFIG_FILE=/workspace/.review/terraform.rc
          export npm_config_ignore_scripts=true YARN_IGNORE_SCRIPTS=true
          export YARN_CACHE_FOLDER="$TMPDIR/yarn-cache" YARN_OFFLINE=true
          export PARALLEL_RSPEC_CHILD=true PARALLEL_TEST_PROCESSORS=5 SKIP_PARALLEL_TEST_PREPARE=true
          unset BUNDLE_PATH BUNDLE_APP_CONFIG BUNDLE_WITHOUT TF_PLUGIN_CACHE_DIR
          mkdir -p "$TMPDIR" "$GEM_HOME"
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
        devShells.review = pkgs.mkShell {
          shellHook = "";
          nativeBuildInputs = [
            pkgs.gitMinimal
            ruby
            pkgs.nodejs_latest
            pkgs.yarn
            reviewTools.pre-commit
            reviewTools.terraform
            reviewTools.tflint
            reviewTools.terraform-docs
            reviewTools.shellcheck
            reviewTools.coreutils
            reviewTools.findutils
            reviewTools.gnugrep
            reviewTools.gnused
            reviewTools.gawk
            reviewTools.jq
            reviewTools.util-linux
            (pkgs.writeShellApplication {
              name = "review-bootstrap";
              text = reviewEnvironment + ''
                IFS=: read -r -a caches <<< "''${REVIEW_GEM_CACHE:-}"
                mkdir -p "$GEM_HOME/bundler" "$GEM_HOME/cache/bundler"
                for cache in "''${caches[@]}"; do
                  if [ -d "$cache/bundler" ]; then cp -an "$cache/bundler/." "$GEM_HOME/bundler/"; fi
                  if [ -d "$cache/cache/bundler" ]; then cp -an "$cache/cache/bundler/." "$GEM_HOME/cache/bundler/"; fi
                done
                for archive in /deps/gem-archives/*.gem; do
                  [ -f "$archive" ] || continue
                  gem install --local --no-document --ignore-dependencies "$archive"
                done
                bundle check || bundle install --local
                bundle binstubs --all
                printf 'yarn-offline-mirror "/deps/yarn-archives"\n' > "$TMPDIR/yarnrc"
                test "$(yarn config get ignore-scripts)" = true
                yarn --use-yarnrc "$TMPDIR/yarnrc" install --offline --frozen-lockfile --ignore-scripts
                printf 'disable_checkpoint = true\nprovider_installation {\n filesystem_mirror {\n path = "/deps/terraform-inputs/providers"\n include = ["registry.terraform.io/*/*"]\n }\n}\n' > "$TF_CLI_CONFIG_FILE"
                files="$(git ls-files '*.tf')"
                test -n "$files"
                mapfile -t roots < <(printf '%s\n' "$files" | while IFS= read -r file; do dirname "$file"; done | sort -u)
                for root in "''${roots[@]}"; do
                  mkdir -p "$root/.terraform/modules"
                  if [ -f "/deps/terraform-inputs/roots/$root/modules.json" ]; then cp "/deps/terraform-inputs/roots/$root/modules.json" "$root/.terraform/modules/modules.json"; fi
                  if [ ! -f "$root/.terraform.lock.hcl" ]; then cp "/deps/terraform-inputs/roots/$root/lock.hcl" "$root/.terraform.lock.hcl"; fi
                  terraform -chdir="$root" init -backend=false -input=false -lockfile=readonly -no-color
                done
              '';
            })
            (pkgs.writeShellApplication {
              name = "review-check";
              text = reviewEnvironment + ''
                status=0
                pre-commit run --all-files --config ${reviewPreCommitConfig} || status=$?
                pre-commit run --all-files --hook-stage pre-push --config ${reviewPreCommitConfig} || status=$?
                bundle exec brakeman || status=$?
                yarn jest --runInBand || status=$?
                bin/rails assets:precompile || status=$?
                bundle exec parallel_test -n 5 --type rspec --serialize-stdout spec 2>&1 | tee "$TMPDIR/unit.log" || status=$?
                ruby -e 'r = File.read(ARGV[0]).scan(/(\d+) examples?, (\d+) failures?(?:, (\d+) pending)?/); abort "Unit tests failed or skipped" unless r.any? { |x| x[0].to_i.positive? } && r.all? { |x| x[1].to_i.zero? && x[2].to_i.zero? }' "$TMPDIR/unit.log" || status=$?
                for root in terraform/modules/puma_capacity_dashboard terraform/modules/frontend_page_visits_dashboard; do
                  terraform -chdir="$root" test -no-color || status=$?
                done
                if [ "$status" -ne 0 ]; then exit "$status"; fi
                echo 'Blocked: accessibility checks require running frontend/admin services and their login configuration.' >&2
                exit 78
              '';
            })
          ];
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
            pkgs.libyaml
            pkgs.zlib
            pkgs.openssl
          ];
          BUNDLE_BUILD__PSYCH = builtins.concatStringsSep " " psychBuildFlags;
          BROWSER_PATH = pkgs.writeShellScript "review-chrome" ''
            if [ "''${REVIEW_SANDBOX:-}" != 1 ]; then exit 64; fi
            exec ${pkgs.google-chrome}/bin/google-chrome-stable --no-sandbox "$@"
          '';
          FONTCONFIG_FILE = pkgs.makeFontsConf { fontDirectories = [ pkgs.dejavu_fonts ]; };
          TZDIR = "${pkgs.tzdata.outPath}/share/zoneinfo";
          SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
        };

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
