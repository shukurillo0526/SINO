import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import '../services/supabase_data_service.dart';

class RewardSkin {
  final String id;
  final String name;
  final String assetPath;
  final int cost;
  final bool isUnlocked;

  RewardSkin({
    required this.id,
    required this.name,
    required this.assetPath,
    required this.cost,
    this.isUnlocked = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'assetPath': assetPath,
    'cost': cost,
    'isUnlocked': isUnlocked,
  };

  factory RewardSkin.fromJson(Map<String, dynamic> json) => RewardSkin(
    id: json['id'],
    name: json['name'],
    assetPath: json['assetPath'],
    cost: json['cost'],
    isUnlocked: json['isUnlocked'],
  );

  RewardSkin copyWith({bool? isUnlocked}) {
    return RewardSkin(
      id: id,
      name: name,
      assetPath: assetPath,
      cost: cost,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}

class RewardCoupon {
  final String id;
  final String name;
  final String description;
  final int cost;
  final bool isPurchased;

  RewardCoupon({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    this.isPurchased = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'cost': cost,
    'isPurchased': isPurchased,
  };

  factory RewardCoupon.fromJson(Map<String, dynamic> json) => RewardCoupon(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    cost: json['cost'],
    isPurchased: json['isPurchased'],
  );

  RewardCoupon copyWith({bool? isPurchased}) {
    return RewardCoupon(
      id: id,
      name: name,
      description: description,
      cost: cost,
      isPurchased: isPurchased ?? this.isPurchased,
    );
  }
}

class RewardsController extends ChangeNotifier {
  int _points = 100; // Starting points
  String _selectedSkinId = 'classic';
  final SupabaseDataService _dataService = SupabaseDataService();
  
  bool get _isGuest => Supabase.instance.client.auth.currentUser == null;
  
  final List<RewardSkin> _skins = [
    RewardSkin(id: 'classic', name: 'Classic SINO', assetPath: 'lib/assets/sino_green_anime.png', cost: 0, isUnlocked: true),
    RewardSkin(id: 'confu', name: 'Confu', assetPath: 'lib/assets/confu_green_anime.png', cost: 300),
    RewardSkin(id: 'scientist', name: 'Scientist', assetPath: 'assets/sino_scientist.png', cost: 500),
    RewardSkin(id: 'hero', name: 'Super Hero', assetPath: 'assets/sino_hero.png', cost: 1000),
    RewardSkin(id: 'traditional', name: 'Traditional', assetPath: 'assets/sino_traditional.png', cost: 750),
  ];

  final List<RewardCoupon> _coupons = [
    RewardCoupon(id: 'coffee', name: 'Coffee Break', description: 'Get a free coffee coupon', cost: 200),
    RewardCoupon(id: 'movie', name: 'Movie Ticket', description: 'One standard movie ticket', cost: 800),
    RewardCoupon(id: 'game_time', name: '1Hr Game Time', description: 'Extra hour of game/screen time', cost: 150),
    RewardCoupon(id: 'snack', name: 'Snack Box', description: 'A box of healthy snacks', cost: 350),
  ];

  int get points => _points;
  String get selectedSkinId => _selectedSkinId;
  List<RewardSkin> get skins => _skins;
  List<RewardCoupon> get coupons => _coupons;
  
  RewardSkin get selectedSkin => _skins.firstWhere((s) => s.id == _selectedSkinId);

  RewardsController() {
    _loadRewardsData();
  }

  // ===== POINTS LOGIC =====

  void addPoints(int amount) {
    _points += amount;
    _saveRewardsData(); // Save local
    
    if (!_isGuest) {
      _dataService.updatePoints(_points); // Sync cloud
    }
    
    notifyListeners();
  }

  // ===== STORE LOGIC (Local State Only) =====

  bool purchaseSkin(String skinId) {
    final index = _skins.indexWhere((s) => s.id == skinId);
    if (index != -1 && _points >= _skins[index].cost && !_skins[index].isUnlocked) {
      _points -= _skins[index].cost;
      _skins[index] = _skins[index].copyWith(isUnlocked: true);
      
      _saveRewardsData();
      if (!_isGuest) _dataService.updatePoints(_points);
      
      notifyListeners();
      return true;
    }
    return false;
  }
  
  bool purchaseCoupon(String couponId) {
    final index = _coupons.indexWhere((c) => c.id == couponId);
    if (index != -1 && _points >= _coupons[index].cost) {
      _points -= _coupons[index].cost;
      _coupons[index] = _coupons[index].copyWith(isPurchased: true);
      
      _saveRewardsData();
      if (!_isGuest) _dataService.updatePoints(_points);
      
      notifyListeners();
      return true;
    }
    return false;
  }
  
  bool redeemCoupon(String couponId) {
     final index = _coupons.indexWhere((c) => c.id == couponId);
     if (index != -1 && _coupons[index].isPurchased) {
       _coupons[index] = _coupons[index].copyWith(isPurchased: false);
       _saveRewardsData();
       notifyListeners();
       return true;
    }
    return false;
  }

  void selectSkin(String skinId) {
    final skin = _skins.firstWhere((s) => s.id == skinId);
    if (skin.isUnlocked) {
      _selectedSkinId = skinId;
      _saveRewardsData();
      notifyListeners();
    }
  }

  // ===== PERSISTENCE =====

  Future<void> _loadRewardsData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load Points
    if (_isGuest) {
       _points = prefs.getInt('sino_points') ?? 100;
    } else {
      // Cloud First
      final cloudPoints = await _dataService.fetchPoints();
      _points = cloudPoints > 0 ? cloudPoints : (prefs.getInt('sino_points') ?? 100);
    }

    _selectedSkinId = prefs.getString('selected_skin_id') ?? 'classic';
    
    // Load Skins (Local)
    final skinsJson = prefs.getString('unlocked_skins');
    if (skinsJson != null) {
      final List<dynamic> decoded = jsonDecode(skinsJson);
      for (var skinData in decoded) {
        final id = skinData['id'];
        final index = _skins.indexWhere((s) => s.id == id);
        if (index != -1) {
          _skins[index] = _skins[index].copyWith(isUnlocked: true);
        }
      }
    }
    
    // Load Coupons (Local)
    final couponsJson = prefs.getString('purchased_coupons');
    if (couponsJson != null) {
       final List<dynamic> decoded = jsonDecode(couponsJson);
       for (var couponData in decoded) {
         final id = couponData['id'];
         final index = _coupons.indexWhere((c) => c.id == id);
         if (index != -1) {
           _coupons[index] = _coupons[index].copyWith(isPurchased: true);
         }
       }
    }
    
    notifyListeners();
  }

  Future<void> _saveRewardsData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Always save local cache
    await prefs.setInt('sino_points', _points);
    await prefs.setString('selected_skin_id', _selectedSkinId);
    
    final unlockedSkins = _skins.where((s) => s.isUnlocked).map((s) => s.toJson()).toList();
    await prefs.setString('unlocked_skins', jsonEncode(unlockedSkins));
    
    final purchasedCoupons = _coupons.where((c) => c.isPurchased).map((c) => c.toJson()).toList();
    await prefs.setString('purchased_coupons', jsonEncode(purchasedCoupons));
  }
}
