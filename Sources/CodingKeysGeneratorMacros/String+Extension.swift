extension String {
    func snakeCased() -> String {
        reduce(into: "") { $0.append(contentsOf: $1.isUppercase ? "_\($1.lowercased())" : "\($1)") }
    }
}
