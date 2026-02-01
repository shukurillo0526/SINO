import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/companion_model.dart';
import '../../services/companion_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CompanionCustomizationScreen extends StatefulWidget {
  final CompanionModel? existingCompanion;

  const CompanionCustomizationScreen({super.key, this.existingCompanion});

  @override
  State<CompanionCustomizationScreen> createState() =>
      _CompanionCustomizationScreenState();
}

class _CompanionCustomizationScreenState
    extends State<CompanionCustomizationScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late CompanionRole _selectedRole;
  final List<String> _selectedTraits = [];
  bool _isLoading = false;

  final Map<CompanionRole, String> _roleDescriptions = {
    CompanionRole.buddy: "A casual friend who jokes around and keeps it light.",
    CompanionRole.mentor: "A wise guide who offers deep advice and perspective.",
    CompanionRole.coach: "An energetic motivator who pushes you to succeed.",
    CompanionRole.sibling: "A caring family member who listens without judgment.",
    CompanionRole.therapist: "A professional-style support focused on mental wellness.",
  };

  final List<String> _availableTraits = [
    'Warm', 'Funny', 'Stoic', 'Energetic', 'Calm', 'Sarcastic',
    'Empathetic', 'Analytical', 'Cheerleader', 'Direct'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingCompanion?.name ?? '');
    _selectedRole = widget.existingCompanion?.role ?? CompanionRole.buddy;
    if (widget.existingCompanion != null) {
      _selectedTraits.addAll(widget.existingCompanion!.personalityTraits);
    } else {
      _selectedTraits.addAll(['Warm', 'Encouraging']);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveCompanion() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTraits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one personality trait')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      final service = context.read<CompanionService>();
      final isNew = widget.existingCompanion == null;

      final companion = CompanionModel(
        id: widget.existingCompanion?.id ?? const Uuid().v4(),
        userId: userId,
        name: _nameController.text.trim(),
        role: _selectedRole,
        personalityTraits: _selectedTraits,
        avatarStyle: widget.existingCompanion?.avatarStyle ?? 'default',
        voiceSettings: widget.existingCompanion?.voiceSettings ?? {},
        isActive: widget.existingCompanion?.isActive ?? false,
        createdAt: widget.existingCompanion?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (isNew) {
        await service.createCompanion(companion);
      } else {
        await service.updateCompanion(companion);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving companion: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Premium Palette
    final primaryColor = const Color(0xFF2D4A3E); // Deep Forest
    final accentColor = const Color(0xFFFF9E9E); // Soft Coral
    final surfaceColor = const Color(0xFFE8F3E8); // Calm Sage

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        title: Text(
          widget.existingCompanion == null ? 'Create Companion' : 'Edit Companion',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Glass Card for Name
              _buildGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Name', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'e.g., Rocky, Luna, SINO',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.5),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Role Selection
              Text('Role', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: CompanionRole.values.map((role) {
                  final isSelected = _selectedRole == role;
                  return ChoiceChip(
                    label: Text(role.name.toUpperCase()),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedRole = role);
                    },
                    selectedColor: accentColor,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _roleDescriptions[_selectedRole]!,
                  style: TextStyle(color: primaryColor, fontStyle: FontStyle.italic),
                ),
              ),
              const SizedBox(height: 24),

              // Personality Traits
              Text('Personality', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableTraits.map((trait) {
                  final isSelected = _selectedTraits.contains(trait);
                  return FilterChip(
                    label: Text(trait),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          if (_selectedTraits.length < 3) {
                            _selectedTraits.add(trait);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Select up to 3 traits only')),
                            );
                          }
                        } else {
                          _selectedTraits.remove(trait);
                        }
                      });
                    },
                    selectedColor: accentColor.withOpacity(0.6),
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : primaryColor,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 40),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveCompanion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Companion', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
