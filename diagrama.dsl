workspace "Arquitectura AI Coach" "Diagramas C4 para el Asistente Inteligente" {

    model {
        // 1. Actores (Personas)
        user = person "Usuario" "Persona que busca alcanzar objetivos personales o profesionales mediante planes y estrategias personalizadas."

        // 2. Nuestro Sistema
        aiCoach = softwareSystem "Asistente Inteligente (AI Coach)" "Plataforma central que permite al usuario interactuar mediante texto para generar, gestionar y recibir notificaciones in-app sobre sus planes de acción." {
            
            webApp = container "WebApp" "Interfaz web" "Next.js + TailwindCSS, Zod Validation" {
                tags "WebApp"
            }
            staticCont = container "Static Content" "" "HTML, CSS, JavaScript, etc" {
                tags "Static Content"
            } 
            fastApi = container "FastApi Service" "" "Python/FastApi/Pydantic"
            inngest = container "Inngest - Automation" "" ""
            langgraph = container "Langgraph - Stateful Orchestrator" "" ""
            supabase = container "Supabase" "Base de datos relacional, vectorial y autenticador" "pgvector, PostgreSQL, Supabase auth" {
                tags "Database"
            }
            redis = container "Redis - In-Memory Store" "Capa de cache para reducir la carga de la DB relacional" ""
        }

        // 3. Sistemas Externos
        geminiApi = softwareSystem "Google Gemini API" "Servicio externo de IA. Procesa el contexto del usuario y genera los planes o estrategias estructuradas." "Sistema Externo"

        vercelDeploy = softwareSystem "Vercel Frontend Deploy" "Servicio externo de deploy para Frontend. ." "Sistema Externo"

        railWayDeploy = softwareSystem "Railway Backend Deploy" "Servicio externo de deploy para Backend. ." "Sistema Externo"
        
        
        // 4. Relaciones (Flechas)
        user -> webApp "Define objetivos, interactúa por texto y visualiza su progreso usando" "HTTPS"
        user -> staticCont "Carga la UI desde"
        staticCont -> webApp "Entrega"
        webApp -> fastApi "" "REST/JSON (HTTPS Connection)"
        fastApi -> supabase "Lee y escribe en CRUD" "SQL/TCP"
        fastApi -> inngest "Event Trigger" "HTTPS"
        inngest -> fastApi "Webhook Callback" "HTTPS"
        fastApi -> langgraph "Invoca" "Python Call"
        langgraph -> geminiApi "Envía contexto/prompts y recibe planes estructurados usando" "JSON / REST / gRPC (HTTPS)"
        langgraph -> redis "State Access" "TCP/RESP"
        langgraph -> supabase "Vector Queries" "Embeddings"
        webApp -> supabase "Auth" "JWT / HTTPS"
        webApp -> vercelDeploy "Se aloja en"
        fastApi -> railWayDeploy "Se aloja en"
    }

    views {
        systemContext aiCoach "DiagramaDeContexto" {
            include *
            autolayout lr
            description "Diagrama de Contexto del Sistema para el Asistente Inteligente."
        }

        container aiCoach "DiagramaDeContenedores" {
          include *
          autolayout lr
          description "Diagrama de Contenedores del Sistema para el Asistente Inteligente"
        }

        // Estilos inspirados en la paleta de C4
        styles {
            element "Element" {
                color #0773af
                stroke #0773af
                strokeWidth 7
                shape roundedbox
            }
            element "Person" {
                shape person
            }
            element "Database" {
                shape cylinder
            }
            element "Boundary" {
                strokeWidth 5
            }
            element "WebApp" {
                shape window
            }
            element "Static Content" {
                shape folder
            }
            relationship "Relationship" {
                thickness 4
            }
        }
    }
}
