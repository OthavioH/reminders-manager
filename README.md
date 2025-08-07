# Reminder Manager - Sistema de Alarmes em Background

Um aplicativo Flutter que implementa um sistema completo de lembretes com notificações em background para Windows e Android.

## 🏗️ Arquitetura do Sistema de Alarmes

### Visão Geral
O sistema de alarmes foi construído seguindo uma arquitetura em camadas, garantindo separação de responsabilidades e funcionamento confiável em background.

### Componentes Principais

#### 1. **Background Service** (`lib/data/services/background_service.dart`)
**Responsabilidade**: Execução contínua em background para verificar lembretes.

```dart
class BackgroundService {
  static void initialize() {
    Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  }

  static void startTaskChecker() {
    Workmanager().registerPeriodicTask(
      'taskChecker',
      'taskChecker',
      frequency: const Duration(minutes: 1), // Verifica a cada 1 minuto
    );
  }
}
```

**Como funciona**:
- Utiliza `WorkManager` (Android) para execução periódica
- Verifica tarefas a cada 1 minuto, mesmo com app fechado
- Executa no isolate separado para não interferir na UI
- Persiste após reinicialização do dispositivo

**Fluxo de verificação**:
1. Busca todas as tarefas salvas no `SharedPreferences`
2. Compara horário atual com `reminderDate` de cada tarefa
3. Se diferença ≤ 1 minuto e tarefa não concluída → dispara alarme
4. Marca alarme como "mostrado" para evitar duplicatas

#### 2. **Notification Service** (`lib/data/services/notification_service.dart`)
**Responsabilidade**: Gerenciar notificações multiplataforma.

```dart
class NotificationService {
  Future<void> showTaskAlarmNotification({
    required String taskId,
    required String title,
    required String description,
  }) async {
    if (Platform.isWindows) {
      await WindowsNotificationService.showTaskNotification(...);
    } else {
      // Android notifications com ações diretas
      const androidDetails = AndroidNotificationDetails(
        'task_alarms',
        'Task Alarms',
        category: AndroidNotificationCategory.alarm,
        fullScreenIntent: true,
        actions: [
          AndroidNotificationAction('mark_done', 'Marcar como Concluída'),
          AndroidNotificationAction('snooze', 'Adiar 5min'),
        ],
      );
    }
  }
}
```

**Características**:
- **Android**: Notificações com `fullScreenIntent` para aparecer sobre outras apps
- **Windows**: Toast notifications nativas do sistema
- Ações diretas nas notificações (Concluir/Adiar)
- Gerenciamento automático de permissões

#### 3. **Alarm Service** (`lib/data/services/alarm_service.dart`)
**Responsabilidade**: Coordenar estado de alarmes pendentes.

```dart
class AlarmService {
  Future<Todo?> checkPendingAlarm() async {
    final prefs = await SharedPreferences.getInstance();
    final pendingTaskId = prefs.getString('pending_alarm_task');
    
    if (pendingTaskId != null) {
      await prefs.remove('pending_alarm_task'); // Remove para evitar loops
      final task = await _findTaskById(pendingTaskId);
      return task?.isCompleted == false ? task : null;
    }
    return null;
  }
}
```

**Funcionalidades**:
- Detecta quando um alarme foi disparado em background
- Gerencia transição entre background → foreground
- Previne loops infinitos de alarmes
- Sincroniza estado entre serviço background e UI

#### 4. **Task Alarm Screen** (`lib/presentation/screens/task_alarm/task_alarm_screen.dart`)
**Responsabilidade**: Interface visual do alarme.

```dart
class TaskAlarmScreen extends ConsumerStatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade900, // Fundo vermelho chamativo
      body: Column(
        children: [
          // Ícone animado pulsante
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) => Transform.scale(
              scale: _scaleAnimation.value,
              child: Icon(Icons.alarm, size: 60),
            ),
          ),
          // Botões de ação
          ElevatedButton(onPressed: _markAsCompleted, child: Text('Concluída')),
          ElevatedButton(onPressed: _snoozeTask, child: Text('Adiar 5min')),
          OutlinedButton(onPressed: _dismissAlarm, child: Text('Dispensar')),
        ],
      ),
    );
  }
}
```

**Recursos visuais**:
- Fundo vermelho para chamar atenção
- Ícone de alarme com animação pulsante contínua
- Três ações claras: Concluir, Adiar, Dispensar
- Interface responsiva e acessível

## 🔄 Fluxo Completo do Sistema

### 1. **Criação de Tarefa com Lembrete**
```
Usuário cria tarefa → Seleciona data/hora → Salva no SharedPreferences
                                        ↓
                            BackgroundService já está rodando
```

### 2. **Verificação em Background**
```
A cada 1 minuto: BackgroundService verifica todas as tarefas
                                        ↓
            Se horário coincide → Dispara NotificationService
                                        ↓
                            Salva 'pending_alarm_task'
```

### 3. **Exibição do Alarme**
```
App em background: Mostra notificação push com ações
                                        ↓
App em foreground: MyApp detecta pending_alarm → Navega para TaskAlarmScreen
```

### 4. **Ações do Usuário**
```
Concluir → Marca task.isCompleted = true → Remove alarme
Adiar → Atualiza reminderDate + 5min → Remove alarme atual
Dispensar → Remove apenas este alarme → Mantém tarefa
```

## 🛠️ Configuração Técnica

### Dependências Principais
```yaml
dependencies:
  workmanager: ^0.5.2              # Background execution
  flutter_local_notifications: ^18.0.1  # Push notifications
  permission_handler: ^11.3.1      # Runtime permissions
  go_router: ^14.6.1              # Navigation
  shared_preferences: ^2.5.3       # Local storage
  flutter_riverpod: ^2.6.1        # State management
```

### Permissões Android
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.USE_EXACT_ALARM" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

### Inicialização no main.dart
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa serviços na ordem correta
  await NotificationService().initialize();  // Primeiro as notificações
  BackgroundService.initialize();           // Depois o background service
  BackgroundService.startTaskChecker();     // Inicia verificação periódica
  
  runApp(const ProviderScope(child: MyApp()));
}
```

## 🎯 Decisões de Design

### Por que verificar a cada 1 minuto?
- **Precisão**: Garante que lembretes não sejam perdidos
- **Bateria**: Intervalo otimizado para não drenar bateria
- **UX**: Usuário percebe o lembrete praticamente no horário exato

### Por que usar WorkManager?
- **Confiabilidade**: Mais confiável que AlarmManager para tarefas periódicas
- **Otimização**: Sistema Android gerencia automaticamente quando executar
- **Compatibilidade**: Funciona em todas as versões do Android

### Por que SharedPreferences?
- **Simplicidade**: Não requer banco de dados complexo
- **Performance**: Acesso rápido para verificações frequentes
- **Sincronização**: Mesmo storage usado pelo background service

### Por que tela de alarme separada?
- **Visibilidade**: Interface dedicada chama mais atenção
- **Ações**: Permite múltiplas ações sem sair da tela
- **Experiência**: Similar a aplicativos de alarme nativos

## 🚀 Como Executar

### Pré-requisitos
- Flutter SDK 3.8.1+
- Android SDK (para Android)
- Visual Studio Build Tools (para Windows)

### Instalação
```bash
# Clone o repositório
git clone <repository-url>
cd reminder_manager

# Instale dependências
flutter pub get

# Execute no Android
flutter run -d android

# Execute no Windows
flutter run -d windows
```

### Build para Produção
```bash
# Android APK
flutter build apk --release

# Windows executável
flutter build windows --release
```

## 📱 Compatibilidade

| Plataforma | Background Service | Notificações | Tela de Alarme |
|------------|-------------------|--------------|----------------|
| Android    | ✅ WorkManager     | ✅ Push + Ações | ✅ Full Screen |
| Windows    | ✅ Timer          | ✅ Toast       | ✅ Window Focus |
| iOS        | ⚠️ Limitado       | ✅ Push        | ✅ Foreground  |

## 🔍 Troubleshooting

### Alarmes não funcionam no Android
1. **Permissões**: Vá em Configurações > Apps > Reminder Manager > Permissões
2. **Bateria**: Desative otimização de bateria para o app
3. **Autostart**: Habilite início automático (alguns fabricantes)

### Notificações não aparecem
1. **Windows**: Verifique configurações de notificação do sistema
2. **Android**: Certifique-se que notificações do app estão habilitadas

### App "mata" em background
1. **Android**: Adicione app à lista de proteção de bateria
2. **MIUI/EMUI**: Configure para permitir atividade em background
