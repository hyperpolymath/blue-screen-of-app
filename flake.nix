{
  description = "Blue Screen of App - A humorous BSOD web application";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Node.js version (matching package.json requirement)
        nodejs = pkgs.nodejs_18;

        # Package definition
        blue-screen-of-app = pkgs.stdenv.mkDerivation {
          pname = "blue-screen-of-app";
          version = "1.0.0";

          src = ./.;

          buildInputs = [ nodejs ];

          nativeBuildInputs = [ pkgs.makeWrapper ];

          buildPhase = ''
            # Install dependencies
            npm ci --production
          '';

          installPhase = ''
            # Create output directory
            mkdir -p $out/lib/blue-screen-of-app

            # Copy application files
            cp -r . $out/lib/blue-screen-of-app/

            # Create bin directory
            mkdir -p $out/bin

            # Create wrapper script
            makeWrapper ${nodejs}/bin/node $out/bin/blue-screen-of-app \
              --add-flags "$out/lib/blue-screen-of-app/src/server.js" \
              --set NODE_ENV production
          '';

          meta = with pkgs.lib; {
            description = "A humorous web application that displays authentic-looking Blue Screen of Death errors";
            homepage = "https://github.com/Hyperpolymath/blue-screen-of-app";
            license = with licenses; [ gpl3Plus ]; # Dual-licensed, but Nix doesn't have Palimpsest yet
            maintainers = [ ];
            platforms = platforms.all;
          };
        };

      in
      {
        # Default package
        packages.default = blue-screen-of-app;
        packages.blue-screen-of-app = blue-screen-of-app;

        # Development shell
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nodejs
            nodePackages.npm
            nodePackages.nodemon

            # Testing and quality tools
            nodePackages.jest
            nodePackages.eslint

            # Docker tooling (if available)
            docker
            docker-compose

            # Build tool
            just

            # Utilities
            jq
            curl
            git
          ];

          shellHook = ''
            echo "🎨 Blue Screen of App Development Environment"
            echo "=============================================="
            echo ""
            echo "Node.js version: $(node --version)"
            echo "npm version: $(npm --version)"
            echo ""
            echo "Available commands:"
            echo "  npm install    - Install dependencies"
            echo "  npm start      - Start the server"
            echo "  npm run dev    - Start development server"
            echo "  npm test       - Run tests"
            echo "  just --list    - Show all just recipes"
            echo ""
            echo "Quick start:"
            echo "  1. npm install"
            echo "  2. cp .env.example .env"
            echo "  3. npm run dev"
            echo ""
            echo "Visit http://localhost:3000 after starting the server"
            echo ""

            # Create .env if it doesn't exist
            if [ ! -f .env ]; then
              echo "Creating .env from .env.example..."
              cp .env.example .env 2>/dev/null || true
            fi

            # Create logs directory
            mkdir -p logs

            # Set up environment variables for development
            export NODE_ENV=development
            export PORT=3000
          '';
        };

        # Docker image builder
        dockerImage = pkgs.dockerTools.buildLayeredImage {
          name = "blue-screen-of-app";
          tag = "latest";

          contents = [ blue-screen-of-app pkgs.bash ];

          config = {
            Cmd = [ "${blue-screen-of-app}/bin/blue-screen-of-app" ];
            ExposedPorts = {
              "3000/tcp" = {};
            };
            Env = [
              "NODE_ENV=production"
              "PORT=3000"
            ];
          };
        };

        # NixOS module (for those running NixOS)
        nixosModules.default = { config, lib, pkgs, ... }:
          with lib;
          let
            cfg = config.services.blue-screen-of-app;
          in {
            options.services.blue-screen-of-app = {
              enable = mkEnableOption "Blue Screen of App service";

              port = mkOption {
                type = types.int;
                default = 3000;
                description = "Port to run the application on";
              };

              host = mkOption {
                type = types.str;
                default = "0.0.0.0";
                description = "Host to bind to";
              };

              environmentFile = mkOption {
                type = types.nullOr types.path;
                default = null;
                description = "Environment file for configuration";
              };
            };

            config = mkIf cfg.enable {
              systemd.services.blue-screen-of-app = {
                description = "Blue Screen of App web application";
                wantedBy = [ "multi-user.target" ];
                after = [ "network.target" ];

                environment = {
                  NODE_ENV = "production";
                  PORT = toString cfg.port;
                };

                serviceConfig = {
                  Type = "simple";
                  ExecStart = "${blue-screen-of-app}/bin/blue-screen-of-app";
                  Restart = "always";
                  RestartSec = "10s";

                  # Security hardening
                  DynamicUser = true;
                  NoNewPrivileges = true;
                  PrivateTmp = true;
                  ProtectSystem = "strict";
                  ProtectHome = true;

                  # Environment file
                  EnvironmentFile = mkIf (cfg.environmentFile != null) cfg.environmentFile;
                };
              };
            };
          };

        # CI/CD helpers
        apps = {
          # Run the application
          default = {
            type = "app";
            program = "${blue-screen-of-app}/bin/blue-screen-of-app";
          };

          # Run tests
          test = {
            type = "app";
            program = toString (pkgs.writeShellScript "test" ''
              export NODE_ENV=test
              ${nodejs}/bin/npm test
            '');
          };

          # Run linter
          lint = {
            type = "app";
            program = toString (pkgs.writeShellScript "lint" ''
              ${nodejs}/bin/npm run lint
            '');
          };

          # Validate RSR compliance
          validate = {
            type = "app";
            program = toString (pkgs.writeShellScript "validate" ''
              ${pkgs.just}/bin/just validate
            '');
          };
        };

        # Checks (for nix flake check)
        checks = {
          # Lint check
          lint = pkgs.runCommand "lint-check" {
            buildInputs = [ nodejs ];
          } ''
            cd ${self}
            npm ci
            npm run lint
            touch $out
          '';

          # Test check
          test = pkgs.runCommand "test-check" {
            buildInputs = [ nodejs ];
          } ''
            cd ${self}
            npm ci
            npm test
            touch $out
          '';

          # RSR validation
          rsr-validation = pkgs.runCommand "rsr-validation" {
            buildInputs = [ pkgs.just ];
          } ''
            cd ${self}
            just validate
            touch $out
          '';
        };

      }
    );
}
