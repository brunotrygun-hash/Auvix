# AUVIX — V1

Aplicativo Flutter inicial para acompanhamento de investimentos.

## O que já funciona
- Tela de login em modo demonstração.
- Dashboard "Meus Ativos".
- BHIA3 pré-cadastrada para demonstração.
- Tela de adicionar ativo com quantidade e preço médio.
- Cálculo de valor investido, valor atual, lucro/prejuízo e rentabilidade.
- Tela de detalhes da BHIA3 com gráfico ilustrativo.
- Navegação básica entre telas.

## Importante
Os preços são **dados demonstrativos**, não cotações reais da B3. A integração de Market Data será feita na próxima etapa.

## Como executar
1. Instale Flutter 3.x e Android Studio.
2. No terminal, entre nesta pasta.
3. Execute:

```bash
flutter pub get
flutter run
```

Para gerar APK de teste:

```bash
flutter build apk --debug
```

O APK será criado em `build/app/outputs/flutter-apk/app-debug.apk`.

## Próximas etapas
1. Persistência local/SQLite ou Supabase.
2. Cadastro e autenticação reais.
3. Integração com provedor de Market Data.
4. Atualização de cotação.
5. Alertas de preço.
6. Backend seguro e publicação.
