workspace "Arquitectura AI Coach" "Diagramas C4 para el Asistente Inteligente" {

    model {
        
        // 1. Actores (Personas)
        
        user = person "Usuario" "Persona que busca alcanzar objetivos personales o profesionales mediante planes y estrategias personalizadas."

        
        // 2. Nuestro Sistema
        
        aiCoach = softwareSystem "Asistente Inteligente (AI Coach)" "Plataforma central que permite al usuario interactuar mediante texto para generar, gestionar y recibir notificaciones." {

            //  CONTENEDORES ORIGINALES FRONTEND 
            webApp = container "WebApp" "Interfaz web" "Next.js + Zod" {
                tags "WebApp"
                stateManager = component "State Manager" "Gestiona el estado global de la aplicación." "Next.js"
                apiClient = component "API Client" "Formatea peticiones HTTP y valida datos." "JavaScript + Zod"
                authProvider = component "Auth Provider" "Gestiona la sesión del usuario." "JavaScript"
            }

            staticCont = container "Static Content" "Assets estáticos y maquetado" "HTML5 + TailwindCSS" {
                tags "Static Content"
                uiComponents = component "UI & Pages" "Renderiza las vistas y captura inputs del usuario." "HTML5 + TailwindCSS"
            }

            //  CONTENEDOR ORIGINAL BACKEND 
            backend = container "Backend" "Lógica de negocio y orquestación" "Python + FastAPI + Pydantic + Docker" {
                group "API Endpoints" {
                    chatApi = component "Chat API" "Lee/escribe conversaciones, crea tareas y espera a inngest." "FastAPI + Pydantic"
                    goalsApi = component "Goals API" "Endpoints CRUD para visualizar y modificar planes." "FastAPI + Pydantic"
                    webhookApi = component "Webhook API" "Recibe triggers asíncronos." "FastAPI + Pydantic"
                }
                securityLayer = component "Security Component" "Valida tokens y extrae contexto." "FastAPI"
                langgraphOrchestrator = component "Langgraph - Stateful Orchestrator" "Máquina de estados de la IA." "LangGraph"
                agentTools = component "Agent Tools" "Acciones deterministas de la IA." "Python"
                inngestClient = component "Automation Client" "Despacha eventos asíncronos." "Python"
                cacheManager = component "Cache Manager" "Gestiona concurrencia y memoria." "Python"
                dal = component "Data Access Layer" "Abstrae consultas a bases de datos y valida modelos." "Python + Pydantic"
            }

            //  CONTENEDORES EXPANDIDOS INFRAESTRUCTURA 
            inngestContainer = container "Inngest - Automation" "Automatización y eventos." "inngest" {
                inngestWorker = component "inngest Worker" "Orquesta trabajos en segundo plano." "inngest"
            }
            
            supabaseContainer = container "Supabase" "Base de datos relacional, vectorial y autenticador." "Supabase" {
                tags "Database"
                supaAuth = component "Supabase Authentication" "Autenticación de usuarios." "Supabase Auth"
                supaDb = component "Full Postgres Database" "Base de datos transaccional." "PostgreSQL"
                supaVector = component "Pgvector" "Almacenamiento de embeddings." "Pgvector"
            }
            
            redisContainer = container "Redis - In-Memory Store" "Capa de cache para reducir la carga de la DB relacional." "Redis" {
                tags "Database"
                redisCache = component "Cached Database" "Almacenamiento temporal." "Redis"
            }
        }

        
        // 3. Sistemas Externos Expandidos
        
        group "AI Models" {
            geminiSys = softwareSystem "Google Gemini API" "Servicio externo de IA. Procesa el contexto del usuario." "Sistema Externo" {
                geminiAPI = container "Gemini" "Modelo estándar." "Gemini"
                gemini3API = container "Gemini 3" "Modelo avanzado." "Gemini 3"
            }
        }

        vercelDeploy = softwareSystem "Vercel Frontend Deploy" "Servicio externo de deploy para Frontend." "Sistema Externo"
        
        railWayDeploy = softwareSystem "Railway Backend Deploy" "Servicio externo de deploy para Backend." "Sistema Externo" {
            railwayService = container "Railway Platform" "Entorno de nube para despliegue." "Railway"
        }

        gitHub = softwareSystem "Git & GitHub" "Control de versiones y colaboración." "Sistema Externo"

        
        // 4. Relaciones (Flechas)
        
        
        // Relaciones nivel usuario y contenedores originales
        user -> webApp "Define objetivos, interactúa por texto y visualiza su progreso usando" "HTTPS"
        user -> staticCont "Carga la UI desde"
        staticCont -> webApp "Entrega"
        webApp -> backend "" "RPC/HTTP Streaming"
        
        // Relaciones internas Frontend
        uiComponents -> stateManager "Lee/Escribe estado" "JavaScript"
        uiComponents -> apiClient "Solicita datos o envía acciones" "JavaScript"
        apiClient -> authProvider "Verifica sesión" "JavaScript"
        authProvider -> supaAuth "Autentica credenciales en" "HTTPS"
        
        // Conexiones específicas API
        apiClient -> chatApi "Envía mensajes" "RPC/HTTP Streaming"
        apiClient -> goalsApi "Consulta información" "RPC/HTTP Streaming"

        // Internas del Backend
        chatApi -> securityLayer "Solicita validación" "Python"
        goalsApi -> securityLayer "Solicita validación" "Python"
        chatApi -> langgraphOrchestrator "Envía contexto" "Python"
        goalsApi -> dal "Pide datos" "Python"
        webhookApi -> inngestClient "Confirma evento" "Python"

        securityLayer -> supaAuth "Verifica firma JWT en" "HTTPS"
        
        langgraphOrchestrator -> cacheManager "Recupera/Guarda estado" "Python"
        langgraphOrchestrator -> agentTools "Ejecuta acciones" "Python"
        langgraphOrchestrator -> geminiAPI "Envía prompts a" "HTTPS"
        langgraphOrchestrator -> gemini3API "Envía prompts avanzados a" "HTTPS"
        
        agentTools -> dal "Lee/Escribe contexto" "Python"
        agentTools -> inngestClient "Dispara tareas en background" "Python"
        
        // Backend hacia Capas de Datos (usando los componentes expandidos)
        backend -> supabaseContainer "Lee y escribe en CRUD" "SQL/TCP"
        dal -> supaDb "Lee/Escribe historial en" "TCP"
        dal -> supaVector "Lee/Escribe vectores en" "TCP"
        
        langgraphOrchestrator -> redisContainer "State Access" "TCP/RESP"
        cacheManager -> redisCache "Lee/Escribe caché en" "TCP"

        // Eventos y Webhooks
        backend -> inngestContainer "Event Trigger" "HTTPS"
        inngestContainer -> backend "Webhook Callback" "HTTPS"
        inngestClient -> inngestWorker "Publica eventos a" "HTTPS"
        inngestWorker -> webhookApi "Ejecuta Webhook Callback" "HTTPS"

        // Despliegues y DevOps
        webApp -> vercelDeploy "Se aloja en"
        backend -> railWayDeploy "Se aloja en"
        
        gitHub -> vercelDeploy "Activa despliegue Frontend"
        gitHub -> railwayService "Activa despliegue Backend"
    }

    
    // 5. Vistas y Estilos (Originales)
    
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

        component backend "DiagramaDeComponentesBackend" {
            include *
            autolayout lr
            description "Diagrama de Componentes del Backend"
        }

        component webApp "DiagramaDeComponentesWebApp" {
            include *
            autolayout lr
        }

        component staticCont "DiagramaDeComponentesStaticContent" {
            include *
            autolayout lr
        }

        component supabaseContainer "DiagramaComponentesSupabase" {
            include *
            autolayout lr
        }

        component redisContainer "DiagramaComponentesRedis" {
            include *
            autolayout lr
        }

        component inngestContainer "DiagramaComponentesInngest" {
            include *
            autolayout lr
        }

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