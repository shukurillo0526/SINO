# Implementation Plan - Phase 3: Rewards Ecosystem

## Goal
To incentivize student engagement, we will add a simple redemption system where students can spend "SINO Points" on real-world rewards (Coupons).

## Proposed Changes

### 1. Rewards Model
#### [MODIFY] [rewards_controller.dart](file:///c:/Users/shuku/OneDrive/Desktop/sino_1.0/lib/controllers/rewards_controller.dart)
- **New Logic**: Add `RewardCoupon` class and a list of mock coupons (e.g., "1 Hour Free Time", "Movie Night Ticket").
- **State**: Track purchased coupons.

### 2. Rewards UI
#### [NEW] [rewards_shop_screen.dart](file:///c:/Users/shuku/OneDrive/Desktop/sino_1.0/lib/features/rewards/rewards_shop_screen.dart)
- **Items**: Display separate sections for **Skins** (existing) and **Coupons** (new).
- **Action**: "Purchase" button deducts points and moves coupon to "My Coupons".

### 3. Navigation
- Add a "Shop" button to the `CharacterScreen` `AppBar` (replacing or next to Settings).

## Verification Plan
- [ ] Earn points via tasks.
- [ ] Open Shop.
- [ ] Purchase a "Coupon".
- [ ] Verify points deduction and coupon ownership.
