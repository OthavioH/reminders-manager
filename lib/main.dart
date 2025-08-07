import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reminder_manager/presentation/routes/app_router.dart';
import 'package:reminder_manager/data/services/background_service.dart';
import 'package:reminder_manager/data/services/windows_background_service.dart';
import 'package:reminder_manager/data/services/notification_service.dart';
import 'package:reminder_manager/data/services/alarm_service.dart';
import 'package:window_manager/window_manager.dart';
import 'package:tray_manager/tray_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o window manager no Windows
  if (Platform.isWindows) {
    await windowManager.ensureInitialized();
    
    final windowOptions = const WindowOptions(
      size: Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );
    
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  // Inicializa os serviços de background e notificações
  await NotificationService().initialize();
  
  if (Platform.isAndroid) {
    BackgroundService.initialize();
    BackgroundService.startTaskChecker();
  } else if (Platform.isWindows) {
    WindowsBackgroundService.startTaskChecker();
  }

  runApp(const ProviderScope(child: MyApp()));
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver, WindowListener, TrayListener {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPendingAlarms();
    if (Platform.isWindows) {
      windowManager.addListener(this);
      trayManager.addListener(this);
      _setupWindowBehavior();
      _initSystemTray();
    }
  }

  Future<void> _setupWindowBehavior() async {
    // Configura para interceptar o fechamento da janela
    await windowManager.setPreventClose(true);
  }

  Future<void> _initSystemTray() async {
    try {
      await trayManager.setIcon(
        'assets/app_icon.ico',
      );
      
      await trayManager.setToolTip('Reminder Manager');
      
      // Cria o menu do system tray
      final List<MenuItem> items = [
        MenuItem(
          key: 'show_window',
          label: 'Show App',
        ),
        MenuItem(
          key: 'hide_window', 
          label: 'Hide App',
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'exit_app',
          label: 'Exit',
        ),
      ];
      
      await trayManager.setContextMenu(Menu(items: items));
      
      log('System tray initialized');
    } catch (e) {
      log('Failed to initialize system tray: $e');
    }
  }

  // TrayListener methods
  @override
  void onTrayIconMouseDown() {
    _toggleWindow();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'show_window':
        _showWindow();
        break;
      case 'hide_window':
        windowManager.hide();
        break;
      case 'exit_app':
        _exitApp();
        break;
    }
  }

  void _showWindow() async {
    await windowManager.show();
    await windowManager.focus();
  }

  void _toggleWindow() async {
    if (await windowManager.isVisible()) {
      await windowManager.hide();
    } else {
      _showWindow();
    }
  }

  void _exitApp() {
    WindowsBackgroundService.stopTaskChecker();
    exit(0);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (Platform.isWindows) {
      windowManager.removeListener(this);
      trayManager.removeListener(this);
    }
    super.dispose();
  }

  @override
  void onWindowClose() async {
    final bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose && Platform.isWindows ) {
      showDialog(
        context: navigatorKey.currentContext!,
        builder: (_) {
          return AlertDialog(
            title: const Text('Confirmação'),
            content: const Text(
              'Deseja minimizar para a bandeja do sistema ou fechar completamente o aplicativo?\n\n'
              'Minimizando para a bandeja do sistema, os lembretes continuarão funcionando e você pode acessar o app pelo ícone na bandeja.',
            ),
            actions: [
              TextButton(
                child: const Text('Minimizar para Bandeja'),
                onPressed: () {
                  navigatorKey.currentState?.pop();
                  windowManager.hide();
                },
              ),
              TextButton(
                child: const Text('Fechar Completamente'),
                onPressed: () {
                  Navigator.of(context).pop();
                  WindowsBackgroundService.stopTaskChecker();
                  windowManager.destroy();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (state == AppLifecycleState.resumed) {
      // Quando o app voltar ao foreground, verifica alarmes pendentes
      _checkPendingAlarms();
    }
  }

  Future<void> _checkPendingAlarms() async {
    try {
      final alarmService = ref.read(alarmServiceProvider);
      final pendingTask = await alarmService.checkPendingAlarm();
      
      if (pendingTask != null) {
        // Navega para a tela de alarme
        navigatorKey.currentState?.pushNamed(
          AppRouter.alarmRoute,
          arguments: pendingTask,
        );
      }
    } catch (e) {
      log('Error checking pending alarms: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Reminder Manager',
      initialRoute: AppRouter.initialRoute,
      routes: AppRouter.routes,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
          ),
        ),  
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
          ),
        ), 
      ),
      themeMode: ThemeMode.system,
    );
  }
}
