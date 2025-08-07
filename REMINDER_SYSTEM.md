# Reminder Manager - Sistema de Lembretes com Notificações em Background

## Funcionalidades Implementadas

### ✅ Sistema de Notificações em Background
- **Android**: Utiliza WorkManager para execução em background
- **Windows**: Suporte a notificações nativas
- Verificação automática de lembretes a cada 1 minuto
- Funcionamento mesmo com o app fechado

### ✅ Tela de Alarme Personalizada
- Interface visual chamativa (fundo vermelho com animações)
- Ícone de alarme animado pulsante
- Três opções de ação:
  - **Marcar como Concluída**: Completa a tarefa
  - **Adiar por 5 minutos**: Reagenda o lembrete
  - **Dispensar**: Remove o alarme atual

### ✅ Gerenciamento de Tarefas
- Criação de tarefas com data/hora específica
- Armazenamento local com SharedPreferences
- Atualização automática da lista de tarefas

## Como Usar

### 1. Criando uma Tarefa com Lembrete
1. Toque no botão "+" na tela principal
2. Preencha o título e descrição da tarefa
3. Toque em "Select Date & Time" para escolher quando quer ser lembrado
4. Selecione a data e hora desejada
5. Toque em "Create"

### 2. Funcionamento dos Lembretes
- O sistema verifica automaticamente a cada minuto se há tarefas para serem lembradas
- Quando o horário da tarefa chegar, você receberá:
  - **Android**: Notificação push com ações diretas
  - **Windows**: Notificação do sistema
  - **Ambos**: Tela de alarme quando o app estiver aberto

### 3. Gerenciando Alarmes
Quando um alarme aparecer, você pode:
- **Marcar como Concluída**: A tarefa será marcada como finalizada
- **Adiar 5 minutos**: O lembrete será reagendado para 5 minutos no futuro
- **Dispensar**: Remove apenas este alarme, mas mantém a tarefa

## Configuração para Android

### Permissões Necessárias
O app solicita automaticamente as seguintes permissões:
- `RECEIVE_BOOT_COMPLETED`: Para reiniciar o serviço após reinicialização
- `WAKE_LOCK`: Para manter o serviço ativo
- `VIBRATE`: Para vibração nas notificações
- `USE_EXACT_ALARM`: Para alarmes precisos
- `SCHEDULE_EXACT_ALARM`: Para agendamento de alarmes
- `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`: Para evitar que o sistema mate o app
- `POST_NOTIFICATIONS`: Para exibir notificações

### Configuração de Bateria
Para garantir que os lembretes funcionem corretamente:
1. Vá em Configurações > Bateria > Otimização de Bateria
2. Encontre "Reminder Manager" na lista
3. Selecione "Não otimizar"

## Configuração para Windows

### Funcionamento em Background
- O app utiliza um timer interno para verificar lembretes
- Notificações aparecem como toast notifications do Windows 10/11
- O app pode ficar minimizado na bandeja do sistema

## Estrutura do Projeto

```
lib/
├── data/
│   ├── services/
│   │   ├── notification_service.dart      # Gerencia notificações
│   │   ├── background_service.dart        # Serviço em background
│   │   ├── alarm_service.dart             # Gerencia alarmes pendentes
│   │   └── windows_notification_service.dart # Notificações Windows
│   └── repositories/
│       └── local_todo_repository.dart     # Armazenamento local
├── domain/
│   └── models/
│       └── todo.dart                      # Modelo de tarefa
├── presentation/
│   ├── screens/
│   │   ├── todo_list/                     # Tela principal
│   │   └── task_alarm/                    # Tela de alarme
│   └── widgets/
│       └── create_todo_modal/             # Modal de criação
└── main.dart                              # Inicialização do app
```

## Dependências Principais

- `workmanager`: Execução em background
- `flutter_local_notifications`: Notificações push
- `permission_handler`: Gerenciamento de permissões
- `go_router`: Navegação entre telas
- `shared_preferences`: Armazenamento local
- `flutter_riverpod`: Gerenciamento de estado

## Compilação

### Android
```bash
flutter build apk --release
```

### Windows
```bash
flutter build windows --release
```

## Troubleshooting

### Lembretes não funcionam no Android
1. Verifique se as permissões foram concedidas
2. Desative a otimização de bateria para o app
3. Certifique-se de que o "Modo Não Perturbe" não está bloqueando as notificações

### App não mostra notificações no Windows
1. Verifique se as notificações estão habilitadas nas configurações do Windows
2. Certifique-se de que o app tem permissão para mostrar notificações

### Alarmes não aparecem
1. Verifique se a data/hora foi configurada corretamente
2. Certifique-se de que a tarefa não foi marcada como concluída
3. Verifique se o serviço em background está rodando

## Próximas Melhorias Possíveis

- [ ] Suporte a lembretes recorrentes (diário, semanal, mensal)
- [ ] Sincronização em nuvem
- [ ] Categorias de tarefas
- [ ] Diferentes tipos de alarme (som, vibração, etc.)
- [ ] Widget para a tela inicial
- [ ] Estatísticas de produtividade
