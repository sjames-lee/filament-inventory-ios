# Filament Inventory - iOS

A native iOS app for managing 3D printer filament inventory. Built with SwiftUI and SwiftData for a fast, offline-first experience.

Ported from the [web app](../filament_inventory/) (Next.js/React) to native Swift.

## Features

- **Catalog** — Browse filaments in a 2-column grid with color-coded cards
- **Search** — Find filaments by name, brand, color, material, or tags
- **Filters** — Multi-select by material, brand, color family, status, and favorites
- **Sort** — By name, brand, price, quantity, or date (ascending/descending)
- **Add/Edit** — Full form with native color picker synced to hex input
- **Detail View** — Color hero header, specs, temperatures, purchase info, tags, notes
- **Dashboard** — Stats (total filaments, spools, value), status overview, material/brand breakdowns, color palette
- **Favorites** — Quick toggle from detail view
- **Offline** — All data stored locally via SwiftData (no server required)

## Requirements

- macOS with Xcode 15+
- iOS 17.0+ deployment target
- [xcodegen](https://github.com/yonaskolb/XcodeGen) (for project generation)

## Getting Started

### 1. Install xcodegen (if not already installed)

```bash
brew install xcodegen
```

### 2. Generate the Xcode project

```bash
cd filament_inventory_ios
xcodegen generate
```

### 3. Open in Xcode

```bash
open FilamentInventory.xcodeproj
```

### 4. Build and run

Select an iPhone simulator (e.g. iPhone 16) and press **Cmd+R**.

Or build from the command line:

```bash
xcodebuild -project FilamentInventory.xcodeproj \
  -scheme FilamentInventory \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5' \
  build
```

## Architecture

### MVVM with SwiftData

```
┌─────────────────────────────────────────────┐
│  Views (SwiftUI)                            │
│  ├── CatalogView        (grid + search)     │
│  ├── FilamentDetailView (hero + sections)   │
│  ├── FilamentFormView   (add/edit sheet)    │
│  ├── FilterSheetView    (multi-select)      │
│  └── DashboardView      (analytics)         │
├─────────────────────────────────────────────┤
│  ViewModels (@Observable)                   │
│  ├── CatalogViewModel   (filter/sort state) │
│  └── DashboardViewModel (aggregations)      │
├─────────────────────────────────────────────┤
│  Model (SwiftData @Model)                   │
│  └── Filament           (all fields)        │
├─────────────────────────────────────────────┤
│  Utilities                                  │
│  ├── Constants           (enums, options)   │
│  ├── ColorHelpers        (hex/luminance)    │
│  └── FilamentFilter      (in-memory filter) │
└─────────────────────────────────────────────┘
```

- **Views** use `@Query` to reactively fetch from SwiftData and `@State`/`@Bindable` for UI state
- **ViewModels** are `@Observable` classes that own mutable filter/sort state and compute derived data
- **Model** is a single `@Model` class (`Filament`) persisted by SwiftData to local SQLite
- **Filtering** is done in-memory via `FilamentFilter.apply()` to avoid SwiftData `#Predicate` macro limitations

### Navigation

- `TabView` with two tabs: Catalog and Dashboard
- `NavigationStack` per tab with push navigation to detail
- Sheets for add/edit form and filter panel

## Project Structure

```
FilamentInventory/
├── FilamentInventoryApp.swift        # Entry point, model container
├── ContentView.swift                 # Root TabView
├── Model/
│   └── Filament.swift                # SwiftData model (22 fields)
├── ViewModels/
│   ├── CatalogViewModel.swift        # Search, filter, sort state
│   └── DashboardViewModel.swift      # Stats and aggregations
├── Views/
│   ├── Catalog/
│   │   ├── CatalogView.swift         # Main grid + search + toolbar
│   │   ├── FilamentCard.swift        # Color header card
│   │   └── FilterSheetView.swift     # Filter multi-select sheet
│   ├── Detail/
│   │   └── FilamentDetailView.swift  # Full detail with hero
│   ├── Form/
│   │   ├── FilamentFormView.swift    # Add/edit form
│   │   └── ColorPickerRow.swift      # ColorPicker + hex sync
│   └── Dashboard/
│       ├── DashboardView.swift       # Analytics tab
│       ├── StatCardView.swift        # Stat tile
│       ├── BarChartView.swift        # Horizontal bar chart
│       └── NeedsAttentionListView.swift
├── Components/
│   ├── ColorSwatchView.swift         # Colored circle
│   ├── MaterialBadgeView.swift       # Material pill badge
│   ├── StockIndicatorView.swift      # Status dot + label
│   └── TagPillsView.swift           # Flow layout tag pills
├── Utilities/
│   ├── Constants.swift               # Materials, brands, colors, statuses
│   ├── ColorHelpers.swift            # isLight(), hex<->Color conversion
│   └── FilamentFilter.swift          # FilterState + in-memory filtering
└── Assets.xcassets/                  # App icon, accent color
```

## Data Model

| Field | Type | Default | Notes |
|-------|------|---------|-------|
| id | UUID | auto | Primary key |
| name | String | — | Required |
| brand | String | — | From predefined list |
| material | String | — | From predefined list |
| colorName | String | — | e.g. "Matte Black" |
| colorHex | String | — | #RRGGBB format |
| colorFamily | String | — | From predefined list |
| diameter | Double | 1.75 | mm |
| spoolWeight | Double | 1000 | grams |
| quantity | Int | 1 | Number of spools |
| weightRemaining | Double? | nil | grams |
| printTempMin/Max | Int? | nil | 0-500 °C |
| bedTempMin/Max | Int? | nil | 0-200 °C |
| price | Double? | nil | USD |
| purchaseUrl | String? | nil | External link |
| notes | String? | nil | Free text |
| tags | String | "" | Comma-separated |
| status | String | "in_stock" | in_stock, low, empty |
| favorite | Bool | false | — |
| createdAt | Date | auto | — |
| updatedAt | Date | auto | Set manually on save |

## Regenerating the Project

If you add/remove Swift files or change the directory structure:

```bash
cd filament_inventory_ios
xcodegen generate
```

This reads `project.yml` and regenerates `FilamentInventory.xcodeproj`.
