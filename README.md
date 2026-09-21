# MacLogin Dylib

Biblioteca dinâmica macOS em Objective-C que exibe uma tela de login automaticamente quando a Dylib é carregada pelo aplicativo hospedeiro. A senha é fixa apenas para demonstração inicial.

## Senha padrão

`123456`

Para alterar a senha, edite `kFixedPassword` em `src/MacLogin.m` e compile novamente.

## Compilação

A compilação é feita pelo GitHub Actions em um runner macOS:

```bash
clang -dynamiclib \
  -framework Cocoa \
  -fobjc-arc \
  -fvisibility=hidden \
  -mmacosx-version-min=12.0 \
  -o build/libMacLogin.dylib \
  src/MacLogin.m
```

O arquivo compilado aparece como artefato do workflow **Build macOS Dylib**. A biblioteca exporta a função `MLD_ShowLogin` e também chama essa função no carregamento por meio de um construtor, fazendo a tela aparecer assim que o processo hospedeiro carrega a Dylib.

## Integração

O aplicativo hospedeiro pode carregar a biblioteca com `dlopen`:

```c
#include <dlfcn.h>

dlclose(NULL); // apenas para mostrar que o código usa libdl
void *handle = dlopen("/caminho/para/libMacLogin.dylib", RTLD_NOW);
if (handle == NULL) {
    // tratar erro com dlerror()
}
```

A inicialização automática depende de o processo hospedeiro possuir um `NSApplication` ativo e executar o loop principal. Alternativamente, depois do carregamento, o app pode obter e chamar a função exportada `MLD_ShowLogin` usando `dlsym`.

## Observações importantes

Esta implementação é uma barreira visual local, não um sistema de autenticação seguro: a senha está embutida no binário e pode ser recuperada por engenharia reversa. Para produção, substitua a senha fixa por autenticação em um serviço seguro e considere assinatura/notarização da Dylib. Aplicativos com Hardened Runtime podem exigir configuração específica para carregar bibliotecas externas.

## Licença

Uso livre para este projeto de demonstração.
