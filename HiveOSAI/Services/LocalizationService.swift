import Foundation
import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable, Codable {
    case english = "en"
    case spanish = "es"
    case french = "fr"
    case german = "de"
    case italian = "it"
    case portuguese = "pt"

    var id: String { rawValue }

    var nativeName: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Español"
        case .french: return "Français"
        case .german: return "Deutsch"
        case .italian: return "Italiano"
        case .portuguese: return "Português"
        }
    }
}

enum L10nKey: String {
    case dashboard
    case apiaries
    case intelligence
    case analytics
    case settings
    case appName
    case operatingSystem
    case hiveSpeaks
    case onboarding
    case experience
    case operation
    case primaryGoals
    case notifications
    case disclaimerTitle
    case disclaimerBody
    case acceptDisclaimer
    case enterApp
    case intelligentBeekeepingOS
    case dashboardSubtitle
    case healthOverview
    case quickActions
    case subscription
    case language
    case languageSubtitle
    case manageSubscription
    case currentPlan
    case preferences
    case legal
    case paywallTitle
    case paywallSubtitle
    case informationalInsights
    case possibleSignals
    case recommendations
    case verifyDecisions
    case weatherIntelligence
    case upgradeBanner
    case swarmAlertNetwork
    case swarmAlertSubtitle
}

@Observable
@MainActor
final class LocalizationService {
    private let storageKey = "HiveOSAI.selectedLanguage"

    var language: AppLanguage {
        didSet {
            UserDefaults.standard.set(language.rawValue, forKey: storageKey)
        }
    }

    init() {
        if let stored = UserDefaults.standard.string(forKey: storageKey),
           let language = AppLanguage(rawValue: stored) {
            self.language = language
        } else {
            let preferred = Locale.preferredLanguages.first?.prefix(2).lowercased() ?? "en"
            self.language = AppLanguage(rawValue: String(preferred)) ?? .english
        }
    }

    func t(_ key: L10nKey) -> String {
        translations[language]?[key] ?? translations[.english]?[key] ?? key.rawValue
    }
}

struct LocalizedText: View {
    @Environment(LocalizationService.self) private var localization
    let key: L10nKey

    var body: some View {
        Text(localization.t(key))
    }
}

private let translations: [AppLanguage: [L10nKey: String]] = [
    .english: [
        .dashboard: "Dashboard",
        .apiaries: "Apiaries",
        .intelligence: "AI",
        .analytics: "Analytics",
        .settings: "Settings",
        .appName: "HiveOS AI",
        .operatingSystem: "The operating system for intelligent beekeeping.",
        .hiveSpeaks: "Your hive speaks before it collapses.",
        .onboarding: "Onboarding",
        .experience: "Experience",
        .operation: "Operation",
        .primaryGoals: "Primary Goals",
        .notifications: "Notifications",
        .disclaimerTitle: "Agricultural Disclaimer",
        .disclaimerBody: "AI insights are informational agricultural insights only. They are not veterinary advice, not guaranteed disease detection, and not guaranteed colony prediction. Independently verify all hive decisions.",
        .acceptDisclaimer: "I understand and accept",
        .enterApp: "Enter HiveOS AI",
        .intelligentBeekeepingOS: "Intelligent Beekeeping OS",
        .dashboardSubtitle: "Predictive signals, inspections, pulse, weather, and reports in one premium local-first workspace.",
        .healthOverview: "Hive Health Overview",
        .quickActions: "Quick Actions",
        .subscription: "Subscription",
        .language: "Language",
        .languageSubtitle: "Choose the in-app language for key screens and safety guidance.",
        .manageSubscription: "Manage Subscription",
        .currentPlan: "Current plan",
        .preferences: "Preferences",
        .legal: "Legal",
        .paywallTitle: "HiveOS AI Plans",
        .paywallSubtitle: "Scale from hobby hives to commercial apiary intelligence.",
        .informationalInsights: "Informational Insights",
        .possibleSignals: "Possible Signals",
        .recommendations: "Recommendations",
        .verifyDecisions: "Informational only. Independently verify all hive decisions.",
        .weatherIntelligence: "Weather Intelligence",
        .upgradeBanner: "Unlock Hive Pulse, AI scans, reports, and advanced analytics.",
        .swarmAlertNetwork: "Swarm Alert Network",
        .swarmAlertSubtitle: "Notify local beekeepers when a swarm is spotted."
    ],
    .spanish: [
        .dashboard: "Panel",
        .apiaries: "Apiarios",
        .intelligence: "IA",
        .analytics: "Analítica",
        .settings: "Ajustes",
        .appName: "HiveOS AI",
        .operatingSystem: "El sistema operativo para la apicultura inteligente.",
        .hiveSpeaks: "Tu colmena habla antes de colapsar.",
        .onboarding: "Introducción",
        .experience: "Experiencia",
        .operation: "Operación",
        .primaryGoals: "Objetivos principales",
        .notifications: "Notificaciones",
        .disclaimerTitle: "Aviso agrícola",
        .disclaimerBody: "Los datos de IA son solo información agrícola. No son consejo veterinario, detección garantizada de enfermedades ni predicción garantizada de la colonia. Verifica de forma independiente todas las decisiones sobre la colmena.",
        .acceptDisclaimer: "Entiendo y acepto",
        .enterApp: "Entrar en HiveOS AI",
        .intelligentBeekeepingOS: "Sistema operativo de apicultura inteligente",
        .dashboardSubtitle: "Señales predictivas, inspecciones, pulso, clima e informes en un espacio local premium.",
        .healthOverview: "Resumen de salud de colmenas",
        .quickActions: "Acciones rápidas",
        .subscription: "Suscripción",
        .language: "Idioma",
        .languageSubtitle: "Elige el idioma de la app para pantallas clave y avisos de seguridad.",
        .manageSubscription: "Gestionar suscripción",
        .currentPlan: "Plan actual",
        .preferences: "Preferencias",
        .legal: "Legal",
        .paywallTitle: "Planes de HiveOS AI",
        .paywallSubtitle: "Escala desde colmenas de hobby hasta inteligencia de apiarios comerciales.",
        .informationalInsights: "Información orientativa",
        .possibleSignals: "Señales posibles",
        .recommendations: "Recomendaciones",
        .verifyDecisions: "Solo informativo. Verifica de forma independiente todas las decisiones.",
        .weatherIntelligence: "Inteligencia meteorológica",
        .upgradeBanner: "Desbloquea Hive Pulse, escaneos de IA, informes y analítica avanzada.",
        .swarmAlertNetwork: "Red de alertas de enjambres",
        .swarmAlertSubtitle: "Avisa a apicultores locales cuando se detecte un enjambre."
    ],
    .french: [
        .dashboard: "Tableau",
        .apiaries: "Ruchers",
        .intelligence: "IA",
        .analytics: "Analytique",
        .settings: "Réglages",
        .appName: "HiveOS AI",
        .operatingSystem: "Le système d'exploitation pour une apiculture intelligente.",
        .hiveSpeaks: "Votre ruche parle avant de s'effondrer.",
        .onboarding: "Accueil",
        .experience: "Expérience",
        .operation: "Exploitation",
        .primaryGoals: "Objectifs principaux",
        .notifications: "Notifications",
        .disclaimerTitle: "Avertissement agricole",
        .disclaimerBody: "Les informations IA sont uniquement des indications agricoles. Elles ne sont pas un avis vétérinaire, une détection garantie de maladies ni une prédiction garantie de colonie. Vérifiez indépendamment toutes les décisions concernant la ruche.",
        .acceptDisclaimer: "Je comprends et j'accepte",
        .enterApp: "Entrer dans HiveOS AI",
        .intelligentBeekeepingOS: "OS d'apiculture intelligente",
        .dashboardSubtitle: "Signaux prédictifs, inspections, pulse, météo et rapports dans un espace local premium.",
        .healthOverview: "Vue d'ensemble de la santé",
        .quickActions: "Actions rapides",
        .subscription: "Abonnement",
        .language: "Langue",
        .languageSubtitle: "Choisissez la langue de l'app pour les écrans clés et les conseils de sécurité.",
        .manageSubscription: "Gérer l'abonnement",
        .currentPlan: "Forfait actuel",
        .preferences: "Préférences",
        .legal: "Mentions légales",
        .paywallTitle: "Forfaits HiveOS AI",
        .paywallSubtitle: "Passez des ruches de loisir à l'intelligence de ruchers commerciaux.",
        .informationalInsights: "Indications informatives",
        .possibleSignals: "Signaux possibles",
        .recommendations: "Recommandations",
        .verifyDecisions: "Informatif uniquement. Vérifiez indépendamment toutes les décisions.",
        .weatherIntelligence: "Intelligence météo",
        .upgradeBanner: "Débloquez Hive Pulse, scans IA, rapports et analytique avancée.",
        .swarmAlertNetwork: "Réseau d'alerte essaim",
        .swarmAlertSubtitle: "Prévenez les apiculteurs locaux lorsqu'un essaim est repéré."
    ],
    .german: [
        .dashboard: "Dashboard",
        .apiaries: "Bienenstände",
        .intelligence: "KI",
        .analytics: "Analysen",
        .settings: "Einstellungen",
        .appName: "HiveOS AI",
        .operatingSystem: "Das Betriebssystem für intelligente Imkerei.",
        .hiveSpeaks: "Dein Bienenvolk spricht, bevor es zusammenbricht.",
        .onboarding: "Einrichtung",
        .experience: "Erfahrung",
        .operation: "Betrieb",
        .primaryGoals: "Hauptziele",
        .notifications: "Benachrichtigungen",
        .disclaimerTitle: "Landwirtschaftlicher Hinweis",
        .disclaimerBody: "KI-Erkenntnisse sind nur landwirtschaftliche Informationen. Sie sind keine tierärztliche Beratung, keine garantierte Krankheitserkennung und keine garantierte Volksprognose. Prüfe alle Entscheidungen zum Bienenvolk unabhängig.",
        .acceptDisclaimer: "Ich verstehe und akzeptiere",
        .enterApp: "HiveOS AI starten",
        .intelligentBeekeepingOS: "Intelligentes Imkerei-OS",
        .dashboardSubtitle: "Prädiktive Signale, Inspektionen, Pulse, Wetter und Berichte in einem lokalen Premium-Arbeitsbereich.",
        .healthOverview: "Gesundheitsübersicht",
        .quickActions: "Schnellaktionen",
        .subscription: "Abonnement",
        .language: "Sprache",
        .languageSubtitle: "Wähle die App-Sprache für wichtige Ansichten und Sicherheitshinweise.",
        .manageSubscription: "Abonnement verwalten",
        .currentPlan: "Aktueller Tarif",
        .preferences: "Präferenzen",
        .legal: "Rechtliches",
        .paywallTitle: "HiveOS AI Tarife",
        .paywallSubtitle: "Vom Hobbyvolk bis zur kommerziellen Bienenstandsintelligenz skalieren.",
        .informationalInsights: "Informative Erkenntnisse",
        .possibleSignals: "Mögliche Signale",
        .recommendations: "Empfehlungen",
        .verifyDecisions: "Nur informativ. Prüfe alle Entscheidungen unabhängig.",
        .weatherIntelligence: "Wetterintelligenz",
        .upgradeBanner: "Schalte Hive Pulse, KI-Scans, Berichte und erweiterte Analysen frei.",
        .swarmAlertNetwork: "Schwarm-Alarmnetzwerk",
        .swarmAlertSubtitle: "Benachrichtige lokale Imker, wenn ein Schwarm gesichtet wird."
    ],
    .italian: [
        .dashboard: "Cruscotto",
        .apiaries: "Apiari",
        .intelligence: "IA",
        .analytics: "Analisi",
        .settings: "Impostazioni",
        .appName: "HiveOS AI",
        .operatingSystem: "Il sistema operativo per l'apicoltura intelligente.",
        .hiveSpeaks: "Il tuo alveare parla prima di collassare.",
        .onboarding: "Introduzione",
        .experience: "Esperienza",
        .operation: "Operazione",
        .primaryGoals: "Obiettivi principali",
        .notifications: "Notifiche",
        .disclaimerTitle: "Avviso agricolo",
        .disclaimerBody: "Gli insight IA sono solo informazioni agricole. Non sono consulenza veterinaria, rilevamento garantito di malattie o previsione garantita della colonia. Verifica in modo indipendente ogni decisione sull'alveare.",
        .acceptDisclaimer: "Capisco e accetto",
        .enterApp: "Entra in HiveOS AI",
        .intelligentBeekeepingOS: "OS per apicoltura intelligente",
        .dashboardSubtitle: "Segnali predittivi, ispezioni, pulse, meteo e report in uno spazio locale premium.",
        .healthOverview: "Panoramica salute alveari",
        .quickActions: "Azioni rapide",
        .subscription: "Abbonamento",
        .language: "Lingua",
        .languageSubtitle: "Scegli la lingua dell'app per schermate chiave e indicazioni di sicurezza.",
        .manageSubscription: "Gestisci abbonamento",
        .currentPlan: "Piano attuale",
        .preferences: "Preferenze",
        .legal: "Legale",
        .paywallTitle: "Piani HiveOS AI",
        .paywallSubtitle: "Scala dagli alveari hobbistici all'intelligence per apiari commerciali.",
        .informationalInsights: "Insight informativi",
        .possibleSignals: "Segnali possibili",
        .recommendations: "Raccomandazioni",
        .verifyDecisions: "Solo informativo. Verifica in modo indipendente ogni decisione.",
        .weatherIntelligence: "Intelligence meteo",
        .upgradeBanner: "Sblocca Hive Pulse, scansioni IA, report e analisi avanzate.",
        .swarmAlertNetwork: "Rete di allerta sciami",
        .swarmAlertSubtitle: "Avvisa gli apicoltori locali quando viene avvistato uno sciame."
    ],
    .portuguese: [
        .dashboard: "Painel",
        .apiaries: "Apiários",
        .intelligence: "IA",
        .analytics: "Análises",
        .settings: "Definições",
        .appName: "HiveOS AI",
        .operatingSystem: "O sistema operativo para apicultura inteligente.",
        .hiveSpeaks: "A tua colmeia fala antes de colapsar.",
        .onboarding: "Introdução",
        .experience: "Experiência",
        .operation: "Operação",
        .primaryGoals: "Objetivos principais",
        .notifications: "Notificações",
        .disclaimerTitle: "Aviso agrícola",
        .disclaimerBody: "Os insights de IA são apenas informações agrícolas. Não são aconselhamento veterinário, deteção garantida de doenças nem previsão garantida da colónia. Verifica de forma independente todas as decisões sobre a colmeia.",
        .acceptDisclaimer: "Compreendo e aceito",
        .enterApp: "Entrar no HiveOS AI",
        .intelligentBeekeepingOS: "OS de apicultura inteligente",
        .dashboardSubtitle: "Sinais preditivos, inspeções, pulse, meteorologia e relatórios num espaço local premium.",
        .healthOverview: "Resumo da saúde das colmeias",
        .quickActions: "Ações rápidas",
        .subscription: "Subscrição",
        .language: "Idioma",
        .languageSubtitle: "Escolhe o idioma da app para ecrãs principais e avisos de segurança.",
        .manageSubscription: "Gerir subscrição",
        .currentPlan: "Plano atual",
        .preferences: "Preferências",
        .legal: "Legal",
        .paywallTitle: "Planos HiveOS AI",
        .paywallSubtitle: "Escala de colmeias amadoras para inteligência de apiários comerciais.",
        .informationalInsights: "Insights informativos",
        .possibleSignals: "Sinais possíveis",
        .recommendations: "Recomendações",
        .verifyDecisions: "Apenas informativo. Verifica todas as decisões de forma independente.",
        .weatherIntelligence: "Inteligência meteorológica",
        .upgradeBanner: "Desbloqueia Hive Pulse, scans de IA, relatórios e análises avançadas.",
        .swarmAlertNetwork: "Rede de alerta de enxames",
        .swarmAlertSubtitle: "Notifica apicultores locais quando um enxame é avistado."
    ]
]
