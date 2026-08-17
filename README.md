# 💞 Nuestro hogar — Gastos de pareja

App de gastos compartidos para **Giancarlo y Thali**, lista para usarse desde PC, celular o cualquier navegador.

## 📁 Archivos de la carpeta

| Archivo | Qué es |
|---|---|
| `index.html` | La app completa (incluye tus datos incrustados como respaldo) |
| `data.json` | Tus datos actuales como archivo (es el que se sincroniza entre dispositivos) |
| `data-backup-original.json` | Respaldo original de los datos (no tocar) |
| `Iniciar App.bat` + `servidor.ps1` | Para abrir la app con **guardado automático** (solo PC, no van a GitHub) |
| `README.md` | Estas instrucciones |

## ⚡ La forma más fácil: guardado automático (PC)

1. Doble clic en **`Iniciar App.bat`** → se abre la app en `http://localhost:8787`.
2. En **Ajustes → 🔗 Activar guardado automático** elegí la carpeta `gastos-pareja` (una sola vez).
3. De ahí en más, **cada cambio se guarda solo** en `data.json` e `index.html` de esa carpeta. No tenés que hacer nada más.
4. Si la carpeta está en **OneDrive**, se sincroniza sola a tu celular: en el teléfono abrís la copia de `index.html` desde OneDrive y ves lo mismo.

## 🖥️ Usarla en la PC (sin GitHub, sin servidor)

Doble clic en `index.html`. Al abrirte pide elegir **🖥️ PC** o **📱 Celular** según dónde la vayas a usar. (Sin guardado automático: los cambios quedan solo en ese navegador.)

## 🌍 Publicarla en GitHub (para usarla en cualquier dispositivo/navegador)

1. Creá un repositorio en GitHub (por ejemplo `gastos-pareja`).
2. Subí los archivos `index.html`, `data.json` y `README.md` al repo.
3. Activá **GitHub Pages**: en el repo → `Settings` → `Pages` → `Deploy from a branch` → rama `main` → carpeta `/root` → Save.
4. Esperá 1-2 minutos. Vas a tener una dirección tipo: `https://tu-usuario.github.io/gastos-pareja/`
5. Abrí esa dirección desde **cualquier** navegador de la PC y del celular: ahí están tus datos.

## 🔄 Cómo actualizar los datos (después de registrar algo)

1. Abrí la app (desde GitHub o la carpeta), registrá tus gastos.
2. Andá a la pestaña **Ajustes** → **⬇️ Descargar data.json (GitHub)**.
3. Reemplazá el archivo `data.json` de tu carpeta por el descargado y súbelo al repositorio (o editá `data.json` directamente en github.com y pegá el contenido).
4. Listo: la próxima vez que abrís la app desde cualquier lado, carga esos datos.

> También podés usar **💾 Guardar en el archivo HTML**, que descarga el `index.html` con los datos incrustados. Esa copia la usás en cualquier navegador sin GitHub.

## 🌐 Sincronización en tiempo real (Firebase) — lo más fácil para los dos

Con esto, **lo que uno ingresa en su PC/celular aparece al instante en el otro dispositivo**, sin subir nada a GitHub.

1. Entrá a **console.firebase.google.com** (con tu cuenta de Google) → **Añadir proyecto** (nombre libre, ej. `gastos-pareja`). Podés dejar desactivado Google Analytics.
2. En el proyecto: **Build → Realtime Database → Crear base de datos**. Elegí una región y modo de **modo bloqueado**.
3. Pestaña **Reglas** (Rules) → reemplazá por: `{ "rules": { ".read": true, ".write": true } }` → **Publicar**. (Ojo: esto permite que cualquiera con tu `databaseURL` lea/escriba; alcanza para tu pareja, pero no uses la app con datos sensibles mientras esté así.)
4. **Ajustes del proyecto → Tus apps → Web (</>)** → registrá la app y copiá el objeto `firebaseConfig`.
5. Abrí la app en tu dispositivo → **Ajustes → Sincronización en línea 🌐** → pegá ese objeto → **🌐 Conectar**.
6. Repetí el paso 5 en el dispositivo de tu pareja (pueden usar el mismo `firebaseConfig`).
7. Listo: ambos están conectados y ven los cambios al instante. El estado queda guardado en la nube de Firebase y en el localStorage de cada uno.

> El chip **🟢 En línea** del encabezado indica que está sincronizando. Se puede desconectar desde Ajustes. La conexión se guarda en cada navegador por separado.

## 📌 Cómo se guardan los datos (para que no te asustes)

- La app guarda automáticamente en el **localStorage del navegador** que uses (por eso cada navegador muestra lo suyo).
- Con **Iniciar App.bat** y el **guardado automático activo**, además guarda sola en `data.json` e `index.html` de la carpeta → OneDrive lo sincroniza al celular.
- Para que tus datos sean **los mismos en todos lados**, siempre que termines de usarla bajá `data.json` y reemplazá el del repo.
- `index.html` trae un respaldo incrustado: si abrís la app en un navegador sin datos, carga ese respaldo en vez de empezar de cero.
- Al abrir desde GitHub, la app lee automáticamente el `data.json` del repo y usa los datos más completos/recientes.
- Los cambios hechos desde el **celular** quedan guardados en el navegador del celular (ahí no se puede escribir archivos). Para llevarlos a la PC, bajá `data.json` desde el celular y súbelo a la carpeta/repo.
- Con **Firebase conectado**, los cambios se sincronizan en tiempo real y no hace falta bajar/subir `data.json` manualmente.
