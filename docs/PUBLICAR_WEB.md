# Publicar el juego: GitHub + Vercel

## 1. Exportar para web (en Godot)
1. **Editor → Administrar plantillas de exportación → Descargar e instalar** (solo la primera vez).
2. **Proyecto → Exportar → Añadir... → Web**.
3. En las opciones del preset Web, deja **Thread Support** (Soporte de hilos) **desactivado**. Así funciona en cualquier hosting.
4. En **Ruta de exportación** escribe `web/index.html`.
5. Clic en **Exportar proyecto** (desactiva "Exportar con depuración").
6. Prueba local (opcional): **Ejecutar en el navegador** (el ícono de HTML5 arriba a la derecha del editor).

La carpeta `web/` ya trae `vercel.json` y un archivo `.gdignore` para que Godot no la importe como parte del proyecto.

## 2. Subir a GitHub
1. Crea un repositorio nuevo en github.com (por ejemplo `salir-del-silencio`), sin README.
2. En la carpeta del proyecto, abre una terminal y escribe:
```
git init
git add .
git commit -m "Salir del silencio - entrega final"
git branch -M main
git remote add origin https://github.com/TU_USUARIO/salir-del-silencio.git
git push -u origin main
```
(La carpeta `.godot/` no se sube; ya está en `.gitignore`.)

Cada vez que cambies algo: exporta otra vez a `web/`, y luego `git add .`, `git commit -m "cambios"` y `git push`.

## 3. Publicar en Vercel
1. Entra a vercel.com con tu cuenta de GitHub → **Add New → Project** → elige el repositorio.
2. **Framework Preset:** Other.
3. **Root Directory:** `web`.
4. Deja vacíos Build Command y Output Directory.
5. **Deploy.** Cada `git push` vuelve a publicar solo.
