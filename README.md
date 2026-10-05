# GovOnRoot

Como fazer o app **gov.br** abrir num Android com **root (Magisk)**, sem precisar tirar o root.

Este guia descreve o que funcionou num aparelho real em outubro de 2026. Ele foi escrito para quem já tem o Magisk instalado e sabe instalar um módulo, mas não precisa entender como cada peça funciona por dentro.

> **Aviso.** Esconder o root é um jogo de gato e rato: o que funciona hoje pode parar de funcionar numa atualização do app ou do Google. Faça por sua conta e risco. Nada aqui altera o gov.br nem burla a sua conta. Só impede que o app enxergue o root do seu próprio aparelho.

---

## Sumário

1. [O aparelho onde isso foi testado](#1-o-aparelho-onde-isso-foi-testado)
2. [Por que o gov.br não abre com root](#2-por-que-o-govbr-não-abre-com-root)
3. [O que você vai precisar](#3-o-que-você-vai-precisar)
4. [Passo a passo](#4-passo-a-passo)
5. [Testando](#5-testando)
6. [Problemas comuns](#6-problemas-comuns)
7. [O que cada peça faz](#7-o-que-cada-peça-faz)
8. [Como desfazer](#8-como-desfazer)
9. [Avançado: achar uma "impressão" que passe na integridade do Google](#9-avançado-achar-uma-impressão-que-passe-na-integridade-do-google)

---

## 1. O aparelho onde isso foi testado

| Item | Versão |
|---|---|
| Aparelho | Samsung Galaxy A12 (SM-A125M) |
| Android | 12 (One UI, firmware de fábrica) |
| Root | Magisk 30.7 com **Zygisk** ligado |
| gov.br | 3.8.9 (instalado pela Play Store) |
| Data | 05/10/2026 |

Em outros aparelhos e versões do Android o caminho é o mesmo, mas os detalhes podem mudar, principalmente a parte da integridade do Google (passo 4.6).

---

## 2. Por que o gov.br não abre com root

Olhando por dentro do app, o gov.br usa duas bibliotecas de segurança:

- **safe_device**: verifica se o aparelho tem root, se é um emulador e se o modo desenvolvedor ou a depuração USB estão ligados.
- **RootBeer**: procura sinais de root, como o arquivo `su`, apps de root instalados e partições do sistema graváveis.

**Pegadinha importante:** quando *qualquer* uma dessas verificações falha, o gov.br mostra a mesma mensagem:

> "Seu dispositivo está em modo desenvolvedor, para sua segurança o app gov.br não pode ser executado neste modo."

Ou seja, **essa mensagem aparece mesmo com o modo desenvolvedor desligado**. No nosso caso, o que disparava a mensagem era o root, não as opções de desenvolvedor.

Além disso, o gov.br **precisa ter sido instalado pela Play Store**. Instalado por outra loja (Aurora, APKPure...), ele abre a Play Store e pede para instalar de lá.

---

## 3. O que você vai precisar

- **Magisk** instalado, com **Zygisk ligado** (Magisk → Configurações → Zygisk).
- **Play Store ativa** e logada numa conta Google. Se você desativou a Play Store para economizar memória, veja como deixá-la "enxuta" no passo 4.4.
- Os módulos abaixo, baixados das páginas oficiais (sempre o arquivo `.zip` da versão mais recente):

| Módulo | Para que serve | Onde baixar | Versão testada |
|---|---|---|---|
| **Shamiko** | Esconde o root dos apps escolhidos | [LSPosed/LSPosed.github.io › Releases](https://github.com/LSPosed/LSPosed.github.io/releases) | v1.2.5 |
| **HMA-OSS** (versão *ZYGISK*) | Esconde do app a lista de apps "perigosos" e o modo desenvolvedor | [frknkrc44/HMA-OSS › Releases](https://github.com/frknkrc44/HMA-OSS/releases) | oss-173 |
| **Play Integrity Fork** | Faz o aparelho passar na verificação de integridade do Google | [osm0sis/PlayIntegrityFork › Releases](https://github.com/osm0sis/PlayIntegrityFork/releases) | v18 |
| **Tricky Store** | Esconde o bootloader desbloqueado na verificação de chaves | [5ec1cff/TrickyStore › Releases](https://github.com/5ec1cff/TrickyStore/releases) | 1.4.1 |

Opcional, mas útil para testar:

- **SPIC – Simple Play Integrity Checker** ([herzhenr/spic-android › Releases](https://github.com/herzhenr/spic-android/releases)): mostra se o aparelho passa na integridade do Google.

> **Sobre o que é realmente obrigatório:** esta foi a combinação que funcionou, mas não testei cada peça isoladamente. Pelo que vimos, o essencial para o gov.br foi: instalar pela **Play Store**, **Shamiko com o gov.br na DenyList** e **HMA-OSS**. O Play Integrity Fork e o Tricky Store foram instalados juntos e provavelmente vão ser exigidos por outros apps do governo e de bancos, então vale já deixar prontos.

---

## 4. Passo a passo

### 4.1 Configurar o Magisk

1. Abra o **Magisk** → **Configurações** (engrenagem).
2. Deixe **Zygisk** **ligado**.
3. Deixe **"Aplicar DenyList" (Enforce DenyList)** **DESLIGADO**.
   > Isso é importante: quem esconde o root agora é o Shamiko. Se você ligar o "Aplicar DenyList", o Shamiko para de funcionar.
4. Recomendado: na mesma tela, use **"Ocultar o app Magisk"**. Ele reinstala o Magisk com um nome e um ícone aleatórios, para os apps não acharem o Magisk pelo nome.

### 4.2 Instalar os módulos

1. Magisk → aba **Módulos** → **Instalar do armazenamento**.
2. Instale, um de cada vez, os quatro `.zip`: **Shamiko**, **HMA-OSS (ZYGISK)**, **Play Integrity Fork** e **Tricky Store**.
3. **Reinicie** o celular.
4. Depois de reiniciar, volte na aba Módulos. A descrição do Shamiko deve dizer algo como *"Shamiko is working as blacklist mode"*.

O HMA-OSS instala junto um app chamado **HMA-OSS** (ícone próprio), que vamos usar no passo 4.5.

### 4.3 Instalar o gov.br pela Play Store

1. Se o gov.br foi instalado por outra loja, **desinstale**.
2. Instale pela **Play Store**.
3. **Ainda não abra o app.** Termine os próximos passos primeiro.

### 4.4 (Opcional) Play Store "enxuta"

Se você só mantém a Play Store por causa desses apps e não quer que ela fique rodando em segundo plano nem se atualizando sozinha, rode no **Termux** (ou outro terminal com root):

```sh
su -c "pm enable com.android.vending"                                        # garante que está ativa
su -c "am set-standby-bucket com.android.vending restricted"                 # quase não roda em segundo plano
su -c "cmd appops set com.android.vending RUN_ANY_IN_BACKGROUND ignore"      # proíbe tarefas em segundo plano
su -c "cmd appops set com.android.vending RUN_IN_BACKGROUND ignore"
su -c "pm disable com.android.vending/.AssetBrowserActivity"                 # some o ícone do launcher
```

A Play Store continua respondendo quando um app pede a verificação de integridade, que é o que importa aqui. Para desfazer o ícone: `su -c "pm enable com.android.vending/.AssetBrowserActivity"`.

### 4.5 Esconder o root do gov.br

#### a) Colocar o gov.br na DenyList (para o Shamiko)

1. Magisk → **Configurações** → **Configurar DenyList**.
2. No menu (⋮), ative **"Mostrar apps do sistema"** se precisar, e procure **gov.br**.
3. Marque o **gov.br** (toque no nome e marque todos os processos dele).

Ou pelo terminal:

```sh
su -c "magisk --denylist add br.gov.meugovbr"
```

> **Não** coloque o **Google Play Services** nem a **Play Store** na DenyList. Isso impede o Play Integrity Fork de funcionar.

#### b) Configurar o HMA-OSS

1. Abra o app **HMA-OSS**.
2. Vá em **Gerenciar apps** → toque em **gov.br**.
3. Ligue **Ativar ocultação**.
4. Deixe o modo em **Lista Negra** (o padrão).
5. Em **Escolher perfil**, marque:
   - Gerenciadores de root/Apps de root
   - Módulos Lsposed/Xposed
   - Apps suspeitos
   - Apps Shizuku/Dhizuku
   - Apps detectores/verificadores
   - Apps de ROM personalizada
6. Em **Perfis de configurações**, marque **Opções de desenvolvedor**.
   > Isso faz o gov.br enxergar o modo desenvolvedor e a depuração USB/sem fio como **desligados**, mesmo que estejam ligados. Assim você pode continuar usando o ADB sem fio.
7. Em **Editar lista** (apps extras a esconder), marque os apps que denunciam root e que os perfis não pegaram. No nosso caso:
   - o **Magisk** (com o nome aleatório, se você o ocultou; veja abaixo como descobrir o nome)
   - **Termux**
   - **Shizuku**
   - o próprio **HMA-OSS**
   - apps de teste de integridade (SPIC etc.)
   - módulos Xposed que você tenha (WaEnhancer, por exemplo)
   - gerenciadores de arquivos com root (MiXplorer, ZArchiver...)
8. **Reinicie** o celular.

Para descobrir o nome do pacote do Magisk oculto:

```sh
su -c "magisk --sqlite \"SELECT value FROM strings WHERE key='requester'\""
```

Para usuários avançados, a pasta [`extras/`](extras/) traz o `config.json` que foi usado, para quem preferir editar o arquivo direto em vez de usar o app.

#### c) Colocar o gov.br no Tricky Store

O Tricky Store guarda a lista de apps em `/data/adb/tricky_store/target.txt`. Adicione o gov.br:

```sh
su -c "echo br.gov.meugovbr >> /data/adb/tricky_store/target.txt"
```

### 4.6 Integridade do Google (Play Integrity Fork)

O Play Integrity Fork precisa de uma **"impressão digital" de aparelho** (o arquivo `custom.pif.prop`) para funcionar. Sem ela, o módulo não faz nada.

1. Instale o **SPIC**, abra, escolha **Nonce Creation: local** e **Check Verdict: local**, e toque em **Make Play Integrity Request**.
2. Veja o resultado em **Device recognition verdict**:
   - `MEETS_BASIC_INTEGRITY` sozinho: passa só no básico.
   - `MEETS_DEVICE_INTEGRITY` aparece: passa no nível "aparelho", que é o que a maioria dos apps exige.
3. Se só aparecer o BASIC, é preciso achar uma impressão que funcione. Veja a [seção 9](#9-avançado-achar-uma-impressão-que-passe-na-integridade-do-google).

> No Android 12 ou mais antigo ainda dá para passar no DEVICE com uma impressão de aparelho **antigo** (lançado com Android 5 a 7). No Android 13 ou mais novo isso ficou bem mais difícil e exige um "keybox" válido no Tricky Store, o que está fora do escopo deste guia.

---

## 5. Testando

1. Feche o gov.br de vez: arraste-o para fora dos apps recentes, ou vá em Configurações → Apps → gov.br → **Forçar parada**.
2. Abra o gov.br.
3. Se abrir normalmente, pronto. 🎉

---

## 6. Problemas comuns

**"Seu dispositivo está em modo desenvolvedor…" mesmo com o modo desenvolvedor desligado**
É a mensagem genérica do gov.br para qualquer detecção. Confira:
- se o gov.br está **marcado na DenyList** (veja o próximo item);
- se o **"Aplicar DenyList" está DESLIGADO** no Magisk;
- se o **Shamiko** aparece como "working" na aba Módulos;
- se a configuração do HMA-OSS para o gov.br está com **Ativar ocultação** ligado.

**Reinstalei ou atualizei o gov.br e ele voltou a reclamar**
⚠️ **Quando um app é desinstalado, o Magisk o tira da DenyList automaticamente.** Depois de reinstalar, marque o gov.br de novo na DenyList (passo 4.5a) e reabra o app. Foi exatamente isso que aconteceu aqui. Atualizar pela Play Store **sem** desinstalar não tira o app da lista.

**O gov.br abre a Play Store em vez de abrir o app**
Ele foi instalado por outra loja. Desinstale e instale pela Play Store (passo 4.3), e depois refaça o passo 4.5a.

**Usei um módulo Xposed (LSPosed, Vector...) para esconder o modo desenvolvedor e piorou**
Não ative módulos Xposed **dentro** de apps do governo ou de banco. Vários deles detectam o próprio fato de terem sido modificados. Num app de banco, isso sozinho bastou para aparecer o aviso de "sistema não homologado". Use o perfil **Opções de desenvolvedor** do HMA-OSS, que funciona por fora do app.

---

## 7. O que cada peça faz

| Peça | Resumo em uma frase |
|---|---|
| **Zygisk** (do Magisk) | Permite que módulos rodem dentro dos apps logo quando eles abrem. É a base para o Shamiko, o HMA e o Play Integrity Fork. |
| **DenyList + Shamiko** | Para os apps marcados, desfaz as marcas do Magisk (arquivos, montagens, o próprio Zygisk). O app abre como se o aparelho não tivesse root. |
| **HMA-OSS** | Mente para o app sobre quais apps estão instalados (esconde Magisk, Termux, Shizuku...) e sobre as configurações de desenvolvedor. |
| **Play Integrity Fork** | Faz o Google achar que o aparelho é um modelo certificado, passando na verificação "DEVICE". |
| **Tricky Store** | Quando o app pede uma prova de que o bootloader está travado, responde que está. |
| **Play Store** | Necessária porque a verificação de integridade do Google passa por ela, e porque o gov.br exige ter sido instalado por ela. |

---

## 8. Como desfazer

- **Módulos:** Magisk → Módulos → remover (🗑️) cada um → reiniciar.
- **DenyList:** desmarque o gov.br em Configurar DenyList.
- **Play Store enxuta:**
  ```sh
  su -c "am set-standby-bucket com.android.vending active"
  su -c "cmd appops set com.android.vending RUN_ANY_IN_BACKGROUND allow"
  su -c "cmd appops set com.android.vending RUN_IN_BACKGROUND allow"
  su -c "pm enable com.android.vending/.AssetBrowserActivity"
  ```

---

## 9. Avançado: achar uma "impressão" que passe na integridade do Google

Esta parte é mais técnica e precisa de um **PC com `adb`** e de **Python 3**.

**A ideia:** testar várias impressões de aparelhos antigos até uma passar no DEVICE. O Google bane as impressões mais usadas com o tempo, então às vezes é preciso repetir este processo.

1. Baixe a coleção pública de impressões (já arquivada, de 2024, mas muitas ainda servem):
   ```sh
   git clone --depth 1 https://github.com/TheFreeman193/PIFS.git
   ```
2. Ligue a **depuração USB ou sem fio** no celular e conecte o `adb` (`adb devices` precisa listar o aparelho).
3. Instale o **SPIC** no celular e **deixe a tela desbloqueada e ligada** durante o teste.
4. Rode o script [`scripts/testar-impressoes.sh`](scripts/testar-impressoes.sh) deste repositório. Ele:
   - escolhe impressões de aparelhos lançados com Android 5 a 7 (API 21–25), versão "user" e assinatura "release-keys";
   - para cada uma, grava o `custom.pif.prop` no módulo, reinicia os serviços do Google e roda o SPIC sozinho;
   - **para na primeira que der `MEETS_DEVICE_INTEGRITY`** e deixa ela instalada.
   ```sh
   ./scripts/testar-impressoes.sh ~/caminho/para/PIFS 40      # testa até 40 impressões
   ```
   Cada teste leva cerca de 1 minuto. No nosso caso, a 5ª impressão testada passou.
5. Guarde uma cópia da impressão que funcionou:
   ```sh
   su -c "cp /data/adb/modules/playintegrityfix/custom.pif.prop /data/adb/meu-custom.pif.prop"
   ```

**Não compartilhe publicamente a impressão que funcionou para você.** Impressões muito usadas são as primeiras a serem banidas pelo Google.
