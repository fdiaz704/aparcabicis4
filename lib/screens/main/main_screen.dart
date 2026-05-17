import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/reservations_provider.dart';
import '../../utils/constants.dart';
import '../../utils/platform_icons.dart';
import '../../services/navigation_service.dart';
import 'bike_stations_list.dart';
import 'bike_stations_map.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final List<Widget> _screens = [
    const _StationsTabView(),
    const HistoryScreen(),
    const ProfileScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<ReservationsProvider>(
      builder: (context, reservationsProvider, child) {
        // If there's an active reservation, navigate to active reservation screen
        if (reservationsProvider.hasActiveReservation) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            NavigationService.pushNamedAndClearStack(AppRoutes.activeReservation);
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Icon(PlatformIcons.bike),
                const SizedBox(width: 8),
                Text(
                  AppConstants.appName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              if (reservationsProvider.hasActiveReservation)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.reserved,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Reserva activa',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              IconButton(
                onPressed: () async {
                  final authProvider = context.read<AuthProvider>();
                  await authProvider.logout();
                  if (mounted) {
                    NavigationService.pushNamedAndClearStack(AppRoutes.login);
                  }
                },
                icon: Icon(PlatformIcons.close),
                tooltip: 'Cerrar sesión',
              ),
            ],
          ),
          body: _screens[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() => _currentIndex = index);
            },
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: Icon(PlatformIcons.bike),
                label: 'Estaciones',
              ),
              BottomNavigationBarItem(
                icon: Icon(PlatformIcons.history),
                label: 'Historial',
              ),
              BottomNavigationBarItem(
                icon: Icon(PlatformIcons.profileTab),
                activeIcon: Icon(PlatformIcons.profileTabFilled),
                label: 'Perfil',
              ),
              BottomNavigationBarItem(
                icon: Icon(PlatformIcons.settingsTab),
                activeIcon: Icon(PlatformIcons.settingsTabFilled),
                label: 'Ajustes',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StationsTabView extends StatefulWidget {
  const _StationsTabView();

  @override
  State<_StationsTabView> createState() => _StationsTabViewState();
}

class _StationsTabViewState extends State<_StationsTabView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Bar
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(
                icon: Icon(PlatformIcons.menu),
                text: 'Lista',
              ),
              Tab(
                icon: Icon(PlatformIcons.location),
                text: 'Mapa',
              ),
            ],
          ),
        ),
        
        // Tab Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              BikeStationsList(),
              BikeStationsMap(),
            ],
          ),
        ),
      ],
    );
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PlatformIcons.history,
            size: 64,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          const Text(
            'Historial de Reservas',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Aquí se mostrará el historial\nde tus reservas anteriores',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PlatformIcons.user,
            size: 64,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          const Text(
            'Perfil de Usuario',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          if (authProvider.user != null)
            Text(
              authProvider.user!.email,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          const SizedBox(height: 16),
          const Text(
            'Aquí se mostrará tu perfil\ny estadísticas de uso',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PlatformIcons.settings,
            size: 64,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          const Text(
            'Configuración',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Aquí se mostrarán las opciones\nde configuración y ayuda',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
