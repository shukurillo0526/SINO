import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/companion_model.dart';

class CompanionService with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<CompanionModel> _companions = [];
  CompanionModel? _activeCompanion;

  List<CompanionModel> get companions => _companions;
  CompanionModel? get activeCompanion => _activeCompanion;

  Future<void> loadCompanions() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase
          .from('companions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      _companions = (response as List)
          .map((data) => CompanionModel.fromMap(data))
          .toList();
      
      _activeCompanion = _companions.firstWhere(
        (c) => c.isActive,
        orElse: () => _companions.isNotEmpty ? _companions.first : CompanionModel.defaultFox(userId),
      );
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading companions: $e');
      // Fallback to default if load fails
      if (_activeCompanion == null && _supabase.auth.currentUser != null) {
         _activeCompanion = CompanionModel.defaultFox(_supabase.auth.currentUser!.id);
         notifyListeners();
      }
    }
  }

  Future<void> createCompanion(CompanionModel companion) async {
    try {
      final response = await _supabase
          .from('companions')
          .insert(companion.toMap())
          .select()
          .single();
      
      final newCompanion = CompanionModel.fromMap(response);
      _companions.add(newCompanion);
      
      // If it's the first one, make it active
      if (_companions.length == 1) {
        await setActiveCompanion(newCompanion.id);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error creating companion: $e');
      rethrow;
    }
  }

  Future<void> updateCompanion(CompanionModel companion) async {
    try {
      await _supabase
          .from('companions')
          .update(companion.toMap())
          .eq('id', companion.id);

      final index = _companions.indexWhere((c) => c.id == companion.id);
      if (index != -1) {
        _companions[index] = companion;
        if (_activeCompanion?.id == companion.id) {
          _activeCompanion = companion;
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating companion: $e');
      rethrow;
    }
  }

  Future<void> setActiveCompanion(String companionId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // 1. Deactivate all others locally
      // 2. Activate target locally
      // 3. Batch update in DB (Optimistic UI)
      
      final prevActive = _activeCompanion;
      
      // DB Update
      // Set all to inactive
      await _supabase.from('companions').update({'is_active': false}).eq('user_id', userId);
      // Set target to active
      await _supabase.from('companions').update({'is_active': true}).eq('id', companionId);

      await loadCompanions(); // Reload to sync state
    } catch (e) {
      debugPrint('Error setting active companion: $e');
      rethrow;
    }
  }

  Future<void> deleteCompanion(String companionId) async {
    try {
      await _supabase.from('companions').delete().eq('id', companionId);
      _companions.removeWhere((c) => c.id == companionId);
      
      // If we deleted the active one, pick another
      if (_activeCompanion?.id == companionId) {
        if (_companions.isNotEmpty) {
           await setActiveCompanion(_companions.first.id);
        } else {
           _activeCompanion = null;
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting companion: $e');
      rethrow;
    }
  }
}
