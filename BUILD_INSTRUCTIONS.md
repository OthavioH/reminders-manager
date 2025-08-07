# Instruções de Build - Reminder Manager

## Como buildar o aplicativo para Windows

Para buildar seu aplicativo Flutter para Windows, execute:

```cmd
flutter build windows
```

O executável será gerado em: `build\windows\x64\runner\Release\reminder_manager.exe`

## Comportamento no Windows

### ⚠️ Limitação Importante
O Flutter no Windows **NÃO** consegue executar completamente em background quando o aplicativo é fechado. Esta é uma limitação técnica do Flutter.

### ✅ Solução Implementada - System Tray
Agora o aplicativo possui funcionalidade completa de system tray (bandeja do sistema):

**Quando você tentar fechar o aplicativo:**
1. Aparece um diálogo com duas opções:
   - **Minimizar para Bandeja**: O app fica na bandeja do sistema e continua executando
   - **Fechar Completamente**: Fecha totalmente o aplicativo

**Funcionalidades da System Tray:**
- 🔵 **Ícone na bandeja**: Aparece um ícone do app na bandeja do sistema
- 🖱️ **Clique simples**: Mostra/esconde a janela do aplicativo  
- 🖱️ **Clique direito**: Abre menu com opções:
  - Show App (mostrar aplicativo)
  - Hide App (esconder aplicativo)  
  - Exit (sair completamente)

### Como usar:
1. Execute o aplicativo
2. Crie seus lembretes normalmente  
3. Quando quiser "fechar", clique no X da janela
4. Escolha "Minimizar para Bandeja" para manter os lembretes funcionando
5. **Acesse o app pela bandeja do sistema**: 
   - Clique no ícone na bandeja para mostrar/esconder
   - Clique direito no ícone para ver o menu

## Alternativas para Background Real

Se você precisar que o app funcione mesmo quando completamente fechado, considere:

1. **Serviço Windows**: Criar um serviço Windows separado (requer conhecimento avançado)
2. **Agendador de Tarefas**: Usar o Task Scheduler do Windows
3. **Aplicação Híbrida**: Combinar Flutter com um serviço nativo Windows

## Como executar em modo de desenvolvimento

```cmd
flutter run -d windows
```

## Como instalar dependências

```cmd
flutter pub get
```

## Requisitos do Sistema

- Windows 10 ou superior
- Flutter SDK configurado para Windows
- Visual Studio 2019 ou superior (para builds)
