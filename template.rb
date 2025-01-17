# app_template.rb
#
# A Rails 8 template that installs:
#   - Devise for authentication
#   - Vite for asset bundling
#   - React (with TypeScript support)
#   - TailwindCSS (using the tailwindcss-rails gem + shadcn setup)
#   - turbo-mount for embedding React in Rails views

# ------------------------------------------------------------------------------
# 1. Add needed gems to the Gemfile
# ------------------------------------------------------------------------------
gem 'devise', '~> 4.9'
gem 'vite_rails', '~> 3.0'
gem 'turbo-mount', '~> 0.4.1'
gem 'tailwindcss-rails', '~> 3.0'

# ------------------------------------------------------------------------------
# 2. AFTER BUNDLE: run installers, generate configs/models, etc.
# ------------------------------------------------------------------------------
after_bundle do
  say '=== Post-bundle setup starting... ===', :green

  # --------------------------------------------------------------------------
  # 2.1: Database setup
  # --------------------------------------------------------------------------
  rails_command 'db:create'
  rails_command 'db:migrate'

  # --------------------------------------------------------------------------
  # 2.2: Devise (install + generate User model)
  # --------------------------------------------------------------------------

  generate 'devise:install'
  generate 'devise', 'User'
  rails_command 'db:migrate'
  rails_command 'tailwindcss:install'
  # --------------------------------------------------------------------------
  # 2.3: Vite + React + Tailwind + shadcn
  # --------------------------------------------------------------------------
  say '=== Installing Vite, React, Tailwind, shadcn, etc. ===', :green

  # --- Vite ---
  run 'bundle exec vite install'

  # --- Install NPM dependencies ---
  run <<~CMD
    npm install \
      react react-dom \
      turbo-mount stimulus-vite-helpers clsx tailwind-merge \
      @hotwired/turbo-rails \
      @rails/actioncable @rails/activestorage  
  CMD
  run <<~CMD
    npm install -D \
      @vitejs/plugin-react eslint globals eslint-plugin-react-refresh typescript-eslint @eslint/js \
      @types/react @types/react-dom vite-plugin-stimulus-hmr vite-plugin-full-reload \
      tailwind autoprefixer tailwindcss-animate \
      @tailwindcss/typography @tailwindcss/container-queries @tailwindcss/forms#{' '}
  CMD

  # Initialize Tailwind configs
  run 'npx tailwindcss init -p'

  # --------------------------------------------------------------------------
  # 2.3.1: Overwrite tailwind.config.js with your preferred config
  # --------------------------------------------------------------------------
  remove_file 'tailwind.config.js'
  create_file 'tailwind.config.js', <<~JS
    const defaultTheme = require('tailwindcss/defaultTheme')

    module.exports = {
      darkMode: ['class'],
      content: [
        './public/*.html',
        './app/helpers/**/*.rb',
        './app/javascript/**/*.{js,jsx,ts,tsx}',
        './app/views/**/*.{erb,haml,html,slim}'
      ],
      theme: {
        extend: {
          fontFamily: {
            sans: [
              'Inter var',
              ...defaultTheme.fontFamily.sans
            ]
          },
          borderRadius: {
            lg: 'var(--radius)',
            md: 'calc(var(--radius) - 2px)',
            sm: 'calc(var(--radius) - 4px)'
          },
          colors: {
            background: 'hsl(var(--background))',
            foreground: 'hsl(var(--foreground))',
            card: {
              DEFAULT: 'hsl(var(--card))',
              foreground: 'hsl(var(--card-foreground))'
            },
            popover: {
              DEFAULT: 'hsl(var(--popover))',
              foreground: 'hsl(var(--popover-foreground))'
            },
            primary: {
              DEFAULT: 'hsl(var(--primary))',
              foreground: 'hsl(var(--primary-foreground))'
            },
            secondary: {
              DEFAULT: 'hsl(var(--secondary))',
              foreground: 'hsl(var(--secondary-foreground))'
            },
            muted: {
              DEFAULT: 'hsl(var(--muted))',
              foreground: 'hsl(var(--muted-foreground))'
            },
            accent: {
              DEFAULT: 'hsl(var(--accent))',
              foreground: 'hsl(var(--accent-foreground))'
            },
            destructive: {
              DEFAULT: 'hsl(var(--destructive))',
              foreground: 'hsl(var(--destructive-foreground))'
            },
            border: 'hsl(var(--border))',
            input: 'hsl(var(--input))',
            ring: 'hsl(var(--ring))',
            chart: {
              '1': 'hsl(var(--chart-1))',
              '2': 'hsl(var(--chart-2))',
              '3': 'hsl(var(--chart-3))',
              '4': 'hsl(var(--chart-4))',
              '5': 'hsl(var(--chart-5))'
            }
          }
        }
      },
      plugins: [
        require('@tailwindcss/forms'),
        require('@tailwindcss/typography'),
        require('@tailwindcss/container-queries'),
        require('tailwindcss-animate')
      ]
    }
  JS

  # --------------------------------------------------------------------------
  # 2.3.2: Overwrite vite.config.js with your React + Ruby config
  # --------------------------------------------------------------------------
  remove_file 'vite.config.js'
  create_file 'vite.config.js', <<~JS
    import path from 'path'
    import { defineConfig } from 'vite'
    import RubyPlugin from 'vite-plugin-ruby'
    import react from "@vitejs/plugin-react"
    server: {
      watch: {
        usePolling: true
      }
    }
    export default defineConfig({
      plugins: [
        react(),
        RubyPlugin(),
      ],
      resolve: {
        alias: {
          "@": path.resolve(__dirname, "./app/javascript"),
        },
      },
    })
  JS

  # --------------------------------------------------------------------------
  # 2.3.3: Add TypeScript config files
  # --------------------------------------------------------------------------
  create_file 'tsconfig.json', <<~JSON
    {
      "files": [],
      "references": [
        { "path": "./tsconfig.app.json" },
        { "path": "./tsconfig.node.json" }
      ],
      "compilerOptions": {
        "baseUrl": ".",
        "paths": {
          "@/*": ["./app/javascript/*"]
        }
      }
    }
  JSON

  create_file 'tsconfig.app.json', <<~JSON
    {
      "compilerOptions": {
        "tsBuildInfoFile": "./node_modules/.tmp/tsconfig.app.tsbuildinfo",
        "target": "ES2020",
        "useDefineForClassFields": true,
        "lib": ["ES2020", "DOM", "DOM.Iterable"],
        "module": "ESNext",
        "skipLibCheck": true,

        "moduleResolution": "bundler",
        "allowImportingTsExtensions": true,
        "isolatedModules": true,
        "moduleDetection": "force",
        "noEmit": true,
        "jsx": "react-jsx",

        "strict": true,
        "noUnusedLocals": true,
        "noUnusedParameters": true,
        "noFallthroughCasesInSwitch": true,
        "noUncheckedSideEffectImports": true,

        "baseUrl": ".",
        "paths": {
          "@/*": ["./app/javascript/*"]
        }
      },
      "include": ["app/javascript/**/*"]
    }
  JSON

  create_file 'tsconfig.node.json', <<~JSON
    {
      "compilerOptions": {
        "tsBuildInfoFile": "./node_modules/.tmp/tsconfig.node.tsbuildinfo",
        "target": "ES2022",
        "lib": ["ES2023"],
        "module": "ESNext",
        "skipLibCheck": true,

        "moduleResolution": "bundler",
        "allowImportingTsExtensions": true,
        "isolatedModules": true,
        "moduleDetection": "force",
        "noEmit": true,

        "strict": true,
        "noUnusedLocals": true,
        "noUnusedParameters": true,
        "noFallthroughCasesInSwitch": true,
        "noUncheckedSideEffectImports": true
      },
      "include": ["vite.config.ts"]
    }
  JSON

  # --------------------------------------------------------------------------
  # 2.3.4: Remove default Rails assets / create Stimulus + Tailwind structure
  # --------------------------------------------------------------------------
  remove_file 'app/javascript/application.js'
  remove_file 'app/javascript/controllers/index.js'

  create_file 'app/javascript/controllers/index.js', <<~JS
    import { application } from "./application";
    import { registerControllers } from "stimulus-vite-helpers";

    const controllers = import.meta.glob("./**/*_controller.js", { eager: true });
    registerControllers(application, controllers);
  JS

  # Remove the default Tailwind file created by the `tailwindcss:install` generator
  remove_file 'app/assets/stylesheets/application.tailwind.css', force: true

  # Create a dedicated folder for styles
  run 'mkdir -p app/javascript/stylesheets'
  create_file 'app/javascript/stylesheets/tailwind.css', <<~CSS
    @import "tailwindcss/base";
    @import "tailwindcss/components";
    @import "tailwindcss/utilities";
  CSS

  # Application-wide CSS entrypoint
  create_file 'app/javascript/entrypoints/application.css', <<~CSS
    @tailwind base;
    @tailwind components;
    @tailwind utilities;

    /* Example theming with CSS variables */
    @layer base {
      :root {
        --background: 0 0% 100%;
        --foreground: 0 0% 3.9%;
        --card: 0 0% 100%;
        --card-foreground: 0 0% 3.9%;
        --popover: 0 0% 100%;
        --popover-foreground: 0 0% 3.9%;
        --primary: 0 0% 9%;
        --primary-foreground: 0 0% 98%;
        --secondary: 0 0% 96.1%;
        --secondary-foreground: 0 0% 9%;
        --muted: 0 0% 96.1%;
        --muted-foreground: 0 0% 45.1%;
        --accent: 0 0% 96.1%;
        --accent-foreground: 0 0% 9%;
        --destructive: 0 84.2% 60.2%;
        --destructive-foreground: 0 0% 98%;
        --border: 0 0% 89.8%;
        --input: 0 0% 89.8%;
        --ring: 0 0% 3.9%;
        --chart-1: 12 76% 61%;
        --chart-2: 173 58% 39%;
        --chart-3: 197 37% 24%;
        --chart-4: 43 74% 66%;
        --chart-5: 27 87% 67%;
        --radius: 0.5rem;
      }
      .dark {
        --background: 0 0% 3.9%;
        --foreground: 0 0% 98%;
        --card: 0 0% 3.9%;
        --card-foreground: 0 0% 98%;
        --popover: 0 0% 3.9%;
        --popover-foreground: 0 0% 98%;
        --primary: 0 0% 98%;
        --primary-foreground: 0 0% 9%;
        --secondary: 0 0% 14.9%;
        --secondary-foreground: 0 0% 98%;
        --muted: 0 0% 14.9%;
        --muted-foreground: 0 0% 63.9%;
        --accent: 0 0% 14.9%;
        --accent-foreground: 0 0% 98%;
        --destructive: 0 62.8% 30.6%;
        --destructive-foreground: 0 0% 98%;
        --border: 0 0% 14.9%;
        --input: 0 0% 14.9%;
        --ring: 0 0% 83.1%;
        --chart-1: 220 70% 50%;
        --chart-2: 160 60% 45%;
        --chart-3: 30 80% 55%;
        --chart-4: 280 65% 60%;
        --chart-5: 340 75% 55%;
      }
    }

    @layer base {
      * {
        @apply border-border;
      }
      body {
        @apply bg-background text-foreground;
      }
    }
  CSS

  # 2.3.5: Create the main JS entrypoint for Vite
  remove_file 'app/javascript/entrypoints/application.js'
  create_file 'app/javascript/entrypoints/application.js', <<~JS
    import "@hotwired/turbo-rails";
    import "../controllers";
    import "./turbo-mount";
    import "./application.css";

    console.log("Hello from application.js");
  JS

  # --------------------------------------------------------------------------
  # 2.4: turbo-mount installation
  # --------------------------------------------------------------------------
  say '=== Installing turbo-mount ===', :green
  generate 'turbo_mount:install'

  # We’ll create a dedicated turbo-mount entry for React components
  remove_file 'app/javascript/turbo-mount.js'
  create_file 'app/javascript/entrypoints/turbo-mount.js', <<~JS
    import { TurboMount } from "turbo-mount";
    import { registerComponent } from "turbo-mount/react";

    // Example React component
    import { App } from "@/components/App";

    const turboMount = new TurboMount();
    registerComponent(turboMount, "App", App);
  JS

  # --------------------------------------------------------------------------
  # 2.5: Example React component + Home controller
  # --------------------------------------------------------------------------
  run 'mkdir -p app/javascript/components'
  create_file 'app/javascript/components/App.tsx', <<~TSX
    import { useState } from "react";

    export function App() {
      const [count, setCount] = useState(0);

      return (
        <div className="flex bg-[#242424] gap-12 text-white h-screen flex-col justify-center items-center mx-auto w-screen">
          <div className="flex text-3xl">
            <a href="https://guides.rubyonrails.org/index.html" target="_blank">
              <img
                src="/images/rails.svg"
                className="logo rails"
                alt="Rails logo"
              />
            </a>
            <a href="https://react.dev" target="_blank">
              <img
                src="/images/react.svg"
                className="logo react"
                alt="React logo"
              />
            </a>
            <a href="https://vite.dev" target="_blank">
              <img src="/images/vite.svg" className="logo" alt="Vite logo" />
            </a>
          </div>
          <h1 className="text-4xl font-bold">
            <span className="text-[#CC0000]">Rails </span>#{' '}
            + <span className="text-[#61dafb]">React </span>
            + <span className="text-[#646cff]">Vite</span>#{' '}
          </h1>
          <div className="card flex flex-col items-center">
            <button className="mb-4 font-semibold border border-transparent hover:border-[#646cff] cursor-pointer  bg-[#1a1a1a] p-1 rounded-lg p-x-8" onClick={() => setCount((count) => count + 1)}>
              count is {count}
            </button>
            <p>
              Edit <code>app/javascript/components/App.tsx</code> and save to test
              HMR
            </p>
          </div>
          <p className="text-[#888]">
            Click on the Rails, Vite and React logos to learn more
          </p>
        </div>
      );
    }
  TSX

  run 'mkdir -p public/images'
  run <<~CMD
    curl -o public/images/rails.svg https://raw.githubusercontent.com/lsproule/react-rails-template/refs/heads/main/images/rails.svg
    curl -o public/images/vite.svg https://raw.githubusercontent.com/lsproule/react-rails-template/refs/heads/main/images/vite.svg
    curl -o public/images/react.svg https://raw.githubusercontent.com/lsproule/react-rails-template/refs/heads/main/images/react.svg
  CMD

  generate :controller, 'route', 'index', '--skip-routes', '--no-helper', '--no-assets'
  route "root to: 'route#index'"

  remove_file 'app/views/route/index.html.erb', force: true
  create_file 'app/views/route/index.html.erb', <<~ERB
    <style>
    .logo {
      height: 6em;
      padding: 1.5em;
      will-change: filter;
      transition: filter 300ms;
    }
    .logo:hover {
      filter: drop-shadow(0 0 2em #646cffaa);
    }
    .logo.react:hover {
      filter: drop-shadow(0 0 2em #61dafbaa);
    }
    .logo.rails:hover {
      filter: drop-shadow(0 0 2em #CC0000);
    }

    @keyframes logo-spin {
      from {
        transform: rotate(0deg);
      }
      to {
        transform: rotate(360deg);
      }
    }
    a .logo.react {
      animation: logo-spin infinite 20s linear;
    }
    </style>
    <%= turbo_mount('App') %>
  ERB

  # --------------------------------------------------------------------------
  # 2.6: Insert needed tags in application.html.erb
  # --------------------------------------------------------------------------
  insert_into_file 'app/views/layouts/application.html.erb',
                   after: "<%= csrf_meta_tags %>\n" do
    <<~ERB
      <%= stylesheet_link_tag :app, "data-turbo-track": "reload" %>
      <%= javascript_importmap_tags %>
      <%= vite_client_tag %>
      <%= vite_javascript_tag 'application' %>

    ERB
  end

  # --------------------------------------------------------------------------
  # 2.7: shadcn initialization
  # --------------------------------------------------------------------------
  run 'npx shadcn@latest init'

  # --------------------------------------------------------------------------
  # 2.7.1: Create the UI Generators
  # --------------------------------------------------------------------------
  say '=== Creating custom UI generators ===', :green

  # Make sure directories exist
  run 'mkdir -p lib/generators/ui/component/templates'
  run 'mkdir -p lib/generators/ui/register'
  run 'mkdir -p lib/generators/rails/typescript'

  # 2.7.1.1: The `ui:component` generator
  create_file 'lib/generators/ui/component/component_generator.rb', <<~RUBY
    # lib/generators/ui/component/component_generator.rb

    module Ui
      class ComponentGenerator < Rails::Generators::NamedBase
        source_root File.expand_path("templates", __dir__)
        desc "Generates a new React component (TSX) and registers it in turbo-mount.js"

        def create_component_file
          # Create a new TSX file in app/javascript/components
          template "component.tsx.erb", "app/javascript/components/\#{class_name}.tsx"
        end

        def add_import_to_turbo_mount
          # Inject an import statement into turbo-mount.js after the registerComponent import
          inject_into_file(
            "app/javascript/entrypoints/turbo-mount.js",
            after: 'import { registerComponent } from "turbo-mount/react";'
          ) do
            "\\nimport { \#{class_name} } from \\"@/components/\#{class_name}\\";"
          end
        end

        def register_component_in_turbo_mount
          # Append a registerComponent call at the bottom of turbo-mount.js
          append_to_file "app/javascript/entrypoints/turbo-mount.js", <<~JS

            registerComponent(turboMount, "\#{class_name}", \#{class_name});
          JS
        end
      end
    end
  RUBY

  # Template for the TSX file
  create_file 'lib/generators/ui/component/templates/component.tsx.erb', <<~TSX
    type Props = {};

    export function <%= class_name %>({}: Props) {
      return (
        <div>
          <h2>New <%= class_name %> component</h2>
        </div>
      );
    }
  TSX



  # 2.7.1.2: The `ui:register_component` generator
  create_file 'lib/generators/ui/register/register_generator.rb', <<~RUBY
    # lib/generators/ui/register/register_generator.rb

    module Ui
      class RegisterGenerator < Rails::Generators::NamedBase
        source_root File.expand_path("templates", __dir__)
        desc "Takes an existing TSX component and auto-registers it in turbo-mount.js"

        def ensure_component_exists
          unless File.exist?("app/javascript/components/\#{class_name}.tsx")
            say "ERROR: app/javascript/components/\#{class_name}.tsx not found!", :red
            exit(1) # or raise an exception
          end
        end

        def add_import_to_turbo_mount
          # Step 1: Inject an import line under the registerComponent import line
          inject_into_file(
            "app/javascript/entrypoints/turbo-mount.js",
            after: 'import { registerComponent } from "turbo-mount/react";'
          ) do
            "\\nimport { \#{class_name} } from \\"@/components/\#{class_name}\\";"
          end
        end

        def register_component_in_turbo_mount
          # Step 2: Append the registerComponent call at the bottom of turbo-mount.js
          append_to_file "app/javascript/entrypoints/turbo-mount.js", <<~JS

            registerComponent(turboMount, "\#{class_name}", \#{class_name});
          JS
        end
      end
    end
  RUBY

  create_file 'lib/generators/rails/tmigration/tmigration.rb', <<~RUBY
    # lib/generators/rails/migration_ts/migration_ts_generator.rb

    class Rails::TmigrationGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      argument :migration_name, type: :string
      argument :attributes, type: :array, default: [], banner: "field:type field:type"

      def update_types
        puts "Updating TypeScript definitions based on \#{migration_name}..."

        types_file_path = Rails.root.join("app/javascript/types.d.ts")
        # read the file, parse it, inject new columns if they don’t exist, etc.
        # For references, do the same logic we did in the scaffold generator

        interface_code = build_migration_interface_snippet

        append_to_file types_file_path, interface_code
      end

      private

      def build_migration_interface_snippet
        # This is obviously simplistic. You would incorporate something
        # like the logic from your main TS generator, or even call
        # a shared module that does the same parsing of attributes.
        attributes_lines = attributes.flat_map do |attr|
          if attr.type == "references"
            [
              "\#{attr.name}_id: number;",
              "\#{attr.name}?: \#{attr.name.camelize};"
            ]
          else
            ["\#{attr.name}?: \#{rails_to_ts_type(attr.type)};"]
          end
        end

        <<~TS
          // AUTO-GENERATED by rails g migration \#{migration_name}
          // You may need to update validations or remove ? accordingly
          // if presence validations exist.
          // Changes introduced by: \#{migration_name}
          \#{attributes_lines.join("\n")}
        TS
      end

      def rails_to_ts_type(rails_type)
        case rails_type
        when "integer", "float", "decimal" then "number"
        when "boolean" then "boolean"
        else "string"
        end
      end
    end
  RUBY

  create_file 'lib/generators/rails/tmodel_validation/tmodel_validation_generator.rb', <<~RUBY
    # lib/generators/rails/tmodel_validation/tmodel_validation_generator.rb

    class Rails::TmodelValidationGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      def update_types_for_validations
        require File.join(Rails.root, "app/models/\#{file_path}.rb")

        model_class = file_name.camelize.constantize

        presence_attributes = model_class.validators
                                         .select { |v| v.is_a?(ActiveModel::Validations::PresenceValidator) }
                                         .flat_map(&:attributes)
                                         .map(&:to_s)

        required_belongs_tos = model_class.reflect_on_all_associations(:belongs_to)
                                          .select { |assoc| assoc.options[:optional] == false || assoc.options[:required] == true }
                                          .map(&:name)
                                          .map(&:to_s)

        presence_required = presence_attributes.to_set
        required_belongs_tos.each do |assoc_name|
          presence_required << assoc_name        # e.g. user
          presence_required << "\#{assoc_name}_id" # e.g. user_id
        end

        types_file_path = Rails.root.join("app/javascript/types.d.ts")
        return unless File.exist?(types_file_path)

        lines = File.read(types_file_path).split("\n")


        in_target_interface = false
        brace_depth = 0


        start_of_interface_regex = /^\s*(?:export\s+)?interface\s+\#{Regexp.escape(model_class.name)}\s*(\{|extends|$)/

        lines.map!.with_index do |line, idx|
          if !in_target_interface && line =~ start_of_interface_regex
            in_target_interface = true
            brace_depth = line.count("{")
          
          elsif in_target_interface
            brace_depth += line.count("{")
            brace_depth -= line.count("}")
            
            if brace_depth <= 0
              in_target_interface = false
            end
          end

          if in_target_interface && brace_depth > 0
            if line =~ /^(\s*)([a-zA-Z_0-9]+)(\??):/
              leading_spaces = $1
              attribute_name = $2
              question_mark  = $3 # could be "" or "?"

              if presence_required.include?(attribute_name)
                line = line.sub("\#{attribute_name}?:", "\#{attribute_name}:")
              else
                unless question_mark == "?"
                  line = line.sub("\#{attribute_name}:", "\#{attribute_name}?:")
                end
              end
            end
          end

          line
        end

        File.write(types_file_path, lines.join("\n"))
      end
    end
  RUBY

  create_file 'lib/generators/rails/tscaffold/tscaffold_generator.rb', <<~RUBY

    # lib/generators/rails/typescript/typescript_generator.rb

    class Rails::TscaffoldGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      argument :attributes, type: :array, default: [], banner: "field:type field:type"

      def create_or_update_types
        types_file_path = Rails.root.join("app/javascript/types.d.ts")

        interface_code = generate_interface_code

        if File.exist?(types_file_path)
          append_to_file types_file_path, interface_code
        else
          create_file types_file_path, interface_code
        end
      end

      private

      def generate_interface_code
        attributes_lines = attributes.flat_map do |attr|
          puts attr.inspect
          if attr.type == :references
            build_reference_lines(attr)
          else
            [build_attribute_line(attr)]
          end
        end

        <<~TS
          // AUTO-GENERATED by rails g scaffold \#{file_name}
          interface \#{class_name} {
            \#{attributes_lines.join("\n\t")}
          }

        TS
      end


      def build_attribute_line(attr)
        "\#{attr.name}?: \#{rails_to_ts_type(attr.type)};"
      end


      def build_reference_lines(attr)
        referenced_interface_name = attr.name.camelize
        [
          "\#{attr.name}_id: number;",
          "\#{attr.name}?: \#{referenced_interface_name};"
        ]
      end


      def rails_to_ts_type(rails_type)
        case rails_type
        when "integer", "float", "decimal" then "number"
        when "boolean" then "boolean"
        else
          "string"
        end
      end
    end
  RUBY

  create_file "config/initializers/custom_scaffold_generator.rb", <<~RUBY 
    require "rails/railtie"
    require "rails/generators"
    require "rails/generators/rails/scaffold_controller/scaffold_controller_generator"

    module TypescriptGenerator
      module ScaffoldControllerGenerator
        extend ActiveSupport::Concern

        included do
          hook_for :typescript, in: nil, default: true, type: :boolean
        end
      end
    end

    module ActiveModel
      class Railtie < Rails::Railtie
        generators do |app|
          Rails::Generators.configure! app.config.generators
          Rails::Generators::ScaffoldControllerGenerator.include TypescriptGenerator::ScaffoldControllerGenerator
        end
      end
    end
  RUBY

  create_file 'eslint.config.js', <<~JS
    import js from '@eslint/js'
    import globals from 'globals'
    import reactRefresh from 'eslint-plugin-react-refresh'
    import tseslint from 'typescript-eslint'

    export default tseslint.config(
      { ignores: ['dist'] },
      {
        extends: [js.configs.recommended, ...tseslint.configs.recommended],
        files: ['**/*.{ts,tsx}'],
        languageOptions: {
          ecmaVersion: 2020,
          globals: globals.browser,
        },
        plugins: {
          'react-refresh': reactRefresh,
        },
        rules: {
          'react-refresh/only-export-components': [
            'warn',
            { allowConstantExport: true },
          ],
          'no-restricted-exports': ["error", { "restrictDefaultExports": { "direct": true } }],
          "@typescript-eslint/no-empty-object-type": 'warn',
          'no-empty-pattern': 'warn'
        },
      },
    )
  JS

  # --------------------------------------------------------------------------
  # 2.8: Done!
  # --------------------------------------------------------------------------
  say '=== Setup Complete ===', :green
  say 'You can now run: bin/rails server', :yellow
  say 'Visit http://localhost:3000 to see the example turbo-mounted React component.', :yellow
end
