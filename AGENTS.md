# Repository Guidelines

## Project Structure & Module Organization
- Primary app code lives in `Her Lives/`. `Core/` defines engine types such as `Agent`, `LivingWorld`, and shared state. `Systems/` holds the simulation subsystems (planning, relationships, culture, persistence). SwiftUI screens are under `Views/`, and shared data models reside in `Models/`. `Services/` wraps integrations like Qwen AI and audio. Assets sit in `Assets.xcassets`; leave `build/` untouched because it is generated output.

## Build, Test, and Development Commands
- `open "Her Lives.xcodeproj"` launches the Xcode workspace with existing schemes.
- `xcodebuild -project "Her Lives.xcodeproj" -scheme "Her Lives" -destination 'platform=iOS Simulator,name=iPhone 15' build` performs a clean headless build; run before pushing.
- Keep SwiftUI previews compiling so UI changes can be exercised quickly inside Xcode.

## Coding Style & Naming Conventions
- Follow Swift API Design Guidelines: 4-space indentation, meaningful doc comments only where intent is non-obvious, and `// MARK:` blocks to group related members as seen in `Core/Agent.swift`.
- Use `UpperCamelCase` for types, `lowerCamelCase` for properties/functions, and prefer protocol extensions for feature-oriented cohesion. Limit `public` to APIs consumed outside the module.
- Run Xcode's "Format File" or equivalent swift-format pass prior to commits to avoid churn; resolve all compiler warnings before merging.

## Testing Guidelines
- House unit tests in `Her LivesTests/` (create the target if missing) mirroring the module layout, e.g. `SystemsTests/PlanningSystemTests.swift`.
- Write tests with `XCTest`, naming classes `<Type>Tests` and methods `test_<Scenario>_<Expectation>()`. Favor deterministic seams (planners, relationship scoring) and mock external services.
- Use `xcodebuild test -project "Her Lives.xcodeproj" -scheme "Her Lives" -destination 'platform=iOS Simulator,name=iPhone 15'` to run the suite; aim to cover new logic when shipping features.

## Commit & Pull Request Guidelines
- Author commits in imperative, scoped form (`feat: add relationship decay`, `fix: guard empty memory stream`) and keep them atomic across code, assets, and localized strings.
- Pull requests should describe the change, include manual test notes (simulator/device, scenarios), attach screenshots for UI alterations, and link any relevant design docs or tasks.

## Security & Configuration Tips
- Inject Qwen API keys at runtime via `QwenConfiguration.configure(apiKeys:)`; never commit secrets or production URLs outside configuration files. Prefer `.xcconfig` or secure keychains for distribution builds.
- Audit logging to avoid leaking full `Agent` state, and verify serialized saves only include data needed by `SaveGameManager`.
