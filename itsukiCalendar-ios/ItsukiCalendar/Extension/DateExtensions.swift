//
//  DateExtensions.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/04/06.
//

import Foundation

extension Date {

    enum Template: String {
        case dateFull = "yMMMd" //2024年4月14日
        case date = "yMd"     // 2023/1/1
        case year = "y"         // 2024年
        case month = "MMM"  // 4月
        case day = "d"  // 14日
        
        case time = "Hms"     // 12:39:22
        case hour = "k"   // 17時
        case weekDay = "EEEE" // Wednesday
    }
    
    static let dateFormatter = DateFormatter()
    static let jstTimeZone = TimeZone(identifier: "JST") ?? TimeZone.current
    static let utcTimeZone = TimeZone(identifier: "UTC") ?? TimeZone.current
    static let calendar = Calendar.current
    
    private static let naiveDateTimeFormat = "yyyy-MM-dd'T'HH:mm:ss"
    
    // for database: yyyy-MM-ddTHH:mm:ss
    var naiveDateTime: String {
        let dateFormatter = Date.dateFormatter
        dateFormatter.timeZone = Date.utcTimeZone
        dateFormatter.dateFormat = Date.naiveDateTimeFormat
        return dateFormatter.string(from: self)
    }
    
    static func fromNaiveDateTime(_ naiveDateTime: String) -> Date? {
        let dateFormatter = Date.dateFormatter
        dateFormatter.timeZone = Date.utcTimeZone
        dateFormatter.dateFormat = Date.naiveDateTimeFormat
        return dateFormatter.date(from: naiveDateTime)
    }
    
    static var localizedTodaySymbol: String {
        let dateFormatter = Date.dateFormatter
        dateFormatter.timeZone = Date.jstTimeZone
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.doesRelativeDateFormatting = true
        return dateFormatter.string(from: Date())

    }
    
    var localizedDate: String {
        let dateFormatter = Date.dateFormatter
        dateFormatter.timeZone = Date.jstTimeZone
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: Template.dateFull.rawValue, options: 0, locale: Locale.current)
        return dateFormatter.string(from: self)
    }
    
    // for display
    var localizedDateWithWeekday: String {
        let dateFormatter = Date.dateFormatter
        dateFormatter.timeZone = Date.jstTimeZone
        let template = "\(Template.dateFull.rawValue)\(Template.weekDay.rawValue)"
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: template, options: 0, locale: Locale.current)
        return dateFormatter.string(from: self)
    }
    
    var localizedYear: String {
        let dateFormatter = Date.dateFormatter
        dateFormatter.timeZone = Date.jstTimeZone
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: Template.year.rawValue, options: 0, locale: Locale.current)
        return dateFormatter.string(from: self)
    }
    
    var localizedMonth: String {
        let dateFormatter = Date.dateFormatter
        dateFormatter.timeZone = Date.jstTimeZone
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: Template.month.rawValue, options: 0, locale: Locale.current)
        return dateFormatter.string(from: self)
    }
    
    var localizedDay: String {
//        let dateFormatter = DateFormatter()
        let dateFormatter = Date.dateFormatter
        dateFormatter.timeZone = Date.jstTimeZone
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: Template.day.rawValue, options: 0, locale: Locale.current)
        return dateFormatter.string(from: self)
    }
    

    // get localized month string of a date (String)
    var localizedMonthShort: String {
        var calendar = Date.calendar
        calendar.timeZone = Date.jstTimeZone
        return calendar.shortStandaloneMonthSymbols[self.month - 1]
    }
    
    
    // get localized Year Month string of a date (String)
    var localizedYearMonth: String {
        let dateFormatter = Date.dateFormatter
        dateFormatter.timeZone = Date.jstTimeZone
        let template = "\(Template.year.rawValue)\(Template.month.rawValue)"
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: template, options: 0, locale: Locale.current)
        return dateFormatter.string(from: self)
    }
    
    // A list of very-shortly-named weekdays in this calendar, localized to the Calendar’s locale.
    // ex: for English in the Gregorian calendar, returns ["S", "M", "T", "W", "T", "F", "S"]
    static var weekdaySymbols: [String] {
        var calendar = Calendar.current
        calendar.timeZone = Date.jstTimeZone
        return calendar.veryShortStandaloneWeekdaySymbols
    }
    
    
    
    
    // get day part of a date (Int)
    var day: Int {
        let dateFormatter = Date.dateFormatter
        dateFormatter.timeZone = Date.jstTimeZone
        dateFormatter.dateFormat = "dd"
        return Int(dateFormatter.string(from: self))!
    }
    
    
    // get month part of a date (Int)
    var month: Int {
        let dateFormatter = Date.dateFormatter
        dateFormatter.timeZone = Date.jstTimeZone

        dateFormatter.dateFormat = "MM"
        return Int(dateFormatter.string(from: self))!
    }
    
    
    // get year part of a date (Int)
    var year: Int {
        let dateFormatter = Date.dateFormatter
        dateFormatter.timeZone = Date.jstTimeZone

        dateFormatter.dateFormat = "yyyy"
        return Int(dateFormatter.string(from: self))!
    }
    
    // get weekday of a date (Int)
    // 0: Sunday
    var weekDay: Int {
        var calendar = Date.calendar
        calendar.timeZone = Date.jstTimeZone

        let components = calendar.dateComponents([.weekday], from: self)
        return components.weekday! - 1
    }

    
    // get the number of days in the month of a date (Int)
    var daysInMonth: Int {
        var calendar = Date.calendar
        calendar.timeZone = Date.jstTimeZone

        let range = calendar.range(of: .day, in: .month, for: self)!
        return range.count
    }
    
    
    // get the date of the first day in the month of a date (Date)
    var firstDayOfMonth: Date {
        var calendar = Date.calendar
        calendar.timeZone = Date.jstTimeZone

        let date = Date.dateFromString(month: self.month, year: self.year, day: 1)
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components)!
    }
    
    static func dateFromString(month: Int, year: Int, day: Int) -> Date {
        let dateFormatter = Date.dateFormatter
        dateFormatter.timeZone = Date.jstTimeZone
        dateFormatter.dateFormat = "yyyy/MM/dd"
        return dateFormatter.date(from: "\(addPadding(year, 4))/\(addPadding(month, 2))/\(addPadding(day, 2))")!
    }
    
    private static func addPadding(_ int: Int, _ targetDigit: Int ) -> String {
        return String(format: "%0\(targetDigit)d", int)
    }

    
    
    // add days to current date (Date)
    func plusDate(_ count: Int = 1) -> Date {
        var calendar = Date.calendar
        calendar.timeZone = Date.jstTimeZone

        return calendar.date(byAdding: .day, value: count, to: self)!
    }
    
    
    // minus days from current date (Date)
    func minusDate(_ count: Int = 1) -> Date {
        var calendar = Date.calendar
        calendar.timeZone = Date.jstTimeZone

        return calendar.date(byAdding: .day, value: -count, to: self)!
    }
    
    
    // add months from current date (Date)
    func plusMonth(_ count: Int = 1) -> Date {
        var calendar = Date.calendar
        calendar.timeZone = Date.jstTimeZone

        return calendar.date(byAdding: .month, value: count, to: self)!
    }
    
    
    // minus months from current date (Date)
    func minusMonth(_ count: Int = 1) -> Date {
        var calendar = Date.calendar
        calendar.timeZone = Date.jstTimeZone

        return calendar.date(byAdding: .month, value: -count, to: self)!
    }

    
    // is the date today (Bool)
    var isToday:  Bool {
        let dateFormatter = Date.dateFormatter
        dateFormatter.timeZone = Date.jstTimeZone
        
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let todayDateString = dateFormatter.string(from: Date())
        let dateToCompareString = dateFormatter.string(from: self)
        return (todayDateString == dateToCompareString)
    }
    
    func isSameDate(_ date: Date?) -> Bool {
        guard let date = date else {return false}
        let dateFormatter = Date.dateFormatter
        dateFormatter.timeZone = Date.jstTimeZone
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: Template.date.rawValue, options: 0, locale: Locale.current)
        return dateFormatter.string(from: self) == dateFormatter.string(from: date)

    }
    
    
    // is the date a weekend (Bool)
    var isWeekend: Bool {
        let weekday = self.weekDay
        return ((weekday == 0 ) || (weekday == 6))
    }
    
    
    // is the date in the same month as today (Bool)
    var isCurrentMonth: Bool {
        let today = Date()
        return (today.year == self.year) && (today.month == self.month)
    }
    
}
