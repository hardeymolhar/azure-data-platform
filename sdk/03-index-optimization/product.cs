public record Product(
    string id,
    string name,
    string category,
    double price,
    int quantity,
    string status,
    string region,
    double rating,
    DateTime createdAt
);