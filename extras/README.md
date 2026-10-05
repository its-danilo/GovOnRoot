# Configuração do HMA-OSS por arquivo (avançado)

`hma-config.json` é o equivalente, em arquivo, do passo 4.5b do guia. Use este caminho só se preferir não configurar pelo app.

1. Troque `NOME.DO.MAGISK.OCULTO` pelo pacote do seu Magisk oculto:
   `su -c "magisk --sqlite \"SELECT value FROM strings WHERE key='requester'\""`
   (se não ocultou o Magisk, use `com.topjohnwu.magisk`). Acrescente em `extraAppList` outros apps que denunciem root.
2. Para mais apps, copie o bloco `"br.gov.meugovbr": {...}` dentro de `scope` trocando o nome do pacote.
3. `configVersion` precisa bater com a versão do HMA-OSS: era **93** na `oss-173`. Para outra versão, veja `configVerCode` no `build.gradle.kts` do repositório do HMA-OSS.
4. Copie o arquivo para a pasta de dados do HMA (o nome dela tem uma parte aleatória) e reinicie:
   ```sh
   D=$(su -c 'ls -d /data/misc/hide_my_applist_*')
   su -c "cp hma-config.json $D/config.json && chown system:system $D/config.json && chmod 600 $D/config.json"
   ```
5. Depois de reiniciar, `su -c "cat $D/log/runtime.log"` deve mostrar `Config loaded`.

Este arquivo **substitui** a configuração que você tenha feito pelo app.
