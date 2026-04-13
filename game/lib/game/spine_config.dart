// import 'package:mg_common_game/core/assets/asset_types.dart'; // Temporarily disabled - module doesn't exist yet

/// Spine 통합 플래그. `--dart-define=SPINE_ENABLED=true`로 활성화.
const kSpineEnabled = bool.fromEnvironment(
  'SPINE_ENABLED',
  defaultValue: false,
);

// ── Crafter ──────────────────────────────────────────────────

// const kCrafterMeta = SpineAssetMeta(
//   key: 'crafter',
//   path: 'spine/characters/crafter',
//   atlasPath: 'assets/spine/characters/crafter/crafter.atlas',
//   skeletonPath: 'assets/spine/characters/crafter/crafter.json',
//   animations: ['idle', 'walk', 'attack', 'hit'],
//   defaultAnimation: 'idle',
//   defaultMix: 0.2,
// );

// ── Miner ────────────────────────────────────────────────────

// const kMinerMeta = SpineAssetMeta(
//   key: 'miner',
//   path: 'spine/characters/miner',
//   atlasPath: 'assets/spine/characters/miner/miner.atlas',
//   skeletonPath: 'assets/spine/characters/miner/miner.json',
//   animations: ['idle', 'walk', 'attack', 'hit'],
//   defaultAnimation: 'idle',
//   defaultMix: 0.2,
// );

// ── Merchant ─────────────────────────────────────────────────

// const kMerchantMeta = SpineAssetMeta(
//   key: 'merchant',
//   path: 'spine/characters/merchant',
//   atlasPath: 'assets/spine/characters/merchant/merchant.atlas',
//   skeletonPath: 'assets/spine/characters/merchant/merchant.json',
//   animations: ['idle', 'walk', 'attack', 'hit'],
//   defaultAnimation: 'idle',
//   defaultMix: 0.2,
// );
