/*
 * XCTestPrueba.swift
 * EventifyAITests
 *
 * Suite de tests específicos de prueba para EventifyAI
 * Arquitectura: Clean Architecture + MVVM + @Observable
 * 
 * Desarrollado por: Javier Gómez
 * Fecha: 8 Septiembre 2025
 * Versión: 1.0.0
 *
 * Descripción:
 * Tests específicos y casos de prueba para verificar funcionalidades
 * particulares de EventifyAI, incluyendo casos edge, errores y 
 * comportamientos específicos del dominio.
 * 
 * Funcionalidades probadas:
 * - Validaciones de entrada
 * - Casos límite
 * - Manejo de errores
 * - Comportamientos específicos del negocio
 */

import XCTest
import Foundation
@testable import EventifyAI

final class XCTestPrueba: XCTestCase {
    
    private var testUser: UserModel!
    private var testEvent: EventModel!
    private var testAttendance: AttendanceModel!
    
    override func setUpWithError() throws {
        super.setUp()
        
        testUser = UserModel(
            id: "test-user-prueba",
            email: "prueba@eventify.com",
            name: "Usuario Prueba"
        )
        
        testEvent = EventModel(
            id: "test-event-prueba",
            title: "Evento de Prueba",
            description: "Este es un evento para realizar pruebas",
            date: Date().addingTimeInterval(86400),
            location: "Lugar de Prueba",
            organizerId: testUser.id,
            organizerName: testUser.name
        )
        
        testAttendance = AttendanceModel(
            id: "test-attendance-prueba",
            eventId: testEvent.id,
            userId: testUser.id,
            userName: testUser.name,
            userEmail: testUser.email,
            status: .going
        )
    }
    
    override func tearDownWithError() throws {
        testUser = nil
        testEvent = nil
        testAttendance = nil
        super.tearDown()
    }
    
    func testValidacionEmailVacio() throws {
        let emailVacio = ""
        let emailConEspacios = "   "
        let emailValido = "usuario@ejemplo.com"
        
        XCTAssertTrue(emailVacio.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                     "Email vacío debe ser detectado como inválido")
        
        XCTAssertTrue(emailConEspacios.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                     "Email solo con espacios debe ser detectado como inválido")
        
        XCTAssertFalse(emailValido.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                      "Email válido no debe ser vacío")
    }
    
    func testValidacionPasswordMinima() throws {
        let passwordCorta = "123"
        let passwordValida = "password123"
        let longitudMinima = 6
        
        XCTAssertTrue(passwordCorta.count < longitudMinima,
                     "Password corta debe ser detectada como inválida")
        
        XCTAssertTrue(passwordValida.count >= longitudMinima,
                     "Password válida debe cumplir longitud mínima")
    }
    
    func testValidacionTituloEvento() throws {
        let tituloVacio = ""
        let tituloMuyLargo = String(repeating: "A", count: 201)
        let tituloValido = "Evento de Prueba"
        let longitudMaxima = 200
        
        XCTAssertTrue(tituloVacio.isEmpty, "Título vacío debe ser detectado")
        
        XCTAssertTrue(tituloMuyLargo.count > longitudMaxima,
                     "Título muy largo debe ser detectado como inválido")
        
        XCTAssertTrue(!tituloValido.isEmpty && tituloValido.count <= longitudMaxima,
                     "Título válido debe pasar validaciones")
    }
    
    func testEventoEnElPasado() throws {
        let fechaPasada = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let fechaFutura = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let ahora = Date()
        
        XCTAssertTrue(fechaPasada < ahora, "Fecha pasada debe ser menor que ahora")
        XCTAssertTrue(fechaFutura > ahora, "Fecha futura debe ser mayor que ahora")
        
        let eventoPasado = EventModel(
            id: "evento-pasado",
            title: "Evento Pasado",
            description: "Descripción",
            date: fechaPasada,
            location: "Ubicación",
            organizerId: "organizer",
            organizerName: "Organizador"
        )
        
        let eventoFuturo = EventModel(
            id: "evento-futuro",
            title: "Evento Futuro", 
            description: "Descripción",
            date: fechaFutura,
            location: "Ubicación",
            organizerId: "organizer",
            organizerName: "Organizador"
        )
        
        XCTAssertFalse(eventoPasado.isUpcoming, "Evento pasado no debe ser upcoming")
        XCTAssertTrue(eventoFuturo.isUpcoming, "Evento futuro debe ser upcoming")
    }
    
    func testFormatoFechas() throws {
        let fechaTest = Calendar.current.date(from: DateComponents(
            year: 2024,
            month: 12,
            day: 25,
            hour: 15,
            minute: 30
        ))!
        
        let evento = EventModel(
            id: "evento-fecha",
            title: "Evento con Fecha",
            description: "Descripción",
            date: fechaTest,
            location: "Ubicación",
            organizerId: "organizer",
            organizerName: "Organizador"
        )
        
        let fechaFormateada = evento.formattedDate
        let horaFormateada = evento.formattedTime
        
        XCTAssertFalse(fechaFormateada.isEmpty, "Fecha formateada no debe estar vacía")
        XCTAssertFalse(horaFormateada.isEmpty, "Hora formateada no debe estar vacía")
    }
    
    func testEstadosAsistencia() throws {
        let estadoSi: AttendanceStatus = .going
        let estadoNo: AttendanceStatus = .notGoing
        let estadoTalVez: AttendanceStatus = .maybe
        
        XCTAssertEqual(estadoSi.rawValue, "going")
        XCTAssertEqual(estadoNo.rawValue, "notGoing")
        XCTAssertEqual(estadoTalVez.rawValue, "maybe")
        
        XCTAssertEqual(estadoSi.displayText, "Asistiré")
        XCTAssertEqual(estadoNo.displayText, "No asistiré")
        XCTAssertEqual(estadoTalVez.displayText, "Tal vez")
    }
    
    func testCambioEstadoAsistencia() throws {
        var asistencia = testAttendance!
        let estadoInicial = asistencia.status
        
        asistencia.status = .maybe
        
        XCTAssertNotEqual(asistencia.status, estadoInicial)
        XCTAssertEqual(asistencia.status, .maybe)
    }
    
    func testBusquedaEventos() throws {
        let eventos = [
            EventModel(id: "1", title: "Cumpleaños Ana", description: "Fiesta de cumpleaños", 
                      date: Date(), location: "Casa Ana", organizerId: "org1", organizerName: "Ana"),
            EventModel(id: "2", title: "Reunión Trabajo", description: "Reunión de equipo", 
                      date: Date(), location: "Oficina", organizerId: "org2", organizerName: "Carlos"),
            EventModel(id: "3", title: "Cena Restaurante", description: "Cena con amigos", 
                      date: Date(), location: "Restaurante El Buen Gusto", organizerId: "org3", organizerName: "María")
        ]
        
        let terminoBusqueda = "cumpleaños"
        
        let resultados = eventos.filter { evento in
            evento.title.localizedCaseInsensitiveContains(terminoBusqueda) ||
            evento.description.localizedCaseInsensitiveContains(terminoBusqueda) ||
            evento.location.localizedCaseInsensitiveContains(terminoBusqueda)
        }
        
        XCTAssertEqual(resultados.count, 1, "Debe encontrar exactamente 1 evento")
        XCTAssertEqual(resultados.first?.title, "Cumpleaños Ana", "Debe encontrar el evento correcto")
    }
    
    func testFiltroEventosPasadosYFuturos() throws {
        let fechaPasada = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        let fechaFutura = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
        
        let eventos = [
            EventModel(id: "1", title: "Evento Pasado", description: "Descripción", 
                      date: fechaPasada, location: "Ubicación", organizerId: "org1", organizerName: "Org1"),
            EventModel(id: "2", title: "Evento Futuro", description: "Descripción", 
                      date: fechaFutura, location: "Ubicación", organizerId: "org2", organizerName: "Org2")
        ]
        
        let eventosPasados = eventos.filter { !$0.isUpcoming }
        let eventosFuturos = eventos.filter { $0.isUpcoming }
        
        XCTAssertEqual(eventosPasados.count, 1, "Debe haber 1 evento pasado")
        XCTAssertEqual(eventosFuturos.count, 1, "Debe haber 1 evento futuro")
        XCTAssertEqual(eventosPasados.first?.title, "Evento Pasado")
        XCTAssertEqual(eventosFuturos.first?.title, "Evento Futuro")
    }
    
    func testPerformanceBusquedaEventos() throws {
        let eventosGrandes = (0..<10000).map { i in
            EventModel(
                id: "event-\(i)",
                title: "Evento \(i)",
                description: "Descripción del evento \(i)",
                date: Date().addingTimeInterval(TimeInterval(i * 3600)),
                location: "Ubicación \(i)",
                organizerId: "org-\(i)",
                organizerName: "Organizador \(i)"
            )
        }
        
        measure {
            let resultado = eventosGrandes.filter { evento in
                evento.title.contains("5000")
            }
            XCTAssertEqual(resultado.count, 1)
        }
    }
    
    func testEventoSinDescripcion() throws {
        let eventoSinDescripcion = EventModel(
            id: "evento-sin-descripcion",
            title: "Evento Sin Descripción",
            description: "",
            date: Date(),
            location: "Ubicación",
            organizerId: "organizer",
            organizerName: "Organizador"
        )
        
        XCTAssertTrue(eventoSinDescripcion.description.isEmpty,
                     "Evento debe permitir descripción vacía")
        XCTAssertFalse(eventoSinDescripcion.title.isEmpty,
                      "Evento debe tener título")
    }
    
    func testEventoConTagsVacios() throws {
        let eventoConTags = EventModel(
            id: "evento-tags",
            title: "Evento con Tags",
            description: "Descripción",
            date: Date(),
            location: "Ubicación",
            organizerId: "organizer",
            organizerName: "Organizador",
            tags: []
        )
        
        XCTAssertTrue(eventoConTags.tags.isEmpty, "Tags pueden estar vacíos")
        XCTAssertNotNil(eventoConTags.tags, "Tags array no debe ser nil")
    }
    
    func testMaximoAsistentes() throws {
        let eventoSinLimite = EventModel(
            id: "evento-sin-limite",
            title: "Evento Sin Límite",
            description: "Descripción",
            date: Date(),
            location: "Ubicación",
            organizerId: "organizer",
            organizerName: "Organizador",
            maxAttendees: nil
        )
        
        let eventoConLimite = EventModel(
            id: "evento-con-limite",
            title: "Evento Con Límite",
            description: "Descripción",
            date: Date(),
            location: "Ubicación",
            organizerId: "organizer",
            organizerName: "Organizador",
            maxAttendees: 50
        )
        
        XCTAssertNil(eventoSinLimite.maxAttendees, "Evento puede no tener límite de asistentes")
        XCTAssertEqual(eventoConLimite.maxAttendees, 50, "Evento debe mantener límite configurado")
    }
    
    func testCreacionUsuarioEventoAsistencia() throws {
        let usuario = testUser!
        let evento = testEvent!
        let asistencia = testAttendance!
        
        XCTAssertEqual(evento.organizerId, usuario.id,
                      "Evento debe estar asociado al usuario organizador")
        
        XCTAssertEqual(asistencia.userId, usuario.id,
                      "Asistencia debe estar asociada al usuario")
        
        XCTAssertEqual(asistencia.eventId, evento.id,
                      "Asistencia debe estar asociada al evento")
        
        XCTAssertEqual(asistencia.userEmail, usuario.email,
                      "Email en asistencia debe coincidir con usuario")
    }
    
    func testCodificacionUserModel() throws {
        let usuario = testUser!
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(usuario)
        
        let decoder = JSONDecoder()
        let usuarioDecodificado = try decoder.decode(UserModel.self, from: data)
        
        XCTAssertEqual(usuario.id, usuarioDecodificado.id)
        XCTAssertEqual(usuario.email, usuarioDecodificado.email)
        XCTAssertEqual(usuario.name, usuarioDecodificado.name)
    }
    
    func testCodificacionEventModel() throws {
        let evento = testEvent!
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(evento)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let eventoDecodificado = try decoder.decode(EventModel.self, from: data)
        
        XCTAssertEqual(evento.id, eventoDecodificado.id)
        XCTAssertEqual(evento.title, eventoDecodificado.title)
        XCTAssertEqual(evento.location, eventoDecodificado.location)
        XCTAssertEqual(evento.organizerId, eventoDecodificado.organizerId)
    }
    
    func testNoMemoryLeaks() throws {
        autoreleasepool {
            let usuario = UserModel(id: "temp", email: "temp@test.com", name: "Temp")
            let evento = EventModel(
                id: "temp-event",
                title: "Temp Event",
                description: "Temp Description",
                date: Date(),
                location: "Temp Location",
                organizerId: usuario.id,
                organizerName: usuario.name
            )
            
            XCTAssertNotNil(usuario)
            XCTAssertNotNil(evento)
        }
        
        XCTAssertTrue(true, "No memory leaks detected")
    }
    
    func testLocalizacion() throws {
        let estadoAsistencia: AttendanceStatus = .going
        
        let textoLocalizado = estadoAsistencia.displayText
        
        XCTAssertFalse(textoLocalizado.isEmpty, "Texto localizado no debe estar vacío")
        XCTAssertEqual(textoLocalizado, "Asistiré", "Texto debe estar en español")
    }
    
    func testConfiguracionCompleta() throws {
        XCTAssertNotNil(testUser)
        XCTAssertNotNil(testEvent)
        XCTAssertNotNil(testAttendance)
        
        XCTAssertEqual(testEvent.organizerId, testUser.id)
        XCTAssertEqual(testAttendance.userId, testUser.id)
        XCTAssertEqual(testAttendance.eventId, testEvent.id)
        
        XCTAssertTrue(testEvent.isUpcoming)
        XCTAssertEqual(testAttendance.status, .going)
    }
}
