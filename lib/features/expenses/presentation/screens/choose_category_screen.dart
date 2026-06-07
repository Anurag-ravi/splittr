import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:splittr/core/constants/expense_categories.dart';
import 'package:splittr/core/utils/haptics.dart';
import 'package:splittr/core/widgets/category_icon.dart';
import 'package:splittr/shared/widgets/neon_glow.dart';

class ChooseCategoryScreen extends StatelessWidget {
  const ChooseCategoryScreen({
    super.key,
    required this.current,
  });

  final String current;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // =====================
            // HEADER
            // =====================

            Padding(
              padding: const EdgeInsets.fromLTRB(
                10,
                10,
                10,
                10,
              ),
              child: Row(
                children: [
                  _topActionButton(
                    context,
                    icon: Icons.close_rounded,
                    onTap: () {
                      Navigator.pop(
                        context,
                        current,
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Choose Category',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        Text(
                          'Select expense type',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color:
                                theme.textTheme.bodyMedium?.color?.withOpacity(
                              0.68,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // =====================
            // LIST
            // =====================

            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  10,
                  8,
                  10,
                  24,
                ),
                itemCount: ExpenseCategories.all.length,
                itemBuilder: (context, index) {
                  final cat = ExpenseCategories.all[index];

                  final selected = cat == current;

                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Haptics.medium();

                        Navigator.pop(
                          context,
                          cat,
                        );
                      },
                      child: NeonGlow(
                        color:
                            selected ? colorScheme.primary : Colors.transparent,
                        radius: 28,
                        spread: -8,
                        glowOpacity: 0.14,
                        child: Container(
                          padding: const EdgeInsets.all(
                            10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              28,
                            ),
                            color: colorScheme.surface.withOpacity(
                              theme.brightness == Brightness.dark ? 0.92 : 0.97,
                            ),
                            border: Border.all(
                              color: selected
                                  ? colorScheme.primary.withOpacity(
                                      0.18,
                                    )
                                  : colorScheme.outline.withOpacity(
                                      0.08,
                                    ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: selected
                                    ? colorScheme.primary.withOpacity(
                                        0.10,
                                      )
                                    : Colors.black.withOpacity(
                                        0.04,
                                      ),
                                blurRadius: 28,
                                spreadRadius: -10,
                                offset: const Offset(
                                  0,
                                  14,
                                ),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // =================
                              // ICON
                              // =================

                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    18,
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      (selected
                                              ? colorScheme.primary
                                              : colorScheme.primary)
                                          .withOpacity(
                                        0.18,
                                      ),
                                      (selected
                                              ? colorScheme.primary
                                              : colorScheme.primary)
                                          .withOpacity(
                                        0.05,
                                      ),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: colorScheme.primary.withOpacity(
                                      0.10,
                                    ),
                                  ),
                                ),
                                child: CategoryIcon(
                                  category: cat,
                                  entityType: 'expense',
                                ),
                              ),

                              const SizedBox(
                                width: 16,
                              ),

                              // =================
                              // TEXT
                              // =================

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ExpenseCategories.labelOf(
                                        cat,
                                      ),
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    Text(
                                      selected
                                          ? 'Currently selected'
                                          : 'Tap to choose',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: selected
                                            ? colorScheme.primary
                                            : theme.textTheme.bodyMedium?.color
                                                ?.withOpacity(
                                                0.64,
                                              ),
                                        fontWeight: selected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(
                                width: 12,
                              ),

                              AnimatedContainer(
                                duration: const Duration(
                                  milliseconds: 220,
                                ),
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: selected
                                      ? colorScheme.primary
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: selected
                                        ? colorScheme.primary
                                        : colorScheme.outline.withOpacity(
                                            0.22,
                                          ),
                                  ),
                                ),
                                child: selected
                                    ? Icon(
                                        Icons.check_rounded,
                                        color: colorScheme.onPrimary,
                                        size: 18,
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================
  // TOP ACTION BUTTON
  // =====================

  Widget _topActionButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          16,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 10,
            sigmaY: 10,
          ),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.surface.withOpacity(
                0.72,
              ),
              borderRadius: BorderRadius.circular(
                16,
              ),
              border: Border.all(
                color: colorScheme.primary.withOpacity(
                  0.08,
                ),
              ),
            ),
            child: Icon(
              icon,
              color: colorScheme.onSurface,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
