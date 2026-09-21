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

O arquivo compilado aparece como artefato do workflow **Build macOS Dylib**. A biblioteca exporta a função `MLD_ShowLogin` e também chama essa função no carregamento por meio de um construtor.

**Importante:** apenas copiar a `.dylib` para a pasta do aplicativo não a executa. O app precisa carregá-la com `dlopen` ou vinculá-la como biblioteca. O construtor só é executado depois que o macOS realmente carrega a Dylib no processo.

## Integração

O aplicativo hospedeiro pode carregar a biblioteca com `dlopen`:

```objective-c
#include <dlfcn.h>

// Execute depois de NSApplication ter sido inicializado, por exemplo
// em applicationDidFinishLaunching: do AppDelegate.
void *handle = dlopen("/caminho/absoluto/libMacLogin.dylib", RTLD_NOW | RTLD_LOCAL);
if (handle == NULL) {
    NSLog(@"Falha ao carregar a Dylib: %s", dlerror());
}
```

Se a biblioteca estiver no bundle do app, use o caminho retornado por `[[NSBundle mainBundle] pathForResource:@"libMacLogin" ofType:@"dylib"]`. O app também precisa ter o mesmo tipo de arquitetura da biblioteca; a versão atual do workflow gera um binário universal **arm64 + x86_64**.

Para chamar explicitamente a tela:

```objective-c
typedef void (*MLDShowLoginFunction)(void);
MLDShowLoginFunction showLogin = (MLDShowLoginFunction)dlsym(handle, "MLD_ShowLogin");
if (showLogin != NULL) {
    showLogin();
}
```

## Observações importantes

Esta implementação é uma barreira visual local, não um sistema de autenticação seguro: a senha está embutida no binário e pode ser recuperada por engenharia reversa. Para produção, substitua a senha fixa por autenticação em um serviço seguro e considere assinatura/notarização da Dylib. Aplicativos com Hardened Runtime podem exigir configuração específica para carregar bibliotecas externas.

## Licença

Uso livre para este projeto de demonstração.
