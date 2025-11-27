import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import '../components/mini_player.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouter.of(context).routeInformationProvider.value.uri.toString();
    if (location.startsWith('/search')) return 1;
    if (location.startsWith('/library')) return 2;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.goNamed('home');
        break;
      case 1:
        context.goNamed('search');
        break;
      case 2:
        context.goNamed('library');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final indexAndColour = _getSelectedIndex(context);
    final currentIndex = indexAndColour == 3 ? 0 : indexAndColour;
    final itemColour = indexAndColour == 3 ? Colors.grey : Colors.cyanAccent;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const MiniPlayer(),
        BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: HeroIcon(HeroIcons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: HeroIcon(HeroIcons.magnifyingGlass),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: HeroIcon(HeroIcons.bookOpen),
              label: 'Library',
            ),
          ],
          currentIndex: currentIndex,
          selectedItemColor: itemColour,
          unselectedItemColor: Colors.grey,
          onTap: (index) => _onItemTapped(context, index),
        ),
      ],
    );
  }
}
