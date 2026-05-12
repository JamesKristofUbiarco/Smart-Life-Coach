# Smart-Assistant

Smart Agent Assistant con Next.js, FastAPI y LangGraph.

## Estructura del monorepo

```
Smart-Life-Coach/
├── frontend/        # Next.js (puerto 3000)         — Dockerfile ✅
├── backend/         # FastAPI principal (puerto 8000) — Dockerfile ✅
├── AI-component/    # LangGraph + Gemini (puerto 8001) — Dockerfile ✅
├── db/              # Supabase (CLI) + Redis (puerto 6379)
├── docker-compose.yml
└── .env.example
```

## Correr todo con Docker en otra PC

### Requisitos
- Docker Desktop (en ejecución)
- Node.js (sólo para la CLI de Supabase)

### Pasos

1. **Levantar Supabase** (gestiona sus propios contenedores con la CLI; aplica migraciones automáticamente):

    ```bash
    cd db
    npx supabase start
    ```

    Cuando termine, obtén las llaves:

    ```bash
    npx supabase status
    ```

2. **Crear el `.env` raíz** copiando el ejemplo y rellenando con las llaves anteriores + tu `GOOGLE_API_KEY` de Gemini:

    ```bash
    cd ..
    cp .env.example .env
    ```

3. **Construir e iniciar el resto** (frontend, backend, ai-component y redis):

    ```bash
    docker compose up -d --build
    ```

4. **Abrir la app** en [http://localhost:3000](http://localhost:3000)
   - Backend docs: [http://localhost:8000/docs](http://localhost:8000/docs)
   - AI-component: [http://localhost:8001](http://localhost:8001)

### Detener todo

```bash
docker compose down            # detiene frontend/backend/ai-component/redis
cd db && npx supabase stop     # detiene Supabase
```

## Comunicación entre servicios

Dentro de la red de docker compose, los servicios se llaman por su nombre:

| Servicio        | URL interna             | URL desde el host (PC) |
| --------------- | ----------------------- | ---------------------- |
| frontend        | `http://frontend:3000`  | `http://localhost:3000` |
| backend         | `http://backend:8000`   | `http://localhost:8000` |
| ai-component    | `http://ai-component:8001` | `http://localhost:8001` |
| redis           | `redis:6379`            | `localhost:6379` |
| Supabase (host) | `host.docker.internal:54321` | `http://127.0.0.1:54321` |
