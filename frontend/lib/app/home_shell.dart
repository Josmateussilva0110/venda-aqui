import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/routing/app_routes.dart';
import '../core/theme/app_breakpoints.dart';
import '../core/theme/theme_context.dart';
import '../l10n/app_localizations.dart';

/// Navegação principal: barra inferior no celular, trilho lateral em telas largas.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  static const _tabs = [AppRoutes.home, AppRoutes.stock];

  int get _selectedIndex {
    final index = _tabs.indexWhere(location.startsWith);
    return index < 0 ? 0 : index;
  }

  void _select(BuildContext context, int index) => context.go(_tabs[index]);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final destinations = [
      (label: l10n.navHome, icon: Icons.home_outlined, selectedIcon: Icons.home_rounded),
      (label: l10n.navStock, icon: Icons.inventory_2_outlined, selectedIcon: Icons.inventory_2_rounded),
    ];

    if (context.screenSize == ScreenSize.expanded) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              right: false,
              child: NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) => _select(context, index),
                labelType: NavigationRailLabelType.all,
                groupAlignment: -0.8,
                destinations: [
                  for (final item in destinations)
                    NavigationRailDestination(icon: Icon(item.icon), selectedIcon: Icon(item.selectedIcon), label: Text(item.label)),
                ],
              ),
            ),
            VerticalDivider(width: 1, color: context.colors.divider),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(context.radius.sheet - 2)),
          boxShadow: [BoxShadow(color: context.colors.shadow.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, -6))],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) => _select(context, index),
          backgroundColor: Colors.transparent,
          destinations: [
            for (final item in destinations)
              NavigationDestination(icon: Icon(item.icon), selectedIcon: Icon(item.selectedIcon), label: item.label),
          ],
        ),
      ),
    );
  }
}
