// Models/IndependentProfile.swift
import Foundation

struct IndependentProfile: Identifiable, Codable {
    let id:             UUID
    let email:          String
    let role:           String
    let firstName:      String
    let lastName:       String
    let phoneNumber:    String
    let siret:          String
    let sector:         String
    let location:       String
    var experiences:    [Experience]   // ← var !
    var availabilities: [Availability] // ← var !
}

struct Experience: Identifiable, Codable {
    let id:          UUID
    var title:       String    // ← var !
    var company:     String    // ← var !
    var from:        Date      // ← var !
    var to:          Date?     // ← var !
    var description: String    // ← var !
}

struct Availability: Identifiable, Codable {
    let id:        UUID
    var dayOfWeek: Int     // ← var !
    var startHour: String  // ← var !
    var endHour:   String  // ← var !
}
