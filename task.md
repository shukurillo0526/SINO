# SINO App Roadmap (PLAN 2)

## Phase 1: Foundations & Infrastructure
- [x] **Enhanced Crisis Protocols** <!-- id: 0 -->
    - [x] Integrate 109 Crisis Hotline into `CrisisService`
    - [x] Add "Call Now" button in the High Risk alert dialog
- [x] **Localization Polish** <!-- id: 1 -->
    - [x] Audit `strings.dart` for direct/awkward translations
    - [x] Implement more culturally nuanced Korean text
- [x] **Backend Migration** <!-- id: 2 -->
    - [x] Design `AuthService` and `DatabaseService` abstraction for easy swapping
    - [x] User to select provider (Supabase/Firebase) & provide keys

## Phase 2: Engagement & AI Intelligence
- [x] **Academics-Mood Loop** <!-- id: 3 -->
    - [x] Update `AcademicsService` to trigger mood logs upon task completion
    - [x] Award SINO points for finishing To-Do items
- [x] **Multimodal AI** <!-- id: 4 -->
    - [x] Upgrade `GeminiService` to support history/context
    - [x] Refactor Chat UI to support multi-turn conversation
- [x] **Biomarker Pilot (Voice)** <!-- id: 5 -->
    - [x] Research Flutter voice recording & analysis packages
    - [x] Implement basic voice note logging

## Phase 3: Validation & B2B Growth
- [x] **Clinical Evidence Gathering** <!-- id: 6 -->
    - [x] Implement detailed logging for "Sentiment Score" tracking
    - [x] Implement CSV Export for Researchers
- [x] **B2B Dashboard** <!-- id: 7 -->
    - [x] Create aggregated data view (stub/mock)
- [x] **Rewards Ecosystem** <!-- id: 8 -->
    - [x] Add placeholder redemption items (Coupons)
