# SimpleCalorieApp — Master Project Spine

## PHASE 1 — Serving Size UX & Engine

**Status:** ✅ Completed

- Add Food Detail Sheet
- ServingSizeGenerator
- Golden master tests
- Domain tests
- Custom unit logic
- UI polish
- Integration with FoodDetailSheet

---

## PHASE 2 — Food Repository Architecture

**Status:** ✅ Completed

### 2.1 Repository Abstractions — ✅ Completed

- FoodRepository protocol (FoodDefinitionRepository)
- TestFoodRepository
- LocalFoodRepository
- Repository factory switch (FoodRepositoryFactory)

### 2.2 Integration with Detail Sheet — ✅ Completed

- Refactor Detail Sheet to consume repository
- Wire to LocalFoodRepository
- Add basic AddFoodViewModel tests using TestFoodRepository

### 2.3 Prepare for Remote Integration — ✅ Completed

- Define RemoteFoodRepository interface for provider A (FDC)
- Add error mapping (FoodDefinitionRepositoryError)
- Confirm data flow from Remote → FoodDefinition → ServingSizeGenerator
- Implement CachingFoodRepository wrapper
- Add DEBUG toggle for FoodRepositoryMode (local/remote/caching)

---

## PHASE 3 — Remote Provider A (FDC)

**Status:** 🟨 In Progress

### 3.1 FDC API Integration — ✅ Completed

- FDC API wiring in RemoteFoodRepository
- FDC DTOs (FDCSearchResponse, FDCFoodDetailsResponse, etc.)
- FDCClient with protocol abstraction for testing
- MockFDCClient for unit tests

### 3.2 FDC Mapping & Tests — ✅ Completed

- Mapping FDC → FoodDefinition (FoodDefinition+FDCMapping)
- Fixture-based mapping tests (FDCMappingTests)
- Integration tests for RemoteFoodRepository
- ServingSizeGenerator integration with FDC-mapped foods

### 3.3 FDC Production Integration — ⏳ Next

- ServingPatternSweeper for FDC
- Generate SeedFoods_fdc.json
- Integrate SeedFoods_fdc.json into LocalFoodRepository
- Tag FDC-enabled milestone

### 3.4 Provider Nutrient Name Sweeper — ✅ Completed

- NutrientNameSweeper debug tool (Features/Debug/ProviderSweep/)
- Sweeps FDC search and detail responses to collect unique nutrient names
- Saves results to DebugOutput/Seed_NutrientNames_fdc.json (gitignored)
- Debug menu entry in Settings → DEBUG → "Run Provider Nutrient Sweep (FDC)"
- ProviderSweepTests for validation

---

## PHASE 4 — Caching Repository

**Status:** 🟨 Partially Complete

### 4.1 In-Memory Caching — ✅ Completed

- CachingFoodRepository (local + remote + in-memory cache)
- Fallback behavior if remote unavailable
- Basic caching tests

### 4.2 Persistent Caching — ⏳ Next

- Add persistent JSON/SQLite cache for normalized FoodDefinition
- Blend in-memory + disk caching
- Enhanced caching tests
- Repo/Cache diagnostics screen (FoodRepositoryDiagnosticsView exists but needs wiring)

---

## PHASE 5 — Serving Pattern Sweep Tool

**Status:** ⏳ Not Started

- Fetch many foods from provider
- Run ServingSizeGenerator on all of them
- Detect odd units / patterns
- Produce canonical seed JSON per provider
- Add dev toggle for UI layout stress test (worst-case labels)
- Tag sweep-tool milestone

---

## PHASE 6 — Provider B (Open Food Facts)

**Status:** ⏳ Not Started

- RemoteFoodRepository_B implementation
- Mapping B → FoodDefinition
- Fixture tests + sweep + seed JSON
- Toggle between providers A/B

---

## PHASE 7 — Provider C / D

**Status:** ⏳ Not Started

- Same pipeline as Phases 3–6 for each additional provider
- Maintain separate seeds and caches per provider

---

# Active Threads

- Complete FDC production integration (ServingPatternSweeper, seed JSON generation)
- Add persistent disk caching to CachingFoodRepository
- Design ServingPatternSweeper tool architecture

# Parking Lot

- Advanced pantry features
- AI-based macro estimate tool
- Meal plans / suggested servings
- Vision-based add flow (for future hardware/scanning)
- Visual debug mode for serving-size anomalies (overlay)
- Multi-provider search results blending
- Offline-first architecture with sync

