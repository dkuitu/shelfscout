import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/category.dart';
import '../../providers/category_provider.dart';
import '../../providers/item_provider.dart';

class SuggestItemScreen extends StatefulWidget {
  const SuggestItemScreen({super.key});

  @override
  State<SuggestItemScreen> createState() => _SuggestItemScreenState();
}

class _SuggestItemScreenState extends State<SuggestItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _unitController = TextEditingController();
  Category? _selectedCategory;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<CategoryProvider>().loadCategories());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final itemProvider = context.read<ItemProvider>();
    final item = await itemProvider.createItem(
      name: _nameController.text.trim(),
      categoryId: _selectedCategory!.id,
      unit: _unitController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (item != null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.surfaceCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.hourglass_top,
                  color: AppTheme.goldColor, size: 24),
              const SizedBox(width: 8),
              Text(
                'ITEM SUGGESTED',
                style: GoogleFonts.orbitron(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.goldColor,
                ),
              ),
            ],
          ),
          content: Text(
            '"${item.name}" is now awaiting community approval. '
            'Once 3 scouts approve it, it will become available for price submissions.',
            style: GoogleFonts.rajdhani(
              fontSize: 15,
              color: Colors.white70,
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('GOT IT'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(itemProvider.error ?? 'Failed to suggest item'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final catProvider = context.watch<CategoryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SUGGEST ITEM',
          style: GoogleFonts.orbitron(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline,
                        color: AppTheme.goldColor, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Can\'t find a product? Suggest it here. '
                        'Once 3 scouts approve, it goes live.',
                        style: GoogleFonts.rajdhani(
                          fontSize: 13,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Item Name',
                  prefixIcon: const Icon(Icons.inventory_2_outlined),
                  hintText: 'e.g. Oat Milk (1L)',
                  labelStyle: GoogleFonts.rajdhani(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Name required';
                  if (v.trim().length < 2) return 'At least 2 characters';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category selector
              GestureDetector(
                onTap: () => _showCategoryPicker(context, catProvider),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedCategory != null
                          ? AppTheme.conquestGreen.withAlpha(60)
                          : Colors.white12,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _selectedCategory?.iconData ?? Icons.category,
                        color: _selectedCategory?.colorValue ?? Colors.white38,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedCategory?.name ?? 'Select Category',
                          style: GoogleFonts.rajdhani(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _selectedCategory != null
                                ? Colors.white
                                : Colors.white54,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.white24),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _unitController,
                decoration: InputDecoration(
                  labelText: 'Unit',
                  prefixIcon: const Icon(Icons.straighten),
                  hintText: 'e.g. 1L, kg, loaf, dozen',
                  labelStyle: GoogleFonts.rajdhani(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Unit required';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.greenGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.conquestGreen.withAlpha(50),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: FilledButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  icon: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black54,
                          ),
                        )
                      : const Icon(Icons.send, color: Colors.black87),
                  label: Text(
                    _isSubmitting ? 'SUGGESTING...' : 'SUGGEST ITEM',
                    style: GoogleFonts.orbitron(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoryPicker(BuildContext context, CategoryProvider catProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        if (catProvider.isLoading) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.category,
                      color: AppTheme.conquestGreen, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'SELECT CATEGORY',
                    style: GoogleFonts.orbitron(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white54,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10, height: 1),
            ...catProvider.categories.map((cat) => ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cat.colorValue.withAlpha(25),
                    ),
                    child: Icon(cat.iconData,
                        color: cat.colorValue, size: 18),
                  ),
                  title: Text(
                    cat.name,
                    style: GoogleFonts.rajdhani(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  trailing: _selectedCategory?.id == cat.id
                      ? Icon(Icons.check_circle,
                          color: AppTheme.conquestGreen, size: 20)
                      : null,
                  onTap: () {
                    setState(() => _selectedCategory = cat);
                    Navigator.pop(ctx);
                  },
                )),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}
