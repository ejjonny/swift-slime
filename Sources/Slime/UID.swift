extension String {
    static var uid: Self {
        let characters = "abcdefghijklmnopqrstuvwxyz1234567890".map { String($0) }
        var uid = String()
        for _ in (0..<10) {
            uid.append(characters.randomElement()!)
        }
        return uid
    }
}
